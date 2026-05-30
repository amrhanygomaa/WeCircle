// Push notifications (Firebase Cloud Messaging).
//
// Design: graceful no-op. If Firebase isn't configured (no google-services.json,
// so Firebase.initializeApp() throws), every method here swallows the error and
// the app runs exactly as before. Once Firebase is set up, push turns on with no
// further code changes. See infra/aws/PUSH_NOTIFICATIONS_SETUP.md.

import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wesal/core/config/api_config.dart';

/// Top-level background handler — must be a top-level (or static) function and
/// annotated so it survives tree-shaking in the background isolate.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // The system tray renders the notification automatically for `notification`
  // payloads while the app is backgrounded/terminated; nothing to do here yet.
  debugPrint('[Push] background message: ${message.messageId}');
}

class PushService {
  PushService._();

  static bool _enabled = false;
  static bool get isEnabled => _enabled;

  /// Initialise Firebase + FCM. Safe to call once at startup. No-ops if Firebase
  /// isn't configured. If a session token already exists, registers the device.
  static Future<void> init() async {
    try {
      await Firebase.initializeApp();

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      // Foreground / tap handlers — the in-app notifications screen reads from the
      // backend, so here we just log. Hook UI refresh in later if needed.
      FirebaseMessaging.onMessage.listen((m) {
        debugPrint('[Push] foreground: ${m.notification?.title}');
      });
      FirebaseMessaging.onMessageOpenedApp.listen((m) {
        debugPrint('[Push] opened from notification: ${m.data}');
      });

      // Keep the backend in sync if FCM rotates the token.
      messaging.onTokenRefresh.listen((token) {
        _sendTokenToBackend(token);
      });

      _enabled = true;

      // If the user is already logged in (e.g. app relaunch), register now.
      final prefs = await SharedPreferences.getInstance();
      if ((prefs.getString('mobile_token') ?? '').isNotEmpty) {
        await registerToken();
      }
    } catch (e) {
      _enabled = false;
      debugPrint('[Push] disabled (Firebase not configured): $e');
    }
  }

  /// Fetch the current FCM token and register it with the backend. Call after login.
  static Future<void> registerToken() async {
    if (!_enabled) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await _sendTokenToBackend(token);
      }
    } catch (e) {
      debugPrint('[Push] registerToken failed: $e');
    }
  }

  static Future<void> _sendTokenToBackend(String fcmToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('mobile_token') ?? '';
      if (authToken.isEmpty) return;

      await http.post(
        Uri.parse('${ApiConfig.getBaseUrl()}/notifications/mobile/device-token'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': fcmToken,
          'platform': Platform.isIOS ? 'ios' : 'android',
        }),
      ).timeout(const Duration(seconds: 15));
      // Remember the token so we can unregister it cleanly on logout.
      await prefs.setString('fcm_token', fcmToken);
    } catch (e) {
      debugPrint('[Push] _sendTokenToBackend failed: $e');
    }
  }

  /// Unregister this device on logout so the user stops receiving pushes here.
  static Future<void> unregister() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('mobile_token') ?? '';
      final fcmToken = prefs.getString('fcm_token') ?? '';
      if (authToken.isNotEmpty && fcmToken.isNotEmpty) {
        await http.delete(
          Uri.parse('${ApiConfig.getBaseUrl()}/notifications/mobile/device-token'),
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'token': fcmToken}),
        ).timeout(const Duration(seconds: 10));
      }
      await prefs.remove('fcm_token');
      if (_enabled) {
        await FirebaseMessaging.instance.deleteToken();
      }
    } catch (e) {
      debugPrint('[Push] unregister failed: $e');
    }
  }
}

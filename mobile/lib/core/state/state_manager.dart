// مدير الحالة (State Manager) للتحكم في بيانات التطبيق العامة كحساب المستخدم واختيار الابن النشط
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wesal/core/api/api_service.dart';

class AppStateManager {
  static final AppStateManager _instance = AppStateManager._internal();
  factory AppStateManager() => _instance;
  AppStateManager._internal() {
    loadSettings();
    loadChildrenFromAWS();
  }

  // Persistance Keys
  static const String keyTheme = 'settings_is_dark';
  static const String keyLang = 'settings_lang';
  static const String keyName = 'user_name';
  static const String keyPhone = 'user_phone';
  static const String keyPicture = 'user_picture';
  static const String keyEmail = 'user_email';
  static const String keyNotifAtt = 'notif_att';
  static const String keyNotifHw = 'notif_hw';
  static const String keyNotifMsg = 'notif_msg';

  // State Notifiers
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(
    ThemeMode.light,
  );
  final ValueNotifier<Locale> locale = ValueNotifier<Locale>(
    const Locale('ar'),
  );
  final ValueNotifier<Map<String, String>> userData =
      ValueNotifier<Map<String, String>>({
        'name': 'سارة محمد',
        'phone': '+20 100 123 4567',
        'picture': '',
        'email': 'sarah@wesal.edu',
      });

  final ValueNotifier<bool> notifAttendance = ValueNotifier<bool>(true);
  final ValueNotifier<bool> notifHomework = ValueNotifier<bool>(true);
  final ValueNotifier<bool> notifMessages = ValueNotifier<bool>(false);

  // Existing States
  final ValueNotifier<int> selectedChildIndex = ValueNotifier<int>(0);
  final ValueNotifier<bool> isAdhamHomeworkSubmitted = ValueNotifier<bool>(
    false,
  );

  // Student Data
  final ValueNotifier<String> selectedStudentAvatar = ValueNotifier<String>('');
  final ValueNotifier<String> selectedGradeLevel = ValueNotifier<String>('1-3');

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Theme
    final isDark = prefs.getBool(keyTheme) ?? false;
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;

    // Language
    final langCode = prefs.getString(keyLang) ?? 'ar';
    locale.value = Locale(langCode);

    // User Data
    final savedName = prefs.getString(keyName) ?? userData.value['name']!;
    final savedPhone = prefs.getString(keyPhone) ?? userData.value['phone']!;
    final savedPic = prefs.getString(keyPicture) ?? userData.value['picture']!;
    final savedEmail = prefs.getString(keyEmail) ?? userData.value['email']!;

    userData.value = {
      'name': savedName,
      'phone': savedPhone,
      'picture': savedPic,
      'email': savedEmail,
    };

    notifAttendance.value = prefs.getBool(keyNotifAtt) ?? true;
    notifHomework.value = prefs.getBool(keyNotifHw) ?? true;
    notifMessages.value = prefs.getBool(keyNotifMsg) ?? false;
  }

  Future<void> toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    await prefs.setBool(keyTheme, isDark);
  }

  Future<void> toggleLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    locale.value = Locale(langCode);
    await prefs.setString(keyLang, langCode);
  }

  Future<void> updateUserData({
    String? name,
    String? phone,
    String? picture,
    String? email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final newData = Map<String, String>.from(userData.value);

    if (name != null) {
      newData['name'] = name;
      await prefs.setString(keyName, name);
    }
    if (phone != null) {
      newData['phone'] = phone;
      await prefs.setString(keyPhone, phone);
    }
    if (picture != null) {
      newData['picture'] = picture;
      await prefs.setString(keyPicture, picture);
    }
    if (email != null) {
      newData['email'] = email;
      await prefs.setString(keyEmail, email);
    }

    userData.value = newData;
  }

  Future<void> updateNotifications({bool? att, bool? hw, bool? msg}) async {
    final prefs = await SharedPreferences.getInstance();
    if (att != null) {
      notifAttendance.value = att;
      await prefs.setBool(keyNotifAtt, att);
    }
    if (hw != null) {
      notifHomework.value = hw;
      await prefs.setBool(keyNotifHw, hw);
    }
    if (msg != null) {
      notifMessages.value = msg;
      await prefs.setBool(keyNotifMsg, msg);
    }
  }

  // Dynamic Children Data from AWS Backend
  final ValueNotifier<List<Map<String, dynamic>>> children = ValueNotifier<List<Map<String, dynamic>>>([]);

  Future<void> loadChildrenFromAWS() async {
    try {
      final fetchedChildren = await ApiService.fetchChildren();
      if (fetchedChildren.isNotEmpty) {
        children.value = fetchedChildren;
      }
    } catch (e) {
      print("Failed to fetch children from AWS: $e");
    }
  }

  void setSelectedChild(int index) {
    selectedChildIndex.value = index;
  }

  void addChild(Map<String, dynamic> child) {
    final currentList = List<Map<String, dynamic>>.from(children.value);
    currentList.add(child);
    children.value = currentList;
  }

  void submitAdhamHomework() {
    isAdhamHomeworkSubmitted.value = true;
  }
}

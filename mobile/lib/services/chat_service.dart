import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wesal/core/config/api_config.dart';
import 'package:wesal/models/message_model.dart';

class ChatService {
  static String get _base => '${ApiConfig.getBaseUrl()}/chat/mobile';

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('mobile_token') ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Returns the current user's entity ID (Parent.id / Teacher.id) set at login.
  /// Used to determine which bubble side each message belongs to.
  static Future<String?> getMyEntityId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('mobile_entity_id');
  }

  // ── Conversations ──────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/conversations'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(body['data'] as List? ?? []);
      }
    } catch (_) {}
    return [];
  }

  Future<Map<String, dynamic>?> findOrCreateConversation(
    String recipientId,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/conversations'),
        headers: await _headers(),
        body: jsonEncode({'recipientId': recipientId}),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        return (jsonDecode(res.body) as Map<String, dynamic>)['data']
            as Map<String, dynamic>?;
      }
    } catch (_) {}
    return null;
  }

  // ── Messages ───────────────────────────────────────────────────────────────

  Future<List<MessageModel>> getMessages(String conversationId) async {
    try {
      final myEntityId = await getMyEntityId();
      final res = await http.get(
        Uri.parse('$_base/conversations/$conversationId/messages'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        final list =
            (jsonDecode(res.body) as Map<String, dynamic>)['data'] as List? ??
                [];
        return list
            .map((m) => MessageModel.fromJson(
                  m as Map<String, dynamic>,
                  myEntityId: myEntityId,
                ))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<MessageModel?> sendMessage({
    String? conversationId,
    String? receiverId,
    required String content,
  }) async {
    try {
      final myEntityId = await getMyEntityId();
      final res = await http.post(
        Uri.parse('$_base/messages'),
        headers: await _headers(),
        body: jsonEncode({
          if (conversationId != null) 'conversationId': conversationId,
          if (receiverId != null) 'receiverId': receiverId,
          'content': content,
        }),
      );
      if (res.statusCode == 201) {
        final data =
            (jsonDecode(res.body) as Map<String, dynamic>)['data']
                as Map<String, dynamic>?;
        if (data != null) {
          return MessageModel.fromJson(data, myEntityId: myEntityId);
        }
      }
    } catch (_) {}
    return null;
  }

  // ── Contacts ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getContacts({String query = ''}) async {
    try {
      final uri = Uri.parse('$_base/contacts').replace(
        queryParameters: query.isNotEmpty ? {'q': query} : null,
      );
      final res = await http.get(uri, headers: await _headers());
      if (res.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
          (jsonDecode(res.body) as Map<String, dynamic>)['data'] as List? ?? [],
        );
      }
    } catch (_) {}
    return [];
  }

  // ── Real-time (polling) ────────────────────────────────────────────────────

  /// Polls messages every 5 s. Cancel the subscription to stop polling.
  Stream<List<MessageModel>> pollMessages(String conversationId) {
    final controller = StreamController<List<MessageModel>>.broadcast();
    Timer? timer;

    Future<void> fetch() async {
      final msgs = await getMessages(conversationId);
      if (!controller.isClosed) controller.add(msgs);
    }

    fetch();
    timer = Timer.periodic(const Duration(seconds: 5), (_) => fetch());
    controller.onCancel = () => timer?.cancel();

    return controller.stream;
  }

  // ── Legacy stubs (kept so existing call-sites compile) ────────────────────

  Stream<List<MessageModel>> getChatMessages(
    String participantAId,
    String participantBId,
  ) =>
      Stream.value([]);

  Future<void> sendMessageLegacy(MessageModel message) => sendMessage(
        receiverId: message.receiverId.isNotEmpty ? message.receiverId : null,
        content: message.messageText,
      );
}

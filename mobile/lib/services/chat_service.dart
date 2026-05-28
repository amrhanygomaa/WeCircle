// خدمة برمجية (Service) لإدارة وتقنية الدردشة والمراسلة خلف الكواليس
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send Message Logic
  Future<void> sendMessage(MessageModel message) async {
    await _firestore.collection('chats').add(message.toMap());
  }

  // Real-time Stream for a specific conversation
  Stream<List<MessageModel>> getChatMessages(
    String parentId,
    String teacherId,
  ) {
    return _firestore
        .collection('chats')
        .where('senderId', whereIn: [parentId, teacherId])
        .where('receiverId', whereIn: [parentId, teacherId])
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Stream for latest chats for the Conversations list
  Stream<List<MessageModel>> getLatestMessages(String userId) {
    return _firestore
        .collection('chats')
        .where('receiverId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromFirestore(doc))
              .toList(),
        );
  }
}

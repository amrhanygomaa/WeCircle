// نموذج هيكلة بيانات الرسائل والمحادثات بين المدرسة وأولياء الأمور
import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageCategory { general, behavior, fees }

class MessageModel {
  final String? id;
  final String senderId;
  final String receiverId;
  final String studentId;
  final String messageText;
  final DateTime timestamp;
  final MessageCategory category;
  final bool isFromTeacher;

  MessageModel({
    this.id,
    required this.senderId,
    required this.receiverId,
    required this.studentId,
    required this.messageText,
    required this.timestamp,
    required this.category,
    this.isFromTeacher = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'studentId': studentId,
      'messageText': messageText,
      'timestamp': FieldValue.serverTimestamp(),
      'category': category.name,
      'isFromTeacher': isFromTeacher,
    };
  }

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = (doc.data() as Map<String, dynamic>?) ?? {};
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      studentId: data['studentId'] ?? '',
      messageText: data['messageText'] ?? '',
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      category: MessageCategory.values.firstWhere(
        (e) => e.name == (data['category'] ?? 'general'),
        orElse: () => MessageCategory.general,
      ),
      isFromTeacher: data['isFromTeacher'] ?? true,
    );
  }
}

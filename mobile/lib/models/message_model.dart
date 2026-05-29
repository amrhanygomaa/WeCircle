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
      'timestamp': timestamp.toIso8601String(),
      'category': category.name,
      'isFromTeacher': isFromTeacher,
    };
  }

  /// Creates a [MessageModel] from a backend REST response map.
  /// Pass [myEntityId] (the current user's parent/teacher entity ID) to
  /// determine which side of the bubble the message belongs to.
  factory MessageModel.fromJson(
    Map<String, dynamic> json, {
    String? myEntityId,
  }) {
    final senderId = (json['senderId'] as String?) ?? '';
    return MessageModel(
      id: json['id'] as String?,
      senderId: senderId,
      receiverId: (json['receiverId'] as String?) ?? '',
      studentId: '',
      messageText:
          (json['content'] as String?) ?? (json['messageText'] as String?) ?? '',
      timestamp: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      category: MessageCategory.values.firstWhere(
        (e) => e.name == (json['category'] as String?),
        orElse: () => MessageCategory.general,
      ),
      isFromTeacher: myEntityId != null ? senderId != myEntityId : true,
    );
  }
}

/*
🧠 اسم الملف: chat_detail_screen.dart

📌 بيعمل إيه؟
دي شاشة المحادثة المباشرة اللي ولي الأمر بيقدر يبعت فيها رسايل لمدرس أو للإدارة.

👤 موجه لمين؟
- أولياء أمور

💡 فكرته:
تسهيل التواصل السريع والفعال بين البيت والمدرسة لحل أي مشكلة فوراً.
*/

import 'package:flutter/material.dart'; // استيراد مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة التحكم في أحجام الشاشة
import 'messages_screen.dart'; // استيراد شاشة الرسائل للوصول للنماذج
import '../../widgets/wesal_background.dart';
import '../../models/message_model.dart'; // استيراد نموذج بيانات الرسالة
import '../../services/chat_service.dart'; // استيراد خدمة المحادثة
import 'package:intl/intl.dart' hide TextDirection; // استيراد مكتبة تنسيق الوقت

class ChatDetailScreen extends StatefulWidget {
  // تعريف كلاس شاشة تفاصيل المحادثة كـ StatefulWidget
  final ChatModel chat; // استقبال بيانات المحادثة
  const ChatDetailScreen({super.key, required this.chat}); // مشيد الكلاس

  @override // إنشاء حالة الشاشة
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  // كلاس حالة شاشة تفاصيل المحادثة
  final ChatService _chatService = ChatService(); // تهيئة خدمة المحادثة
  final TextEditingController _msgController =
      TextEditingController(); // متحكم حقل الإدخال

  static const Color primaryBlue = Color(0xFF2563EB); // اللون الأزرق الأساسي
  static const Color primaryPurple = Color(
    0xFF9333EA,
  ); // اللون البنفسجي الأساسي
  static const Color baseColor = Color(0xFFF0F3F8); // لون الخلفية الأساسي
  static const Color textDark = Color(0xFF1E293B); // لون النص الداكن
  static const Color textMuted = Color(0xFF64748B); // لون النص الباهت

  @override // تنظيف الموارد عند الإغلاق
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    // دالة معالجة إرسال الرسالة
    if (_msgController.text.trim().isEmpty) return; // منع الإرسال الفارغ
    _chatService.sendMessage(
      MessageModel(
        senderId: 'parent_123',
        receiverId: 'teacher_456',
        studentId: 'student_adham',
        messageText: _msgController.text,
        timestamp: DateTime.now(),
        category: MessageCategory.general,
        isFromTeacher: false,
      ),
    );
    _msgController.clear(); // مسح الحقل بعد الإرسال
  }

  @override // بناء واجهة الشاشة
  Widget build(BuildContext context) {
    return Directionality(
      // ضبط الاتجاه للعربية
      textDirection: TextDirection.rtl,
      child: WesalBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent, // شفاف لرؤية الخلفية الموحدة
          appBar: _ChatAppBar(
            chat: widget.chat,
            baseColor: baseColor,
            textDark: textDark,
            primaryBlue: primaryBlue,
          ), // ترويسة المحادثة (معزولة)
          body: Column(
            children: [
              Expanded(
                child: _MessageListArea(
                  chatService: _chatService,
                  textMuted: textMuted,
                  primaryBlue: primaryBlue,
                  primaryPurple: primaryPurple,
                  textDark: textDark,
                ),
              ), // منطقة عرض الرسائل
              _ChatInputArea(
                controller: _msgController,
                onSend: _sendMessage,
                baseColor: baseColor,
                primaryBlue: primaryBlue,
                primaryPurple: primaryPurple,
              ), // منطقة إدخال الرسائل
            ],
          ),
        ),
      ),
    );
  }
}

// ── Optimized Sub-Widgets ──────────────────────────────────────────────────

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  // ويدجت ترويسة المحادثة (معزول)
  final ChatModel chat;
  final Color baseColor, textDark, primaryBlue;

  const _ChatAppBar({
    required this.chat,
    required this.baseColor,
    required this.textDark,
    required this.primaryBlue,
  });

  @override // بناء الترويسة المخصصة
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent, // شفاف لرؤية الخلفية
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Color(0xFF1E293B),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_rounded, color: primaryBlue, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chat.name,
                style: TextStyle(
                  color: textDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 16.sp,
                  fontFamily: 'Cairo',
                ),
              ),
              Text(
                'متصل الآن',
                style: TextStyle(
                  color: const Color(0xFF22C55E),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override // تحديد حجم الترويسة
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MessageListArea extends StatelessWidget {
  // ويدجت منطقة عرض الرسائل (معزول الأداء)
  final ChatService chatService;
  final Color textMuted, primaryBlue, primaryPurple, textDark;

  const _MessageListArea({
    required this.chatService,
    required this.textMuted,
    required this.primaryBlue,
    required this.primaryPurple,
    required this.textDark,
  });

  @override // بناء القائمة باستخدام StreamBuilder
  Widget build(BuildContext context) {
    return StreamBuilder<List<MessageModel>>(
      stream: chatService.getChatMessages('parent_123', 'teacher_456'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2563EB)),
          );
        }
        final messages = snapshot.data ?? [];
        if (messages.isEmpty) {
          return Center(
            child: Text(
              'ابدأ المحادثة الآن',
              style: TextStyle(
                color: textMuted,
                fontFamily: 'Cairo',
                fontSize: 14.sp,
              ),
            ),
          );
        }

        return ListView.builder(
          reverse: true,
          padding: EdgeInsets.all(20.r),
          itemCount: messages.length,
          itemBuilder: (context, i) => _MessageBubble(
            msg: messages[i],
            primaryBlue: primaryBlue,
            primaryPurple: primaryPurple,
            textDark: textDark,
            textMuted: textMuted,
          ),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  // ويدجت فقاعة الرسالة (معزول لتحسين أداء القائمة)
  final MessageModel msg;
  final Color primaryBlue, primaryPurple, textDark, textMuted;

  const _MessageBubble({
    required this.msg,
    required this.primaryBlue,
    required this.primaryPurple,
    required this.textDark,
    required this.textMuted,
  });

  @override // بناء الفقاعة بتنسيق مختلف للمرسل والمستقبل
  Widget build(BuildContext context) {
    bool isMe = !msg.isFromTeacher;
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        constraints: BoxConstraints(maxWidth: 0.75.sw),
        decoration: BoxDecoration(
          gradient: isMe
              ? LinearGradient(colors: [primaryBlue, primaryPurple])
              : null,
          color: isMe ? null : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              msg.messageText,
              style: TextStyle(
                color: isMe ? Colors.white : textDark,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Cairo',
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              DateFormat('hh:mm a').format(msg.timestamp),
              style: TextStyle(
                color: isMe ? Colors.white.withValues(alpha: 0.7) : textMuted,
                fontSize: 9.sp,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatInputArea extends StatelessWidget {
  // ويدجت منطقة إدخال الرسائل (معزول)
  final TextEditingController controller;
  final VoidCallback onSend;
  final Color baseColor, primaryBlue, primaryPurple;

  const _ChatInputArea({
    required this.controller,
    required this.onSend,
    required this.baseColor,
    required this.primaryBlue,
    required this.primaryPurple,
  });

  @override // بناء حقل النص وزر الإرسال
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 30.h),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  const BoxShadow(
                    color: Colors.white,
                    blurRadius: 5,
                    offset: Offset(-2, -2),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 5,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          _SendButton(
            onTap: onSend,
            primaryBlue: primaryBlue,
            primaryPurple: primaryPurple,
          ), // زر الإرسال المنفصل
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  // ويدجت زر الإرسال
  final VoidCallback onTap;
  final Color primaryBlue, primaryPurple;
  const _SendButton({
    required this.onTap,
    required this.primaryBlue,
    required this.primaryPurple,
  });

  @override // بناء الزر بتصميم دائرى متدرج
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [primaryBlue, primaryPurple]),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}

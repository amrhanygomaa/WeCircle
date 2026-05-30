/*
🧠 اسم الملف: student_chatbot_screen.dart

📌 بيعمل إيه؟
ده الشات بوت الخاص بالطالب (Wesal Space Buddy V2.0).
بيعتمد على تقنيات الذكاء الاصطناعي السلوكي لتوجيه الطلاب (خاصة من 4-6 ابتدائي).

👤 موجه لمين؟
- الطلاب (Hero)

💡 فكرته:
دعم الطالب نفسياً وسلوكياً من خلال "رفيق فضاء" بيسمع، بيحلل، وبيوجهه دايماً للتواصل مع أهله.
*/

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

import '../../core/config/api_config.dart';
import '../../widgets/student1-3/animated_space_background.dart';

class StudentChatbotScreen extends StatefulWidget {
  final bool isGroupB;
  const StudentChatbotScreen({super.key, this.isGroupB = false});

  @override
  State<StudentChatbotScreen> createState() => _StudentChatbotScreenState();
}

class _StudentChatbotScreenState extends State<StudentChatbotScreen> with TickerProviderStateMixin {
  // ── Group B (4-6) Colors ──────────────────────────────────────────────────
  static const Color primaryCyan   = Color(0xFF00F2FF);
  static const Color primaryPurple = Color(0xFFBC00FF);
  static const Color bgDarkB       = Color(0xFF020412);
  static const Color cardDarkB     = Color(0xFF0A0E21);

  // ── Group A (1-3) Colors ──────────────────────────────────────────────────
  static const Color primaryBlue   = Color(0xFF1E88E5);
  static const Color primaryPurpleA = Color(0xFF9C27B0);
  static const Color bgDarkA       = Color(0xFF03001C);

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  late AnimationController _gridAnimationController;

  @override
  void initState() {
    super.initState();
    _gridAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    
    // الرسالة الترحيبية حسب النظام الجديد V2.0
    _messages.add({
      'isUser': false,
      'text': widget.isGroupB 
          ? 'مرحباً بك يا بطل! 🚀 أنا رفيقك في الفضاء (Space Buddy). أنا هنا لأسمعك وأدعمك في كل خطوة في رحلتك. إيه الأخبار النهاردة؟'
          : 'أهلاً بك يا بطل المجرة! ⭐ أنا رفيقك الفضائي الصغير، موجود هنا عشان أسمعك وأساعدك. تحب تحكيلي عن حاجة؟',
      'time': _getFormattedTime(),
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _gridAnimationController.dispose();
    super.dispose();
  }

  void _handleQuickAction(String action) {
    _messageController.text = action;
    _sendMessage();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    final userMsg = _messageController.text;
    setState(() {
      _messages.add({
        'isUser': true, 
        'text': userMsg, 
        'time': _getFormattedTime()
      });
      _messageController.clear();
    });
    _scrollToBottom();
    unawaited(_respondToUser(userMsg));
  }

  String _getFormattedTime() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 🤖 محرك الاستجابة — Gemini AI عبر الـ backend
  Future<void> _respondToUser(String userMsg) async {
    // Build history from existing messages (exclude the last user message just added)
    final history = _messages
        .where((m) => !(m['isUser'] as bool) || m['text'] != userMsg)
        .map((m) => {
          'role':  (m['isUser'] as bool) ? 'user' : 'model',
          'parts': [{'text': m['text'] as String}],
        })
        .toList();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('mobile_token') ?? '';

      final res = await http.post(
        Uri.parse('${ApiConfig.getBaseUrl()}/students/mobile/ai-chat'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type':  'application/json',
        },
        body: jsonEncode({'message': userMsg, 'history': history}),
      ).timeout(const Duration(seconds: 20));

      if (!mounted) return;

      String reply;
      if (res.statusCode == 200) {
        final d = jsonDecode(res.body) as Map<String, dynamic>;
        reply = (d['data']?['reply'] as String?) ??
                (d['reply']    as String?) ??
                'أنا معاك يا بطل! 🛰️';
      } else {
        reply = 'أنا معاك يا بطل! 🛰️ قولي إيه اللي شاغل تفكيرك؟';
      }

      setState(() {
        _messages.add({'isUser': false, 'text': reply, 'time': _getFormattedTime()});
      });
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'isUser': false,
          'text':   'أنا معاك يا بطل! 🛰️ قولي إيه اللي شاغل تفكيرك؟',
          'time':   _getFormattedTime(),
        });
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color currentBg = widget.isGroupB ? bgDarkB : bgDarkA;
    final Color currentPrimary = widget.isGroupB ? primaryCyan : primaryBlue;
    final Color currentSecondary = widget.isGroupB ? primaryPurple : primaryPurpleA;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: currentBg,
        body: Stack(
          children: [
            if (widget.isGroupB)
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      const Color(0xFF0A0E21),
                      const Color(0xFF020108),
                    ],
                  ),
                ),
              ),

            if (!widget.isGroupB) 
              const RepaintBoundary(child: AnimatedSpaceBackground())
            else ...[
               Positioned.fill(
                 child: RepaintBoundary(
                   child: AnimatedBuilder(
                     animation: _gridAnimationController,
                     builder: (context, child) {
                       return CustomPaint(
                         painter: _CyberGridPainter(
                           animationValue: _gridAnimationController.value,
                         ),
                       );
                     }
                   ),
                 ),
               ),
            ],

            SafeArea(
              child: Column(
                children: [
                  _buildHeader(currentPrimary, currentSecondary),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) => _MessageBubble(
                        msg: _messages[index],
                        primaryColor: currentPrimary,
                        secondaryColor: currentSecondary,
                        isGroupB: widget.isGroupB,
                      ),
                    ),
                  ),
                  _buildQuickActions(),
                  _buildInputArea(currentPrimary, currentSecondary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      height: 45.h,
      margin: EdgeInsets.only(bottom: 10.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        children: [
          _quickActionChip('أنا زعلان', Icons.sentiment_dissatisfied_rounded),
          _quickActionChip('عايز حل', Icons.lightbulb_rounded),
          _quickActionChip('حصل مشكلة', Icons.warning_amber_rounded),
          _quickActionChip('تمام كده', Icons.check_circle_outline_rounded),
        ],
      ),
    );
  }

  Widget _quickActionChip(String label, IconData icon) {
    final Color color = widget.isGroupB ? primaryCyan : Colors.white;
    return GestureDetector(
      onTap: () => _handleQuickAction(label),
      child: Container(
        margin: EdgeInsets.only(left: 10.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: widget.isGroupB ? cardDarkB : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 14.sp),
            SizedBox(width: 8.w),
            Text(label, style: TextStyle(color: color, fontSize: 12.sp, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color primary, Color secondary) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primary, secondary]),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.3), blurRadius: 10)],
            ),
            child: Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 22.sp),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .shimmer(duration: 2.seconds, color: Colors.white24),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wesal Space Buddy',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17.sp, fontFamily: 'Cairo'),
              ),
              Text(
                'رفيقك في الفضاء - V2.0',
                style: TextStyle(color: primary.withValues(alpha: 0.8), fontSize: 10.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(Color primary, Color secondary) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 30.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: widget.isGroupB ? cardDarkB.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              cursorColor: primary,
              style: TextStyle(color: Colors.white, fontSize: 14.sp, fontFamily: 'Cairo'),
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك هنا...',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 13.sp, color: Colors.white38, fontFamily: 'Cairo'),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primary, secondary]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.3), blurRadius: 10)],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> msg;
  final Color primaryColor, secondaryColor;
  final bool isGroupB;

  const _MessageBubble({
    required this.msg,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isGroupB,
  });

  @override
  Widget build(BuildContext context) {
    bool isUser = msg['isUser'];
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 20.h),
        constraints: BoxConstraints(maxWidth: 0.8.sw),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isUser ? null : (isGroupB ? const Color(0xFF10162F) : Colors.white.withValues(alpha: 0.08)),
          gradient: isUser ? LinearGradient(colors: [primaryColor, secondaryColor]) : null,
          borderRadius: isGroupB 
            ? BorderRadius.only(
                topLeft: Radius.circular(4.r),
                topRight: Radius.circular(4.r),
                bottomLeft: isUser ? Radius.circular(4.r) : Radius.zero,
                bottomRight: isUser ? Radius.zero : Radius.circular(4.r),
              )
            : BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
                bottomLeft: isUser ? Radius.circular(20.r) : Radius.zero,
                bottomRight: isUser ? Radius.zero : Radius.circular(20.r),
              ),
          border: isGroupB 
            ? Border.all(color: primaryColor.withValues(alpha: 0.3), width: 1)
            : Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg['text'],
              style: TextStyle(color: Colors.white, fontSize: 14.sp, height: 1.5, fontFamily: 'Cairo', fontWeight: isUser ? FontWeight.bold : FontWeight.w600),
            ),
            SizedBox(height: 6.h),
            Text(
              msg['time'],
              style: TextStyle(color: isUser ? Colors.white70 : Colors.white24, fontSize: 9.sp),
            ),
          ],
        ),
      ).animate().fade(duration: 300.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }
}

class _CyberGridPainter extends CustomPainter {
  final double animationValue;
  _CyberGridPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 0.5;

    final dotPaint = Paint()
      ..style = PaintingStyle.fill;

    double spacing = 50.w;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), basePaint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), basePaint);
    }

    for (double x = 0; x <= size.width; x += spacing) {
      for (double y = 0; y <= size.height; y += spacing) {
        double pulse = math.sin((animationValue * math.pi * 2) - (x + y) / 200);
        double normalizedPulse = (pulse + 1) / 2;
        
        if (normalizedPulse > 0.3) {
          double opacity = (normalizedPulse - 0.3) * 0.4;
          canvas.drawCircle(
            Offset(x, y), 
            1.5.r + (normalizedPulse * 1.0.r), 
            dotPaint..color = const Color(0xFF00F2FF).withValues(alpha: opacity)
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_CyberGridPainter old) => old.animationValue != animationValue;
}

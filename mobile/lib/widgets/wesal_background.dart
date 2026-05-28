import 'package:flutter/material.dart';

/// 🧠 اسم الملف: wesal_background.dart
/// 📌 بيعمل إيه؟
/// ويدجت الخلفية الموحدة للتطبيق، بيضيف صورة الخلفية المميزة (login_bg) بشكل احترافي خلف العناصر.
/// 
/// 👤 موجه لمين؟
/// - المطورين لاستخدامه في شاشات ولي الأمر والمعلم وغيرهم.
class WesalBackground extends StatelessWidget {
  final Widget child;
  final double opacity;
  final Color backgroundColor;

  const WesalBackground({
    super.key,
    required this.child,
    this.opacity = 0.3, // نفس الشفافية المستخدمة في شاشة الترحيب لراحة العين
    this.backgroundColor = const Color(0xFFF0F3F8),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        image: DecorationImage(
          image: const AssetImage('assets/images/login_bg.png'),
          fit: BoxFit.cover,
          opacity: opacity,
        ),
      ),
      child: child,
    );
  }
}

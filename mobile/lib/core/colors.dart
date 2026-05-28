import 'package:flutter/material.dart';

class AppColors {
  // Brand Palette
  static const Color background = Color(0xFFFAFAF8);
  static const Color primaryDark = Color(0xFF064E3B);
  static const Color primaryTeal = Color(0xFF0D9488);
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color softTeal = Color(0xFF14B8A6);
  static const Color mintGreen = Color(0xFF34D399);
  static const Color vibrantOrange = Color(0xFFF97316);
  static const Color skyBlue = Color(0xFF0EA5E9);
  static const Color softRose = Color(0xFFFB7185);

  // Text Colors
  static const Color textDark = Color(0xFF1E293B);
  static const Color textSlate = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D9488), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient magicGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF064E3B), Color(0xFF0D9488)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFFDBA74)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF7DD3FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Compatibility/Feature specific
  static const Color feesAccentOrange = Color(0xFFF59E0B);
  static const Color feesAlertRed = Color(0xFFEF4444);
  static const Color feesLightGray = Color(0xFFF1F5F9);
}

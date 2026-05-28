import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';
import '../services/responsive_helper.dart';

class AppStyles {
  // Shadows
  static List<BoxShadow> premiumShadow({Color? color}) {
    return [
      BoxShadow(
        color: (color ?? AppColors.primaryDark).withValues(alpha: 0.05),
        blurRadius: 20,
        offset: const Offset(0, 10),
        spreadRadius: -5,
      ),
    ];
  }

  // Padding
  static EdgeInsets screenPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: context.responsive(24.w, tablet: 48.w, desktop: 80.w),
      vertical: context.responsive(16.h, tablet: 24.h),
    );
  }

  // Border Radius
  static double adaptiveRadius(BuildContext context, double base) {
    return context.isTablet ? base * 1.2 : base;
  }

  // Decorations
  static BoxDecoration premiumCardDecoration() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(32.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ],
      border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5.w),
    );
  }

  static BoxDecoration glassDecoration({double blur = 15, Color? color}) {
    return BoxDecoration(
      color: (color ?? Colors.white).withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(32.r),
      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5.w),
    );
  }

  // Text Styles
  static TextStyle headingStyle = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w900,
    fontFamily: 'Outfit',
    color: AppColors.textDark,
  );

  static TextStyle titleStyle = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static TextStyle subtitleStyle = TextStyle(
    fontSize: 14.sp,
    color: AppColors.textSlate,
    fontWeight: FontWeight.w500,
  );

  static TextStyle bodyStyle = TextStyle(
    fontSize: 16.sp,
    color: AppColors.textDark,
  );

  static TextStyle captionStyle = TextStyle(
    fontSize: 12.sp,
    color: AppColors.textLight,
  );
}

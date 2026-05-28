import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wesal/core/colors.dart';
import 'package:wesal/core/styles.dart';

class AppTheme {
  // Brand Palette
  static const Color background = AppColors.background;
  static const Color primaryDark = AppColors.primaryDark;
  static const Color royalBlue = AppColors.primaryTeal;
  static const Color emeraldGreen = AppColors.emeraldGreen;
  static const Color luxuryViolet = AppColors.softTeal;
  static const Color accentGold = AppColors.mintGreen;
  static const Color vibrantOrange = AppColors.vibrantOrange;
  static const Color skyBlue = AppColors.skyBlue;
  static const Color softRose = AppColors.softRose;

  static const Color textDark = AppColors.textDark;
  static const Color textSlate = AppColors.textSlate;
  static const Color textLight = AppColors.textLight;

  // Gradients
  static const LinearGradient primaryGradient = AppColors.primaryGradient;
  static const LinearGradient magicGradient = AppColors.magicGradient;
  static const LinearGradient successGradient = AppColors.successGradient;
  static const LinearGradient orangeGradient = AppColors.orangeGradient;
  static const LinearGradient blueGradient = AppColors.blueGradient;
  static const LinearGradient brandGradient = AppColors.brandGradient;

  // Precision Shadows
  static List<BoxShadow> premiumShadow({Color? color}) =>
      AppStyles.premiumShadow(color: color);

  // Adaptive Padding & Layout Utils
  static EdgeInsets screenPadding(BuildContext context) =>
      AppStyles.screenPadding(context);

  static double adaptiveRadius(BuildContext context, double base) =>
      AppStyles.adaptiveRadius(context, base);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryDark,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDark,
        primary: primaryDark,
        secondary: accentGold,
        surface: Colors.white,
      ),
      fontFamily: 'Outfit',
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryDark),
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 58.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          textStyle: TextStyle(
            fontWeight: FontWeight.w900,
            fontFamily: 'Outfit',
            color: Colors.white,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }

  static BoxDecoration premiumCardDecoration() =>
      AppStyles.premiumCardDecoration();

  static BoxDecoration glassDecoration({double blur = 15, Color? color}) =>
      AppStyles.glassDecoration(blur: blur, color: color);

  static Widget buildTextField({
    required String hintText,
    required IconData icon,
    int maxLines = 1,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: premiumCardDecoration(),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: textLight, fontSize: 14.sp),
          prefixIcon: Icon(icon, color: primaryDark.withValues(alpha: 0.5)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 16.h,
          ),
        ),
      ),
    );
  }

  static Widget buildButton({
    required String text,
    required VoidCallback? onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 58.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        elevation: 0,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w900,
          fontFamily: 'Outfit',
        ),
      ),
    );
  }

  // Compatibility Setters
  static const Color primaryBlue = primaryDark;
  static const Color feesPrimaryBlue = royalBlue;
  static const Color accentIndigo = luxuryViolet;
  static const Color primaryGreen = emeraldGreen;
  static const Color feesSuccessGreen = emeraldGreen;
  static const Color amber = accentGold;
  static const Color feesAccentOrange = AppColors.feesAccentOrange;
  static const Color feesAlertRed = AppColors.feesAlertRed;
  static const Color feesTextDark = textDark;
  static const Color feesLightGray = AppColors.feesLightGray;
}

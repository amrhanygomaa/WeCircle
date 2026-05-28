import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/colors.dart';

class SectionLabel extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final String? actionText;

  const SectionLabel({
    super.key,
    required this.title,
    this.onTap,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryDark,
            fontFamily: 'Outfit',
            letterSpacing: -0.5,
          ),
        ),
        if (onTap != null)
          GestureDetector(
            onTap: onTap,
            child: Text(
              actionText ?? 'عرض الكل',
              style: TextStyle(
                color: AppColors.emeraldGreen,
                fontWeight: FontWeight.w900,
                fontSize: 14.sp,
              ),
            ),
          ),
      ],
    );
  }
}

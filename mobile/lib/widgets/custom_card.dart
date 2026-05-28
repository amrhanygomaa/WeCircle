import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/styles.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;
  final double? borderRadius;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.gradient,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(28.r),
      decoration: AppStyles.premiumCardDecoration().copyWith(
        gradient: gradient,
        borderRadius: borderRadius != null ? BorderRadius.circular(borderRadius!.r) : null,
      ),
      child: child,
    );
  }
}

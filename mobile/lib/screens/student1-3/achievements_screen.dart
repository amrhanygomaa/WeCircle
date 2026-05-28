import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/student1-3/animated_space_background.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final List<Map<String, dynamic>> badges = [
    {
      'title': 'بطل الهدوء',
      'points': 12,
      'total': 15,
      'color': const Color(0xFF00FF95),
      'icon': '🧘‍♂️',
      'isLocked': false,
    },
    {
      'title': 'درع اللطف',
      'points': 11,
      'total': 15,
      'color': const Color(0xFFFF4B8D),
      'icon': '🛡️',
      'isLocked': false,
    },
    {
      'title': 'ملك المشاركة',
      'points': 10,
      'total': 15,
      'color': const Color(0xFFFF9D00),
      'icon': '🎁',
      'isLocked': false,
    },
    {
      'title': 'قائد التركيز',
      'points': 11,
      'total': 15,
      'color': const Color(0xFFBC00FF),
      'icon': '🔭',
      'isLocked': false,
    },
    {
      'title': 'رائد مستقل',
      'points': 10,
      'total': 15,
      'color': const Color(0xFFFFD700),
      'icon': '🚀',
      'isLocked': false,
    },
    {
      'title': 'بطل الأبطال',
      'points': 0,
      'total': 15,
      'color': const Color(0xFF00F2FF),
      'icon': '⭐',
      'isLocked': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: const Color(0xFF03001C),
        child: Stack(
          children: [
            // 1. Background
            const AnimatedSpaceBackground(),

            // 3. Main Content
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: [
                          SizedBox(height: 20.h),
                          _buildBadgeGrid(),
                          SizedBox(height: 120.h), // Space for bottom bar
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Center(
        child: Text(
          'صندوق أوسمة البطل',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            shadows: [
              Shadow(color: Colors.blue.withValues(alpha: 0.5), blurRadius: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: badges.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 20.h,
        mainAxisExtent: 245.h,
      ),
      itemBuilder: (context, index) {
        final badge = badges[index];
        return _buildBadgeCard(badge, index);
      },
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge, int index) {
    final Color color = badge['color'];
    final bool isLocked = badge['isLocked'];
    final double progress = badge['points'] / badge['total'];

    return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D1126).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: isLocked ? Colors.white12 : color.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              if (!isLocked)
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 20.r,
                  spreadRadius: 2.r,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Badge Icon Circle
                Container(
                      width: 90.r,
                      height: 90.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: isLocked
                              ? [Colors.white12, Colors.transparent]
                              : [
                                  color.withValues(alpha: 0.4),
                                  color.withValues(alpha: 0.05),
                                ],
                        ),
                        border: Border.all(
                          color: isLocked
                              ? Colors.white24
                              : color.withValues(alpha: 0.8),
                          width: 2.r,
                        ),
                        boxShadow: [
                          if (!isLocked)
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 15.r,
                              spreadRadius: 2.r,
                            ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            badge['icon'],
                            style: TextStyle(
                              fontSize: 45.sp,
                              color: isLocked ? Colors.white30 : Colors.white,
                            ),
                          ),
                          if (isLocked)
                            Icon(
                                  Icons.lock_rounded,
                                  color: Colors.white70,
                                  size: 30.r,
                                )
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .shimmer(duration: 2.seconds),
                        ],
                      ),
                    )
                    .animate(
                      onPlay: (c) => isLocked ? null : c.repeat(reverse: true),
                    )
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.05, 1.05),
                      duration: 2.seconds,
                    ),

                SizedBox(height: 16.h),

                // Title
                Text(
                  badge['title'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isLocked ? Colors.white38 : Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Cairo',
                    shadows: isLocked
                        ? []
                        : [
                            Shadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                  ),
                ),

                const Spacer(),

                // Progress Bar Container
                Container(
                  height: 8.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Colors.white10),
                  ),
                  alignment: Alignment.centerRight, // RTL alignment
                  child: FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        gradient: LinearGradient(
                          colors: isLocked
                              ? [Colors.white24, Colors.white12]
                              : [color, color.withValues(alpha: 0.6)],
                        ),
                        boxShadow: [
                          if (!isLocked)
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                // Points Text
                Text(
                  '${badge['points']}/${badge['total']} Points collected',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: index * 30))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, curve: Curves.easeOutCubic);
  }
}

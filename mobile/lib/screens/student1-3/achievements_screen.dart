import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/api_config.dart';
import '../../widgets/student1-3/animated_space_background.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  // Static badge metadata — titles, colors, icons per game ID (1-5)
  static const _meta = [
    {'title': 'بطل الهدوء',      'color': Color(0xFF00FF95), 'icon': '🧘‍♂️'},
    {'title': 'درع اللطف',       'color': Color(0xFFFF4B8D), 'icon': '🛡️'},
    {'title': 'ملك المشاركة',    'color': Color(0xFFFF9D00), 'icon': '🎁'},
    {'title': 'قائد التركيز',    'color': Color(0xFFBC00FF), 'icon': '🔭'},
    {'title': 'رائد مستقل',      'color': Color(0xFFFFD700), 'icon': '🚀'},
  ];

  static const int _maxLevel = 5; // levels needed to "unlock" a badge

  bool _loading = true;
  List<Map<String, dynamic>> _badges = _buildDefault();

  static List<Map<String, dynamic>> _buildDefault() => List.generate(5, (i) => {
    ..._meta[i],
    'level': 0,
    'isLocked': true,
  });

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('mobile_token') ?? '';

      final res = await http.get(
        Uri.parse('${ApiConfig.getBaseUrl()}/students/mobile/game-state'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) return;

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? {};
      final raw  = (data['gameProgress'] as List? ?? []).cast<Map<String, dynamic>>();

      // Build a map: gameId → level
      final Map<int, int> levels = {};
      for (final g in raw) {
        final id    = (g['gameId'] as num).toInt();
        final level = (g['level']  as num).toInt();
        levels[id]  = level;
      }

      final badges = List.generate(5, (i) {
        final gameId = i + 1;
        final level  = levels[gameId] ?? 0;
        return {
          ..._meta[i],
          'level':    level,
          'isLocked': level < _maxLevel,
        };
      });

      if (mounted) setState(() { _badges = badges; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: const Color(0xFF03001C),
        child: Stack(
          children: [
            const AnimatedSpaceBackground(),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Column(children: [
                              SizedBox(height: 20.h),
                              _buildBadgeGrid(),
                              SizedBox(height: 120.h),
                            ]),
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

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Center(
        child: Text(
          'صندوق أوسمة البطل',
          style: TextStyle(
            color: Colors.white, fontSize: 22.sp,
            fontWeight: FontWeight.w900, letterSpacing: 1,
            shadows: [Shadow(color: Colors.blue.withValues(alpha: 0.5), blurRadius: 10)],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _badges.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 16.w,
        mainAxisSpacing: 20.h, mainAxisExtent: 245.h,
      ),
      itemBuilder: (_, i) => _buildBadgeCard(_badges[i], i),
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge, int index) {
    final Color color    = badge['color'] as Color;
    final bool isLocked  = badge['isLocked'] as bool;
    final int  level     = badge['level'] as int;
    final double progress = (level / _maxLevel).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1126).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: isLocked ? Colors.white12 : color.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          if (!isLocked) BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 20.r, spreadRadius: 2.r, offset: const Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon circle
            Container(
              width: 90.r, height: 90.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: isLocked
                    ? [Colors.white12, Colors.transparent]
                    : [color.withValues(alpha: 0.4), color.withValues(alpha: 0.05)]),
                border: Border.all(color: isLocked ? Colors.white24 : color.withValues(alpha: 0.8), width: 2.r),
                boxShadow: [if (!isLocked) BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 15.r, spreadRadius: 2.r)],
              ),
              child: Stack(alignment: Alignment.center, children: [
                Text(badge['icon'] as String, style: TextStyle(fontSize: 45.sp, color: isLocked ? Colors.white30 : Colors.white)),
                if (isLocked)
                  Icon(Icons.lock_rounded, color: Colors.white70, size: 30.r)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .shimmer(duration: 2.seconds),
              ]),
            )
            .animate(onPlay: (c) => isLocked ? null : c.repeat(reverse: true))
            .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2.seconds),

            SizedBox(height: 16.h),
            Text(badge['title'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isLocked ? Colors.white38 : Colors.white,
                fontSize: 14.sp, fontWeight: FontWeight.w900, fontFamily: 'Cairo',
                shadows: isLocked ? [] : [Shadow(color: color.withValues(alpha: 0.5), blurRadius: 8)],
              ),
            ),
            const Spacer(),

            // Progress bar
            Container(
              height: 8.h, width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.white10),
              ),
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    gradient: LinearGradient(colors: isLocked
                        ? [Colors.white24, Colors.white12]
                        : [color, color.withValues(alpha: 0.6)]),
                    boxShadow: [if (!isLocked) BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)],
                  ),
                ),
              ),
            ),

            SizedBox(height: 8.h),
            Text('المستوى $level / $_maxLevel',
              style: TextStyle(color: Colors.white54, fontSize: 10.sp, fontWeight: FontWeight.bold),
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

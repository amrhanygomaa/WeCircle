import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/api_config.dart';
import '../../widgets/wesal_background.dart';

class ResultsScreen extends StatefulWidget {
  final Map<String, dynamic>? childData;
  const ResultsScreen({super.key, this.childData});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  static const Color primaryPurple = Color(0xFF9333EA);
  static const Color textDark      = Color(0xFF1E293B);
  static const Color textMuted     = Color(0xFF64748B);
  static const Color trendGreen    = Color(0xFF22C55E);

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _subjects = [];
  double _average = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final studentId = widget.childData?['id'] as String?;
    if (studentId == null) {
      setState(() { _loading = false; _error = 'لا توجد بيانات للطالب'; });
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('mobile_token') ?? '';

      final uri = Uri.parse('${ApiConfig.getBaseUrl()}/exams/mobile/student/$studentId');
      final res = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }).timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        setState(() { _loading = false; _error = 'تعذّر تحميل النتائج'; });
        return;
      }

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final raw = (body['data'] as List? ?? []).cast<Map<String, dynamic>>();

      // Group by subject name and calculate percentage per subject
      final Map<String, List<double>> bySubject = {};
      for (final r in raw) {
        final name = (r['exam']?['subject']?['name'] as String?) ?? 'غير محدد';
        final score   = (r['score']   as num?)?.toDouble() ?? 0;
        final maxScore = (r['exam']?['totalMarks'] as num?)?.toDouble() ?? 100;
        final pct = maxScore > 0 ? (score / maxScore) * 100 : 0.0;
        bySubject.putIfAbsent(name, () => []).add(pct);
      }

      final subjects = bySubject.entries.map((e) {
        final avg = e.value.reduce((a, b) => a + b) / e.value.length;
        return {'subject': e.key, 'grade': '${avg.toStringAsFixed(0)}%', 'progress': avg / 100};
      }).toList();

      final overall = subjects.isEmpty ? 0.0
          : subjects.map((s) => (s['progress'] as double) * 100).reduce((a, b) => a + b) / subjects.length;

      setState(() {
        _subjects = subjects;
        _average  = overall;
        _loading  = false;
      });
    } catch (_) {
      setState(() { _loading = false; _error = 'خطأ في الاتصال بالخادم'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final childName = (widget.childData?['name'] as String?) ?? 'الطالب';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: WesalBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: primaryPurple))
                : _error != null
                    ? Center(child: Text(_error!, style: TextStyle(color: textDark, fontFamily: 'Cairo', fontSize: 16.sp)))
                    : _buildContent(childName),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(String childName) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          _ResultsHeader(name: childName, textDark: textDark, textMuted: textMuted),
          SizedBox(height: 32.h),
          Text('تحليلات الطالب', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: textDark, fontFamily: 'Cairo', letterSpacing: -0.5)),
          Text('تتبع الأداء الأكاديمي والتقدم', style: TextStyle(fontSize: 15.sp, color: textMuted, fontFamily: 'Cairo')),
          SizedBox(height: 24.h),
          _OverallAverageCard(average: _average, primaryPurple: primaryPurple),
          SizedBox(height: 40.h),
          if (_subjects.isEmpty)
            Center(child: Text('لا توجد نتائج متاحة بعد', style: TextStyle(color: textMuted, fontFamily: 'Cairo', fontSize: 15.sp)))
          else ...[
            Text('أداء المواد الدراسية', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: textDark, fontFamily: 'Cairo')),
            SizedBox(height: 16.h),
            ..._subjects.map((s) => _SubjectCard(
              subject:  s['subject'] as String,
              grade:    s['grade']   as String,
              progress: s['progress'] as double,
              primaryPurple: primaryPurple, textDark: textDark,
              textMuted: textMuted, trendGreen: trendGreen,
            )),
          ],
          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ResultsHeader extends StatelessWidget {
  final String name;
  final Color textDark, textMuted;
  const _ResultsHeader({required this.name, required this.textDark, required this.textMuted});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.white, shape: BoxShape.circle,
              boxShadow: [
                const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
                BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
              ],
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: textDark, size: 18.sp),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w900, color: textDark, fontFamily: 'Cairo')),
              Text('ولي أمر', style: TextStyle(fontSize: 12.sp, color: textMuted, fontFamily: 'Cairo')),
            ],
          ),
        ),
      ],
    );
  }
}

class _OverallAverageCard extends StatelessWidget {
  final double average;
  final Color primaryPurple;
  const _OverallAverageCard({required this.average, required this.primaryPurple});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: EdgeInsets.all(32.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF9333EA), Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: primaryPurple.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('المعدل العام', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 15.sp, fontFamily: 'Cairo')),
              SizedBox(height: 4.h),
              Text('${average.toStringAsFixed(0)}%', style: TextStyle(color: Colors.white, fontSize: 44.sp, fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
            ],
          ),
          Positioned(
            left: 0, top: 0, bottom: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20.r)),
                child: Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 30.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String subject, grade;
  final double progress;
  final Color primaryPurple, textDark, textMuted, trendGreen;
  const _SubjectCard({required this.subject, required this.grade, required this.progress, required this.primaryPurple, required this.textDark, required this.textMuted, required this.trendGreen});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h), padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(padding: EdgeInsets.all(10.r), decoration: BoxDecoration(color: primaryPurple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)), child: Icon(Icons.menu_book_rounded, color: primaryPurple, size: 20.sp)),
              SizedBox(width: 16.w),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(subject, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: textDark, fontFamily: 'Cairo')),
                Text('الدرجة الحالية', style: TextStyle(fontSize: 11.sp, color: textMuted, fontFamily: 'Cairo')),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(grade, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: textDark, fontFamily: 'Cairo')),
                Icon(Icons.trending_up_rounded, color: trendGreen, size: 14.sp),
              ]),
            ],
          ),
          SizedBox(height: 16.h),
          Stack(children: [
            Container(height: 6.h, width: double.infinity, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(3.r))),
            FractionallySizedBox(widthFactor: progress.clamp(0.0, 1.0), child: Container(height: 6.h, decoration: BoxDecoration(color: primaryPurple, borderRadius: BorderRadius.circular(3.r)))),
          ]),
        ],
      ),
    );
  }
}

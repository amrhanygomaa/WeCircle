/*
🧠 اسم الملف: results_screen.dart

📌 بيعمل إيه؟
دي شاشة بتعرض نتايج الامتحانات والتقييمات الأكاديمية للطالب في كل المواد.

👤 موجه لمين؟
- أولياء أمور

💡 فكرته:
توفير رؤية واضحة لمستوى الطالب الدراسي عشان ولي الأمر يعرف يوجهه صح.
*/

import 'package:flutter/material.dart'; // استيراد مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة التحكم في أحجام الشاشة
import '../../widgets/wesal_background.dart';

class ResultsScreen extends StatelessWidget { // تعريف كلاس شاشة النتائج كـ StatelessWidget
  final Map<String, dynamic>? childData; // استقبال بيانات الطفل
  const ResultsScreen({super.key, this.childData}); // مشيد الكلاس

  // ── Design tokens ─────────────────────────────────────────────────────────
  static const Color primaryPurple = Color(0xFF9333EA); // اللون البنفسجي الأساسي
  static const Color textDark      = Color(0xFF1E293B); // اللون النص الداكن
  static const Color textMuted     = Color(0xFF64748B); // اللون النص الباهت
  static const Color trendGreen    = Color(0xFF22C55E); // لون التحسن الأخضر

  @override // بناء واجهة المستخدم
  Widget build(BuildContext context) {
    return Directionality( // ضبط الاتجاه للعربية
      textDirection: TextDirection.rtl,
      child: WesalBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent, // لون الخلفية شفاف لرؤية الخلفية الموحدة
          body: SafeArea(
            child: SingleChildScrollView( // تمكين التمرير
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  const _ResultsHeader(textDark: textDark, textMuted: textMuted), // ترويسة الصفحة (معزولة)
                  SizedBox(height: 32.h),
                  Text('تحليلات الطالب', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: textDark, fontFamily: 'Cairo', letterSpacing: -0.5)), // العنوان الرئيسي
                  Text('تتبع الأداء الأكاديمي والتقدم', style: TextStyle(fontSize: 15.sp, color: textMuted, fontFamily: 'Cairo')), // وصف فرعى
                  SizedBox(height: 24.h),
                  const _OverallAverageCard(primaryPurple: primaryPurple), // بطاقة المعدل العام (معزولة)
                  SizedBox(height: 40.h),
                  Text('أداء المواد الدراسية', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: textDark, fontFamily: 'Cairo')), // عنوان قسم المواد
                  SizedBox(height: 16.h),
                  const _SubjectCard(subject: 'الرياضيات', grade: '95%', progress: 0.95, primaryPurple: primaryPurple, textDark: textDark, textMuted: textMuted, trendGreen: trendGreen), // مادة الرياضيات
                  const _SubjectCard(subject: 'العلوم', grade: '92%', progress: 0.92, primaryPurple: primaryPurple, textDark: textDark, textMuted: textMuted, trendGreen: trendGreen), // مادة العلوم
                  const _SubjectCard(subject: 'اللغة الإنجليزية', grade: '91%', progress: 0.91, primaryPurple: primaryPurple, textDark: textDark, textMuted: textMuted, trendGreen: trendGreen), // مادة الإنجليزية
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Optimized Sub-Widgets ──────────────────────────────────────────────────

class _ResultsHeader extends StatelessWidget { // ويدجت ترويسة شاشة النتائج (معزول)
  final Color textDark, textMuted;
  const _ResultsHeader({required this.textDark, required this.textMuted});

  @override // بناء الترويسة ببيانات ولى الأمر
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container( // زر الرجوع بتصميم Neumorphic
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
              Text('سارة محمد', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w900, color: textDark, fontFamily: 'Cairo')),
              Text('ولي أمر', style: TextStyle(fontSize: 12.sp, color: textMuted, fontFamily: 'Cairo')),
            ],
          ),
        ),
      ],
    );
  }
}

class _OverallAverageCard extends StatelessWidget { // ويدجت بطاقة المعدل العام (معزول)
  final Color primaryPurple;
  const _OverallAverageCard({required this.primaryPurple});

  @override // بناء البطاقة بتدرج لونى وظل
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
              Text('91%', style: TextStyle(color: Colors.white, fontSize: 44.sp, fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Icon(Icons.trending_up_rounded, color: Colors.white, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text('+3% منذ الشهر الماضي', style: TextStyle(color: Colors.white, fontSize: 13.sp, fontFamily: 'Cairo')),
                ],
              ),
            ],
          ),
          Positioned( // أيقونة التميز فى الجانب
            left: 0, top: 0, bottom: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.all(16.r), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20.r)),
                child: Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 30.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget { // ويدجت بطاقة أداء المادة (معزول)
  final String subject, grade;
  final double progress;
  final Color primaryPurple, textDark, textMuted, trendGreen;

  const _SubjectCard({
    required this.subject, required this.grade, required this.progress,
    required this.primaryPurple, required this.textDark, required this.textMuted, required this.trendGreen
  });

  @override // بناء بطاقة المادة بشريط التقدم
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: textDark, fontFamily: 'Cairo')),
                    Text('الدرجة الحالية', style: TextStyle(fontSize: 11.sp, color: textMuted, fontFamily: 'Cairo')),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(grade, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: textDark, fontFamily: 'Cairo')),
                  Icon(Icons.trending_up_rounded, color: trendGreen, size: 14.sp),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _ProgressBar(progress: progress, primaryPurple: primaryPurple), // شريط التقدم المنفصل
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget { // ويدجت شريط التقدم المخصص
  final double progress;
  final Color primaryPurple;
  const _ProgressBar({required this.progress, required this.primaryPurple});

  @override // بناء الشريط
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(height: 6.h, width: double.infinity, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(3.r))),
        FractionallySizedBox(widthFactor: progress, child: Container(height: 6.h, decoration: BoxDecoration(color: primaryPurple, borderRadius: BorderRadius.circular(3.r)))),
      ],
    );
  }
}

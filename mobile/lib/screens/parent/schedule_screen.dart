/*
🧠 اسم الملف: schedule_screen.dart

📌 بيعمل إيه؟
دي شاشة بتعرض الجدول الدراسي الأسبوعي للطالب بكل تفاصيله.

👤 موجه لمين؟
- أولياء أمور

💡 فكرته:
مساعدة ولي الأمر والطالب في تنظيم وقتهم وتجهيز الشنطة والدروس بناءً على الجدول.
*/

import 'package:flutter/material.dart'; // استيراد مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة التحكم في أحجام الشاشة
import '../../widgets/wesal_background.dart';

class ScheduleScreen extends StatefulWidget { // تعريف كلاس شاشة الجدول الدراسي كـ StatefulWidget
  const ScheduleScreen({super.key}); // مشيد الكلاس

  @override // إنشاء حالة الشاشة
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> { // كلاس حالة شاشة الجدول الدراسي
  // ── Design tokens ─────────────────────────────────────────────────────────
  static const Color primaryBlue   = Color(0xFF2563EB); // اللون الأزرق الأساسي
  static const Color primaryPurple = Color(0xFF9333EA); // اللون البنفسجي الأساسي
  static const Color baseColor     = Color(0xFFF0F3F8); // لون الخلفية الأساسي
  static const Color textDark      = Color(0xFF1E293B); // لون النص الداكن
  static const Color textMuted     = Color(0xFF64748B); // لون النص الباهت

  String _selectedDay = 'الأحد'; // اليوم المختار حالياً من الفلتر

  @override // بناء واجهة المستخدم الرئيسية
  Widget build(BuildContext context) {
    return Directionality( // ضبط الاتجاه للعربية
      textDirection: TextDirection.rtl,
      child: WesalBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent, // شفاف لرؤية الخلفية الموحدة
          body: SafeArea(
            child: Column(
              children: [
                const _ScheduleHeader(primaryBlue: primaryBlue, primaryPurple: primaryPurple, textDark: textDark), // ترويسة الجدول (معزولة)
              SizedBox(height: 16.h),
              _DaySelector( // شريط اختيار الأيام (معزول الأداء)
                selectedDay: _selectedDay,
                onChanged: (day) => setState(() => _selectedDay = day),
                primaryBlue: primaryBlue,
                primaryPurple: primaryPurple,
                baseColor: baseColor,
                textDark: textDark,
              ),
              SizedBox(height: 24.h),
              Expanded( // قائمة عرض حصص اليوم المختار
                child: _ScheduleListView(
                  selectedDay: _selectedDay,
                  baseColor: baseColor,
                  textDark: textDark,
                  textMuted: textMuted,
                  primaryBlue: primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

// ── Optimized Sub-Widgets ──────────────────────────────────────────────────

class _ScheduleHeader extends StatelessWidget { // ويدجت ترويسة شاشة الجدول (معزول)
  final Color primaryBlue, primaryPurple, textDark;
  const _ScheduleHeader({required this.primaryBlue, required this.primaryPurple, required this.textDark});

  @override // بناء الترويسة بالأيقونة والعنوان
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Row(
        children: [
          Container( // أيقونة التقويم المتدرجة
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primaryBlue, primaryPurple]), shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: primaryPurple.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Icon(Icons.calendar_today_rounded, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Text('الجدول الدراسي', style: TextStyle(color: textDark, fontWeight: FontWeight.w900, fontSize: 22.sp, fontFamily: 'Cairo')),
        ],
      ),
    );
  }
}

class _DaySelector extends StatelessWidget { // ويدجت شريط اختيار اليوم (معزول الأداء)
  final String selectedDay;
  final ValueChanged<String> onChanged;
  final Color primaryBlue, primaryPurple, baseColor, textDark;

  const _DaySelector({required this.selectedDay, required this.onChanged, required this.primaryBlue, required this.primaryPurple, required this.baseColor, required this.textDark});

  @override // بناء شريط الأيام الأفقى
  Widget build(BuildContext context) {
    final days = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس'];
    return SizedBox(
      height: 50.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal, padding: EdgeInsets.symmetric(horizontal: 16.w), itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final active = selectedDay == day;
          return GestureDetector(
            onTap: () => onChanged(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300), margin: EdgeInsets.symmetric(horizontal: 6.w), padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                gradient: active ? LinearGradient(colors: [primaryBlue, primaryPurple]) : null, color: active ? null : baseColor,
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: active ? [BoxShadow(color: primaryPurple.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : [
                  const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
                ],
              ),
              alignment: Alignment.center,
              child: Text(day, style: TextStyle(color: active ? Colors.white : textDark, fontWeight: FontWeight.bold, fontSize: 13.sp, fontFamily: 'Cairo')),
            ),
          );
        },
      ),
    );
  }
}

class _ScheduleListView extends StatelessWidget { // ويدجت قائمة الحصص (معزول الأداء)
  final String selectedDay;
  final Color baseColor, textDark, textMuted, primaryBlue;

  const _ScheduleListView({required this.selectedDay, required this.baseColor, required this.textDark, required this.textMuted, required this.primaryBlue});

  @override // بناء القائمة بناءً على بيانات اليوم المختار
  Widget build(BuildContext context) {
    final Map<String, List<Map<String, String>>> schedule = { // بيانات الجدول (محاكاة)
      'الأحد': [{'time': '08:00 - 08:45', 'subject': 'اللغة العربية', 'teacher': 'أ/ محمد علي', 'room': 'قاعة 101'}, {'time': '08:45 - 09:30', 'subject': 'الرياضيات', 'teacher': 'أ/ سارة محمود', 'room': 'مختبر ب'}, {'time': '09:30 - 10:00', 'subject': 'فترة راحة', 'teacher': '-', 'room': 'الفناء'}, {'time': '10:00 - 10:45', 'subject': 'العلوم', 'teacher': 'د/ أحمد خالد', 'room': 'مختبر العلوم'}, {'time': '10:45 - 11:30', 'subject': 'اللغة الإنجليزية', 'teacher': 'أ/ جيهان حسن', 'room': 'قاعة 204'}],
      'الاثنين': [{'time': '08:00 - 08:45', 'subject': 'التربية الدينية', 'teacher': 'أ/ حسن إبراهيم', 'room': 'قاعة 105'}, {'time': '08:45 - 09:30', 'subject': 'اللغة العربية', 'teacher': 'أ/ محمد علي', 'room': 'قاعة 101'}, {'time': '09:30 - 10:00', 'subject': 'فترة راحة', 'teacher': '-', 'room': 'الفناء'}, {'time': '10:00 - 10:45', 'subject': 'الرياضيات', 'teacher': 'أ/ سارة محمود', 'room': 'مختبر ب'}, {'time': '10:45 - 11:30', 'subject': 'الدراسات الاجتماعية', 'teacher': 'أ/ نورا يوسف', 'room': 'قاعة 302'}],
      'الثلاثاء': [{'time': '08:00 - 08:45', 'subject': 'اللغة الإنجليزية', 'teacher': 'أ/ جيهان حسن', 'room': 'قاعة 204'}, {'time': '08:45 - 09:30', 'subject': 'العلوم', 'teacher': 'د/ أحمد خالد', 'room': 'مختبر العلوم'}, {'time': '09:30 - 10:00', 'subject': 'فترة راحة', 'teacher': '-', 'room': 'الفناء'}, {'time': '10:00 - 10:45', 'subject': 'اللغة العربية', 'teacher': 'أ/ محمد علي', 'room': 'قاعة 101'}, {'time': '10:45 - 11:30', 'subject': 'التربية الرياضية', 'teacher': 'ك/ وليد سعد', 'room': 'الملعب'}],
      'الأربعاء': [{'time': '08:00 - 08:45', 'subject': 'الرياضيات', 'teacher': 'أ/ سارة محمود', 'room': 'مختبر ب'}, {'time': '08:45 - 09:30', 'subject': 'اللغة العربية', 'teacher': 'أ/ محمد علي', 'room': 'قاعة 101'}, {'time': '09:30 - 10:00', 'subject': 'فترة راحة', 'teacher': '-', 'room': 'الفناء'}, {'time': '10:00 - 10:45', 'subject': 'البرمجة', 'teacher': 'م/ علي رضا', 'room': 'معمل الحاسوب'}, {'time': '10:45 - 11:30', 'subject': 'التربية الفنية', 'teacher': 'أ/ منى مجدي', 'room': 'المرسم'}],
      'الخميس': [{'time': '08:00 - 08:45', 'subject': 'العلوم', 'teacher': 'د/ أحمد خالد', 'room': 'مختبر العلوم'}, {'time': '08:45 - 09:30', 'subject': 'اللغة الإنجليزية', 'teacher': 'أ/ جيهان حسن', 'room': 'قاعة 204'}, {'time': '09:30 - 10:00', 'subject': 'فترة راحة', 'teacher': '-', 'room': 'الفناء'}, {'time': '10:00 - 10:45', 'subject': 'الدراسات الاجتماعية', 'teacher': 'أ/ نورا يوسف', 'room': 'قاعة 302'}, {'time': '10:45 - 11:30', 'subject': 'نشاط حر', 'teacher': '-', 'room': 'قاعة النشاط'}],
    };
    final dailyClasses = schedule[selectedDay] ?? [];
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h), physics: const BouncingScrollPhysics(), itemCount: dailyClasses.length,
      itemBuilder: (context, index) => _ScheduleCard(item: dailyClasses[index], baseColor: baseColor, textDark: textDark, textMuted: textMuted, primaryBlue: primaryBlue),
    );
  }
}

class _ScheduleCard extends StatelessWidget { // ويدجت بطاقة الحصة الدراسية (معزول)
  final Map<String, String> item;
  final Color baseColor, textDark, textMuted, primaryBlue;

  const _ScheduleCard({required this.item, required this.baseColor, required this.textDark, required this.textMuted, required this.primaryBlue});

  @override // بناء بطاقة الحصة بتصميم Neumorphic
  Widget build(BuildContext context) {
    final isBreak = item['subject'] == 'فترة راحة';
    return Container(
      margin: EdgeInsets.only(bottom: 16.h), padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: baseColor, borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
        ],
      ),
      child: Row(
        children: [
          _TimeBadge(time: item['time']!, isBreak: isBreak, primaryBlue: primaryBlue), // شارة الوقت المنفصلة
          SizedBox(width: 16.w),
          Expanded(child: _ClassDetails(item: item, isBreak: isBreak, textDark: textDark, textMuted: textMuted)), // تفاصيل الحصة المنفصلة
          isBreak ? const Icon(Icons.coffee_rounded, color: Colors.orange, size: 24) : Icon(Icons.arrow_forward_ios_rounded, color: textMuted.withValues(alpha: 0.3), size: 16.sp),
        ],
      ),
    );
  }
}

class _TimeBadge extends StatelessWidget { // ويدجت شارة عرض الوقت
  final String time;
  final bool isBreak;
  final Color primaryBlue;
  const _TimeBadge({required this.time, required this.isBreak, required this.primaryBlue});

  @override // بناء الشارة الملونة
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(color: (isBreak ? Colors.orange : primaryBlue).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
      child: Text(time, style: TextStyle(color: isBreak ? Colors.orange : primaryBlue, fontWeight: FontWeight.bold, fontSize: 11.sp)),
    );
  }
}

class _ClassDetails extends StatelessWidget { // ويدجت نصوص تفاصيل الحصة
  final Map<String, String> item;
  final bool isBreak;
  final Color textDark, textMuted;

  const _ClassDetails({required this.item, required this.isBreak, required this.textDark, required this.textMuted});

  @override // بناء النصوص الوصفية
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item['subject']!, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp, color: textDark, fontFamily: 'Cairo')),
        if (!isBreak) ...[
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 12.sp, color: textMuted),
              SizedBox(width: 4.w),
              Text(item['teacher']!, style: TextStyle(color: textMuted, fontSize: 11.sp, fontFamily: 'Cairo')),
              SizedBox(width: 12.w),
              Icon(Icons.location_on_outlined, size: 12.sp, color: textMuted),
              SizedBox(width: 4.w),
              Text(item['room']!, style: TextStyle(color: textMuted, fontSize: 11.sp, fontFamily: 'Cairo')),
            ],
          ),
        ],
      ],
    );
  }
}

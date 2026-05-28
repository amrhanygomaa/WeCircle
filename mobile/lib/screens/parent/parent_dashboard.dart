/*
🧠 اسم الملف: parent_dashboard.dart

📌 بيعمل إيه؟
دي الشاشة اللي ولي الأمر بيشوف فيها كل حاجة تخص ولاده، زي درجاتهم، غيابهم، وتنبيهات الباص.

👤 موجه لمين؟
- أولياء أمور

💡 فكرته:
بيدي ولي الأمر تحكم كامل ومتابعة لحظية لكل تفاصيل حياة ابنه المدرسية.
*/

import 'package:flutter/material.dart'; // استيراد مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة التحكم في أحجام الشاشة
import 'package:flutter/services.dart'; // استيراد مكتبة الهابتيك والخدمات
import '../../state_manager.dart';
import 'messages_screen.dart'; // استيراد شاشة الرسائل
import 'homework_screen.dart'; // استيراد شاشة الواجبات
import 'schedule_screen.dart'; // استيراد شاشة الجدول الدراسي
import 'parent_add_task_screen.dart'; // استيراد شاشة إضافة المهام

import '../../widgets/wesal_background.dart';

class ParentDashboardScreen extends StatefulWidget {
  // تعريف كلاس شاشة لوحة تحكم ولي الأمر
  const ParentDashboardScreen({super.key}); // مشيد الكلاس مع مفتاح فريد

  @override // إعادة تعريف دالة إنشاء الحالة
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState(); // إنشاء حالة الشاشة
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  // كلاس حالة شاشة لوحة التحكم
  int _currentIndex = 0; // متغير لتخزين مؤشر التبويب الحالي
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<
        ScaffoldState
      >(); // مفتاح للتحكم في الـ Scaffold (مثل فتح القائمة الجانبية)

  // ── Design tokens ─────────────────────────────────────────────────────────
  static const Color primaryBlue = Color(0xFF2563EB); // اللون الأزرق الأساسي
  static const Color primaryPurple = Color(
    0xFF9333EA,
  ); // اللون البنفسجي الأساسي
  static const Color baseColor = Color(0xFFF0F3F8); // لون الخلفية الأساسي
  static const Color textDark = Color(0xFF1E293B); // لون النص الداكن
  static const Color textMuted = Color(0xFF64748B); // لون النص الباهت
  static const Color presentColor = Color(0xFF22C55E); // لون حالة الحضور (أخضر)
  static const Color absentColor = Color(0xFFEF4444); // لون حالة الغياب (أحمر)
  static const Color lateColor = Color(
    0xFFF59E0B,
  ); // لون حالة التأخير (برتقالي)

  @override // إعادة تعريف دالة بناء الواجهة
  Widget build(BuildContext context) {
    // دالة بناء الشاشة
    return Directionality(
      // تحديد اتجاه النص
      textDirection:
          TextDirection.rtl, // تعيين الاتجاه من اليمين إلى اليسار (عربي)
      child: Scaffold(
        // الهيكل الأساسي للصفحة
        key: _scaffoldKey, // ربط المفتاح بالهيكل
        backgroundColor: Colors.transparent, // جعل خلفية السكافولد شفافة لرؤية الخلفية الموحدة
        drawer: _DashboardDrawer(
          absentColor: absentColor,
          baseColor: baseColor,
          textMuted: textMuted,
          primaryBlue: primaryBlue,
          primaryPurple: primaryPurple,
          textDark: textDark,
        ), // بناء القائمة الجانبية كويدجت منفصل لتحسين الأداء
        body: WesalBackground(
          child: SafeArea(
            // التأكد من عدم تداخل الواجهة مع حواف الشاشة
          child: IndexedStack(
            // مكدس للتبديل بين الصفحات مع الحفاظ على حالتها
            index: _currentIndex, // تحديد الصفحة النشطة بناءً على المؤشر
            children: [
              // قائمة الصفحات المتوفرة في التبويبات
              RepaintBoundary(
                child: _HomeTab(
                  scaffoldKey: _scaffoldKey,
                  primaryBlue: primaryBlue,
                  primaryPurple: primaryPurple,
                  baseColor: baseColor,
                  textDark: textDark,
                  textMuted: textMuted,
                  presentColor: presentColor,
                  lateColor: lateColor,
                  absentColor: absentColor,
                ),
              ), // تبويب الصفحة الرئيسية كويدجت منفصل
              RepaintBoundary(
                child: HomeworkScreen(
                  isTab: true,
                  onBack: () => setState(() => _currentIndex = 0),
                ),
              ), // تبويب الواجبات
              const RepaintBoundary(
                child: ScheduleScreen(),
              ), // تبويب الجدول الدراسي (ثابت)
              const RepaintBoundary(
                child: ParentAddTaskScreen(),
              ), // تبويب إضافة المهام (ثابت)

              RepaintBoundary(
                child: MessagingCenterScreen(
                  isTab: true,
                  onBack: () => setState(() => _currentIndex = 0),
                ),
              ), // تبويب الرسائل
            ],
          ),
        ),
      ),
      bottomNavigationBar: _DashboardBottomNav(
          // بناء شريط التنقل السفلي كويدجت منفصل
          currentIndex: _currentIndex, // تمرير المؤشر الحالي
          onTap: (idx) => setState(
            () => _currentIndex = idx,
          ), // دالة تحديث المؤشر عند الضغط
          primaryBlue: primaryBlue, // تمرير الألوان
          primaryPurple: primaryPurple,
          baseColor: baseColor,
          textMuted: textMuted,
        ),
      ),
    );
  }
}

// ── Supporting Widgets (Optimized for Performance) ──────────────────────────

class _HomeTab extends StatelessWidget {
  // ويدجت تبويب الصفحة الرئيسية (Stateless لتقليل إعادة البناء غير الضرورية)
  final GlobalKey<ScaffoldState>
  scaffoldKey; // مفتاح الهيكل لفتح القائمة الجانبية
  final Color primaryBlue,
      primaryPurple,
      baseColor,
      textDark,
      textMuted,
      presentColor,
      lateColor,
      absentColor; // الألوان الأساسية

  const _HomeTab({
    // مشيد الويدجت
    required this.scaffoldKey,
    required this.primaryBlue,
    required this.primaryPurple,
    required this.baseColor,
    required this.textDark,
    required this.textMuted,
    required this.presentColor,
    required this.lateColor,
    required this.absentColor,
  });

  @override // بناء واجهة التبويب الرئيسي
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      // مراقب لتحديث محتوى الطفل المختار فقط دون إعادة بناء الترويسة
      valueListenable:
          AppStateManager().selectedChildIndex, // الاستماع لمؤشر الطفل
      builder: (context, childIdx, _) {
        // بناء الواجهة عند التغيير
        final selectedChild =
            AppStateManager().children[childIdx]; // جلب بيانات الطفل المختار

        return SingleChildScrollView(
          // تمكين التمرير
          physics: const BouncingScrollPhysics(), // تأثير الارتداد
          padding: EdgeInsets.symmetric(horizontal: 20.w), // حشوة أفقية
          child: Column(
            // ترتيب رأسي للعناصر
            crossAxisAlignment: CrossAxisAlignment.start, // محاذاة لليمين
            children: [
              SizedBox(height: 10.h), // مسافة رأسية
              _DashboardHeader(
                scaffoldKey: scaffoldKey,
                primaryBlue: primaryBlue,
                primaryPurple: primaryPurple,
                baseColor: baseColor,
                textDark: textDark,
                textMuted: textMuted,
              ), // ترويسة الصفحة
              SizedBox(height: 24.h), // مسافة رأسية

              _ChildCard(
                child: selectedChild,
                primaryBlue: primaryBlue,
                primaryPurple: primaryPurple,
              ), // بطاقة تعريف الطفل
              SizedBox(height: 32.h), // مسافة رأسية

              Text(
                'نظرة عامة اليوم',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                  fontFamily: 'Cairo',
                ),
              ), // عنوان القسم
              SizedBox(height: 16.h),
              _TodayOverview(
                selectedChild: selectedChild,
                textDark: textDark,
                textMuted: textMuted,
                baseColor: baseColor,
              ),

              SizedBox(height: 32.h),
              Text(
                'إجراءات سريعة',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                  fontFamily: 'Cairo',
                ),
              ), // عنوان القسم
              SizedBox(height: 16.h),
              _QuickActionsGrid(
                selectedChild: selectedChild,
                textDark: textDark,
              ),

              SizedBox(height: 40.h),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardBanner extends StatelessWidget {
  final Map<String, dynamic> selectedChild;

  const _DashboardBanner({required this.selectedChild});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7367F0), Color(0xFF9E95F5)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40.r),
          bottomRight: Radius.circular(40.r),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'ID: ${selectedChild['id']}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  // ويدجت ترويسة الصفحة (معزول)
  final GlobalKey<ScaffoldState> scaffoldKey; // مفتاح الهيكل
  final Color primaryBlue,
      primaryPurple,
      baseColor,
      textDark,
      textMuted; // الألوان

  const _DashboardHeader({
    // مشيد الترويسة
    required this.scaffoldKey,
    required this.primaryBlue,
    required this.primaryPurple,
    required this.baseColor,
    required this.textDark,
    required this.textMuted,
  });

  @override // بناء الترويسة
  Widget build(BuildContext context) {
    return Row(
      // ترتيب أفقياً
      children: [
        GestureDetector(
          // زر فتح القائمة الجانبية
          onTap: () => scaffoldKey.currentState?.openDrawer(), // فتح القائمة
          child: Container(
            // حاوية الأيقونة بتصميم Neumorphic
            padding: EdgeInsets.all(10.r), // حشوة
            decoration: BoxDecoration(
              // تنسيق الظل واللون
              color: baseColor,
              shape: BoxShape.circle,
              boxShadow: [
                const BoxShadow(
                  color: Colors.white,
                  blurRadius: 8,
                  offset: Offset(-4, -4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(4, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.person_rounded,
              color: primaryBlue,
              size: 24.sp,
            ), // أيقونة المستخدم
          ),
        ),
        SizedBox(width: 12.w), // مسافة
        Expanded(
          // النصوص التعريفية
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'سارة محمد',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                  fontFamily: 'Cairo',
                ),
              ), // الاسم
              PopupMenuButton<int>(
                onSelected: (idx) => AppStateManager().setSelectedChild(idx),
                color: baseColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 8,
                offset: Offset(0, 50.h),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(4, 4),
                      ),
                      const BoxShadow(
                        color: Colors.white,
                        blurRadius: 8,
                        offset: Offset(-4, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.family_restroom_rounded,
                        size: 18.sp,
                        color: primaryBlue,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'الأبناء',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: textDark,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18.sp,
                        color: textMuted,
                      ),
                    ],
                  ),
                ),
                itemBuilder: (context) =>
                    AppStateManager().children.asMap().entries.map((entry) {
                      final child = entry.value;
                      return PopupMenuItem<int>(
                        value: entry.key,
                        child: Row(
                          children: [
                            Container(
                              width: 8.r,
                              height: 8.r,
                              decoration: BoxDecoration(
                                color: child['color'] as Color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              child['name'],
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: textDark,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ), // قائمة منسدلة لاختيار الأبناء
            ],
          ),
        ),
        _NotificationIcon(
          primaryPurple: primaryPurple,
          baseColor: baseColor,
        ), // أيقونة التنبيهات المنفصلة
      ],
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  // ويدجت أيقونة التنبيهات (معزول)
  final Color primaryPurple, baseColor; // الألوان

  const _NotificationIcon({
    required this.primaryPurple,
    required this.baseColor,
  }); // مشيد الأيقونة

  @override // بناء الأيقونة مع القائمة المنبثقة
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      // زر القائمة
      offset: Offset(0, 50.h), // الإزاحة
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ), // شكل دائرى
      color: baseColor, // اللون
      elevation: 8, // الظل
      onSelected: (val) {}, // اختيار عنصر
      child: Container(
        // شكل زر التنبيهات
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: baseColor,
          shape: BoxShape.circle,
          boxShadow: [
            const BoxShadow(
              color: Colors.white,
              blurRadius: 8,
              offset: Offset(-4, -4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Stack(
          // مكدس لنقطة التنبيه
          children: [
            Icon(
              Icons.notifications_none_rounded,
              color: primaryPurple,
              size: 24.sp,
            ), // الجرس
            Positioned(
              // تحديد موقع النقطة
              right: 0,
              top: 0,
              child: Container(
                width: 8.r,
                height: 8.r,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ), // اللون الأحمر
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        // قائمة التنبيهات التجريبية
        _buildPopupItem(
          'تم تصحيح واجب الرياضيات',
          'منذ 10 دقائق',
          Icons.assignment_turned_in_rounded,
          const Color(0xFF2563EB),
        ),
        _buildPopupItem(
          'رسالة جديدة من مدرسة العربي',
          'منذ ساعة',
          Icons.chat_bubble_outline_rounded,
          primaryPurple,
        ),
        _buildPopupItem(
          'تنبيه: موعد الرحلة غداً',
          'منذ ساعتين',
          Icons.info_outline_rounded,
          const Color(0xFFF59E0B),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    // بناء عنصر واحد في قائمة التنبيهات
    return PopupMenuItem(
      child: Container(
        width: 250.w,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Container(
              // أيقونة التنبيه الصغيرة
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18.sp),
            ),
            SizedBox(width: 12.w), // مسافة
            Expanded(
              // نصوص التنبيه
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                      fontFamily: 'Cairo',
                    ),
                  ), // العنوان
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: const Color(0xFF64748B),
                      fontFamily: 'Cairo',
                    ),
                  ), // الوقت
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  // ويدجت بطاقة تعريف الطفل (تصميم Premium)
  final Map<String, dynamic> child; // بيانات الطفل
  final Color primaryBlue, primaryPurple; // الألوان

  const _ChildCard({
    required this.child,
    required this.primaryBlue,
    required this.primaryPurple,
  }); // مشيد البطاقة

  @override // بناء البطاقة
  Widget build(BuildContext context) {
    return Container(
      // الحاوية الرئيسية بتدرج لونى
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, primaryPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ), // تدرج
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ], // ظل بنفسجي مشع
      ),
      child: Row(
        // محتوى البطاقة
        children: [
          Container(
            // الصورة الرمزية (Avatar)
            width: 70.r,
            height: 70.r,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                child['name'][0],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ), // أول حرف
          ),
          SizedBox(width: 20.w), // مسافة
          Expanded(
            // نصوص التعريف
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child['name'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ), // الاسم
                SizedBox(height: 4.h),
                Text(
                  child['grade'],
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13.sp,
                    fontFamily: 'Cairo',
                  ),
                ), // الصف
                Text(
                  'ID: ${child['id']}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11.sp,
                  ),
                ), // رقم التعريف
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayOverview extends StatelessWidget {
  final Map<String, dynamic> selectedChild;
  final Color textDark, textMuted, baseColor;

  const _TodayOverview({
    required this.selectedChild,
    required this.textDark,
    required this.textMuted,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Attendance Card
        _OverviewItem(
          title: 'الحضور والغياب',
          subtitle: 'حاضر • ${selectedChild['arrivalTime']}',
          rightWidget: Container(
            padding: EdgeInsets.all(8.r),
            decoration: const BoxDecoration(
              color: Color(0xFF22C55E),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: Colors.white, size: 18.sp),
          ),
          leftWidget: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: const Color(0xFF22C55E), size: 14.sp),
              ),
              SizedBox(width: 8.w),
              Icon(Icons.chevron_left_rounded, color: textMuted, size: 20.sp),
            ],
          ),
          bottomWidget: Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 6.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    Container(
                      height: 6.h,
                      width: 200.w, // Simulated progress
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7367F0), Color(0xFF22C55E)],
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    Positioned(
                      right: 10.w,
                      top: 0,
                      child: Container(
                        width: 6.r,
                        height: 6.r,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    Text('AM 7:45', style: TextStyle(fontSize: 10.sp, color: textMuted)),
                  ],
                ),
              ],
            ),
          ),
          onTap: () => Navigator.pushNamed(context, '/attendance', arguments: {'child': selectedChild}),
        ),

        // Homework Card
        _OverviewItem(
          title: 'الواجبات المنزلية',
          subtitle: '${selectedChild['homeworkCount']} واجبات معلقة',
          rightWidget: Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.menu_book_rounded, color: const Color(0xFF6366F1), size: 22.sp),
          ),
          leftWidget: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 30.r,
                height: 30.r,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: 0.1, // Simulated progress
                      strokeWidth: 3,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                    ),
                    Text(
                      '0',
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: textDark),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(Icons.chevron_left_rounded, color: textMuted, size: 20.sp),
            ],
          ),
          onTap: () => Navigator.pushNamed(context, '/homework'),
        ),

        // Behavior Card
        _OverviewItem(
          title: 'آخر ملاحظة سلوكية',
          subtitle: 'العمل الجماعي رائع',
          rightWidget: Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: const Color(0xFFFEFCE8),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.thumb_up_alt_rounded, color: const Color(0xFFEAB308), size: 22.sp),
          ),
          leftWidget: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: List.generate(
                    5,
                    (index) => Icon(Icons.star_rounded, color: const Color(0xFFF59E0B), size: 14.sp),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Icon(Icons.chevron_left_rounded, color: textMuted, size: 20.sp),
            ],
          ),
          onTap: () => Navigator.pushNamed(context, '/behavior_report'),
        ),
      ],
    );
  }
}

class _OverviewItem extends StatelessWidget {
  final String title, subtitle;
  final Widget leftWidget, rightWidget;
  final Widget? bottomWidget;
  final VoidCallback? onTap;

  const _OverviewItem({
    required this.title,
    required this.subtitle,
    required this.leftWidget,
    required this.rightWidget,
    this.bottomWidget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28.r), // Softer corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03), // Very subtle shadow
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                rightWidget,
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E293B),
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                leftWidget,
              ],
            ),
            if (bottomWidget != null) bottomWidget!,
          ],
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final Map<String, dynamic> selectedChild;
  final Color textDark;

  const _QuickActionsGrid({
    required this.selectedChild,
    required this.textDark,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 10.w,
      mainAxisSpacing: 16.h,
      childAspectRatio: 0.7,
      children: [
        _buildAction(context, 'السلوك', Icons.report_problem_rounded, const Color(0xFFFF7E21), '/behavior_report'),
        _buildAction(context, 'الرسائل', Icons.chat_bubble_rounded, const Color(0xFF00A36C), '/messages'),
        _buildAction(context, 'الواجبات', Icons.menu_book_rounded, const Color(0xFF9333EA), '/homework'),
        _buildAction(context, 'الحضور', Icons.calendar_today_rounded, const Color(0xFF3B82F6), '/attendance', isAttendance: true),
        _buildAction(context, 'الأنشطة', Icons.camera_alt_rounded, const Color(0xFFE91E63), '/activities'),
        _buildAction(context, 'المصروفات', Icons.credit_card_rounded, const Color(0xFF6366F1), '/fees'),
        _buildAction(context, 'الباص', Icons.directions_bus_rounded, const Color(0xFFF59E0B), '/bus_tracker'),
        _buildAction(context, 'التحليلات', Icons.trending_up_rounded, const Color(0xFF8B5CF6), '/results'),

      ],


    );
  }

  Widget _buildAction(BuildContext context, String title, IconData icon, Color color, String route, {bool isAttendance = false}) {
    return GestureDetector(
      onTap: () {
        if (isAttendance) {
          Navigator.pushNamed(context, route, arguments: {'child': selectedChild});
        } else {
          Navigator.pushNamed(context, route, arguments: selectedChild);
        }
      },
      child: Column(
        children: [
          Container(
            width: 58.r,
            height: 58.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
              color: textDark,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),

    );
  }
}




class _DashboardBottomNav extends StatelessWidget {
  // ويدجت شريط التنقل السفلي المخصص (معزول)
  final int currentIndex; // المؤشر الحالى
  final ValueChanged<int> onTap; // دالة التغيير
  final Color primaryBlue, primaryPurple, baseColor, textMuted; // الألوان

  const _DashboardBottomNav({
    // مشيد شريط التنقل
    required this.currentIndex,
    required this.onTap,
    required this.primaryBlue,
    required this.primaryPurple,
    required this.baseColor,
    required this.textMuted,
  });

  @override // بناء شريط التنقل
  Widget build(BuildContext context) {
    return Container(
      // الحاوية الأساسية للشريط
      height: 55.h,
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        color: Colors.white, // العودة للون الأبيض بناءً على طلب المستخدم
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ], // ظل علوى خفيف
      ),
      child: Row(
        // توزيع الأزرار بالتساوي
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_rounded, 'الرئيسية'),
          _buildNavItem(1, Icons.menu_book_rounded, 'الواجبات'),
          _buildNavItem(2, Icons.calendar_today_rounded, 'الجدول'),
          _buildNavItem(3, Icons.add_task_rounded, 'مهمة'),
          _buildNavItem(4, Icons.chat_bubble_rounded, 'الرسائل'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    // دالة بناء زر تنقل واحد
    final active = currentIndex == index; // هل الزر هو الحالى؟
    return GestureDetector(
      // كاشف الضغط
      onTap: () {
        HapticFeedback.lightImpact();
        onTap(index);
      },
      child: AnimatedContainer(
        // حاوية متحركة للتفاعل البصرى
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutQuart,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(colors: [primaryBlue, primaryPurple])
              : null, // تدرج للنشط
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: primaryPurple.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null, // ظل للنشط
        ),
        child: Column(
          // محتوى الزر (أيقونة واسم)
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? Colors.white : textMuted.withValues(alpha: 0.6),
              size: 22.sp,
            ), // الأيقونة
            if (active) ...[
              // إظهار الاسم فقط للزر النشط لتوفير المساحة
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ), // الاسم
            ],
          ],
        ),
      ),
    );
  }
}

class _DashboardDrawer extends StatelessWidget {
  // ويدجت القائمة الجانبية (معزول لتحسين أداء الفتح والغلق)
  final Color baseColor,
      primaryBlue,
      primaryPurple,
      textDark,
      textMuted,
      absentColor; // الألوان

  const _DashboardDrawer({
    // مشيد القائمة الجانبية
    required this.baseColor,
    required this.primaryBlue,
    required this.primaryPurple,
    required this.textDark,
    required this.textMuted,
    required this.absentColor,
  });

  @override // بناء القائمة الجانبية
  Widget build(BuildContext context) {
    return Drawer(
      // ويدجت الدرج
      backgroundColor: baseColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(30.r)),
      ), // حواف دائرية
      child: Column(
        // ترتيب المحتوى رأسيًا
        children: [
          _buildDrawerHeader(), // ترويسة الدرج
          Expanded(
            // القائمة القابلة للتمرير
            child: ListView(
              padding: EdgeInsets.all(20.r),
              children: [
                _buildDrawerItem(
                  Icons.person_outline_rounded,
                  'إعدادات الحساب',
                  primaryBlue,
                  onTap: () {},
                ),
                _buildDrawerItem(
                  Icons.notifications_none_rounded,
                  'الإشعارات',
                  Colors.orange,
                  onTap: () {},
                ),
                _buildDrawerItem(
                  Icons.language_rounded,
                  'اللغة والمظهر',
                  Colors.green,
                  onTap: () {},
                ),
                _buildDrawerItem(
                  Icons.security_outlined,
                  'الخصوصية والأمان',
                  textDark,
                  onTap: () {},
                ),
                _buildDrawerItem(
                  Icons.auto_stories_rounded,
                  'الكتب السلوكية',
                  const Color(0xFF0D9488),
                  onTap: () => Navigator.pushNamed(context, '/behavioral_books'),
                ),
                _buildDrawerItem(
                  Icons.person_pin_rounded,
                  'استشارة سلوكية',
                  primaryPurple,
                  onTap: () => Navigator.pushNamed(context, '/behavioral_consultation'),
                ),
                SizedBox(height: 40.h),
                _buildDrawerItem(
                  Icons.logout_rounded,
                  'تسجيل الخروج',
                  absentColor,
                  isLogout: true,
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                ), // تسجيل الخروج
              ],
            ),
          ),
          Padding(
            // رقم الإصدار فى الأسفل
            padding: EdgeInsets.all(20.r),
            child: Text(
              'Wesal v1.0.4',
              style: TextStyle(color: textMuted, fontSize: 10.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    // بناء ترويسة الدرج بتصميم جذاب
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 30.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryBlue, primaryPurple]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40.r)),
      ),
      child: Row(
        children: [
          Expanded(
            // نصوص بيانات المستخدم
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'سارة محمد',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  'sarah@wesal.edu',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          Container(
            // أيقونة المستخدم البيضاء
            width: 60.r,
            height: 60.r,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_rounded, color: Colors.white, size: 35.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String label,
    Color color, {
    bool isLogout = false,
    required VoidCallback onTap,
  }) {
    // بناء عنصر واحد فى قائمة الدرج
    return Container(
      // حاوية العنصر بتصميم Neumorphic متناسق
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          const BoxShadow(
            color: Colors.white,
            blurRadius: 8,
            offset: Offset(-4, -4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color, size: 22.sp),
        title: Text(
          label,
          style: TextStyle(
            color: isLogout ? absentColor : textDark,
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
        trailing: const Icon(
          Icons.chevron_left_rounded,
          color: Color(0xFF64748B),
          size: 20,
        ), // سهم الانتقال
      ),
    );
  }
}

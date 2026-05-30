/*
🧠 اسم الملف: teacher_dashboard.dart

📌 بيعمل إيه؟
دي اللوحة الرئيسية للمدرس، بيقدر منها يتابع الفصول بتاعته، يسجل الغياب، ويبعت تقارير للطلاب.

👤 موجه لمين؟
- مدرسين

💡 فكرته:
تسهيل الإدارة الصفية والمتابعة اليومية للطلاب في مكان واحد منظم.
*/

import 'dart:convert';
import 'package:flutter/material.dart'; // استيراد مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة التحكم في أحجام الشاشة
import 'package:flutter/services.dart'; // استيراد مكتبة الهابتيك والخدمات
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/api_config.dart';
import 'teacher_attendance_screen.dart';
import 'teacher_add_assignment_screen.dart'; // استيراد شاشة إضافة واجب جديد
import 'teacher_behavior_report_screen.dart'; // استيراد شاشة تقارير سلوك الطلاب
import 'teacher_messages_screen.dart'; // استيراد شاشة الرسائل والدردشة
import 'teacher_add_task_screen.dart'; // استيراد شاشة إضافة مهام للطلاب
import 'teacher_daily_report_screen.dart'; // استيراد شاشة التقرير اليومي
import '../../widgets/wesal_background.dart';

class TeacherDashboard extends StatefulWidget {
  // تعريف كلاس لوحة تحكم المعلم كـ StatefulWidget
  const TeacherDashboard({super.key}); // مشيد الكلاس
  @override // إنشاء حالة الشاشة
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  // كلاس حالة لوحة تحكم المعلم
  int _currentIndex =
      0; // متغير لتحديد التبويب المختار حالياً في شريط التنقل السفلي
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<
        ScaffoldState
      >(); // مفتاح للتحكم في حالة الـ Scaffold (لفتح الدرج الجانبي)

  // ── Design tokens – same as Login screen ───────────────────────────────────
  static const Color primaryBlue = Color(0xFF2563EB); // اللون الأزرق الأساسي
  static const Color primaryPurple = Color(
    0xFF9333EA,
  ); // اللون البنفسجي الأساسي
  static const Color baseColor = Color(
    0xFFF0F3F8,
  ); // لون الخلفية الرمادي الفاتح
  static const Color textDark = Color(0xFF1E293B); // لون النص الداكن
  static const Color textMuted = Color(0xFF64748B); // لون النص الباهت

  static const Color presentColor = Color(0xFF22C55E); // لون حالة الحضور (أخضر)
  static const Color absentColor = Color(0xFFEF4444); // لون حالة الغياب (أحمر)
  static const Color lateColor = Color(
    0xFFF59E0B,
  ); // لون حالة التأخير (برتقالي)

  // ── API-loaded state ────────────────────────────────────────────────────────
  String _teacherName  = '';
  String _teacherEmail = '';
  String _teacherTitle = '';
  String _firstClassName   = '';
  String _firstSubjectName = '';
  int    _totalStudents = 0;
  int    _absentToday   = 0;
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('mobile_token') ?? '';
      if (token.isEmpty) return;

      final base = ApiConfig.getBaseUrl();
      final headers = {'Authorization': 'Bearer $token'};

      final results = await Future.wait([
        http.get(Uri.parse('$base/teachers/mobile/dashboard'), headers: headers)
            .timeout(const Duration(seconds: 15)),
        http.get(Uri.parse('$base/teachers/mobile/classes'), headers: headers)
            .timeout(const Duration(seconds: 15)),
      ]);

      if (!mounted) return;

      // Dashboard profile + stats
      if (results[0].statusCode == 200) {
        final d = (jsonDecode(results[0].body)['data'] as Map<String, dynamic>);
        final profile = d['profile'] as Map<String, dynamic>? ?? {};
        final stats   = d['stats']   as Map<String, dynamic>? ?? {};
        setState(() {
          _teacherName  = profile['fullName'] as String? ?? '';
          _teacherEmail = profile['email']    as String? ?? '';
          _teacherTitle = profile['jobTitle'] as String? ?? 'معلم';
          _totalStudents = (stats['totalStudents'] as num?)?.toInt() ?? 0;
          _absentToday   = (stats['absentStudents'] as num?)?.toInt() ?? 0;
        });
      }

      // Classes + students
      if (results[1].statusCode == 200) {
        final classes = (jsonDecode(results[1].body)['data'] as List? ?? [])
            .cast<Map<String, dynamic>>();
        if (classes.isNotEmpty) {
          final first = classes.first;
          final studs = (first['students'] as List? ?? [])
              .cast<Map<String, dynamic>>();
          setState(() {
            _firstClassName   = first['name']    as String? ?? '';
            _firstSubjectName = first['subject'] as String? ?? '';
            _students = studs.map((s) => {
              'name':        s['name'] ?? 'طالب',
              'class':       first['name'] ?? '',
              'isPresent':   true,
              'performance': 'جيد',
            }).toList();
          });
        }
      }
    } catch (_) {}
  }

  List<Map<String, dynamic>> get _displayStudents =>
      _students.isNotEmpty ? _students : _mockStudents;

  // ── Helpers ─────────────────────────────────────────────────────────────────
  /// Lightweight shadow pair for Neumorphic "raised" effect
  List<BoxShadow> get _raiseShadow => [
    // دالة للحصول على تأثير الظل المرتفع Neumorphic
    const BoxShadow(
      color: Colors.white,
      blurRadius: 10,
      offset: Offset(-5, -5),
    ), // ظل إضاءة علوي
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 10,
      offset: const Offset(5, 5),
    ), // ظل عمق سفلي
  ];

  @override // دالة بناء واجهة الشاشة
  Widget build(BuildContext context) {
    return PopScope(
      // التحكم في زر الرجوع بالخلف لمنع الخروج المفاجئ
      canPop: false,
      child: Directionality(
        // تحديد اتجاه النصوص للعربية
        textDirection: TextDirection.rtl,
        child: Scaffold(
          // هيكل الصفحة
          key: _scaffoldKey, // ربط المفتاح
          backgroundColor: Colors.transparent, // جعل خلفية السكافولد شفافة لرؤية الخلفية الموحدة
          drawer: _buildDrawer(), // بناء الدرج الجانبي (Drawer)
          body: WesalBackground(
            child: RepaintBoundary(
              // تحسين أداء الرسم
              child: IndexedStack(
                // مكدس لعرض الشاشات بناءً على التبويب المختار مع الحفاظ على حالتها
                index: _currentIndex,
                children: [
                  RepaintBoundary(child: _buildHomeTab()), // تبويب الرئيسية
                  const RepaintBoundary(
                    child: TeacherAddAssignmentScreen(isTab: true),
                  ), // تبويب الواجبات
                  const RepaintBoundary(
                    child: TeacherMessagesScreen(isTab: true),
                  ), // تبويب الرسائل
                  const RepaintBoundary(
                    child: TeacherBehaviorReportScreen(isTab: true),
                  ), // تبويب السلوك
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomNav(), // بناء شريط التنقل السفلي
        ),
      ),
    );
  }

  // ── Home Tab ─────────────────────────────────────────────────────────────────
  Widget _buildHomeTab() {
    // دالة بناء محتوى تبويب الرئيسية
    return SafeArea(
      // حماية المحتوى من الحواف
      child: CustomScrollView(
        // قائمة تمرير مخصصة
        physics: const BouncingScrollPhysics(), // تأثير الارتداد
        slivers: [
          // 1. Header (no logout / dark-mode icon)
          SliverToBoxAdapter(
            // ترويسة الصفحة
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: _buildHeader(),
            ),
          ),

          // 2. Purple Class Card (matching screenshot exactly)
          SliverToBoxAdapter(
            // بطاقة الفصل الأرجوانية الكبيرة
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
              child: _buildClassCard3D(),
            ),
          ),

          // 3. كروت الحضور (حاضر / غائب / متأخر)
          SliverToBoxAdapter(
            // صف إحصائيات الحضور السريعة
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: _buildStatusRow(),
            ),
          ),

          // 4. الإجراءات السريعة
          SliverToBoxAdapter(
            // عنوان قسم الإجراءات السريعة
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 12.h),
              child: Text(
                'الإجراءات السريعة',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            // شبكة أزرار الإجراءات السريعة
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildQuickActionsGrid(),
            ),
          ),

          // 5. Today's Students
          SliverToBoxAdapter(
            // عنوان قسم قائمة الطلاب
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 12.h),
              child: _buildSectionHeader('طلاب اليوم', 'عرض الكل'),
            ),
          ),
          SliverPadding(
            // قائمة عرض الطلاب الفردية
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) =>
                    _buildStudentCard(_displayStudents[i]),
                childCount: _displayStudents.length,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(height: 120.h),
          ), // مسافة سفلية إضافية للتمرير خلف شريط التنقل
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    // دالة بناء ترويسة الصفحة (الصورة الشخصية والاسم والتنبيهات)
    return Row(
      children: [
        // 3D avatar circle (Clickable to open Drawer)
        GestureDetector(
          onTap: () => _scaffoldKey.currentState
              ?.openDrawer(), // فتح الدرج الجانبي عند الضغط على الصورة
          child: RepaintBoundary(
            child: Container(
              padding: EdgeInsets.all(3.r),
              decoration: BoxDecoration(
                color: baseColor,
                shape: BoxShape.circle,
                boxShadow: _raiseShadow,
              ),
              child: CircleAvatar(
                // صورة المعلم الرمزية
                radius: 28.r,
                backgroundColor: primaryPurple.withValues(alpha: 0.1),
                child: Icon(
                  Icons.person_rounded,
                  color: primaryPurple,
                  size: 30.sp,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 14.w), // مسافة أفقية
        Expanded(
          // اسم المعلم وتخصصه
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _teacherName.isNotEmpty ? _teacherName : 'المعلم',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                  fontFamily: 'Cairo',
                ),
              ),
              Text(
                _teacherTitle.isNotEmpty ? _teacherTitle : 'معلم',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: textMuted,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
        // 3D Notification Icon with Dropdown
        _buildNotificationIcon(), // بناء أيقونة التنبيهات مع القائمة المنبثقة
      ],
    );
  }

  Widget _buildNotificationIcon() {
    // دالة بناء أيقونة التنبيهات وقائمة التنبيهات المنسدلة
    return PopupMenuButton<String>(
      offset: Offset(0, 50.h), // إزاحة القائمة للأسفل
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      color: baseColor,
      elevation: 8,
      onSelected: (val) {},
      child: Container(
        // تصميم زر التنبيهات الدائري
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: baseColor,
          shape: BoxShape.circle,
          boxShadow: _raiseShadow,
        ),
        child: Stack(
          // استخدام Stack لإضافة نقطة حمراء عند وجود تنبيهات
          children: [
            Icon(
              Icons.notifications_none_rounded,
              color: primaryPurple,
              size: 24.sp,
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8.r,
                height: 8.r,
                decoration: const BoxDecoration(
                  color: absentColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        // محتويات قائمة التنبيهات التجريبية
        _buildPopupItem(
          'إشعار جديد: تم تسليم واجب',
          'منذ 5 دقائق',
          Icons.assignment_turned_in_rounded,
          primaryBlue,
        ),
        _buildPopupItem(
          'ولي أمر أحمد محمد أرسل رسالة',
          'منذ ساعة',
          Icons.chat_bubble_outline_rounded,
          primaryPurple,
        ),
        _buildPopupItem(
          'تنبيه: موعد الاجتماع غداً',
          'منذ 3 ساعات',
          Icons.info_outline_rounded,
          lateColor,
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
    // دالة بناء عنصر فردي في قائمة التنبيهات
    return PopupMenuItem(
      child: Container(
        width: 250.w,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Container(
              // أيقونة التنبيه مع لون خلفية خفيف
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              // نصوص التنبيه ووقت حدوثه
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: textMuted,
                      fontFamily: 'Cairo',
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

  // ── Purple Class Card ────────────────────────────────────────────────────────
  Widget _buildClassCard3D() {
    // دالة بناء بطاقة الفصل الأساسية بتصميم ثلاثي الأبعاد وتدرج لوني
    return Container(
      padding: EdgeInsets.all(4.r), // إطار خارجي للتأثير ثلاثي الأبعاد
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: _raiseShadow,
      ),
      child: Container(
        padding: EdgeInsets.all(22.r),
        decoration: BoxDecoration(
          // التدرج اللوني الأساسي للبطاقة
          gradient: const LinearGradient(
            colors: [primaryBlue, primaryPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: primaryPurple.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              // معلومات الفصل والمادة وأيقونة المجموعة
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _firstClassName.isNotEmpty ? _firstClassName : 'الفصل',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    Text(
                      _firstSubjectName.isNotEmpty ? _firstSubjectName : 'المادة',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.group_rounded,
                    color: Colors.white,
                    size: 26.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 28.h),
            // Divider row of stats
            Row(
              // إحصائيات سريعة للطلاب والحضور داخل البطاقة
              children: [
                _buildCardStat('إجمالي الطلاب', _totalStudents > 0 ? '$_totalStudents' : '-'),
                Container(
                  width: 1,
                  height: 44.h,
                  color: Colors.white.withValues(alpha: 0.3),
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                ),
                _buildCardStat('غياب اليوم', '$_absentToday'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardStat(String label, String value) {
    // دالة بناء عنصر إحصائي فردي داخل البطاقة
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Outfit',
          ),
        ),
      ],
    );
  }

  // ── Status Row ───────────────────────────────────────────────────────────────
  Widget _buildStatusRow() {
    // دالة بناء صف بطاقات حالة الحضور اليومية
    return Row(
      children: [
        _buildStatusCard(
          Icons.check_circle_outline_rounded,
          '3',
          'حاضر',
          presentColor,
        ),
        SizedBox(width: 12.w),
        _buildStatusCard(Icons.cancel_outlined, '1', 'غائب', absentColor),
        SizedBox(width: 12.w),
        _buildStatusCard(Icons.access_time_rounded, '1', 'متأخر', lateColor),
      ],
    );
  }

  Widget _buildStatusCard(
    IconData icon,
    String count,
    String label,
    Color color,
  ) {
    // دالة بناء بطاقة حالة فردية (حاضر/غائب/متأخر)
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18.h),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: color.withValues(alpha: 0.12), width: 1.5),
          boxShadow: _raiseShadow,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22.sp),
            SizedBox(height: 10.h),
            Text(
              count,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: textDark,
                fontFamily: 'Outfit',
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11.sp, color: textMuted),
            ),
          ],
        ),
      ),
    );
  }

  // ── Quick Actions title ─────────────────────────────────────────────────────
  Widget _buildQuickActionsGrid() {
    // دالة بناء شبكة الإجراءات السريعة للمعلم
    final actions = [
      _QuickAction(
        'تسجيل\nالحضور',
        Icons.check_circle_outline_rounded,
        const Color(0xFF22C55E),
        () => _push(const TeacherAttendanceScreen()),
      ),
      _QuickAction(
        'إضافة\nواجب',
        Icons.menu_book_rounded,
        const Color(0xFF9333EA),
        () => _push(const TeacherAddAssignmentScreen()),
      ),
      _QuickAction(
        'تقرير\nالسلوك',
        Icons.warning_amber_rounded,
        const Color(0xFFEF4444),
        () => _push(const TeacherBehaviorReportScreen()),
      ),
      _QuickAction(
        'الرسائل',
        Icons.chat_bubble_outline_rounded,
        const Color(0xFF2563EB),
        () => _push(const TeacherMessagesScreen()),
      ),
      _QuickAction(
        'التقرير اليومي',
        Icons.description_outlined,
        const Color(0xFF6366F1),
        () => _push(const TeacherDailyReportScreen()),
      ),
      _QuickAction(
        'مهمة',
        Icons.assignment_rounded,
        const Color(0xFF06B6D4),
        () => _push(const TeacherAddTaskScreen()),
      ),
    ];

    return GridView.count(
      // عرض الأيقونات في شبكة مكونة من 3 أعمدة
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // منع التمرير الخاص بالشبكة لاستخدام تمرير الصفحة الكلي
      crossAxisCount: 3,
      mainAxisSpacing: 20.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 0.95,
      children: actions.map(_buildActionCell).toList(),
    );
  }

  Widget _buildActionCell(_QuickAction a) {
    // دالة بناء خلية فردية للإجراء السريع
    return GestureDetector(
      onTap: a.onTap, // تنفيذ الوظيفة عند الضغط
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            // تصميم الحاوية الملونة للأيقونة
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [a.color, a.color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: a.color.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(a.icon, color: Colors.white, size: 24.sp),
          ),
          SizedBox(height: 10.h),
          Text(
            // اسم الإجراء تحت الأيقونة
            a.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: textDark,
              height: 1.3,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  // ── Today's Students ─────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, String action) {
    // دالة بناء ترويسة أي قسم (مثل طلاب اليوم)
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
            color: textDark,
          ),
        ),
        Text(
          action,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: primaryPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> s) {
    // دالة بناء بطاقة عرض بيانات الطالب في القائمة
    final bool present = s['isPresent'] as bool; // جلب حالة الحضور
    final Color statusColor = present ? presentColor : absentColor;
    final IconData statusIcon = present
        ? Icons.check_circle_outline_rounded
        : Icons.cancel_outlined;
    final String statusLabel = present ? 'حاضر' : 'غائب';
    final String perfLabel = s['performance'] as String; // جلب تقييم الأداء
    final Color perfColor = _perfColor(perfLabel);

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: _raiseShadow,
      ),
      child: Row(
        children: [
          // Avatar with 3D ring
          Container(
            // صورة الطالب مع إطار ثلاثي الأبعاد
            padding: EdgeInsets.all(2.r),
            decoration: BoxDecoration(
              color: baseColor,
              shape: BoxShape.circle,
              boxShadow: _raiseShadow,
            ),
            child: CircleAvatar(
              radius: 24.r,
              backgroundColor: primaryPurple.withValues(alpha: 0.15),
              child: Text(
                s['name'].toString()[0], // أول حرف من اسم الطالب
                style: TextStyle(
                  color: primaryPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            // اسم الطالب وفصله الدراسي
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s['name'].toString(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  s['class'].toString(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: textMuted,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          Column(
            // ملصقات الحالة والأداء بجانب الاسم
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildTag(statusLabel, statusColor, icon: statusIcon),
              SizedBox(height: 6.h),
              _buildTag(perfLabel, perfColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color, {IconData? icon}) {
    // دالة بناء ملصق نصي ملون (Tag)
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11.sp, color: color),
            SizedBox(width: 3.w),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _perfColor(String p) {
    // دالة لتحديد لون ملصق الأداء بناءً على النص
    if (p == 'ممتاز') return presentColor;
    if (p == 'جيد') return primaryBlue;
    if (p == 'يحتاج اهتمام') return lateColor;
    return textMuted;
  }

  // ── Bottom Navigation (Gradient on Active) ───────────────────────────────────
  Widget _buildBottomNav() {
    // دالة بناء شريط التنقل السفلي المخصص
    return Container(
      height: 55.h,
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_rounded, 'الرئيسية'),
          _buildNavItem(1, Icons.menu_book_rounded, 'الواجبات'),
          _buildNavItem(2, Icons.chat_bubble_rounded, 'الرسائل'),
          _buildNavItem(3, Icons.warning_amber_rounded, 'السلوك'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    // دالة بناء عنصر فردي في شريط التنقل السفلي
    final bool active =
        _currentIndex == index; // هل هذا العنصر هو النشط حالياً؟
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _currentIndex = index);
      }, // تحديث الصفحة المعروضة عند الضغط مع هابتيك
      child: AnimatedContainer(
        // حاوية متحركة تبرز التبويب المختار بتدرج لوني
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutQuart,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
        decoration: BoxDecoration(
          // Active item gets the login-button gradient background
          gradient: active
              ? const LinearGradient(
                  colors: [primaryBlue, primaryPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: active ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: primaryPurple.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? Colors.white : textMuted, size: 24.sp),
            if (active) ...[
              // إظهار الاسم فقط عندما يكون التبويب نشطاً
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Drawer ──────────────────────────────────────────────────────────────────
  Widget _buildDrawer() {
    // دالة بناء الدرج الجانبي (Drawer) الذي يحتوي على الإعدادات
    return Drawer(
      backgroundColor: baseColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(30.r)),
      ),
      child: Column(
        children: [
          _buildDrawerHeader(), // ترويسة الدرج الجانبي
          Expanded(
            child: ListView(
              // قائمة خيارات الدرج الجانبي
              padding: EdgeInsets.all(20.r),
              children: [
                _buildDrawerItem(
                  Icons.person_outline_rounded,
                  'إعدادات الحساب',
                  primaryBlue,
                  onTap: _showChangePasswordDialog,
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
                  presentColor,
                  onTap: () {},
                ),
                _buildDrawerItem(
                  Icons.security_outlined,
                  'الخصوصية والأمان',
                  textDark,
                  onTap: () {},
                ),
                SizedBox(height: 40.h),
                _buildDrawerItem(
                  Icons.logout_rounded,
                  'تسجيل الخروج',
                  absentColor,
                  isLogout: true,
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                ),
              ],
            ),
          ),
          Padding(
            // إصدار التطبيق في أسفل الدرج الجانبي
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
    // دالة بناء ترويسة الدرج الجانبي مع اسم المعلم وإيميله
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 30.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [primaryBlue, primaryPurple]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40.r)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _teacherName.isNotEmpty ? _teacherName : 'المعلم',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  _teacherEmail.isNotEmpty ? _teacherEmail : '',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          Container(
            // أيقونة المستخدم الرمزية داخل الدرج
            width: 70.r,
            height: 70.r,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_rounded, color: Colors.white, size: 45.sp),
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
    // دالة بناء خيار فردي في قائمة الدرج الجانبي
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: _raiseShadow,
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
        trailing: Icon(
          Icons.chevron_left_rounded,
          color: textMuted,
          size: 20.sp,
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    // دالة لإظهار نافذة تغيير كلمة المرور من الأسفل
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        // الحاوية الرئيسية للنافذة مع إزاحة للوحة المفاتيح
        padding: EdgeInsets.fromLTRB(
          24.w,
          24.h,
          24.w,
          MediaQuery.of(context).viewInsets.bottom + 40.h,
        ),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: textMuted.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              // عنوان النافذة المنبثقة
              children: [
                Icon(
                  Icons.lock_reset_rounded,
                  color: primaryPurple,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'تغيير كلمة المرور',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: textDark,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h), // حقول الإدخال لكلمة المرور
            _buildDialogField(
              'كلمة المرور الحالية',
              Icons.lock_outline_rounded,
              true,
            ),
            SizedBox(height: 16.h),
            _buildDialogField(
              'كلمة المرور الجديدة',
              Icons.lock_open_rounded,
              true,
            ),
            SizedBox(height: 16.h),
            _buildDialogField(
              'تأكيد كلمة المرور',
              Icons.check_circle_outline_rounded,
              true,
            ),
            SizedBox(height: 32.h),
            GestureDetector(
              // زر حفظ التغييرات
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'تم تغيير كلمة المرور بنجاح',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                    backgroundColor: presentColor,
                  ),
                );
              },
              child: Container(
                height: 56.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryBlue, primaryPurple],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: const Center(
                  child: Text(
                    'حفظ التغييرات',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogField(String hint, IconData icon, bool isPass) {
    // دالة بناء حقل إدخال داخل النوافذ المنبثقة
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: _raiseShadow,
      ),
      child: TextField(
        obscureText: isPass, // إخفاء النص لبيانات كلمة المرور
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: textMuted,
            fontSize: 13.sp,
            fontFamily: 'Cairo',
          ),
          prefixIcon: Icon(icon, color: primaryPurple, size: 18),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  void _push(Widget screen) => // دالة مساعدة للانتقال لشاشة جديدة
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  // Mock data
  final _mockStudents = [
    // بيانات تجريبية لقائمة الطلاب
    {
      'name': 'عمر محمود',
      'class': '5-أ',
      'isPresent': true,
      'performance': 'ممتاز',
    },
    {
      'name': 'سارة أحمد',
      'class': '5-أ',
      'isPresent': true,
      'performance': 'جيد',
    },
    {
      'name': 'أدهم سمير',
      'class': '5-أ',
      'isPresent': false,
      'performance': 'يحتاج اهتمام',
    },
    {
      'name': 'ليلى حسن',
      'class': '5-أ',
      'isPresent': true,
      'performance': 'ممتاز',
    },
  ];
}

// ── Data class for Quick Actions ─────────────────────────────────────────────
class _QuickAction {
  // كلاس بيانات بسيط لتعريف الإجراءات السريعة
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(this.label, this.icon, this.color, this.onTap);
}

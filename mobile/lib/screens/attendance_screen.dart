/*
🧠 اسم الملف: attendance_screen.dart

📌 بيعمل إيه؟
دي شاشة بتعرض سجل الحضور والغياب بتاع الطالب، وكمان الجدول الدراسي بتاعه عشان يعرف حصصه امتى.

👤 موجه لمين؟
- أولياء أمور / طلاب

💡 فكرته:
بيساعد ولي الأمر يطمن على حضور ابنه ويتابع جدوله اليومي بسهولة.
*/

// شاشة عرض تفاصيل حضور وغياب وتأخير الطالب، بالإضافة للجدول الزمني
import 'package:flutter/material.dart'; // استيراد مكتبة فلاتر الأساسية
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة أحجام الشاشة
import 'package:wesal/core/theme/app_theme.dart'; // استيراد ثيم التطبيق
import '../widgets/wesal_background.dart';

class AttendanceScreen extends StatefulWidget { // تعريف كلاس شاشة الحضور
  final int initialIndex; // المؤشر الأولي للتبويب
  final bool isSingleMode; // هل الشاشة في وضع عرض تبويب واحد فقط؟
  final Map<String, dynamic>? childData; // بيانات الطفل الممررة
  const AttendanceScreen({
    super.key,
    this.initialIndex = 0,
    this.isSingleMode = false,
    this.childData,
  });

  @override // إنشاء الحالة
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with TickerProviderStateMixin { // استخدام Ticker للتحكم في التبويبات
  late TabController _tabController; // متحكم التبويبات
  final List<String> _weekDays = ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس']; // أيام الأسبوع
  int _selectedDayIndex = 0; // اليوم المختار في الجدول

  // جلب بيانات الجدول بناءً على اليوم المختار
  Map<int, List<Map<String, dynamic>>> get _schedulesByDay {
    if (widget.childData != null && widget.childData!['schedule'] != null) {
      return widget.childData!['schedule'] as Map<int, List<Map<String, dynamic>>>;
    }
    return { // بيانات افتراضية في حال عدم توفر بيانات ممررة
      0: [
        {'time': '08:00 ص', 'subject': 'الرياضيات', 'teacher': 'أ/ محمد علي', 'room': 'فصل A', 'color': AppTheme.royalBlue},
        {'time': '09:30 ص', 'subject': 'اللغة العربية', 'teacher': 'أستاذة/ سارة', 'room': 'فصل B', 'color': AppTheme.emeraldGreen},
      ],
    };
  }

  // جلب سجلات الحضور
  List<Map<String, dynamic>> get _allLogs {
    if (widget.childData != null && widget.childData!['attendanceLogs'] != null) {
      return List<Map<String, dynamic>>.from(widget.childData!['attendanceLogs']);
    }
    return [ // سجلات افتراضية
      {'date': 'الخميس، 12 مارس', 'time': '7:45 ص', 'status': 'حاضر', 'statusColor': const Color(0xFF22C55E), 'icon': Icons.check_circle_outline_rounded},
      {'date': 'الأربعاء، 11 مارس', 'time': '7:42 ص', 'status': 'حاضر', 'statusColor': const Color(0xFF22C55E), 'icon': Icons.check_circle_outline_rounded},
      {'date': 'الثلاثاء، 10 مارس', 'time': '8:15 ص', 'status': 'متأخر', 'statusColor': const Color(0xFFF59E0B), 'icon': Icons.access_time_rounded},
      {'date': 'الأحد، 8 مارس', 'time': '-', 'status': 'غائب', 'statusColor': const Color(0xFFEF4444), 'icon': Icons.cancel_outlined},
    ];
  }

  @override // تهيئة الحالة
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialIndex); // إعداد المتحكم
  }

  @override // التخلص من الموارد
  void dispose() {
    _tabController.dispose(); // إغلاق متحكم التبويبات لتوفير الذاكرة
    super.dispose();
  }

  @override // بناء الواجهة
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // تحديد الاتجاه للعربية
      child: WesalBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent, // جعل الخلفية شفافة لرؤية الصورة الموحدة
          body: SafeArea(
            child: Column(
              children: [
                _buildCustomAppBar(), // بناء الترويسة المخصصة
                if (!widget.isSingleMode) _buildTabBar(), // بناء شريط التبويبات إذا لم يكن وضعاً منفرداً
                Expanded(
                  child: widget.isSingleMode // عرض المحتوى بناءً على الوضع المختار
                      ? (widget.initialIndex == 0 ? _buildScheduleTab() : _buildAttendanceTab())
                      : TabBarView(
                          physics: const ClampingScrollPhysics(), // منع التمرير الزائد
                          controller: _tabController,
                          children: [_buildScheduleTab(), _buildAttendanceTab()],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() { // بناء ترويسة الصفحة مع زر الرجوع
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector( // زر الرجوع
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                  child: Icon(Icons.arrow_back_ios_rounded, color: const Color(0xFF1E293B), size: 18.sp),
                ),
              ),
              const Icon(Icons.notifications_none_rounded, color: Color(0xFF1E293B)), // أيقونة التنبيهات
            ],
          ),
          SizedBox(height: 24.h),
          Text('الحضور', style: TextStyle(color: const Color(0xFF1E293B), fontSize: 28.sp, fontWeight: FontWeight.w900, fontFamily: 'Cairo')), // العنوان الرئيسي
          Text('تتبع حضور طفلك وانضباطه', style: TextStyle(color: const Color(0xFF64748B), fontSize: 14.sp, fontFamily: 'Cairo')), // وصف فرعي
        ],
      ),
    );
  }

  Widget _buildTabBar() { // بناء شريط التبديل بين الجدول والحضور
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(16.r)),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, fontFamily: 'Cairo'),
        unselectedLabelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF64748B),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: const Color(0xFF2563EB), // اللون الأزرق للمؤشر النشط
          boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        tabs: const [Tab(text: 'جدول الحصص'), Tab(text: 'الحضور والغياب')], // أسماء التبويبات
      ),
    );
  }

  Widget _buildScheduleTab() { // محتوى تبويب الجدول الدراسي
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeekSelector(), // اختيار يوم الأسبوع
          SizedBox(height: 32.h),
          _buildDayScheduleList(), // قائمة حصص اليوم المختار
        ],
      ),
    );
  }

  Widget _buildWeekSelector() { // شريط اختيار أيام الأسبوع
    return SizedBox(
      height: 90.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _weekDays.length,
        itemBuilder: (context, index) {
          bool isSel = _selectedDayIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = index), // تحديث اليوم المختار
            child: AnimatedContainer( // حاوية متحركة لليوم
              duration: const Duration(milliseconds: 300),
              width: 100.w,
              margin: EdgeInsets.only(left: 12.w),
              decoration: BoxDecoration(
                color: isSel ? const Color(0xFF2563EB) : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_weekDays[index], style: TextStyle(color: isSel ? Colors.white70 : const Color(0xFF64748B), fontSize: 12.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo')), // اسم اليوم
                  SizedBox(height: 4.h),
                  Text((11 + index).toString(), style: TextStyle(color: isSel ? Colors.white : const Color(0xFF1E293B), fontSize: 18.sp, fontWeight: FontWeight.w900, fontFamily: 'Cairo')), // تاريخ افتراضي
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayScheduleList() { // بناء قائمة الحصص
    final schedule = _schedulesByDay[_selectedDayIndex] ?? []; // جلب حصص اليوم
    if (schedule.isEmpty) {
      return Center(child: Padding(padding: EdgeInsets.only(top: 40.h), child: Text('لا يوجد حصص مخصصة لهذا اليوم', style: TextStyle(color: const Color(0xFF64748B), fontSize: 14.sp, fontFamily: 'Cairo'))));
    }
    return Column(children: schedule.map((item) => _buildScheduleItem(item)).toList()); // عرض الحصص كقائمة
  }

  Widget _buildScheduleItem(Map<String, dynamic> item) { // بناء بطاقة الحصة الواحدة
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          Column( // عرض الوقت
            children: [
              Text(item['time'].split(' ')[0], style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B))),
              Text(item['time'].split(' ')[1], style: TextStyle(fontSize: 10.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(width: 20.w),
          Container(width: 4.w, height: 40.h, decoration: BoxDecoration(color: item['color'] as Color, borderRadius: BorderRadius.circular(2.r))), // خط جانبي ملون حسب المادة
          SizedBox(width: 20.w),
          Expanded( // عرض المادة والمدرس
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['subject'] as String, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B), fontFamily: 'Cairo')),
                Text(item['teacher'] as String, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B), fontFamily: 'Cairo')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab() { // محتوى تبويب سجل الحضور والغياب
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummarySection(), // ملخص إحصائي (نسبة الحضور)
          SizedBox(height: 32.h),
          _buildCalendarSection(), // عرض التقويم الشهري
          SizedBox(height: 32.h),
          Text('السجل الأخير', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B), fontFamily: 'Cairo')), // عنوان السجل
          SizedBox(height: 16.h),
          ..._allLogs.map((log) => _buildHistoryCard(log)), // عرض السجلات الأخيرة
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildSummarySection() { // بناء قسم الملخص الإحصائي
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded( // بطاقة نسبة الحضور الكلية
          flex: 4,
          child: Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]), // تدرج أخضر للنجاح
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('نسبة الحضور', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12.sp, fontFamily: 'Cairo')),
                Row(children: [Text('94%', style: TextStyle(color: Colors.white, fontSize: 32.sp, fontWeight: FontWeight.w900, fontFamily: 'Cairo')), const Spacer(), Icon(Icons.trending_up, color: Colors.white, size: 28.sp)]),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded( // إحصائيات تفصيلية (حاضر، غائب، متأخر)
          flex: 4,
          child: Column(
            children: [
              _buildStatBox('حاضر: 15', const Color(0xFFDCFCE7), const Color(0xFF166534), Icons.check_circle_outline),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(child: _buildSmallStatBox('غائب: 1', const Color(0xFFFEE2E2), const Color(0xFF991B1B), Icons.cancel_outlined)),
                  SizedBox(width: 8.w),
                  Expanded(child: _buildSmallStatBox('متأخر: 1', const Color(0xFFFFEFD6), const Color(0xFF92400E), Icons.access_time)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String text, Color bg, Color textCol, IconData icon) { // صندوق إحصائي متوسط الحجم
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16.r)),
      child: Row(children: [Icon(icon, color: textCol, size: 16.sp), SizedBox(width: 8.w), Text(text, style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 13.sp, fontFamily: 'Cairo'))]),
    );
  }

  Widget _buildSmallStatBox(String text, Color bg, Color textCol, IconData icon) { // صندوق إحصائي صغير
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16.r)),
      child: Column(children: [Icon(icon, color: textCol, size: 14.sp), SizedBox(height: 4.h), Text(text, style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 10.sp, fontFamily: 'Cairo'))]),
    );
  }

  Widget _buildCalendarSection() { // بناء قسم التقويم الشهري
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24.r), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(
        children: [
          Row(children: [Icon(Icons.calendar_today, color: const Color(0xFF9333EA), size: 20.sp), SizedBox(width: 12.w), Text('مارس 2026', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B), fontFamily: 'Cairo'))]), // أيقونة التقويم وعنوان الشهر الدراسي مع تعليق عربي لكل سطر كما هو مطلوب
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text('أحد', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              Text('اثن', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              Text('ثلا', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              Text('أرب', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              Text('خميس', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              Text('جمعة', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              Text('سبت', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
            ],
          ),
          SizedBox(height: 16.h),
          GridView.builder( // بناء أيام الشهر
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 12, crossAxisSpacing: 12),
            itemCount: 31,
            itemBuilder: (context, index) {
              int day = index + 1;
              Color? statusColor;
              if ([6, 7, 9, 11, 12].contains(day)) statusColor = const Color(0xFFDCFCE7); // أخضر للحضور
              if ([8].contains(day)) statusColor = const Color(0xFFFEE2E2); // أحمر للغياب
              if ([10].contains(day)) statusColor = const Color(0xFFFFEFD6); // أصفر للتأخير
              return Container(
                decoration: BoxDecoration(color: statusColor ?? const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10.r)),
                child: Center(child: Text(day.toString(), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: statusColor != null ? Colors.black87 : const Color(0xFF64748B)))),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> log) { // بناء بطاقة سجل حضور فردية
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Row(
        children: [
          Container( // أيقونة الحالة ملونة
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(color: (log['statusColor'] as Color).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14.r)),
            child: Icon(log['icon'] as IconData, color: log['statusColor'] as Color, size: 22.sp),
          ),
          SizedBox(width: 16.w),
          Expanded( // تفاصيل الحالة والتاريخ
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(log['status'] as String, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp, color: const Color(0xFF1E293B), fontFamily: 'Cairo')),
              Text(log['date'] as String, style: TextStyle(color: const Color(0xFF64748B), fontSize: 12.sp, fontFamily: 'Cairo')),
            ]),
          ),
          Container( // وقت الحضور
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8.r), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Text(log['time'] as String, style: TextStyle(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 11.sp)),
          ),
        ],
      ),
    );
  }
}

// لوحة تحكم السائق (شاشة السائق) لإدارة الرحلة ومتابعة حضور ونزول الطلاب في الحافلة
/*
🧠 اسم الملف: driver_dashboard.dart

📌 بيعمل إيه؟
دي الشاشة اللي السواق بيستخدمها عشان يشوف خط السير، يسجل ركوب ونزول الطلاب من الباص، ويتواصل مع المدرسة.

👤 موجه لمين؟
- سواقين

💡 فكرته:
ضمان أمان الطلاب في الرحلة المدرسية وتوفير تتبع دقيق للحافلة.
*/

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app_theme.dart';
import 'driver_messages_screen.dart';

// شاشة لوحة تحكم السائق (Driver Dashboard)
// تعرض هذه الشاشة خريطة الطريق، قائمة الطلاب، وحالة الرحلة (بدأت أم لا)
class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen>
    with TickerProviderStateMixin {
  // ── Design tokens ─────────────────────────────────────────────────────────
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryPurple = Color(0xFF9333EA);
  static const Color baseColor = Color(0xFFF0F3F8);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);


  List<BoxShadow> get _raiseShadow => [
    const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(4, 4),
    ),
  ];

  // متغير لتتبع حالة الرحلة (هل بدأت أم لا)
  bool _isTripStarted = false;

  // متحكم الحركات (Animation) الخاص بنبض المؤشر على الخريطة
  late AnimationController _pulseController;

  // قائمة وهمية ببيانات الطلاب المحمولين في الحافلة
  // تحتوي على أسماء الطلاب، الصف الدراسي، محطة التوقف، وحالة التواجد
  final List<Map<String, dynamic>> _students = [
    {
      'name': 'أدهم',
      'grade': 'الصف الرابع',
      'stop': 'مجمع الياسمين السكني',
      'status': 'pending',
    },
    {
      'name': 'مريم',
      'grade': 'تمهيدي ج',
      'stop': 'حي الورود، شارع 15',
      'status': 'pending',
    },
    {
      'name': 'كريم',
      'grade': 'الصف الخامس',
      'stop': 'الروضة بلازا',
      'status': 'pending',
    },
    {
      'name': 'جهاد',
      'grade': 'الصف الأول',
      'stop': 'شارع الحجاز',
      'status': 'pending',
    },
    {
      'name': 'فادي',
      'grade': 'الصف الثالث',
      'stop': 'ميدان المحكمة',
      'status': 'pending',
    },
  ];

  @override
  void initState() {
    super.initState();
    // تهيئة تأثير النبض الخاص بأيقونة الحافلة عند بدء الرحلة
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // دالة لبدء الرحلة عند ضغط السائق على زر البدء
  void _startTrip() {
    setState(() {
      _isTripStarted = true; // تغيير حالة الرحلة إلى "بدأت"
    });
    // إظهار إشعار سفلي (SnackBar) بنجاح بدء الرحلة
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8.w),
            Text(
              'تم بدء الرحلة بنجاح!',
              style: TextStyle(fontFamily: 'Outfit'),
            ),
          ],
        ),
        backgroundColor: AppTheme.emeraldGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _endTrip() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: baseColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r),
        ),
        title: Text(
          'إنهاء الرحلة؟',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'هل أنت متأكد من نزول جميع الطلاب في الحافلة الآن؟',
          style: TextStyle(fontFamily: 'Cairo', color: textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'إلغاء',
              style: TextStyle(color: textMuted, fontFamily: 'Cairo'),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFFB7185)],
              ),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _isTripStarted = false;
                  for (var s in _students) {
                    s['status'] = 'pending';
                  }
                });
              },
              child: Text(
                'نعم، إنهاء',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }



  // دالة لإظهار القائمة السفلية (Bottom Sheet) التي تحتوي على أسماء الطلاب
  // للتحضير وإثبات الركوب أو الغياب
  void _showStudentsList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: baseColor,
                          shape: BoxShape.circle,
                          boxShadow: _raiseShadow,
                        ),
                        child: Icon(
                          Icons.people_alt_rounded,
                          color: primaryPurple,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        'قائمة طلاب الرحلة',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          color: textDark,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _students.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 16.h),
                      itemBuilder: (context, index) {
                        final student = _students[index];
                        bool isBoarded = student['status'] == 'boarded';
                        bool isAbsent = student['status'] == 'absent';

                        return Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(24.r),
                            boxShadow: _raiseShadow,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(2.r),
                                    decoration: BoxDecoration(
                                      color: baseColor,
                                      shape: BoxShape.circle,
                                      boxShadow: _raiseShadow,
                                    ),
                                    child: CircleAvatar(
                                      radius: 24.r,
                                      backgroundColor: isBoarded
                                          ? AppTheme.emeraldGreen.withValues(alpha: 
                                              0.12,
                                            )
                                          : isAbsent
                                          ? AppTheme.softRose.withValues(alpha: 0.12)
                                          : primaryBlue.withValues(alpha: 0.12),
                                      child: Text(
                                        student['name'].substring(0, 1),
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: isBoarded
                                              ? AppTheme.emeraldGreen
                                              : isAbsent
                                              ? AppTheme.softRose
                                              : primaryBlue,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          student['name'],
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w900,
                                            color: textDark,
                                            fontFamily: 'Cairo',
                                          ),
                                        ),
                                        Text(
                                          student['stop'],
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: textMuted,
                                            fontFamily: 'Cairo',
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isBoarded || isAbsent)
                                    Icon(
                                      isBoarded
                                          ? Icons.check_circle_rounded
                                          : Icons.cancel_rounded,
                                      color: isBoarded
                                          ? AppTheme.emeraldGreen
                                          : AppTheme.softRose,
                                      size: 24.sp,
                                    ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setModalState(
                                          () => _students[index]['status'] =
                                              isBoarded ? 'pending' : 'boarded',
                                        );
                                        setState(() {});
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 10.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isBoarded
                                              ? AppTheme.emeraldGreen
                                              : baseColor,
                                          borderRadius: BorderRadius.circular(
                                            16.r,
                                          ),
                                          boxShadow: isBoarded
                                              ? []
                                              : _raiseShadow,
                                        ),
                                        child: Center(
                                          child: Text(
                                            isBoarded
                                                ? 'تم الركوب'
                                                : 'تأكيد الركوب',
                                            style: TextStyle(
                                              color: isBoarded
                                                  ? Colors.white
                                                  : AppTheme.emeraldGreen,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Cairo',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setModalState(
                                          () => _students[index]['status'] =
                                              isAbsent ? 'pending' : 'absent',
                                        );
                                        setState(() {});
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 10.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isAbsent
                                              ? AppTheme.softRose
                                              : baseColor,
                                          borderRadius: BorderRadius.circular(
                                            16.r,
                                          ),
                                          boxShadow: isAbsent
                                              ? []
                                              : _raiseShadow,
                                        ),
                                        child: Center(
                                          child: Text(
                                            isAbsent ? 'غائب' : 'تسجيل غياب',
                                            style: TextStyle(
                                              color: isAbsent
                                                  ? Colors.white
                                                  : AppTheme.softRose,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Cairo',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    // تحديد واجهة التطبيق لتعمل من اليمين لليسار (اللغة العربية)
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            _buildCleanMinimalMap(), // واجهة الخريطة الوهمية
            _buildFloatingHeader(), // الشريط العلوي العائم (شاشة القيادة)
            if (_isTripStarted)
              _buildLiveStatusIndicator(), // شارة "مباشر" أثناء الرحلة
            _buildWhiteBentoSheet(), // الورقة السفلية البيضاء (التحكم بالرحلة والطلاب)
          ],
        ),
      ),
    );
  }

  // أداة بناء واجهة الخريطة (مجرد خطوط وأيقونة نبض تعبيراً عن الخريطة)
  Widget _buildCleanMinimalMap() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(color: baseColor),
      child: Stack(
        children: [
          // Subtle Grid Lines
          ...List.generate(
            15,
            (i) => Positioned(
              left: i * 80.0,
              top: 0,
              bottom: 0,
              child: Container(width: 2, color: Colors.white.withValues(alpha: 0.8)),
            ),
          ),
          ...List.generate(
            30,
            (i) => Positioned(
              left: 0,
              right: 0,
              top: i * 60.0,
              child: Container(height: 2, color: Colors.white.withValues(alpha: 0.8)),
            ),
          ),

          if (_isTripStarted)
            Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 150.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ScaleTransition(
                          scale: Tween<double>(begin: 1.0, end: 2.0).animate(
                            CurvedAnimation(
                              parent: _pulseController,
                              curve: Curves.easeOut,
                            ),
                          ),
                          child: Container(
                            width: 80.r,
                            height: 80.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.emeraldGreen.withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(18.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.directions_bus_rounded,
                            color: AppTheme.emeraldGreen,
                            size: 30.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(15.r),
                        boxShadow: _raiseShadow,
                      ),
                      child: Text(
                        'الرحلة جارية الآن',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppTheme.emeraldGreen,
                          fontSize: 11.sp,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // أداة بناء الشريط العلوي الذي يظهر تفاصيل تخص السائق ورقم الخط
  Widget _buildFloatingHeader() {
    return Positioned(
      top: 60.h,
      left: 24.w,
      right: 24.w,
      child: Container(
        height: 74.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: _raiseShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryBlue, primaryPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.drive_eta_rounded,
                color: Colors.white,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'شاشة القيادة',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18.sp,
                      color: textDark,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Text(
                    'خط جسر السويس • رحلة صباحية',
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                if (_isTripStarted) {
                  _endTrip();
                } else {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              child: Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: baseColor,
                  shape: BoxShape.circle,
                  boxShadow: _raiseShadow,
                ),
                child: Icon(
                  _isTripStarted
                      ? Icons.power_settings_new_rounded
                      : Icons.logout_rounded,
                  color: AppTheme.softRose,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveStatusIndicator() {
    return Positioned(
      top: 146.h,
      right: 32.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [primaryBlue, primaryPurple],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(color: primaryBlue.withValues(alpha: 0.3), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 6.r,
              height: 6.r,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'مباشر الآن',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.w900,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhiteBentoSheet() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isTripStarted ? 420.h : 380.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(50.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 35.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 24.h),

            if (_isTripStarted) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_students.where((s) => s['status'] == 'boarded').length} ركبوا من أصل ${_students.length}',
                        style: TextStyle(
                          color: textDark,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: _raiseShadow,
                      ),
                      child: Text(
                        '${_students.where((s) => s['status'] == 'pending').length} متبقي',
                        style: TextStyle(
                          color: AppTheme.emeraldGreen,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
            ] else ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Text(
                  'الرحلة جاهزة للبدء',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _showStudentsList,
                      child: Container(
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryBlue.withValues(alpha: 0.8),
                              primaryPurple.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24.r),
                          boxShadow: [
                            BoxShadow(
                              color: primaryBlue.withValues(alpha: 0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.checklist_rtl_rounded,
                              color: Colors.white,
                              size: 28.sp,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'الطلاب\nوالحضور',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DriverMessagingCenterScreen(isTab: false),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryPurple.withValues(alpha: 0.1),
                              primaryBlue.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24.r),
                          boxShadow: _raiseShadow,
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryPurple.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.headset_mic_rounded,
                                color: primaryPurple,
                                size: 24.sp,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'مراسلة',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w900,
                                color: textDark,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),

            if (!_isTripStarted)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
                child: SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: _startTrip,
                    child: Container(
                      height: 60.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [primaryBlue, primaryPurple],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_circle_fill_rounded,
                            size: 24.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'بدء الرحلة الآن',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
                child: SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: _endTrip,
                    child: Container(
                      height: 60.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFFB7185)],
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.stop_circle_rounded,
                            size: 24.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'إنهاء الرحلة',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
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
}

/*
🧠 اسم الملف: teacher_attendance_screen.dart

📌 بيعمل إيه؟
دي الشاشة اللي المدرس بياخد فيها الغياب والحضور بتاع الفصل كل يوم بلمسة واحدة.

👤 موجه لمين؟
- مدرسين

💡 فكرته:
توفير وقت الحصة وضمان دقة كشوف الغياب وإرسال تنبيهات فورية لأولياء الأمور.
*/

import 'package:flutter/material.dart'; // استيراد مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة التحكم في أحجام الشاشة
import '../../widgets/wesal_background.dart';

class TeacherAttendanceScreen extends StatefulWidget { // تعريف كلاس شاشة تسجيل الحضور للمعلم كـ StatefulWidget
  final Map<String, dynamic>? initialClass; // بيانات الفصل الأولية (اختياري)
  const TeacherAttendanceScreen({super.key, this.initialClass}); // مشيد الكلاس

  @override // إنشاء حالة الشاشة
  State<TeacherAttendanceScreen> createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> { // كلاس حالة شاشة تسجيل الحضور
  // ── Design tokens ─────────────────────────────────────────────────────────
  static const Color primaryBlue   = Color(0xFF2563EB); // اللون الأزرق الأساسي
  static const Color primaryPurple = Color(0xFF9333EA); // اللون البنفسجي الأساسي
  static const Color baseColor     = Color(0xFFF0F3F8); // لون الخلفية الرمادي الفاتح
  static const Color textDark      = Color(0xFF1E293B); // لون النص الداكن
  static const Color textMuted     = Color(0xFF64748B); // لون النص الباهت
  static const Color presentColor  = Color(0xFF22C55E); // لون حالة الحاضر (أخضر)
  static const Color absentColor   = Color(0xFFEF4444); // لون حالة الغائب (أحمر)
  static const Color lateColor     = Color(0xFFF59E0B); // لون حالة المتأخر (برتقالي)

  // ── State ──────────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> students = [ // قائمة الطلاب المتاحين لرصد حضورهم (بيانات تجريبية)
    {'name': 'عمر محمود',   'class': '5-أ', 'status': 'حاضر',  'initial': 'ع'},
    {'name': 'سارة أحمد',   'class': '5-أ', 'status': 'حاضر',  'initial': 'س'},
    {'name': 'أدهم سمير',   'class': '5-أ', 'status': 'غائب',  'initial': 'أ'},
    {'name': 'ليلى حسن',    'class': '5-أ', 'status': 'حاضر',  'initial': 'ل'},
    {'name': 'داوود أحمد',  'class': '5-أ', 'status': 'متأخر', 'initial': 'د'},
  ];

  int get presentCount => students.where((s) => s['status'] == 'حاضر').length; // حساب عدد الطلاب الحاضرين
  int get absentCount  => students.where((s) => s['status'] == 'غائب').length; // حساب عدد الطلاب الغائبين
  int get lateCount    => students.where((s) => s['status'] == 'متأخر').length; // حساب عدد الطلاب المتأخرين

  List<BoxShadow> get _raiseShadow => [ // دالة للحصول على تأثير الظل Neumorphic المرتفع
    const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)), // ظل إضاءة علوي
    BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)), // ظل عمق سفلي
  ];

  String _todayArabic() { // دالة لتحويل التاريخ الحالي لتنسيق نصي عربي
    final now = DateTime.now();
    const months = [
      '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${now.day} ${months[now.month]}، ${now.year}';
  }

  @override // دالة بناء واجهة الشاشة
  Widget build(BuildContext context) {
    final today = _todayArabic(); // جلب تاريخ اليوم باللغة العربية

    return Directionality( // تحديد اتجاه النصوص للعربية
      textDirection: TextDirection.rtl,
      child: Scaffold( // هيكل الصفحة
        backgroundColor: Colors.transparent, // لون الخلفية شفاف لرؤية الخلفية الموحدة
        body: WesalBackground(
          child: SafeArea( // حماية المحتوى من الحواف
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              Padding( // ترويسة الصفحة مع زر الرجوع والعنوان
                padding: EdgeInsets.all(20.r),
                child: Row(
                  children: [
                    // Back button (3D Neumorphic)
                    GestureDetector(
                      onTap: () => Navigator.pop(context), // العودة للشاشة السابقة
                      child: Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: baseColor,
                          shape: BoxShape.circle,
                          boxShadow: _raiseShadow,
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded, size: 18.sp, color: textDark),
                      ),
                    ),
                    SizedBox(width: 16.w), // مسافة أفقية
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text( // عنوان الشاشة
                            'تسجيل الحضور',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w900,
                              color: textDark,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          Text( // اسم الفصل وتاريخ اليوم
                            'فصل 5-أ  •  $today',
                            style: TextStyle(fontSize: 12.sp, color: textMuted, fontFamily: 'Cairo'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Stats Row ─────────────────────────────────────────────────
              Padding( // صف بطاقات إحصائيات الحضور (حاضر / غائب / متأخر)
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    _buildStatCard(Icons.check_circle_outline_rounded, '$presentCount', 'حاضر',  presentColor),
                    SizedBox(width: 12.w),
                    _buildStatCard(Icons.cancel_outlined,              '$absentCount',  'غائب',  absentColor),
                    SizedBox(width: 12.w),
                    _buildStatCard(Icons.access_time_rounded,          '$lateCount',   'متأخر', lateColor),
                  ],
                ),
              ),

              SizedBox(height: 24.h), // مسافة رأسية

              // ── Student list ──────────────────────────────────────────────
              Expanded( // قائمة الطلاب القابلة للتمرير
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  physics: const BouncingScrollPhysics(),
                  itemCount: students.length,
                  itemBuilder: (context, i) => _buildStudentCard(i), // بناء بطاقة لكل طالب
                ),
              ),

              // ── Save Button ───────────────────────────────────────────────
              _buildSaveButton(), // بناء زر الحفظ النهائي في أسفل الشاشة
            ],
          ),
        ),
      ),
    ),
  );
}

  // ── Stat card ─────────────────────────────────────────────────────────────
  Widget _buildStatCard(IconData icon, String count, String label, Color color) { // دالة بناء بطاقة إحصائية ملونة
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
          boxShadow: _raiseShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(height: 12.h),
            Text(count, // الرقم الإحصائي
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold,
                color: textDark, fontFamily: 'Outfit')),
            Text(label, // الوصف (مثل: حاضر)
              style: TextStyle(fontSize: 12.sp, color: textMuted, fontFamily: 'Cairo')),
          ],
        ),
      ),
    );
  }

  // ── Student card ──────────────────────────────────────────────────────────
  Widget _buildStudentCard(int index) { // دالة بناء بطاقة عرض طالب وخيارات تحضيره
    final s = students[index];
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: _raiseShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar 3D
              Container( // صورة الطالب الرمزية مع تصميم بارز
                padding: EdgeInsets.all(2.r),
                decoration: BoxDecoration(
                  color: baseColor,
                  shape: BoxShape.circle,
                  boxShadow: _raiseShadow,
                ),
                child: CircleAvatar(
                  radius: 22.r,
                  backgroundColor: primaryPurple.withValues(alpha: 0.12),
                  child: Text(s['initial'],
                    style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold, fontSize: 17.sp)),
                ),
              ),
              SizedBox(width: 12.w),
              Column( // اسم الطالب وفصله
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s['name'],
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold,
                      color: textDark, fontFamily: 'Cairo')),
                  Text(s['class'],
                    style: TextStyle(fontSize: 12.sp, color: textMuted, fontFamily: 'Cairo')),
                ],
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row( // أزرار تبديل حالة الحضور للطالب
            children: [
              _buildStatusBtn(index, 'حاضر',  Icons.check_circle_outline_rounded,  presentColor),
              SizedBox(width: 8.w),
              _buildStatusBtn(index, 'غائب',  Icons.cancel_outlined,              absentColor),
              SizedBox(width: 8.w),
              _buildStatusBtn(index, 'متأخر', Icons.access_time_rounded,           lateColor),
            ],
          ),
        ],
      ),
    );
  }

  // ── Status toggle button ───────────────────────────────────────────────────
  Widget _buildStatusBtn(int index, String status, IconData icon, Color color) { // دالة بناء زر اختيار حالة الحضور
    final bool active = students[index]['status'] == status; // هل هذه الحالة هي المختارة؟
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => students[index]['status'] = status), // تحديث حالة الطالب
        child: AnimatedContainer( // حاوية متحركة تبرز الزر المختار لونياً
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: active ? color : baseColor,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: active ? Colors.transparent : Colors.black.withValues(alpha: 0.08),
            ),
            boxShadow: active
                ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]
                : _raiseShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14.sp, color: active ? Colors.white : textMuted),
              SizedBox(width: 4.w),
              Text(status, // نص الحالة (حاضر/غائب/متأخر)
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: active ? Colors.white : textMuted,
                  fontFamily: 'Cairo',
                )),
            ],
          ),
        ),
      ),
    );
  }

  // ── Save button ───────────────────────────────────────────────────────────
  Widget _buildSaveButton() { // دالة بناء زر حفظ الحضور النهائي مع تأثير تدرج لوني
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      child: GestureDetector(
        onTap: () { // تنفيذ عملية الحفظ وإظهار رسالة تأكيد
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حفظ الحضور بنجاح لـ ${students.length} طالب',
                style: const TextStyle(fontFamily: 'Cairo')),
              backgroundColor: presentColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
            ),
          );
          Navigator.pop(context); // العودة للشاشة السابقة
        },
        child: Container(
          height: 56.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [primaryBlue, primaryPurple],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(color: primaryPurple.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.save_rounded, color: Colors.white, size: 20.sp), // إزالة const هنا
              SizedBox(width: 8.w),
              Text('حفظ الحضور',
                style: TextStyle(color: Colors.white, fontSize: 16.sp,
                  fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
            ],
          ),
        ),
      ),
    );
  }
}

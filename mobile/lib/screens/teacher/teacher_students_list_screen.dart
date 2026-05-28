/*
🧠 اسم الملف: teacher_students_list_screen.dart

📌 بيعمل إيه؟
شاشة بتعرض قائمة بكل الطلاب اللي في فصول المدرس، مع إمكانية البحث عن طالب معين.

👤 موجه لمين؟
- مدرسين

💡 فكرته:
توفير قاعدة بيانات سريعة وسهلة للمدرس عشان يوصل لأي طالب في أي وقت.
*/

import 'package:flutter/material.dart'; // استيراد مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة التحكم في أحجام الشاشة
import 'package:wesal/core/theme/app_theme.dart'; // استيراد ثيم التطبيق الموحد
import 'teacher_attendance_screen.dart'; // استيراد شاشة تسجيل الحضور
import 'teacher_behavior_report_screen.dart'; // استيراد شاشة تقارير السلوك

class TeacherStudentsListScreen extends StatefulWidget { // تعريف كلاس شاشة قائمة الطلاب للمعلم كـ StatefulWidget
  final Map<String, dynamic> classData; // بيانات الفصل الممررة للشاشة
  const TeacherStudentsListScreen({super.key, required this.classData}); // مشيد الكلاس

  @override // إنشاء حالة الشاشة
  State<TeacherStudentsListScreen> createState() =>
      _TeacherStudentsListScreenState();
}

class _TeacherStudentsListScreenState extends State<TeacherStudentsListScreen> { // كلاس حالة شاشة قائمة الطلاب
  final TextEditingController _searchController = TextEditingController(); // متحكم حقل البحث عن الطلاب
  List<Map<String, dynamic>> filteredStudents = []; // قائمة الطلاب المفلترة التي تظهر في الواجهة

  final List<Map<String, dynamic>> allStudents = [ // قائمة بيانات الطلاب (بيانات تجريبية)
    {
      'id': '1',
      'name': 'أحمد محمد علي',
      'status': 'حاضر',
      'behavior': 'إيجابي',
      'behaviorColor': AppTheme.emeraldGreen,
      'initial': 'أ',
    },
    {
      'id': '2',
      'name': 'سارة عبد الله',
      'status': 'حاضر',
      'behavior': 'إيجابي',
      'behaviorColor': AppTheme.emeraldGreen,
      'initial': 'س',
    },
    {
      'id': '3',
      'name': 'ياسين محمود',
      'status': 'غائب',
      'behavior': 'محايد',
      'behaviorColor': AppTheme.textLight,
      'initial': 'ي',
    },
    {
      'id': '4',
      'name': 'ليلى إبراهيم',
      'status': 'متأخر',
      'behavior': 'سلبي',
      'behaviorColor': AppTheme.softRose,
      'initial': 'ل',
    },
    {
      'id': '5',
      'name': 'عمر خالد',
      'status': 'حاضر',
      'behavior': 'إيجابي',
      'behaviorColor': AppTheme.emeraldGreen,
      'initial': 'ع',
    },
    {
      'id': '6',
      'name': 'منى حسن',
      'status': 'حاضر',
      'behavior': 'سلبي',
      'behaviorColor': AppTheme.softRose,
      'initial': 'م',
    },
  ];

  @override // تهيئة الحالة الأولية
  void initState() {
    super.initState();
    filteredStudents = allStudents; // عرض جميع الطلاب في البداية
  }

  void _filterStudents(String query) { // دالة لتصفية قائمة الطلاب بناءً على نص البحث
    setState(() {
      filteredStudents = allStudents
          .where((student) => student['name'].contains(query))
          .toList();
    });
  }

  @override // دالة بناء واجهة الشاشة
  Widget build(BuildContext context) {
    return Directionality( // تحديد اتجاه النصوص للعربية
      textDirection: TextDirection.rtl,
      child: Scaffold( // هيكل الصفحة
        backgroundColor: AppTheme.background, // لون الخلفية
        body: Stack(
          children: [
            SafeArea( // حماية المحتوى من الحواف
              child: Column(
                children: [
                  _buildHeader(), // بناء ترويسة الشاشة
                  _buildSearchBox(), // بناء صندوق البحث
                  Expanded( // الجزء الذي يعرض قائمة الطلاب
                    child: filteredStudents.isEmpty
                        ? _buildEmptyState() // عرض حالة فارغة إذا لم يوجد نتائج للبحث
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 10.h,
                            ),
                            itemCount: filteredStudents.length,
                            itemBuilder: (context, index) =>
                                _buildStudentCard(filteredStudents[index]), // بناء بطاقة كل طالب
                          ),
                  ),
                  _buildBottomActions(), // بناء أزرار الإجراءات السفلية (مثل تسجيل الحضور)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() { // دالة بناء ترويسة الشاشة (زر الرجوع واسم الفصل)
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context), // العودة للشاشة السابقة
            child: Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18.sp,
                color: AppTheme.primaryDark,
              ),
            ),
          ),
          SizedBox(width: 16.w), // مسافة أفقية
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'طلاب ${widget.classData['name']}', // عرض اسم الفصل
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryDark,
                ),
              ),
              Text(
                '${allStudents.length} طالب مسجل', // عرض عدد الطلاب الإجمالي
                style: TextStyle(fontSize: 12.sp, color: AppTheme.textSlate),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() { // دالة بناء حقل البحث عن الطلاب بتصميم الثيم الموحد
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: AppTheme.buildTextField(
        hintText: 'ابحث عن اسم الطالب...',
        icon: Icons.search_rounded,
        controller: _searchController,
        onChanged: _filterStudents, // استدعاء دالة الفلترة عند كل تغيير
      ),
    );
  }

  Widget _buildEmptyState() { // دالة بناء واجهة تظهر عند عدم العثور على نتائج للبحث
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 60.sp,
            color: AppTheme.textLight,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا يوجد طلاب بهذا الاسم',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppTheme.textSlate,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) { // دالة بناء بطاقة الطالب الفردية في القائمة
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: AppTheme.premiumCardDecoration(), // استخدام زخرفة البطاقات الفاخرة من الثيم
      child: Row(
        children: [
          CircleAvatar( // عرض الحرف الأول من اسم الطالب
            radius: 24.r,
            backgroundColor: AppTheme.primaryDark.withValues(alpha: 0.05),
            child: Text(
              student['initial'],
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDark,
                fontFamily: 'Outfit',
              ),
            ),
          ),
          SizedBox(width: 16.w), // مسافة أفقية
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['name'], // اسم الطالب
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDark,
                  ),
                ),
                SizedBox(height: 4.h),
                Row( // عرض ملصقات حالة الحضور والسلوك
                  children: [
                    _buildMiniBadge(
                      student['status'],
                      student['status'] == 'غائب'
                          ? AppTheme.softRose
                          : AppTheme.emeraldGreen,
                    ),
                    SizedBox(width: 8.w),
                    _buildBehaviorIndicator(student['behaviorColor']),
                  ],
                ),
              ],
            ),
          ),
          IconButton( // زر سريع لتسجيل تقرير سلوك لهذا الطالب تحديداً
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      TeacherBehaviorReportScreen(studentName: student['name']),
                ),
              );
            },
            icon: const Icon(Icons.psychology_rounded, color: AppTheme.royalBlue),
            tooltip: 'تسجيل سلوك',
          ),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.textLight), // سهم جانبي للجمالية
        ],
      ),
    );
  }

  Widget _buildMiniBadge(String text, Color color) { // دالة بناء ملصق صغير ملون لحالة الطالب
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildBehaviorIndicator(Color color) { // دالة بناء نقطة ملونة لتمثيل حالة السلوك العام
    return Container(
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4)],
      ),
    );
  }

  Widget _buildBottomActions() { // دالة بناء شريط الإجراءات السفلية (زر تسجيل الحضور الجماعي)
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded( // زر الانتقال لشاشة تسجيل حضور الفصل بالكامل
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TeacherAttendanceScreen(initialClass: widget.classData),
                  ),
                );
              },
              icon: Icon(Icons.how_to_reg_rounded, size: 20.sp),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text( // إزالة const هنا
                  'تسجيل الحضور',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.emeraldGreen,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w), // مسافة أفقية
          Container( // زر تصفية القائمة (الفلتر)
            decoration: BoxDecoration(
              color: AppTheme.primaryDark.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.filter_list_rounded,
                color: AppTheme.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

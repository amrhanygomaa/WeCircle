/*
🧠 اسم الملف: teacher_add_grades_screen.dart

📌 بيعمل إيه؟
دي الشاشة اللي المدرس بيستخدمها عشان يسجل درجات الطلاب في الاختبارات أو التقييمات.

👤 موجه لمين؟
- مدرسين

💡 فكرته:
تحويل رصد الدرجات من الورقي للإلكتروني لضمان الدقة والسرعة في إعلان النتايج.
*/

import 'dart:convert';
import 'package:flutter/material.dart'; // استيراد مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة التحكم في أحجام الشاشة
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/api_config.dart';

class TeacherAddGradesScreen extends StatefulWidget { // تعريف كلاس شاشة رصد الدرجات كـ StatefulWidget
  const TeacherAddGradesScreen({super.key}); // مشيد الكلاس

  @override // إنشاء حالة الشاشة
  State<TeacherAddGradesScreen> createState() => _TeacherAddGradesScreenState();
}

class _TeacherAddGradesScreenState extends State<TeacherAddGradesScreen> { // كلاس حالة شاشة رصد الدرجات
  // ── Design tokens ─────────────────────────────────────────────────────────
  static const Color primaryBlue   = Color(0xFF2563EB); // اللون الأزرق الأساسي
  static const Color primaryPurple = Color(0xFF9333EA); // اللون البنفسجي الأساسي
  static const Color baseColor     = Color(0xFFF0F3F8); // لون الخلفية الرمادي الفاتح
  static const Color textDark      = Color(0xFF1E293B); // لون النص الداكن
  static const Color textMuted     = Color(0xFF64748B); // لون النص الباهت
  static const Color presentColor  = Color(0xFF22C55E); // لون حالة النجاح (أخضر)

  // ── State ──────────────────────────────────────────────────────────────────
  Map<String, dynamic>? selectedClass;
  Map<String, dynamic>? selectedExam;
  List<Map<String, dynamic>> myClasses = [];
  List<Map<String, dynamic>> myExams = [];
  List<Map<String, dynamic>> students = [];
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('mobile_token') ?? '';
      if (token.isEmpty) return;

      final base = ApiConfig.getBaseUrl();
      final headers = {'Authorization': 'Bearer $token'};

      final results = await Future.wait([
        http.get(Uri.parse('$base/teachers/mobile/classes'), headers: headers).timeout(const Duration(seconds: 15)),
        http.get(Uri.parse('$base/exams/mobile/teacher-classes'), headers: headers).timeout(const Duration(seconds: 15)),
      ]);

      if (!mounted) return;
      final classes = (jsonDecode(results[0].body)['data'] as List? ?? []).cast<Map<String, dynamic>>();
      final exams   = (jsonDecode(results[1].body)['data'] as List? ?? []).cast<Map<String, dynamic>>();

      setState(() {
        myClasses = classes;
        myExams   = exams;
        if (classes.isNotEmpty) { selectedClass = classes.first; _buildStudents(classes.first); }
        if (exams.isNotEmpty) selectedExam = exams.first;
      });
    } catch (_) {}
  }

  void _buildStudents(Map<String, dynamic> cls) {
    for (final s in students) { (s['gradeController'] as TextEditingController).dispose(); }
    final raw = (cls['students'] as List? ?? []).cast<Map<String, dynamic>>();
    students = raw.map((s) {
      final name = s['name'] as String? ?? 'طالب';
      return {
        'id':              s['id'] ?? '',
        'name':            name,
        'initial':         name.isNotEmpty ? name.substring(0, 1) : 'ط',
        'gradeController': TextEditingController(),
      };
    }).toList();
  }

  Future<void> _saveGrades() async {
    if (_submitting || selectedExam == null || students.isEmpty) return;
    setState(() => _submitting = true);
    bool ok = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('mobile_token') ?? '';
      final examId = selectedExam!['id'] as String;
      final records = students
          .where((s) => (s['id'] as String).isNotEmpty)
          .map((s) {
            final raw = (s['gradeController'] as TextEditingController).text.trim();
            final score = double.tryParse(raw) ?? 0;
            return {'studentId': s['id'], 'score': score, 'absent': raw.isEmpty};
          }).toList();

      final res = await http.post(
        Uri.parse('${ApiConfig.getBaseUrl()}/exams/mobile/$examId/results'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({'results': records}),
      ).timeout(const Duration(seconds: 20));
      ok = res.statusCode == 200 || res.statusCode == 201;
    } catch (_) {
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'تم حفظ الدرجات بنجاح' : 'تعذّر الحفظ، حاول مرة أخرى', style: const TextStyle(fontFamily: 'Cairo')),
      backgroundColor: ok ? presentColor : const Color(0xFFEF4444),
      behavior: SnackBarBehavior.floating,
    ));
    if (ok) Navigator.pop(context);
  }

  List<BoxShadow> get _raiseShadow => [ // دالة للحصول على تأثير الظل Neumorphic المرتفع
    const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)), // ظل إضاءة علوي
    BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)), // ظل عمق سفلي
  ];

  @override
  void dispose() {
    for (var s in students) { (s['gradeController'] as TextEditingController).dispose(); }
    super.dispose();
  }

  @override // دالة بناء واجهة الشاشة
  Widget build(BuildContext context) {
    return Directionality( // تحديد اتجاه النصوص للعربية
      textDirection: TextDirection.rtl,
      child: Scaffold( // هيكل الصفحة
        backgroundColor: baseColor, // لون الخلفية
        body: SafeArea( // حماية المحتوى من الحواف
          child: Column(
            children: [
              _buildHeader(), // بناء ترويسة الشاشة مع قائمة اختيار الفصل
              Expanded( // عرض قائمة الطلاب أو حالة فارغة إذا لم يتم اختيار فصل
                child: selectedClass == null
                    ? _buildEmptyState() // بناء واجهة تطالب باختيار فصل
                    : ListView.builder( // عرض قائمة الطلاب لرصد درجاتهم
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        physics: const BouncingScrollPhysics(),
                        itemCount: students.length,
                        itemBuilder: (context, i) => _buildGradeCard(i), // بناء بطاقة رصد لكل طالب
                      ),
              ),
              if (selectedClass != null) _buildSaveButton(), // إظهار زر الحفظ فقط بعد اختيار فصل
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() { // دالة بناء ترويسة الشاشة (زر الرجوع وقائمة اختيار الفصل)
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context), // العودة للشاشة السابقة
            child: Container( // تصميم زر الرجوع الدائري
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
          Expanded( // حقل قائمة اختيار الفصل المنسدلة
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(16.r), boxShadow: _raiseShadow),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Map<String, dynamic>>(
                  value: selectedClass,
                  isExpanded: true, // جعل القائمة تأخذ كامل العرض المتاح
                  hint: Text('اختر الفصل...', style: TextStyle(color: textMuted, fontSize: 14.sp, fontFamily: 'Cairo')),
                  items: myClasses.map((c) => DropdownMenuItem(value: c, child: Text(c['name'] as String, style: const TextStyle(fontFamily: 'Cairo')))).toList(),
                  onChanged: (v) { if (v != null) setState(() { selectedClass = v; _buildStudents(v); }); },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() { // دالة بناء واجهة تظهر للمستخدم عند عدم اختيار فصل بعد
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.class_outlined, size: 60.sp, color: textMuted.withValues(alpha: 0.4)),
          SizedBox(height: 16.h),
          Text('الرجاء اختيار الفصل أولاً لإضافة الدرجات', style: TextStyle(fontSize: 14.sp, color: textMuted, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        ],
      ),
    );
  }

  Widget _buildGradeCard(int index) { // دالة بناء بطاقة رصد درجة طالب فردي
    final s = students[index];
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(20.r), boxShadow: _raiseShadow),
      child: Row(
        children: [
          Container( // أيقونة الحرف الأول من اسم الطالب مع تصميم Neumorphic
            padding: EdgeInsets.all(2.r),
            decoration: BoxDecoration(color: baseColor, shape: BoxShape.circle, boxShadow: _raiseShadow),
            child: CircleAvatar(
              radius: 20.r,
              backgroundColor: primaryPurple.withValues(alpha: 0.12),
              child: Text(s['initial'], style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold, fontSize: 16.sp)),
            ),
          ),
          SizedBox(width: 12.w), // مسافة أفقية
          Expanded(child: Text(s['name'], style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Cairo'))),
          Container( // حقل إدخال الدرجة الرقمية
            width: 70.w,
            decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(12.r), boxShadow: _raiseShadow),
            child: TextField(
              controller: s['gradeController'],
              keyboardType: TextInputType.number, // تحديد لوحة المفاتيح للأرقام فقط
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: primaryPurple, fontFamily: 'Outfit'),
              decoration: InputDecoration(hintText: '-', hintStyle: const TextStyle(color: textMuted), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 10.h)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() { // دالة بناء زر حفظ الدرجات النهائي
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: GestureDetector(
        onTap: _submitting ? null : _saveGrades,
        child: Container( // تصميم الزر بتدرج لوني وظل بارز
          height: 56.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [primaryBlue, primaryPurple]),
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [BoxShadow(color: primaryPurple.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Center(child: Text(_submitting ? 'جارٍ الحفظ...' : 'حفظ الدرجات', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo'))),
        ),
      ),
    );
  }
}

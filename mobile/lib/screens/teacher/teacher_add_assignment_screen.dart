/*
🧠 اسم الملف: teacher_add_assignment_screen.dart

📌 بيعمل إيه؟
شاشة بتسمح للمدرس إنه يضيف واجب جديد للفصل، ويحدد المعاد النهائي للتقديم.

👤 موجه لمين؟
- مدرسين

💡 فكرته:
تنظيم الواجبات المدرسية وتسهيل وصولها للطلاب وأولياء الأمور بشكل رقمي.
*/

import 'package:flutter/material.dart'; // استيراد مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة التحكم في أحجام الشاشة
import '../../widgets/wesal_background.dart';

class TeacherAddAssignmentScreen extends StatefulWidget { // تعريف كلاس شاشة إضافة واجب كـ StatefulWidget
  final bool isTab; // متغير لتحديد هل الشاشة معروضة كتبويب أم شاشة مستقلة
  const TeacherAddAssignmentScreen({super.key, this.isTab = false}); // مشيد الكلاس

  @override // إنشاء حالة الشاشة
  State<TeacherAddAssignmentScreen> createState() => _TeacherAddAssignmentScreenState();
}

class _TeacherAddAssignmentScreenState extends State<TeacherAddAssignmentScreen> { // كلاس حالة شاشة إضافة واجب
  // ── Design tokens ─────────────────────────────────────────────────────────
  static const Color primaryBlue   = Color(0xFF2563EB); // اللون الأزرق الأساسي
  static const Color primaryPurple = Color(0xFF9333EA); // اللون البنفسجي الأساسي
  static const Color baseColor     = Color(0xFFF0F3F8); // لون الخلفية الرمادي الفاتح
  static const Color textDark      = Color(0xFF1E293B); // لون النص الداكن
  static const Color textMuted     = Color(0xFF64748B); // لون النص الباهت
  static const Color presentColor  = Color(0xFF22C55E); // لون النجاح (أخضر)
  static const Color lateColor     = Color(0xFFF59E0B); // لون التنبيه (برتقالي)

  // ── State ──────────────────────────────────────────────────────────────────
  final TextEditingController titleController = TextEditingController(); // متحكم حقل عنوان الواجب
  final TextEditingController descController = TextEditingController(); // متحكم حقل وصف الواجب
  String? selectedClass; // متغير لتخزين الفصل المختار للواجب
  DateTime? selectedDate; // متغير لتخزين الموعد النهائي للواجب

  final List<String> classes = ['فصل 5-أ', 'فصل 5-ب', 'فصل 5-ج', 'الكل']; // قائمة الفصول المتاحة للاختيار

  List<BoxShadow> get _raiseShadow => [ // دالة للحصول على تأثير الظل Neumorphic المرتفع
    const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)), // ظل إضاءة علوي
    BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)), // ظل عمق سفلي
  ];

  Future<void> _pickDate() async { // دالة لفتح نافذة اختيار التاريخ للموعد النهائي
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)), // التاريخ الافتراضي هو غداً
      firstDate: DateTime.now(), // أقدم تاريخ يمكن اختياره هو اليوم
      lastDate: DateTime.now().add(const Duration(days: 60)), // أبعد تاريخ هو بعد شهرين
      locale: const Locale('ar', 'SA'), // تحديد اللغة العربية للتقويم
      builder: (context, child) {
        return Theme( // تخصيص ثيم نافذة اختيار التاريخ
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryPurple,
              onPrimary: Colors.white,
              surface: baseColor,
              onSurface: textDark,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: baseColor), // تحديث ثيم خلفية الحوار
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryPurple,
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => selectedDate = picked); // تحديث التاريخ المختار إذا لم يتم الإلغاء
  }

  @override // دالة بناء واجهة الشاشة
  Widget build(BuildContext context) {
    return Directionality( // تحديد اتجاه النصوص للعربية
      textDirection: TextDirection.rtl,
      child: WesalBackground(
        child: Scaffold( // هيكل الصفحة
          backgroundColor: Colors.transparent, // شفاف لرؤية الخلفية الموحدة
          body: SafeArea( // حماية المحتوى من الحواف
            child: Column(
              children: [
                _buildHeader(), // بناء ترويسة الشاشة
                Expanded( // محتوى النموذج القابل للتمرير
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('عنوان الواجب'), // عنوان قسم إدخال العنوان
                        _buildTextField(titleController, 'اكتب عنوان الواجب...', Icons.task_alt_rounded),
                        SizedBox(height: 24.h), // مسافة رأسية
                        
                        _buildSectionTitle('الفصل المستهدف'), // عنوان قسم اختيار الفصل
                        _buildClassSelector(), // بناء قائمة اختيار الفصل
                        SizedBox(height: 24.h), // مسافة رأسية
                        
                        _buildSectionTitle('وصف الواجب'), // عنوان قسم إدخال الوصف
                        _buildTextField(descController, 'اكتب تفاصيل الواجب...', Icons.description_rounded, maxLines: 4),
                        SizedBox(height: 24.h), // مسافة رأسية
                        
                        _buildSectionTitle('الموعد النهائي'), // عنوان قسم اختيار التاريخ
                        _buildDatePicker(), // بناء حقل اختيار التاريخ
                        SizedBox(height: 24.h), // مسافة رأسية
                        
                        SizedBox(height: 120.h), // مسافة سفلية إضافية للتمرير خلف زر النشر
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // وضع زر النشر في أسفل الوسط
          floatingActionButton: _buildSubmitButton(), // بناء زر نشر الواجب
        ),
      ),
    );
  }

  Widget _buildHeader() { // دالة بناء ترويسة الشاشة (زر الرجوع والعنوان)
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Row(
        children: [
          if (!widget.isTab) ...[ // إظهار زر الرجوع فقط إذا لم تكن الشاشة جزءاً من تبويب
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
          ],
          Column( // نصوص ترويسة الصفحة
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('إنشاء واجب', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: textDark, fontFamily: 'Cairo')),
              Text('ارسل واجب تحفيزي لطلابك', style: TextStyle(fontSize: 12.sp, color: textMuted, fontFamily: 'Cairo')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) { // دالة بناء عناوين الأقسام داخل النموذج
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, right: 4.w),
      child: Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Cairo')),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {int maxLines = 1}) { // دالة بناء حقول إدخال النصوص بتصميم Neumorphic
    return Container(
      decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(16.r), boxShadow: _raiseShadow),
      child: TextField(
        controller: controller,
        maxLines: maxLines, // تحديد عدد الأسطر المسموح بها
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: textMuted, fontSize: 13.sp, fontFamily: 'Cairo'),
          prefixIcon: Icon(icon, color: primaryPurple, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 16.w),
        ),
      ),
    );
  }

  Widget _buildClassSelector() { // دالة بناء شريط اختيار الفصول المستهدفة
    return Wrap( // توزيع الأزرار في صفوف تلقائياً
      spacing: 10.w,
      runSpacing: 10.h,
      children: classes.map((c) {
        final active = selectedClass == c; // هل هذا الفصل هو المختار؟
        return GestureDetector(
          onTap: () => setState(() => selectedClass = c), // تحديث الفصل المختار عند الضغط
          child: AnimatedContainer( // حاوية متحركة تبرز الفصل المختار لونياً
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: active ? primaryPurple : baseColor,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: active ? [BoxShadow(color: primaryPurple.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : _raiseShadow,
            ),
            child: Text(c, style: TextStyle(color: active ? Colors.white : textDark, fontSize: 13.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker() { // دالة بناء حقل عرض واختيار التاريخ
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(16.r), boxShadow: _raiseShadow),
        child: Row(
          children: [
            Icon(Icons.calendar_month_rounded, color: lateColor, size: 22.sp),
            SizedBox(width: 16.w),
            Text( // عرض التاريخ المختار أو نص تذكيري
              selectedDate == null ? 'اختر الموعد النهائي...' : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: selectedDate == null ? textMuted : textDark, fontFamily: 'Cairo'),
            ),
            const Spacer(),
            Icon(Icons.chevron_left_rounded, color: textMuted), // أيقونة سهم لبيان القابلية للضغط
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() { // دالة بناء زر إرسال ونشر الواجب النهائي
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: GestureDetector(
        onTap: () {
          if (selectedClass == null || titleController.text.isEmpty) return; // منع النشر في حال نقص البيانات
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نشر الواجب بنجاح', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: presentColor, behavior: SnackBarBehavior.floating));
          if (!widget.isTab) Navigator.pop(context); // إغلاق الشاشة إذا لم تكن تبويباً
        },
        child: Container( // تصميم الزر بتدرج لوني وظل
          height: 56.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [primaryBlue, primaryPurple]),
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [BoxShadow(color: primaryPurple.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Center(child: Text('نشر الواجب', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo'))), // إزالة const هنا لأن sp تحسب في وقت التشغيل
        ),
      ),
    );
  }
}

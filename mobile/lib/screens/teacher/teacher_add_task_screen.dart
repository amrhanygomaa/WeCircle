/*
🧠 اسم الملف: teacher_add_task_screen.dart

📌 بيعمل إيه؟
شاشة لإضافة مهام أو نشاطات إضافية للطلاب، ممكن تكون برا المنهج أو للتوعية السلوكية.

👤 موجه لمين؟
- مدرسين

💡 فكرته:
إشراك الطلاب في نشاطات متنوعة بتنمي مهاراتهم الشخصية بجانب الدراسة.
*/

import 'package:flutter/material.dart'; // استيراد مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة التحكم في أحجام الشاشة
import '../../widgets/wesal_background.dart';

class TeacherAddTaskScreen extends StatefulWidget { // تعريف كلاس شاشة إضافة مهمة للمعلم كـ StatefulWidget
  const TeacherAddTaskScreen({super.key}); // مشيد الكلاس

  @override // إنشاء حالة الشاشة
  State<TeacherAddTaskScreen> createState() => _TeacherAddTaskScreenState();
}

class _TeacherAddTaskScreenState extends State<TeacherAddTaskScreen> { // كلاس حالة شاشة إضافة مهمة
  // ── Design tokens ─────────────────────────────────────────────────────────
  static const Color primaryBlue   = Color(0xFF2563EB); // اللون الأزرق الأساسي
  static const Color primaryPurple = Color(0xFF9333EA); // اللون البنفسجي الأساسي
  static const Color baseColor     = Color(0xFFF0F3F8); // لون الخلفية الرمادي الفاتح
  static const Color textDark      = Color(0xFF1E293B); // لون النص الداكن
  static const Color textMuted     = Color(0xFF64748B); // لون النص الباهت
  static const Color presentColor  = Color(0xFF22C55E); // لون حالة النجاح (أخضر)
  static const Color lateColor     = Color(0xFFF59E0B); // لون العملات/التنبيه (برتقالي)

  // ── State ──────────────────────────────────────────────────────────────────
  final TextEditingController titleController = TextEditingController(); // متحكم حقل عنوان المهمة
  final TextEditingController descController = TextEditingController(); // متحكم حقل وصف المهمة
  String? selectedClass; // متغير لتخزين الفصل المختار
  DateTime? selectedDate; // متغير لتخزين الموعد النهائي للمهمة
  int selectedCoins = 10; // عدد النقاط (العملات) المحددة كمكافأة للمهمة

  final List<String> classes = ['فصل 5-أ', 'فصل 5-ب', 'فصل 5-ج', 'الكل']; // قائمة الفصول المتاحة
  final List<int> coinOptions = [5, 10, 15, 20, 30, 50]; // خيارات نقاط المكافأة المتاحة

  List<BoxShadow> get _raiseShadow => [ // دالة للحصول على تأثير الظل Neumorphic المرتفع
    const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)), // ظل إضاءة علوي
    BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)), // ظل عمق سفلي
  ];

  Future<void> _pickDate() async { // دالة لفتح نافذة اختيار التاريخ للموعد النهائي
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)), // التاريخ الافتراضي غداً
      firstDate: DateTime.now(), // أقدم تاريخ هو اليوم
      lastDate: DateTime.now().add(const Duration(days: 60)), // أقصى تاريخ بعد شهرين
      locale: const Locale('ar', 'SA'), // اللغة العربية للتقويم
      builder: (context, child) {
        return Theme( // تخصيص ألوان وثيم نافذة التقويم
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
    if (picked != null) setState(() => selectedDate = picked); // تحديث التاريخ المختار
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
                Expanded( // الجزء القابل للتمرير من النموذج
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('عنوان المهمة'), // عنوان قسم العنوان
                        _buildTextField(titleController, 'اكتب عنوان المهمة...', Icons.assignment_turned_in_rounded),
                        SizedBox(height: 24.h), // مسافة رأسية
                        
                        _buildSectionTitle('الفصل المستهدف'), // عنوان قسم الفصل
                        _buildClassSelector(), // بناء اختيار الفصل
                        SizedBox(height: 24.h), // مسافة رأسية
                        
                        _buildSectionTitle('وصف المهمة'), // عنوان قسم الوصف
                        _buildTextField(descController, 'اكتب تفاصيل المهمة...', Icons.description_rounded, maxLines: 4),
                        SizedBox(height: 24.h), // مسافة رأسية
                        
                        _buildSectionTitle('الموعد النهائي'), // عنوان قسم التاريخ
                        _buildDatePicker(), // بناء اختيار التاريخ
                        SizedBox(height: 24.h), // مسافة رأسية

                        _buildSectionTitle('نقاط المكافأة (Coins)'), // عنوان قسم النقاط
                        _buildCoinsSelector(), // بناء اختيار نقاط المكافأة
                        
                        SizedBox(height: 120.h), // مسافة سفلية إضافية للتمرير خلف زر النشر
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // زر عائم في الأسفل الوسط
          floatingActionButton: _buildSubmitButton(), // بناء زر نشر المهمة
        ),
      ),
    );
  }

  Widget _buildHeader() { // دالة بناء ترويسة الشاشة (زر الرجوع والعنوان)
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Row(
        children: [
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
          Column( // نصوص الترويسة
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('إنشاء مهمة', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: textDark, fontFamily: 'Cairo')),
              Text('حدد مهمة لطلابك لزيادة تفاعلهم', style: TextStyle(fontSize: 12.sp, color: textMuted, fontFamily: 'Cairo')),
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
        maxLines: maxLines,
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

  Widget _buildClassSelector() { // دالة بناء أزرار اختيار الفصول المستهدفة
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: classes.map((c) {
        final active = selectedClass == c; // هل هذا الفصل هو المختار؟
        return GestureDetector(
          onTap: () => setState(() => selectedClass = c),
          child: AnimatedContainer( // حاوية متحركة لتغيير اللون عند الاختيار
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

  Widget _buildDatePicker() { // دالة بناء حقل عرض واختيار التاريخ للموعد النهائي
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
            Icon(Icons.chevron_left_rounded, color: textMuted), // سهم جانبي للجمالية
          ],
        ),
      ),
    );
  }

  Widget _buildCoinsSelector() { // دالة بناء بطاقة اختيار عدد نقاط المكافأة للمهمة
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(20.r), boxShadow: _raiseShadow),
      child: Column(
        children: [
          Row( // عرض العملة والعدد الحالي المختار
            children: [
              const Text('🪙', style: TextStyle(fontSize: 24)),
              SizedBox(width: 12.w),
              Text('$selectedCoins نقطة مكافأة', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: lateColor, fontFamily: 'Cairo')),
            ],
          ),
          SizedBox(height: 16.h),
          Wrap( // شبكة خيارات النقاط المتاحة
            spacing: 10.w,
            runSpacing: 10.h,
            children: coinOptions.map((coins) {
              final active = selectedCoins == coins; // هل هذا العدد هو المختار؟
              return GestureDetector(
                onTap: () => setState(() => selectedCoins = coins),
                child: AnimatedContainer( // زر دائري أو بيضاوي لاختيار النقاط
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: active ? lateColor : baseColor,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: active ? [] : _raiseShadow,
                  ),
                  child: Text('$coins 🪙', style: TextStyle(color: active ? Colors.white : lateColor, fontSize: 13.sp, fontWeight: FontWeight.bold)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() { // دالة بناء زر نشر المهمة النهائي
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: GestureDetector(
        onTap: () {
          if (selectedClass == null || titleController.text.isEmpty) return; // التحقق من تعبئة البيانات الأساسية
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نشر المهمة بنجاح', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: presentColor, behavior: SnackBarBehavior.floating));
          Navigator.pop(context); // العودة للشاشة السابقة
        },
        child: Container( // تصميم الزر بتدرج لوني وظل بارز
          height: 56.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [primaryBlue, primaryPurple]),
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [BoxShadow(color: primaryPurple.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Center(child: Text('نشر المهمة', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo'))), // إزالة const هنا
        ),
      ),
    );
  }
}

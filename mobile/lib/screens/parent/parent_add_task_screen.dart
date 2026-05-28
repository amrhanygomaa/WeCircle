/*
🧠 اسم الملف: parent_add_task_screen.dart

📌 بيعمل إيه؟
شاشة بتخلي ولي الأمر يضيف مهام خاصة لابنه في البيت عشان تظهرله في الـ Dashboard بتاعته.

👤 موجه لمين؟
- أولياء أمور

💡 فكرته:
دمج المهام المنزلية مع المهام المدرسية عشان نساعد الطفل يتعود على النظام والمسؤولية.
*/

import 'package:flutter/material.dart'; // استيراد مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة التحكم في أحجام الشاشة
import '../../widgets/wesal_background.dart';

class ParentAddTaskScreen extends StatefulWidget { // تعريف كلاس شاشة إضافة مهمة جديدة كـ StatefulWidget
  const ParentAddTaskScreen({super.key}); // مشيد الكلاس

  @override // إنشاء حالة الشاشة
  State<ParentAddTaskScreen> createState() => _ParentAddTaskScreenState();
}

class _ParentAddTaskScreenState extends State<ParentAddTaskScreen> { // كلاس حالة شاشة إضافة مهمة
  // ── Design tokens ─────────────────────────────────────────────────────────
  static const Color primaryBlue   = Color(0xFF2563EB); // اللون الأزرق الأساسي
  static const Color primaryPurple = Color(0xFF9333EA); // اللون البنفسجي الأساسي
  static const Color baseColor     = Color(0xFFF0F3F8); // لون الخلفية الأساسي
  static const Color textDark      = Color(0xFF1E293B); // لون النص الداكن
  static const Color textMuted     = Color(0xFF64748B); // لون النص الباهت

  int selectedChildIndex = 0; // مؤشر الطفل المختار
  final TextEditingController titleController = TextEditingController(); // متحكم العنوان
  final TextEditingController descController = TextEditingController(); // متحكم الوصف

  @override // تنظيف الموارد عند إغلاق الشاشة
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  void _submitTask() { // دالة معالجة إرسال المهمة
    if (titleController.text.trim().isEmpty) { // التحقق من وجود عنوان
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('يرجى كتابة عنوان المهمة', style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      ));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar( // رسالة نجاح الإرسال
      content: Row(children: [Icon(Icons.check_circle_rounded, color: Colors.white, size: 24.sp), SizedBox(width: 12.w), const Expanded(child: Text('تمت إضافة المهمة بنجاح، سيتم تنبيه طفلك!', style: TextStyle(fontFamily: 'Cairo')))]),
      backgroundColor: Colors.green, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    ));
    setState(() { titleController.clear(); descController.clear(); }); // تصفير الحقول
  }

  @override // بناء واجهة المستخدم
  Widget build(BuildContext context) {
    return Directionality( // ضبط الاتجاه للعربية
      textDirection: TextDirection.rtl,
      child: WesalBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent, // شفاف لرؤية الخلفية الموحدة
          body: SafeArea(
            child: CustomScrollView( // استخدام Sliver لتحسين أداء التمرير
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _TaskHeader(primaryBlue: primaryBlue, primaryPurple: primaryPurple, textDark: textDark, textMuted: textMuted), // ترويسة الصفحة
                      SizedBox(height: 32.h),
                      const _SectionTitle(title: 'لمن ترغب في إضافة المهمة؟'), // عنوان القسم
                      SizedBox(height: 16.h),
                      _ChildSelector( // شريط اختيار الطفل (معزول)
                        selectedIndex: selectedChildIndex,
                        onChanged: (idx) => setState(() => selectedChildIndex = idx),
                        primaryBlue: primaryBlue,
                        primaryPurple: primaryPurple,
                        baseColor: baseColor,
                        textDark: textDark,
                      ),
                      SizedBox(height: 32.h),
                      const _SectionTitle(title: 'تفاصيل المهمة'),
                      SizedBox(height: 16.h),
                      _CustomTaskForm( // نموذج الإدخال (معزول)
                        titleController: titleController,
                        descController: descController,
                        onSubmit: _submitTask,
                        primaryBlue: primaryBlue,
                        primaryPurple: primaryPurple,
                        baseColor: baseColor,
                        textDark: textDark,
                        textMuted: textMuted,
                      ),
                      SizedBox(height: 32.h),
                      const _SectionTitle(title: 'أو اختر مهمة سريعة'),
                      SizedBox(height: 16.h),
                      _QuickTasksArea( // منطقة المهام الجاهزة (معزولة)
                        onTaskSelect: (title) => setState(() => titleController.text = title),
                        baseColor: baseColor,
                        textDark: textDark,
                      ),
                    ],
                  ),
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

class _TaskHeader extends StatelessWidget { // ويدجت ترويسة شاشة المهام (معزول)
  final Color primaryBlue, primaryPurple, textDark, textMuted;
  const _TaskHeader({required this.primaryBlue, required this.primaryPurple, required this.textDark, required this.textMuted});

  @override // بناء الترويسة
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container( // أيقونة الإضافة المتدرجة
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primaryBlue, primaryPurple]), shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: primaryPurple.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Icon(Icons.add_task_rounded, color: Colors.white, size: 24.sp),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('إضافة مهمة جديدة', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: textDark, fontFamily: 'Cairo')),
            Text('شجع أطفالك بمهام مشوقة ومكافآت مميزة', style: TextStyle(fontSize: 11.sp, color: textMuted, fontFamily: 'Cairo')),
          ],
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget { // ويدجت عنوان القسم (معزول)
  final String title;
  const _SectionTitle({required this.title});

  @override // بناء النص
  Widget build(BuildContext context) {
    return Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B), fontFamily: 'Cairo'));
  }
}

class _ChildSelector extends StatelessWidget { // ويدجت اختيار الطفل (معزول الأداء)
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color primaryBlue, primaryPurple, baseColor, textDark;

  const _ChildSelector({required this.selectedIndex, required this.onChanged, required this.primaryBlue, required this.primaryPurple, required this.baseColor, required this.textDark});

  @override // بناء القائمة الأفقية للأطفال
  Widget build(BuildContext context) {
    final children = [
      {'name': 'أدهم', 'avatar': 'أ', 'color': primaryBlue},
      {'name': 'كريم', 'avatar': 'ك', 'color': primaryPurple},
      {'name': 'مريم', 'avatar': 'م', 'color': Colors.pink},
    ];
    return SizedBox(
      height: 110.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal, itemCount: children.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          final child = children[index];
          final color = child['color'] as Color;
          return GestureDetector(
            onTap: () => onChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300), width: 100.w, margin: EdgeInsets.only(left: 16.w), padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: baseColor, borderRadius: BorderRadius.circular(25.r),
                boxShadow: isSelected ? [] : [
                  const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
                ],
                border: isSelected ? Border.all(color: color, width: 2) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(radius: 20.r, backgroundColor: color.withValues(alpha: 0.1), child: Text(child['avatar'] as String, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: color))),
                  SizedBox(height: 8.h),
                  Text(child['name'] as String, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Cairo')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CustomTaskForm extends StatelessWidget { // ويدجت نموذج إدخال المهمة (معزول)
  final TextEditingController titleController, descController;
  final VoidCallback onSubmit;
  final Color primaryBlue, primaryPurple, baseColor, textDark, textMuted;

  const _CustomTaskForm({
    required this.titleController, required this.descController, required this.onSubmit,
    required this.primaryBlue, required this.primaryPurple, required this.baseColor,
    required this.textDark, required this.textMuted
  });

  @override // بناء الحقول وزر الإرسال
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: baseColor, borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: titleController, style: TextStyle(fontWeight: FontWeight.bold, color: textDark, fontSize: 14.sp, fontFamily: 'Cairo'),
            decoration: InputDecoration(hintText: 'عنوان المهمة (مثال: حفظ سورة النبأ)', hintStyle: TextStyle(color: textMuted, fontSize: 12.sp, fontFamily: 'Cairo'), prefixIcon: Icon(Icons.edit_rounded, color: primaryBlue, size: 20.sp), border: InputBorder.none),
          ),
          Divider(height: 32.h, color: textMuted.withValues(alpha: 0.1)),
          TextField(
            controller: descController, maxLines: 2, style: TextStyle(color: textDark, fontSize: 13.sp, fontFamily: 'Cairo'),
            decoration: InputDecoration(hintText: 'تفاصيل المهمة (اختياري)...', hintStyle: TextStyle(color: textMuted, fontSize: 12.sp, fontFamily: 'Cairo'), prefixIcon: Icon(Icons.description_rounded, color: primaryPurple.withValues(alpha: 0.5), size: 20.sp), border: InputBorder.none),
          ),
          SizedBox(height: 24.h),
          _SubmitButton(onTap: onSubmit, primaryBlue: primaryBlue, primaryPurple: primaryPurple), // زر الإرسال المنفصل
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget { // ويدجت زر الإرسال
  final VoidCallback onTap;
  final Color primaryBlue, primaryPurple;
  const _SubmitButton({required this.onTap, required this.primaryBlue, required this.primaryPurple});

  @override // بناء الزر بتصميم متدرج وظل
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [primaryBlue, primaryPurple]), borderRadius: BorderRadius.circular(20.r),
          boxShadow: [BoxShadow(color: primaryPurple.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_task_rounded, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text('إرسال المهمة للطالب', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Cairo')),
          ],
        ),
      ),
    );
  }
}

class _QuickTasksArea extends StatelessWidget { // ويدجت منطقة المهام الجاهزة (معزولة)
  final ValueChanged<String> onTaskSelect;
  final Color baseColor, textDark;

  const _QuickTasksArea({required this.onTaskSelect, required this.baseColor, required this.textDark});

  @override // بناء قائمة المهام السريعة بنظام Wrap
  Widget build(BuildContext context) {
    final predefinedTasks = [
      {'title': 'مراجعة واجب الرياضيات', 'icon': Icons.calculate_rounded, 'color': const Color(0xFF2563EB)},
      {'title': 'قراءة قصة قبل النوم', 'icon': Icons.menu_book_rounded, 'color': const Color(0xFF9333EA)},
      {'title': 'ترتيب الغرفة', 'icon': Icons.bed_rounded, 'color': const Color(0xFFF59E0B)},
      {'title': 'تحضير حقيبة المدرسة', 'icon': Icons.backpack_rounded, 'color': const Color(0xFFEC4899)},
    ];
    return Wrap(
      spacing: 12.w, runSpacing: 12.h,
      children: predefinedTasks.map((task) => _QuickTaskItem(task: task, onSelect: onTaskSelect, baseColor: baseColor, textDark: textDark)).toList(),
    );
  }
}

class _QuickTaskItem extends StatelessWidget { // عنصر واحد فى المهام الجاهزة
  final Map<String, dynamic> task;
  final ValueChanged<String> onSelect;
  final Color baseColor, textDark;

  const _QuickTaskItem({required this.task, required this.onSelect, required this.baseColor, required this.textDark});

  @override // بناء عنصر المهمة الجاهزة Neumorphic
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelect(task['title'] as String),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: baseColor, borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(task['icon'] as IconData, color: task['color'] as Color, size: 16.sp),
            SizedBox(width: 8.w),
            Text(task['title'] as String, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Cairo')),
          ],
        ),
      ),
    );
  }
}

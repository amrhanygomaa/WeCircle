/*
🧠 اسم الملف: homework_screen.dart

📌 بيعمل إيه؟
دي شاشة بتعرض كل الواجبات اللي الطالب مكلف بيها، ومين منها خلص ومين لسه.

👤 موجه لمين؟
- أولياء أمور

💡 فكرته:
مساعدة ولي الأمر في متابعة التحصيل الدراسي لابنه والتأكد إنه بيخلص واجباته أول بأول.
*/

import 'package:flutter/material.dart'; // استيراد مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة التحكم في أحجام الشاشة
import 'package:image_picker/image_picker.dart'; // استيراد مكتبة التقاط الصور من الكاميرا
import '../../widgets/wesal_background.dart';

class HomeworkScreen extends StatefulWidget {
  // تعريف كلاس شاشة الواجبات المدرسية كـ StatefulWidget
  final bool isTab; // متغير لتحديد هل الشاشة تعمل كأحد التبويبات؟
  final VoidCallback? onBack; // دالة للتنفيذ عند الضغط على زر الرجوع
  const HomeworkScreen({
    super.key,
    this.isTab = true,
    this.onBack,
  }); // مشيد الكلاس مع قيم افتراضية

  @override // إنشاء حالة الشاشة لتتبع التغيرات
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  // كلاس حالة شاشة الواجبات لتخزين البيانات المحلية
  String _selectedFilter = 'الكل'; // متغير الحالة لتخزين الفلتر المختار حالياً

  final List<Map<String, dynamic>> _allHomeworks = [
    // قائمة بيانات الواجبات المدرسية (بيانات تجريبية)
    {
      'id': 1, // معرف فريد للواجب
      'title': 'تجربة نمو النبات', // عنوان المهمة
      'subject': 'العلوم', // المادة
      'description':
          'قم بتوثيق ملاحظات النبات لهذا الأسبوع ومتابعة مراحل النمو.', // الوصف التفصيلي
      'dueDate': '13 مارس', // موعد التسليم النهائي
      'status': 'تم التسليم', // الحالة الحالية
      'priority': 'عالي', // درجة الأهمية للتنبيه
      'icon': Icons.menu_book_rounded, // الأيقونة المناسبة للمادة
      'iconColor': const Color(0xFF10B981), // لون أخضر للعلوم
    },
    {
      'id': 2,
      'title': 'القراءة والاستيعاب',
      'subject': 'اللغة العربية',
      'description': 'أجب على الأسئلة من 1-5 في كتاب التدريبات المخصص.',
      'dueDate': '16 مارس',
      'status': 'قيد التنفيذ',
      'priority': 'منخفض',
      'icon': Icons.menu_book_rounded,
      'iconColor': const Color(0xFFF97316), // لون برتقالي للغة العربية
    },
    {
      'id': 3,
      'title': 'الفصل الخامس: الكسور',
      'subject': 'الرياضيات',
      'description': 'أكمل التمارين من 1-10 في الصفحة رقم 45 من كتاب الطالب.',
      'dueDate': '14 مارس',
      'status': 'قيد التنفيذ',
      'priority': 'عالي',
      'icon': Icons.menu_book_rounded,
      'iconColor': const Color(0xFF0EA5E9), // لون أزرق للرياضيات
    },
    {
      'id': 4,
      'title': 'مشروع العلوم',
      'subject': 'العلوم',
      'description': 'تحضير العرض التقديمي لمشروع الطاقة المتجددة.',
      'dueDate': '18 مارس',
      'status': 'قيد التنفيذ',
      'priority': 'عالي',
      'icon': Icons.lightbulb_outline_rounded,
      'iconColor': const Color(0xFFFFB800), // لون أصفر للمشاريع
    },
  ];

  List<Map<String, dynamic>> get _filteredHomeworks {
    // دالة منطقية لتصفية القائمة بناءً على اختيار المستخدم
    if (_selectedFilter == 'الكل') return _allHomeworks; // عرض الكل
    if (_selectedFilter == 'قيد التنفيذ') {
      // تصفية المعلق
      return _allHomeworks.where((h) => h['status'] == 'قيد التنفيذ').toList();
    }
    return _allHomeworks
        .where((h) => h['status'] == 'تم التسليم')
        .toList(); // تصفية المسلم
  }

  @override // دالة بناء واجهة المستخدم الرئيسية
  Widget build(BuildContext context) {
    return Directionality(
      // ضبط اتجاه التطبيق للعربية
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // هيكل الصفحة
        backgroundColor: Colors.transparent, // جعل خلفية السكافولد شفافة لرؤية الخلفية الموحدة
        body: WesalBackground(
          child: SafeArea(
            // حماية المحتوى من الحواف والنتوءات
          child: Column(
            // ترتيب المحتوى رأسياً
            children: [
              _HomeworkHeader(
                isTab: widget.isTab,
                onBack: widget.onBack,
              ), // ترويسة الصفحة كويدجت منفصل لتحسين الأداء
              Expanded(
                // الجزء القابل للتمرير يأخذ المساحة المتبقية
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(), // تأثير ارتداد طبيعي
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // محاذاة لليمين
                    children: [
                      Padding(
                        // قسم العناوين والترحيب
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الواجبات المدرسية',
                              style: TextStyle(
                                color: const Color(0xFF1E293B),
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Cairo',
                              ),
                            ), // العنوان الرئيسي
                            Text(
                              'تتبع المهام اليومية والمواعيد النهائية',
                              style: TextStyle(
                                color: const Color(0xFF64748B),
                                fontSize: 14.sp,
                                fontFamily: 'Cairo',
                              ),
                            ), // وصف مساعد
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h), // مسافة فاصلة
                      _SummaryBar(
                        allHomeworks: _allHomeworks,
                      ), // شريط ملخص الأرقام كويدجت منفصل
                      _FilterBar(
                        // شريط أزرار الفلترة
                        selectedFilter: _selectedFilter,
                        onFilterChanged: (filter) => setState(
                          () => _selectedFilter = filter,
                        ), // تحديث الحالة عند اختيار فلتر جديد
                      ),
                      _HomeworkListView(
                        // قائمة عرض البطاقات
                        filteredHomeworks: _filteredHomeworks,
                        onCapture: (id) =>
                            _takePicture(id), // تمرير دالة التصوير
                      ),
                      SizedBox(height: 32.h), // مسافة سفلية للتنفس
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

  Future<void> _takePicture(int id) async {
    // دالة معالجة التقاط صورة الواجب وتسليمه
    final ImagePicker picker = ImagePicker(); // أداة اختيار الصور
    try {
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      ); // فتح الكاميرا بجودة متوسطة لتوفير المساحة
      if (photo != null) {
        // إذا تم التقاط الصورة
        setState(() {
          // تحديث حالة الواجب محلياً إلى "تم التسليم"
          final index = _allHomeworks.indexWhere((h) => h['id'] == id);
          if (index != -1) _allHomeworks[index]['status'] = 'تم التسليم';
        });
        if (mounted) {
          // إظهار رسالة تأكيد للمستخدم
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'تم تصوير وتسليم الواجب بنجاح',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint(
        'Error picking image: $e',
      ); // طباعة الخطأ في حال حدوث مشكلة تقنية
    }
  }
}

// ── Optimized Sub-Widgets ──────────────────────────────────────────────────

class _HomeworkHeader extends StatelessWidget {
  // ويدجت ترويسة الصفحة (معزول لتقليل إعادة البناء)
  final bool isTab; // هل هي داخل تبويب
  final VoidCallback? onBack; // دالة الرجوع

  const _HomeworkHeader({required this.isTab, this.onBack}); // مشيد الترويسة

  @override // بناء الترويسة
  Widget build(BuildContext context) {
    bool canPop = Navigator.canPop(context); // فحص إمكانية الرجوع برمجياً
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        children: [
          if (canPop || isTab) ...[
            // إظهار زر الرجوع إذا كان متاحاً
            GestureDetector(
              onTap: () => canPop
                  ? Navigator.pop(context)
                  : onBack?.call(), // تنفيذ الرجوع حسب الحالة
              child: _CircularIcon(
                icon: Icons.arrow_back_ios_rounded,
                size: 18.sp,
              ), // أيقونة دائرية Neumorphic
            ),
            SizedBox(width: 16.w),
          ],
          _CircularIcon(
            icon: Icons.person_rounded,
            color: const Color(0xFF2563EB),
            size: 22.sp,
          ), // أيقونة المستخدم
          SizedBox(width: 12.w),
          Expanded(
            // نصوص بيانات ولي الأمر
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سارة محمد',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  'ولي أمر',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12.sp,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          const _NotificationButton(), // زر التنبيهات المنفصل
        ],
      ),
    );
  }
}

class _CircularIcon extends StatelessWidget {
  // ويدجت أيقونة دائرية بتصميم Neumorphic موحد
  final IconData icon; // الأيقونة المطلوبة
  final Color? color; // لون الأيقونة
  final double size; // حجم الأيقونة

  const _CircularIcon({
    required this.icon,
    this.color,
    required this.size,
  }); // مشيد الأيقونة الثابت

  @override // بناء الأيقونة الدائرية مع الظل
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: color ?? const Color(0xFF1E293B), size: size),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  // ويدجت زر التنبيهات مع القائمة المنبثقة
  const _NotificationButton(); // مشيد ثابت

  @override // بناء الزر مع التنبيهات التجريبية
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: Offset(0, 50.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      color: Colors.white,
      elevation: 8,
      child: Container(
        // شكل الزر الخارجى مع نقطة التنبيه
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Icon(
              Icons.notifications_none_rounded,
              color: const Color(0xFF9333EA),
              size: 22.sp,
            ),
            Positioned(
              // النقطة الحمراء
              right: 0,
              top: 0,
              child: Container(
                width: 8.r,
                height: 8.r,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        // قائمة العناصر المنسدلة
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
          const Color(0xFF9333EA),
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
    // بناء عنصر واحد فى القائمة
    return PopupMenuItem(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
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
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: const Color(0xFF64748B),
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  // ويدجت شريط الملخص الرقمى (معزول الأداء)
  final List<Map<String, dynamic>> allHomeworks; // البيانات الكاملة للواجبات

  const _SummaryBar({required this.allHomeworks}); // مشيد الشريط

  @override // بناء شريط الملخص
  Widget build(BuildContext context) {
    // حساب الإحصائيات وقت البناء
    int total = allHomeworks.length;
    int pending = allHomeworks
        .where((h) => h['status'] == 'قيد التنفيذ')
        .length;
    int submitted = allHomeworks
        .where((h) => h['status'] == 'تم التسليم')
        .length;

    return Container(
      height: 120.h,
      padding: EdgeInsets.only(right: 24.w),
      child: ListView(
        // قائمة أفقية للبطاقات الملخصة
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _SummaryCard(
            label: 'الإجمالي',
            count: total.toString(),
            colors: const [Color(0xFFEC4899), Color(0xFF8B5CF6)],
          ),
          _SummaryCard(
            label: 'قيد التنفيذ',
            count: pending.toString(),
            colors: const [Color(0xFFF97316), Color(0xFFEA580C)],
          ),
          _SummaryCard(
            label: 'تم التسليم',
            count: submitted.toString(),
            colors: const [Color(0xFF10B981), Color(0xFF059669)],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  // ويدجت بطاقة ملخص واحدة بتصميم متدرج
  final String label, count; // التسمية والقيمة الرقمية
  final List<Color> colors; // ألوان التدرج اللوني

  const _SummaryCard({
    required this.label,
    required this.count,
    required this.colors,
  }); // مشيد البطاقة الثابت

  @override // بناء البطاقة
  Widget build(BuildContext context) {
    return Container(
      width: 110.w,
      margin: EdgeInsets.only(left: 12.w),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 10.sp,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            count,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  // ويدجت شريط الفلترة (معزول)
  final String selectedFilter; // الفلتر المختار حالياً
  final Function(String) onFilterChanged; // دالة عند تغيير الفلتر

  const _FilterBar({
    required this.selectedFilter,
    required this.onFilterChanged,
  }); // مشيد الشريط

  @override // بناء شريط الأزرار
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Row(
        children: ['الكل', 'قيد التنفيذ', 'تم التسليم']
            .map(
              (filter) => Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: _FilterChip(
                  label: filter,
                  isSelected: selectedFilter == filter,
                  onTap: () => onFilterChanged(filter),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  // ويدجت زر فلترة واحد
  final String label; // اسم الفلتر
  final bool isSelected; // هل هو النشط؟
  final VoidCallback onTap; // إجراء الضغط

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  }); // مشيد ثابت

  @override // بناء الزر
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6) : Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}

class _HomeworkListView extends StatelessWidget {
  // ويدجت قائمة عرض الواجبات (معزول الأداء)
  final List<Map<String, dynamic>>
  filteredHomeworks; // القائمة المصفاة للواجبات
  final Function(int) onCapture; // دالة التصوير

  const _HomeworkListView({
    required this.filteredHomeworks,
    required this.onCapture,
  }); // مشيد القائمة

  @override // بناء القائمة باستخدام ويدجت البطاقة المنفصل
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: filteredHomeworks
            .map((h) => _HomeworkCard(homework: h, onCapture: onCapture))
            .toList(),
      ),
    );
  }
}

class _HomeworkCard extends StatelessWidget {
  // ويدجت بطاقة واجب واحد (معزول تماماً لتحسين أداء القائمة)
  final Map<String, dynamic> homework; // بيانات الواجب
  final Function(int) onCapture; // دالة التصوير

  const _HomeworkCard({
    required this.homework,
    required this.onCapture,
  }); // مشيد البطاقة الثابت

  @override // بناء البطاقة بتصميم أنيق
  Widget build(BuildContext context) {
    bool isPending = homework['status'] == 'قيد التنفيذ'; // فحص حالة المهمة
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // ترويسة البطاقة (أيقونة، عنوان، أولوية)
            children: [
              Container(
                // الأيقونة الملونة
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: (homework['iconColor'] as Color).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  homework['icon'] as IconData,
                  color: homework['iconColor'] as Color,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                // نصوص التعريف بالواجب
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      homework['title'],
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E293B),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    Text(
                      homework['subject'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
              _PriorityBadge(
                priority: homework['priority'],
              ), // ملصق الأولوية المنفصل
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            homework['description'],
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF475569),
              fontFamily: 'Cairo',
              height: 1.5,
            ),
          ), // وصف المهمة
          SizedBox(height: 20.h),
          Row(
            // ذيل البطاقة (التاريخ، الحالة، زر التصوير)
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: const Color(0xFF64748B),
                size: 16.sp,
              ), // أيقونة الوقت
              SizedBox(width: 8.w),
              Text(
                'الموعد: ${homework['dueDate']}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF64748B),
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
              ), // نص الموعد
              if (isPending) ...[
                // تنبيه أحمر إذا كان الواجب معلقاً
                SizedBox(width: 8.w),
                Icon(
                  Icons.error_outline_rounded,
                  color: const Color(0xFFEF4444),
                  size: 16.sp,
                ),
              ],
              const Spacer(),
              _StatusBadge(status: homework['status']), // ملصق الحالة
              if (isPending) ...[
                // زر التصوير للتسليم السريع
                SizedBox(width: 12.w),
                _CaptureButton(onPressed: () => onCapture(homework['id'])),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  // ويدجت ملصق الأولوية (عالى / منخفض)
  final String priority; // درجة الأهمية
  const _PriorityBadge({required this.priority}); // مشيد ثابت

  @override // بناء الملصق
  Widget build(BuildContext context) {
    bool isHigh = priority == 'عالي';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isHigh ? const Color(0xFFFEE2E2) : const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: isHigh ? const Color(0xFFEF4444) : const Color(0xFF0EA5E9),
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  // ويدجت ملصق حالة التسليم (معزول)
  final String status; // الحالة الحالية
  const _StatusBadge({required this.status}); // مشيد ثابت

  @override // بناء ملصق الحالة
  Widget build(BuildContext context) {
    bool isSubmitted = status == 'تم التسليم';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isSubmitted ? const Color(0xFFDCFCE7) : Colors.transparent,
        borderRadius: BorderRadius.circular(30.r),
        border: isSubmitted ? null : Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSubmitted) ...[
            // أيقونة صح للواجبات المسلمة
            Icon(
              Icons.check_circle_rounded,
              color: const Color(0xFF10B981),
              size: 14.sp,
            ),
            SizedBox(width: 6.w),
          ],
          Text(
            status,
            style: TextStyle(
              color: isSubmitted
                  ? const Color(0xFF059669)
                  : const Color(0xFF64748B),
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  // ويدجت زر التصوير السريع
  final VoidCallback onPressed; // دالة الضغط
  const _CaptureButton({required this.onPressed}); // مشيد ثابت

  @override // بناء الزر
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.camera_alt_rounded,
              color: const Color(0xFF1E293B),
              size: 16.sp,
            ), // أيقونة الكاميرا
            SizedBox(width: 6.w),
            Text(
              'تصوير',
              style: TextStyle(
                color: const Color(0xFF1E293B),
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ), // نص الزر
          ],
        ),
      ),
    );
  }
}

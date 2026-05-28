/*
🧠 اسم الملف: activities_screen.dart

📌 بيعمل إيه؟
دي شاشة بتعرض كل الأنشطة المدرسية اللي الطالب مشترك فيها أو اللي لسه هتبدأ.

👤 موجه لمين؟
- أولياء أمور

💡 فكرته:
بيخلي ولي الأمر دايماً في قلب الحدث وعارف ابنه بيشارك في إيه برا الفصول الدراسية.
*/

import 'package:flutter/material.dart'; // استيراد مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة التحكم في أحجام الشاشة
import 'activity_detail_screen.dart'; // استيراد شاشة تفاصيل النشاط
import '../../widgets/wesal_background.dart';

class ActivitiesScreen extends StatefulWidget { // تعريف كلاس شاشة الأنشطة كـ StatefulWidget
  const ActivitiesScreen({super.key}); // مشيد الكلاس مع مفتاح فريد

  @override // إعادة تعريف دالة إنشاء الحالة
  State<ActivitiesScreen> createState() => _ActivitiesScreenState(); // إنشاء حالة الشاشة
}

class _ActivitiesScreenState extends State<ActivitiesScreen> { // كلاس حالة شاشة الأنشطة
  // ── Design tokens ─────────────────────────────────────────────────────────
  static const Color primaryBlue   = Color(0xFF2563EB); // اللون الأزرق الأساسي
  static const Color primaryPurple = Color(0xFF9333EA); // اللون البنفسجي الأساسي
  static const Color baseColor     = Color(0xFFF0F3F8); // لون الخلفية الأساسي
  static const Color textDark      = Color(0xFF1E293B); // لون النص الداكن
  static const Color textMuted     = Color(0xFF64748B); // لون النص الباهت

  String _selectedCategory = 'الكل'; // متغير لتخزين التصنيف المختار
  final List<String> _categories = const ['الكل', 'أكاديمي', 'رحلات', 'رياضة', 'مسابقات']; // قائمة التصنيفات المتاحة (ثابتة)

  final List<Map<String, dynamic>> _allActivities = [ // قائمة بيانات الأنشطة (بيانات تجريبية)
    {
      'title': 'رحلة استكشافية للمتحف المصري الكبير',
      'subtitle': 'التاريخ والآثار • 5 أبريل',
      'status': 'قيد التسجيل',
      'statusColor': const Color(0xFF22C55E),
      'icon': Icons.account_balance_rounded,
      'color': const Color(0xFF22C55E),
      'type': 'رحلات',
    },
    {
      'title': 'ندوة الأمن السيبراني للجيل الواعد',
      'subtitle': 'توعية تقنية • 7 أبريل',
      'status': 'قريباً',
      'statusColor': primaryBlue,
      'icon': Icons.security_rounded,
      'color': primaryBlue,
      'type': 'أكاديمي',
    },
    {
      'title': 'بطولة الشطرنج المدرسية الكبرى',
      'subtitle': 'ألعاب ذكاء • 11 أبريل',
      'status': 'متاح',
      'statusColor': const Color(0xFFF59E0B),
      'icon': Icons.grid_view_rounded,
      'color': const Color(0xFFF59E0B),
      'type': 'مسابقات',
    },
    {
      'title': 'الماراثون الرياضي السنوي الثالث',
      'subtitle': 'نشاط بدني • 15 أبريل',
      'status': 'متاح',
      'statusColor': primaryPurple,
      'icon': Icons.directions_run_rounded,
      'color': primaryPurple,
      'type': 'رياضة',
    },
  ];

  @override // بناء واجهة الشاشة
  Widget build(BuildContext context) {
    final filteredActivities = _selectedCategory == 'الكل' // تصفية القائمة
        ? _allActivities
        : _allActivities.where((a) => a['type'] == _selectedCategory).toList();

    return Directionality( // ضبط اتجاه النصوص للعربية
      textDirection: TextDirection.rtl,
      child: WesalBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent, // جعل خلفية السكافولد شفافة لرؤية الخلفية الموحدة
          body: SafeArea(
            child: CustomScrollView( // استخدام SliverList للأداء العالي عند التمرير
              physics: const BouncingScrollPhysics(),
              slivers: [
                _PremiumHeader(baseColor: baseColor, textDark: textDark), // ترويسة الصفحة كويدجت منفصل
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      SizedBox(height: 16.h),
                      const _FeaturedBanner(), // بنر الفعالية المميزة (ثابت)
                      SizedBox(height: 32.h),
                      _SectionHeader(title: 'التصنيفات', textDark: textDark), // عنوان القسم
                      SizedBox(height: 16.h),
                      _CategoryBar( // شريط التصنيفات (معزول الأداء)
                        categories: _categories,
                        selectedCategory: _selectedCategory,
                        baseColor: baseColor,
                        textDark: textDark,
                        primaryBlue: primaryBlue,
                        primaryPurple: primaryPurple,
                        onCategoryChanged: (cat) => setState(() => _selectedCategory = cat),
                      ),
                      SizedBox(height: 32.h),
                      _SectionHeader(title: 'الأنشطة والفعاليات', textDark: textDark), // عنوان القسم الثاني
                      SizedBox(height: 16.h),
                      if (filteredActivities.isEmpty) // حالة عدم وجود نتائج
                        _EmptyState(textMuted: textMuted)
                      else // عرض النتائج المفلترة
                        ...filteredActivities.map((activity) => _ActivityCard(
                          activity: activity,
                          baseColor: baseColor,
                          textDark: textDark,
                          textMuted: textMuted,
                          onUpdate: (result) => setState(() { // تحديث حالة النشاط عند الرجوع من التفاصيل
                            activity['status'] = result == 'accepted' ? 'تم الموافقة' : 'تم الرفض';
                            activity['statusColor'] = result == 'accepted' ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
                          }),
                        )),
                      SizedBox(height: 40.h), // مسافة سفلية
                    ]),
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

// ── Supporting Widgets ─────────────────────────────────────────────────────

class _PremiumHeader extends StatelessWidget { // ويدجت ترويسة الصفحة (معزول)
  final Color baseColor, textDark; // الألوان الأساسية
  const _PremiumHeader({required this.baseColor, required this.textDark}); // مشيد الترويسة

  @override // بناء الترويسة المثبتة
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: baseColor,
      elevation: 0,
      pinned: true, // تثبيت عند التمرير
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          GestureDetector( // زر الرجوع بتصميم Neumorphic
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: baseColor,
                shape: BoxShape.circle,
                boxShadow: [
                  const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
                ],
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: textDark, size: 20.sp),
            ),
          ),
          SizedBox(width: 16.w),
          Text('الأنشطة والفعاليات', style: TextStyle(color: textDark, fontWeight: FontWeight.w900, fontSize: 22.sp, fontFamily: 'Cairo')), // العنوان
        ],
      ),
    );
  }
}

class _FeaturedBanner extends StatelessWidget { // ويدجت بنر الفعالية المميزة (معزول)
  const _FeaturedBanner(); // مشيد ثابت

  @override // بناء البنر بصورة وتدرج لونى
  Widget build(BuildContext context) {
    return Container(
      height: 180.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
        ],
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1509062522246-3755977927d7?w=800&q=80'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container( // تدرج أسود لتحسين وضوح النص
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),
          gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent]),
        ),
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container( // ملصق "فعالية مميزة"
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(10.r)),
              child: Text('فعالية مميزة', style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
            ),
            SizedBox(height: 8.h),
            Text('مخيم الابتكار الصيفي 2026', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo')), // الاسم
            Row(
              children: [
                const Icon(Icons.location_on_rounded, color: Colors.white70, size: 14),
                SizedBox(width: 4.w),
                Text('المبنى الرئيسي - القاعة الكبرى', style: TextStyle(color: Colors.white70, fontSize: 11.sp, fontFamily: 'Cairo')), // الموقع
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget { // ويدجت عنوان القسم (بسيط ومعزول)
  final String title; // نص العنوان
  final Color textDark; // اللون
  const _SectionHeader({required this.title, required this.textDark}); // مشيد ثابت

  @override // بناء النص بخط عريض
  Widget build(BuildContext context) {
    return Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: textDark, fontFamily: 'Cairo'));
  }
}

class _CategoryBar extends StatelessWidget { // ويدجت شريط التصنيفات الأفقي (معزول الأداء)
  final List<String> categories; // قائمة التصنيفات
  final String selectedCategory; // المختار حالياً
  final Color baseColor, textDark, primaryBlue, primaryPurple; // الألوان
  final ValueChanged<String> onCategoryChanged; // دالة التغيير

  const _CategoryBar({ // مشيد الشريط
    required this.categories,
    required this.selectedCategory,
    required this.baseColor,
    required this.textDark,
    required this.primaryBlue,
    required this.primaryPurple,
    required this.onCategoryChanged,
  });

  @override // بناء قائمة التصنيفات
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final active = selectedCategory == cat;
          return GestureDetector(
            onTap: () => onCategoryChanged(cat),
            child: AnimatedContainer( // تفاعل حركى عند الاختيار
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(left: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                gradient: active ? LinearGradient(colors: [primaryBlue, primaryPurple]) : null,
                color: active ? null : baseColor,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: active ? [BoxShadow(color: primaryPurple.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))] : [
                  const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
                ],
              ),
              alignment: Alignment.center,
              child: Text(cat, style: TextStyle(color: active ? Colors.white : textDark, fontWeight: FontWeight.bold, fontSize: 13.sp, fontFamily: 'Cairo')), // اسم التصنيف
            ),
          );
        },
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget { // ويدجت بطاقة النشاط (معزول تماماً لتحسين أداء القائمة)
  final Map<String, dynamic> activity; // بيانات النشاط
  final Color baseColor, textDark, textMuted; // الألوان
  final ValueChanged<String?> onUpdate; // دالة التحديث عند الرجوع

  const _ActivityCard({ // مشيد البطاقة الثابت
    required this.activity,
    required this.baseColor,
    required this.textDark,
    required this.textMuted,
    required this.onUpdate,
  });

  @override // بناء بطاقة النشاط بتصميم Neumorphic
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async { // الانتقال للتفاصيل والانتظار للنتيجة
        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityDetailScreen(activity: activity)));
        if (result != null) onUpdate(result);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: [
            const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
          ],
        ),
        child: Row(
          children: [
            Container( // أيقونة النشاط الملونة
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(color: (activity['color'] as Color).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(18.r)),
              child: Icon(activity['icon'] as IconData, color: activity['color'] as Color, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded( // نصوص وصف النشاط
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activity['title']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: textDark, fontFamily: 'Cairo', height: 1.3)), // العنوان
                  SizedBox(height: 4.h),
                  Text(activity['subtitle']!, style: TextStyle(color: textMuted, fontSize: 11.sp, fontFamily: 'Cairo')), // الوصف الفرعي
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Container( // ملصق حالة التسجيل
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(color: (activity['statusColor'] as Color).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.r)),
              child: Text(activity['status']!, style: TextStyle(color: activity['statusColor'] as Color, fontSize: 10.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo')), // نص الحالة
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget { // ويدجت الحالة الفارغة (معزول)
  final Color textMuted; // اللون
  const _EmptyState({required this.textMuted}); // مشيد ثابت

  @override // بناء رسالة لا توجد فعاليات
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.r),
        child: Text('لا توجد فعاليات حالياً', style: TextStyle(color: textMuted, fontFamily: 'Cairo', fontSize: 14.sp)),
      ),
    );
  }
}

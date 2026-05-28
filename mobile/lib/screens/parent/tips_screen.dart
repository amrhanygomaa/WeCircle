/*
🧠 اسم الملف: tips_screen.dart

📌 بيعمل إيه؟
دي شاشة بتعرض قائمة من النصائح والمقالات التربوية اللي بتهم أولياء الأمور.

👤 موجه لمين؟
- أولياء أمور

💡 فكرته:
نشر الوعي التربوي وتقديم دعم تعليمي وسلوكي لأولياء الأمور.
*/

import 'package:flutter/material.dart'; // استيراد مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة التحكم في أحجام الشاشة
import 'package:wesal/core/theme/app_theme.dart'; // استيراد ثيم التطبيق
import '../../widgets/wesal_background.dart';
import '../../services/responsive_helper.dart'; // استيراد مساعد الاستجابة
import 'tip_detail_screen.dart'; // استيراد شاشة تفاصيل النصيحة

class EducationalTipsScreen extends StatefulWidget { // تعريف كلاس شاشة النصائح التعليمية كـ StatefulWidget
  const EducationalTipsScreen({super.key}); // مشيد الكلاس

  @override // إنشاء حالة الشاشة
  State<EducationalTipsScreen> createState() => _EducationalTipsScreenState();
}

class _EducationalTipsScreenState extends State<EducationalTipsScreen> { // كلاس حالة شاشة النصائح
  String _selectedCategory = 'الكل'; // التصنيف المختار حالياً

  @override // بناء واجهة المستخدم الرئيسية
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> articles = _getArticles(); // الحصول على بيانات المقالات
    final filteredArticles = _selectedCategory == 'الكل' ? articles : articles.where((a) => a['category'] == _selectedCategory).toList();

    return Directionality( // ضبط الاتجاه للعربية
      textDirection: TextDirection.rtl,
      child: WesalBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent, // شفاف لرؤية الخلفية الموحدة
          body: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              const _TipsHeader(), // ترويسة الصفحة الفاخرة (معزولة)
              SliverPadding(
                padding: AppTheme.screenPadding(context).copyWith(top: 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    SizedBox(height: 16.h),
                    _TodayTipCard(articles: articles), // بطاقة نصيحة اليوم (معزولة)
                    SizedBox(height: 48.h),
                    const _SectionHeader(title: 'فيديوهات تعليمية', action: 'عرض الكل'), // عنوان قسم الفيديوهات
                    SizedBox(height: 20.h),
                    const _VideosRow(), // شريط الفيديوهات (معزول)
                    SizedBox(height: 48.h),
                    const _SectionHeader(title: 'مقالات مختارة', action: ''),
                    SizedBox(height: 20.h),
                    _CategoryFilters(selectedCategory: _selectedCategory, onChanged: (cat) => setState(() => _selectedCategory = cat)), // فلاتر التصنيفات (معزولة)
                    SizedBox(height: 24.h),
                    if (filteredArticles.isEmpty) const _NoArticlesPlaceholder(), // حالة عدم وجود مقالات
                    ...filteredArticles.map((article) => _ArticleItem(article: article)), // عرض المقالات (معزولة الأداء)
                    SizedBox(height: 120.h),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getArticles() { // دالة تجلب بيانات المقالات (محاكاة)
    return [
      {'title': 'كيف تحمي طفلك من التنمر في المدرسة؟', 'subtitle': 'سلوك • 8 دقائق', 'category': 'سلوك', 'icon': Icons.security_rounded, 'color': AppTheme.softRose, 'content': 'التنمر مشكلة تؤرق الكثير من الآباء...'},
      {'title': 'التعامل مع السلوك العدواني والعنيف عند الأطفال', 'subtitle': 'سلوك • 10 دقائق', 'category': 'سلوك', 'icon': Icons.mood_bad_rounded, 'color': AppTheme.vibrantOrange, 'content': 'السلوك العنيف غالباً ما يكون صرخة...'},
      {'title': 'خطة فعالة لعلاج إدمان الهاتف والأجهزة الإلكترونية', 'subtitle': 'سلوك • 12 دقيقة', 'category': 'سلوك', 'icon': Icons.phonelink_erase_rounded, 'color': AppTheme.skyBlue, 'content': 'إدمان الشاشات يؤثر على النمو...'},
      {'title': 'خطوات عملية لزيادة تركيز طفلك وسرعة استيعابه', 'subtitle': 'دراسة • 6 دقائق', 'category': 'دراسة', 'icon': Icons.psychology_rounded, 'color': AppTheme.emeraldGreen, 'content': 'التركيز هو مهارة يمكن تنميتها...'},
      {'title': 'لماذا يكذب الأطفال؟ وكيف نغرس فيهم قيمة الصدق؟', 'subtitle': 'سلوك • 7 دقائق', 'category': 'سلوك', 'icon': Icons.record_voice_over_rounded, 'color': AppTheme.royalBlue, 'content': 'الطفل غالباً ما يكذب خوفاً من العقاب...'},
      {'title': 'كيف تكتشف وتنمي مواهب طفلك الإيجابية؟', 'subtitle': 'تطوير • 9 دقائق', 'category': 'تطوير', 'icon': Icons.auto_awesome_rounded, 'color': AppTheme.accentGold, 'content': 'كل طفل يمتلك جانباً مشرقاً...'},
    ];
  }
}

// ── Optimized Sub-Widgets ──────────────────────────────────────────────────

class _TipsHeader extends StatelessWidget { // ويدجت ترويسة شاشة النصائح (معزول)
  const _TipsHeader();

  @override // بناء شريط التطبيق المتمدد
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.h, backgroundColor: Colors.transparent, elevation: 0, pinned: true,
      leading: IconButton(icon: Icon(Icons.keyboard_arrow_right_rounded, color: AppTheme.primaryDark, size: 32.sp), onPressed: () => Navigator.pop(context)),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(right: context.responsive(24.w, tablet: 48.w), bottom: 18.h),
        title: Text('نصائح تربوية', style: TextStyle(color: AppTheme.primaryDark, fontWeight: FontWeight.w900, fontSize: 24.sp, fontFamily: 'Outfit', letterSpacing: -1)),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppTheme.premiumShadow()),
            child: IconButton(icon: Icon(Icons.bookmark_rounded, color: AppTheme.accentGold, size: 20.sp), onPressed: () {}),
          ),
        ),
      ],
    );
  }
}

class _TodayTipCard extends StatelessWidget { // ويدجت بطاقة نصيحة اليوم (معزول)
  final List<Map<String, dynamic>> articles;
  const _TodayTipCard({required this.articles});

  @override // بناء البطاقة بتصميم متدرج جذاب
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(42.r), border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [BoxShadow(color: AppTheme.emeraldGreen.withValues(alpha: 0.15), blurRadius: 30, offset: const Offset(0, 15), spreadRadius: -10)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(42.r),
        child: Stack(
          children: [
            Positioned.fill(child: Opacity(opacity: 0.95, child: Container(decoration: const BoxDecoration(gradient: AppTheme.magicGradient)))),
            Padding(
              padding: EdgeInsets.all(28.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12.r)), child: Text('نصيحة اليوم ✨', style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5))),
                  SizedBox(height: 24.h),
                  Text('القدوة الحسنة هي أسرع طريق لتعليم طفلك الصدق', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w900, fontFamily: 'Outfit', height: 1.3, letterSpacing: -0.5)),
                  SizedBox(height: 12.h),
                  Text('عندما يراك طفلك تفي بوعودك وتتحرى الصدق، سيتعلم أن القيمة في الفعل لا في القول فقط.', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12.sp, height: 1.6, fontWeight: FontWeight.w600)),
                  SizedBox(height: 28.h),
                  _TodayTipActions(articles: articles), // أزرار التفاعل داخل البطاقة
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayTipActions extends StatelessWidget { // ويدجت أزرار بطاقة نصيحة اليوم
  final List<Map<String, dynamic>> articles;
  const _TodayTipActions({required this.articles});

  @override // بناء الزر وعداد الوقت
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              final honestyArticle = articles.firstWhere((a) => a['title']!.contains('يكذب'), orElse: () => articles[0]);
              Navigator.push(context, MaterialPageRoute(builder: (context) => TipDetailScreen(tip: honestyArticle)));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.emeraldGreen, elevation: 0, minimumSize: Size(double.infinity, 45.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r))),
            child: Text('اقرأ المزيد', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp)),
          ),
        ),
        SizedBox(width: 12.w),
        Container(padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h), decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.r)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.timer_outlined, color: Colors.white, size: 14.sp), SizedBox(width: 6.w), Text('3 دقائق', style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold))])),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget { // ويدجت ترويسة القسم (معزول)
  final String title, action;
  const _SectionHeader({required this.title, required this.action});

  @override // بناء العنوان وزر الإجراء
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: const Color(0xFF064E3B), fontFamily: 'Outfit', letterSpacing: -0.5)),
        if (action.isNotEmpty) TextButton(onPressed: () {}, child: Text(action, style: TextStyle(color: AppTheme.emeraldGreen, fontWeight: FontWeight.w900, fontSize: 14.sp))),
      ],
    );
  }
}

class _VideosRow extends StatelessWidget { // ويدجت شريط الفيديوهات (معزول الأداء)
  const _VideosRow();

  @override // بناء قائمة تمرير أفقية للفيديوهات
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal, clipBehavior: Clip.none, padding: EdgeInsets.only(bottom: 20.h), itemCount: 2,
        itemBuilder: (context, index) => _VideoCard(index: index),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget { // ويدجت بطاقة الفيديو (معزول)
  final int index;
  const _VideoCard({required this.index});

  @override // بناء البطاقة بصورة الغلاف وزر التشغيل
  Widget build(BuildContext context) {
    return Container(
      width: context.responsive(280.w, tablet: 360.w), margin: EdgeInsets.only(left: 20.w), decoration: AppTheme.premiumCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)), child: Image.network(index == 0 ? 'https://images.unsplash.com/photo-1543269865-cbf427effbad?q=80&w=500' : 'https://images.unsplash.com/photo-1488190211105-8b0e65b80b4e?q=80&w=500', height: 140.h, width: double.infinity, fit: BoxFit.cover)),
              Container(padding: EdgeInsets.all(12.r), decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle), child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32.sp)),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(index == 0 ? 'نصيحة الخبراء: التعامل مع العنف' : 'مخاطر إدمان الهاتف وطرق الوقاية', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.sp, color: AppTheme.primaryDark, fontFamily: 'Outfit'), maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 8.h),
                Row(children: [Icon(Icons.video_library_rounded, color: AppTheme.emeraldGreen.withValues(alpha: 0.6), size: 14.sp), SizedBox(width: 8.w), Text('فيديو تعليمي • 8:42 دقيقة', style: TextStyle(color: AppTheme.textSlate, fontSize: 11.sp, fontWeight: FontWeight.bold))]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilters extends StatelessWidget { // ويدجت شريط التصنيفات (معزول)
  final String selectedCategory;
  final ValueChanged<String> onChanged;
  const _CategoryFilters({required this.selectedCategory, required this.onChanged});

  @override // بناء شريط الأزرار الأفقى
  Widget build(BuildContext context) {
    final categories = ['الكل', 'سلوك', 'دراسة', 'تطوير', 'صحة'];
    return SizedBox(
      height: 50.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal, clipBehavior: Clip.none, itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSel = selectedCategory == cat;
          return GestureDetector(
            onTap: () => onChanged(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300), margin: EdgeInsets.only(left: 12.w), padding: EdgeInsets.symmetric(horizontal: 24.w),
              decoration: BoxDecoration(color: isSel ? AppTheme.emeraldGreen : Colors.white.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(16.r), border: Border.all(color: isSel ? AppTheme.emeraldGreen : Colors.white, width: 1.5), boxShadow: isSel ? [BoxShadow(color: AppTheme.emeraldGreen.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))] : null),
              alignment: Alignment.center,
              child: Text(cat, style: TextStyle(color: isSel ? Colors.white : AppTheme.textSlate, fontWeight: FontWeight.w900, fontSize: 13.sp, fontFamily: 'Outfit')),
            ),
          );
        },
      ),
    );
  }
}

class _ArticleItem extends StatelessWidget { // ويدجت عنصر المقال فى القائمة (معزول الأداء)
  final Map<String, dynamic> article;
  const _ArticleItem({required this.article});

  @override // بناء بطاقة المقال
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TipDetailScreen(tip: article))),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h), padding: EdgeInsets.all(20.r), decoration: AppTheme.premiumCardDecoration(),
        child: Row(
          children: [
            Container(padding: EdgeInsets.all(12.r), decoration: BoxDecoration(color: (article['color'] as Color).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16.r)), child: Icon(article['icon'] as IconData, color: article['color'] as Color, size: 24.sp)),
            SizedBox(width: 16.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(article['title']!, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp, color: AppTheme.primaryDark, fontFamily: 'Outfit'), maxLines: 2, overflow: TextOverflow.ellipsis), SizedBox(height: 6.h), Text(article['subtitle']!, style: TextStyle(color: AppTheme.textSlate, fontSize: 11.sp, fontWeight: FontWeight.w900))])),
            const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFE2E8F0), size: 16),
          ],
        ),
      ),
    );
  }
}

class _NoArticlesPlaceholder extends StatelessWidget { // ويدجت حالة عدم وجود مقالات
  const _NoArticlesPlaceholder();

  @override // بناء نص التلميح
  Widget build(BuildContext context) {
    return Center(child: Padding(padding: EdgeInsets.all(40.r), child: const Text('لا يوجد مقالات حالياً', style: TextStyle(color: AppTheme.textSlate))));
  }
}

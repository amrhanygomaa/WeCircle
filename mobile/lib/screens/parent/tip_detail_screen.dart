/*
🧠 اسم الملف: tip_detail_screen.dart

📌 بيعمل إيه؟
شاشة بتعرض تفاصيل نصيحة تربوية معينة بشكل كامل ومفيد.

👤 موجه لمين؟
- أولياء أمور

💡 فكرته:
تقديم محتوى تربوي قيم يساعد ولي الأمر في التعامل مع ابنه بشكل أحسن.
*/

import 'package:flutter/material.dart'; // استيراد مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة التحكم في أحجام الشاشة
import 'package:wesal/core/theme/app_theme.dart'; // استيراد ثيم التطبيق
import '../../widgets/wesal_background.dart';

class TipDetailScreen extends StatelessWidget { // تعريف كلاس شاشة تفاصيل النصيحة كـ StatelessWidget
  final Map<String, dynamic> tip; // استقبال بيانات النصيحة المختارة
  const TipDetailScreen({super.key, required this.tip}); // مشيد الكلاس

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: WesalBackground(
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              _TipHeader(tip: tip),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _TipContentArea(tip: tip),
                    SizedBox(height: 120.h),
                  ]),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const _ConfirmReadButton(),
      ),
    );
  }
}

// ── Optimized Sub-Widgets ──────────────────────────────────────────────────

class _TipHeader extends StatelessWidget { // ويدجت ترويسة النصيحة (معزول)
  final Map<String, dynamic> tip;
  const _TipHeader({required this.tip});

  @override // بناء شريط التطبيق المتمدد بالصورة
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300.h, pinned: true, backgroundColor: const Color(0xFF10B981), elevation: 0,
      leading: Container(
        margin: EdgeInsets.all(8.r), decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2), shape: BoxShape.circle),
        child: IconButton(icon: Icon(Icons.keyboard_arrow_right_rounded, color: Colors.white, size: 28.sp), onPressed: () => Navigator.pop(context)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1543269865-cbf427effbad?q=80&w=1000', fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(decoration: const BoxDecoration(gradient: AppTheme.magicGradient), child: Center(child: Icon(Icons.school_rounded, color: Colors.white, size: 60.sp))),
            ),
            Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withValues(alpha: 0.3), Colors.black.withValues(alpha: 0.7)]))),
          ],
        ),
      ),
    );
  }
}

class _TipContentArea extends StatelessWidget { // ويدجت عرض محتوى النصيحة (معزول)
  final Map<String, dynamic> tip;
  const _TipContentArea({required this.tip});

  @override // بناء النصوص الوصفية والمحتوى
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CategoryTag(category: tip['category'], color: tip['color']), // وسم التصنيف
        SizedBox(height: 20.h),
        Text(tip['title'] ?? '', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B), height: 1.3, fontFamily: 'Outfit')),
        SizedBox(height: 16.h),
        _ReadingTimeRow(subtitle: tip['subtitle']), // صف وقت القراءة
        SizedBox(height: 32.h),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
        SizedBox(height: 32.h),
        Text(
          tip['content'] ?? 'القراءة ليست مجرد هواية، بل هي غذاء للعقل والروح. شجع طفلك على القراءة من خلال توفير قصص ملونة وجذابة، وخصص وقتاً يومياً للقراءة سوياً قبل النوم لبناء علاقة وطيدة مع الكتاب.',
          style: TextStyle(fontSize: 16.sp, color: const Color(0xFF64748B), height: 1.9, fontWeight: FontWeight.w600, fontFamily: 'Outfit'),
        ),
        SizedBox(height: 48.h),
        const _SourceBadge(), // شارة المصدر
        SizedBox(height: 24.h),
        const _InteractionsCard(), // بطاقة التفاعل
      ],
    );
  }
}

class _CategoryTag extends StatelessWidget { // ويدجت وسم التصنيف
  final String? category;
  final Color? color;
  const _CategoryTag({this.category, this.color});

  @override // بناء الوسم الملون
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(color: (color ?? Colors.blue).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.r)),
      child: Text(category?.toUpperCase() ?? 'نصيحة', style: TextStyle(color: color ?? Colors.blue, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }
}

class _ReadingTimeRow extends StatelessWidget { // ويدجت وقت القراءة
  final String? subtitle;
  const _ReadingTimeRow({this.subtitle});

  @override // بناء السطر بالأيقونة
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.timer_outlined, color: const Color(0xFF64748B), size: 16.sp),
        SizedBox(width: 8.w),
        Text(subtitle ?? '', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _SourceBadge extends StatelessWidget { // ويدجت شارة المصدر
  const _SourceBadge();

  @override // بناء الشارة الخضراء
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 16),
        SizedBox(width: 8.w),
        const Text('المصدر: خبراء التربية في وصال وجمعيات دولية', style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _InteractionsCard extends StatelessWidget { // ويدجت بطاقة التفاعل والمفضلة
  const _InteractionsCard();

  @override // بناء البطاقة بتصميم جذاب
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.05), borderRadius: BorderRadius.circular(24.r), border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.1))),
      child: Row(
        children: [
          Container(padding: EdgeInsets.all(10.r), decoration: const BoxDecoration(color: Color(0x1A10B981), shape: BoxShape.circle), child: const Icon(Icons.info_outline_rounded, color: Color(0xFF10B981), size: 20)),
          SizedBox(width: 20.w),
          const Expanded(child: Text('هل أعجبك هذا المحتوى؟ يمكنك حفظه للرجوع إليه لاحقاً عبر أيقونة المفضلة.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, height: 1.5, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

class _ConfirmReadButton extends StatelessWidget { // ويدجت زر التأكيد السفلى
  const _ConfirmReadButton();

  @override // بناء الزر المتدرج
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 60.h),
      child: Container(
        height: 62.h,
        decoration: BoxDecoration(
          gradient: AppTheme.magicGradient, borderRadius: BorderRadius.circular(20.r),
          boxShadow: [BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.35), blurRadius: 25, offset: const Offset(0, 12))],
        ),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r))),
          child: const Text('فهمت، شكراً لك', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Outfit')),
        ),
      ),
    );
  }
}

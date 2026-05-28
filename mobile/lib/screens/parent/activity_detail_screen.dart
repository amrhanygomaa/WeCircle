/*
🧠 اسم الملف: activity_detail_screen.dart

📌 بيعمل إيه؟
شاشة بتعرض تفاصيل نشاط معين، زي المعاد، المكان، والوصف بتاع النشاط ده.

👤 موجه لمين؟
- أولياء أمور

💡 فكرته:
توفير كل المعلومات اللي ولي الأمر محتاجها عشان يقرر يشترك لابنه في النشاط ولا لأ.
*/

import 'package:flutter/material.dart'; // استيراد مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة التحكم في أحجام الشاشة
import '../../widgets/wesal_background.dart';

class ActivityDetailScreen extends StatefulWidget { // تعريف كلاس شاشة تفاصيل النشاط كـ StatefulWidget
  final Map<String, dynamic> activity; // متغير لاستقبال بيانات النشاط

  const ActivityDetailScreen({super.key, required this.activity}); // مشيد الكلاس

  @override // إنشاء حالة الشاشة
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> { // كلاس حالة شاشة تفاصيل النشاط
  // ── Design tokens ─────────────────────────────────────────────────────────
  static const Color primaryBlue   = Color(0xFF2563EB); // اللون الأزرق الأساسي
  static const Color primaryPurple = Color(0xFF9333EA); // اللون البنفسجي الأساسي
  static const Color baseColor     = Color(0xFFF0F3F8); // لون الخلفية الأساسي
  static const Color textDark      = Color(0xFF1E293B); // لون النص الداكن
  static const Color textMuted     = Color(0xFF64748B); // لون النص الباهت

  String? _currentStatus; // متغير الحالة المحلية لقرار المشاركة

  void _handleParticipation(bool accepted) { // دالة معالجة قرار المشاركة (قبول أو رفض)
    showDialog( // إظهار مربع حوار تأكيدي
      context: context,
      builder: (context) => _ParticipationDialog( // استدعاء ويدجت الحوار المخصص
        accepted: accepted,
        baseColor: baseColor,
        textDark: textDark,
        textMuted: textMuted,
        onConfirm: () { // دالة تنفذ عند التأكيد داخل الحوار
          setState(() => _currentStatus = accepted ? 'تم القبول' : 'تم الرفض'); // تحديث الحالة
          Navigator.pop(context); // إغلاق الحوار
        },
      ),
    );
  }

  @override // بناء واجهة الشاشة الرئيسية
  Widget build(BuildContext context) {
    final activity = widget.activity; // جلب البيانات
    return Directionality( // ضبط الاتجاه للعربية
      textDirection: TextDirection.rtl,
      child: WesalBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent, // جعل خلفية السكافولد شفافة لرؤية الخلفية الموحدة
          body: CustomScrollView( // استخدام CustomScrollView لتأثيرات الترويسة المتحركة
            physics: const BouncingScrollPhysics(),
            slivers: [
              _DetailAppBar( // ترويسة الصفحة (AppBar) كويدجت منفصل
                activity: activity,
                baseColor: baseColor,
                primaryBlue: primaryBlue,
                currentStatus: _currentStatus,
              ),
              SliverToBoxAdapter( // تحويل المحتوى العادى ليتناسب مع Sliver
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 100.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusHeader( // سطر الحالة والنوع
                        type: activity['type'] ?? 'نشاط عام',
                        currentStatus: _currentStatus,
                        primaryBlue: primaryBlue,
                        primaryPurple: primaryPurple,
                      ),
                      SizedBox(height: 20.h),
                      Text(activity['title'] ?? '', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: textDark, fontFamily: 'Cairo', height: 1.2)), // العنوان
                      SizedBox(height: 30.h),
                      const _InfoRow(), // سطر معلومات التاريخ والوقت (ثابت)
                      SizedBox(height: 40.h),
                      Text('عن النشاط', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: textDark, fontFamily: 'Cairo')), // عنوان الوصف
                      SizedBox(height: 12.h),
                      Text( // نص وصف النشاط
                        'هدفنا من هذا النشاط هو تعزيز مهارات الطلاب الاجتماعية والبدنية. سيتضمن البرنامج فقرات تفاعلية بإشراف نخبة من المتخصصين.',
                        style: TextStyle(fontSize: 14.sp, color: textMuted, height: 1.7, fontFamily: 'Cairo'),
                      ),
                      SizedBox(height: 32.h),
                      const _RequirementsCard(), // بطاقة المتطلبات (معزولة الأداء)
                      SizedBox(height: 48.h),
                      if (_currentStatus == null) // أزرار التحكم تظهر فقط إذا لم يتم اتخاذ قرار
                        _ActionButtons(onAccept: () => _handleParticipation(true), onReject: () => _handleParticipation(false), primaryBlue: primaryBlue, primaryPurple: primaryPurple, baseColor: baseColor)
                      else // عرض الحالة النهائية بعد اتخاذ القرار
                        _FinalStatusInfo(status: _currentStatus!),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Optimized Sub-Widgets ──────────────────────────────────────────────────

class _DetailAppBar extends StatelessWidget { // ويدجت ترويسة الصفحة المتمددة
  final Map<String, dynamic> activity; // بيانات النشاط
  final Color baseColor, primaryBlue; // الألوان
  final String? currentStatus; // الحالة الحالية

  const _DetailAppBar({required this.activity, required this.baseColor, required this.primaryBlue, this.currentStatus});

  @override // بناء الترويسة مع الصورة
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300.h,
      pinned: true, // تثبيت عند التمرير
      backgroundColor: primaryBlue,
      leading: GestureDetector( // زر الرجوع المخصص
        onTap: () => Navigator.pop(context, currentStatus == 'تم القبول' ? 'accepted' : (currentStatus == 'تم الرفض' ? 'rejected' : null)),
        child: Container(
          margin: EdgeInsets.all(8.r),
          decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
          child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.sp),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar( // خلفية الترويسة (Stack)
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(_getImageForActivity(activity['type'] ?? ''), fit: BoxFit.cover), // جلب الصورة بناءً على النوع
            DecoratedBox( // تدرج لونى لتحسين المظهر
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withValues(alpha: 0.4), Colors.transparent, baseColor]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getImageForActivity(String type) { // منطق اختيار الصورة المناسبة
    switch (type) {
      case 'رحلات': return 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=800&q=80';
      case 'أكاديمي': return 'https://images.unsplash.com/photo-1503676260728-1c00da096a0b?w=800&q=80';
      case 'رياضة': return 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800&q=80';
      case 'مسابقات': return 'https://images.unsplash.com/photo-1528605248644-14dd04cb21c7?w=800&q=80';
      default: return 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=800&q=80';
    }
  }
}

class _StatusHeader extends StatelessWidget { // ويدجت سطر الحالة والنوع (معزول)
  final String type; // نوع النشاط
  final String? currentStatus; // الحالة الحالية
  final Color primaryBlue, primaryPurple; // الألوان

  const _StatusHeader({required this.type, this.currentStatus, required this.primaryBlue, required this.primaryPurple});

  @override // بناء السطر العلوى للتفاصيل
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container( // ملصق نوع النشاط بتدرج لونى
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primaryBlue, primaryPurple]),
            borderRadius: BorderRadius.circular(15.r),
            boxShadow: [BoxShadow(color: primaryPurple.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Text(type, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.sp, fontFamily: 'Cairo')),
        ),
        if (currentStatus != null) // إظهار قرار ولى الأمر إذا اتخذ
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: (currentStatus == 'تم القبول' ? Colors.green : Colors.redAccent).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15.r),
              border: Border.all(color: currentStatus == 'تم القبول' ? Colors.green : Colors.redAccent),
            ),
            child: Text(currentStatus!, style: TextStyle(color: currentStatus == 'تم القبول' ? Colors.green : Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 11.sp, fontFamily: 'Cairo')),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget { // سطر معلومات النشاط الثابتة
  const _InfoRow(); // مشيد ثابت

  @override // بناء السطر الأفقي للمعلومات
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _InfoItem(icon: Icons.calendar_today_rounded, label: 'التاريخ', value: '5 أبريل 2026'),
        _InfoItem(icon: Icons.access_time_rounded, label: 'الوقت', value: '09:00 ص'),
        _InfoItem(icon: Icons.location_on_rounded, label: 'المكان', value: 'النادي المدرسي'),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget { // ويدجت معلومة واحدة (معزول)
  final IconData icon; // الأيقونة
  final String label, value; // النصوص
  const _InfoItem({required this.icon, required this.label, required this.value}); // مشيد ثابت

  @override // بناء عنصر المعلومة
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container( // أيقونة Neumorphic دائرية
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F3F8),
            shape: BoxShape.circle,
            boxShadow: [
              const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 18.sp),
        ),
        SizedBox(height: 10.h),
        Text(label, style: TextStyle(fontSize: 10.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        Text(value, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B), fontFamily: 'Cairo')),
      ],
    );
  }
}

class _RequirementsCard extends StatelessWidget { // ويدجت بطاقة المتطلبات (معزول الأداء)
  const _RequirementsCard(); // مشيد ثابت

  @override // بناء بطاقة المتطلبات بتصميم Neumorphic
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F8),
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.checklist_rounded, color: const Color(0xFF9333EA), size: 22.sp),
              SizedBox(width: 12.w),
              Text('المتطلبات الأساسية', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B), fontFamily: 'Cairo')),
            ],
          ),
          SizedBox(height: 20.h),
          const _RequirementItem(text: 'الزي المدرسي الرياضي'),
          const _RequirementItem(text: 'زجاجة مياه خاصة'),
          const _RequirementItem(text: 'الموافقة الكتابية الموقعة'),
        ],
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget { // عنصر متطلب واحد فى القائمة
  final String text; // نص المتطلب
  const _RequirementItem({required this.text}); // مشيد ثابت

  @override // بناء سطر المتطلب
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 18),
          SizedBox(width: 12.w),
          Text(text, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF1E293B), fontWeight: FontWeight.w500, fontFamily: 'Cairo')),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget { // ويدجت أزرار المشاركة (معزول)
  final VoidCallback onAccept, onReject; // دوال الضغط
  final Color primaryBlue, primaryPurple, baseColor; // الألوان

  const _ActionButtons({required this.onAccept, required this.onReject, required this.primaryBlue, required this.primaryPurple, required this.baseColor});

  @override // بناء الأزرار السفلية
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: onAccept,
            child: Container( // زر الموافقة المتدرج
              height: 48.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primaryBlue, primaryPurple]),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [BoxShadow(color: primaryPurple.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              alignment: Alignment.center,
              child: Text('موافقة ومشاركة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14.sp, fontFamily: 'Cairo')),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: onReject,
            child: Container( // زر الاعتذار Neumorphic
              height: 48.h,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
                ],
              ),
              alignment: Alignment.center,
              child: Text('اعتذار', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 14.sp, fontFamily: 'Cairo')),
            ),
          ),
        ),
      ],
    );
  }
}

class _FinalStatusInfo extends StatelessWidget { // ويدجت عرض الحالة النهائية بعد القرار
  final String status; // القرار المتخذ
  const _FinalStatusInfo({required this.status}); // مشيد ثابت

  @override // بناء رسالة التأكيد الملونة
  Widget build(BuildContext context) {
    bool accepted = status == 'تم القبول';
    Color color = accepted ? Colors.green : Colors.redAccent;
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(accepted ? Icons.verified : Icons.error_outline, color: color),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              accepted ? 'لقد أكدت مشاركة ابنك في هذا النشاط.' : 'لقد أبديت اعتذارك عن هذا النشاط.',
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13.sp, fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipationDialog extends StatelessWidget { // ويدجت مربع الحوار (معزول)
  final bool accepted; // هل القرار قبول؟
  final Color baseColor, textDark, textMuted; // الألوان
  final VoidCallback onConfirm; // دالة التأكيد

  const _ParticipationDialog({required this.accepted, required this.baseColor, required this.textDark, required this.textMuted, required this.onConfirm});

  @override // بناء مربع الحوار Neumorphic
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: baseColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
        title: Container( // أيقونة الحالة فى الحوار
          padding: EdgeInsets.all(15.r),
          decoration: BoxDecoration(color: (accepted ? Colors.green : Colors.redAccent).withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(accepted ? Icons.verified_rounded : Icons.cancel_rounded, color: accepted ? Colors.green : Colors.redAccent, size: 50.sp),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(accepted ? 'تأكيد التسجيل' : 'تأكيد الرفض', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20.sp, color: textDark, fontFamily: 'Cairo')),
            SizedBox(height: 12.h),
            Text(accepted ? 'هل أنت متأكد من رغبتك في تسجيل طفلك في هذا النشاط؟' : 'هل أنت متأكد من رفض المشاركة؟', textAlign: TextAlign.center, style: TextStyle(color: textMuted, fontSize: 13.sp, height: 1.5, fontFamily: 'Cairo')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('تراجع', style: TextStyle(color: textMuted, fontWeight: FontWeight.bold, fontFamily: 'Cairo'))),
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(backgroundColor: accepted ? Colors.green : Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r))),
            child: const Text('تأكيد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}

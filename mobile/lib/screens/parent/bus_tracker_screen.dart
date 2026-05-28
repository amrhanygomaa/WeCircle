/*
🧠 اسم الملف: bus_tracker_screen.dart

📌 بيعمل إيه؟
دي شاشة بتعرض خريطة حية لمكان الباص بتاع المدرسة، وبتعرف ولي الأمر ابنه فين دلوقتي.

👤 موجه لمين؟
- أولياء أمور

💡 فكرته:
توفير راحة بال تامة لولي الأمر وهو بيتابع رحلة ابنه من وإلى المدرسة في الوقت الفعلي.
*/

import 'package:flutter/material.dart'; // استيراد مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة التحكم في أحجام الشاشة
import '../../widgets/wesal_background.dart';

class BusTrackerScreen extends StatefulWidget { // تعريف كلاس شاشة تتبع الحافلة كـ StatefulWidget
  const BusTrackerScreen({super.key}); // مشيد الكلاس

  @override // إنشاء حالة الشاشة لتتبع الحركات
  State<BusTrackerScreen> createState() => _BusTrackerScreenState();
}

class _BusTrackerScreenState extends State<BusTrackerScreen> with SingleTickerProviderStateMixin { // كلاس حالة شاشة التتبع
  // ── Design tokens ─────────────────────────────────────────────────────────
  static const Color primaryBlue   = Color(0xFF2563EB); // اللون الأزرق الأساسي
  static const Color primaryPurple = Color(0xFF9333EA); // اللون البنفسجي الأساسي
  static const Color baseColor     = Color(0xFFF0F3F8); // لون الخلفية الأساسي
  static const Color textDark      = Color(0xFF1E293B); // لون النص الداكن
  static const Color textMuted     = Color(0xFF64748B); // لون النص الباهت
  static const Color accentOrange  = Color(0xFFF59E0B); // لون برتقالي
  static const Color liveRed       = Color(0xFFEF4444); // لون أحمر للبث المباشر

  late AnimationController _pulseController; // متحكم حركة النبض للمؤشر

  @override // تهيئة الحالة وبدء الحركة
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(); // تكرار الحركة
  }

  @override // التخلص من المتحكم عند إغلاق الشاشة
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override // بناء واجهة الشاشة
  Widget build(BuildContext context) {
    return Directionality( // ضبط الاتجاه للعربية
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent, // شفاف لرؤية الخلفية الموحدة
        body: WesalBackground(
          child: Stack( // مكدس لوضع الخريطة واللوحات فوق بعضها
          children: [
            _CleanMap(pulseController: _pulseController, primaryBlue: primaryBlue, baseColor: baseColor, textDark: textDark), // الخريطة الوهمية (معزولة)
            _FloatingHeader(baseColor: baseColor, textDark: textDark, textMuted: textMuted, liveRed: liveRed), // الترويسة الطافية
            _BentoSheet(baseColor: baseColor, textDark: textDark, textMuted: textMuted, primaryBlue: primaryBlue, primaryPurple: primaryPurple, accentOrange: accentOrange), // اللوحة السفلية للمعلومات
          ],
        ),
      ),
    ),
  );
}
}

// ── Optimized Sub-Widgets ──────────────────────────────────────────────────

class _CleanMap extends StatelessWidget { // ويدجت الخريطة الوهمية المبسطة
  final AnimationController pulseController; // متحكم النبض
  final Color primaryBlue, baseColor, textDark; // الألوان الأساسية

  const _CleanMap({required this.pulseController, required this.primaryBlue, required this.baseColor, required this.textDark});

  @override // بناء الخريطة بخطوط وهمية ومؤشر الحافلة
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, height: double.infinity,
      color: Colors.transparent, // جعل الخريطة شفافة لإظهار صورة الخلفية
      child: Stack(
        children: [
          ...List.generate(15, (i) => Positioned(left: i * 80.w, top: 0, bottom: 0, child: Container(width: 1.w, color: Colors.white))), // خطوط طولية
          ...List.generate(30, (i) => Positioned(left: 0, right: 0, top: i * 60.h, child: Container(height: 1.h, color: Colors.white))), // خطوط عرضية
          Center( // مؤشر الحافلة في المنتصف
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ScaleTransition( // حركة النبض الدائرية
                      scale: Tween<double>(begin: 1.0, end: 2.0).animate(CurvedAnimation(parent: pulseController, curve: Curves.easeOut)),
                      child: Container(width: 80.r, height: 80.r, decoration: BoxDecoration(shape: BoxShape.circle, color: primaryBlue.withValues(alpha: 0.1))),
                    ),
                    _BusIcon(primaryBlue: primaryBlue, baseColor: baseColor), // أيقونة الحافلة المنفصلة
                  ],
                ),
                SizedBox(height: 12.h),
                _MapInfoBadge(textDark: textDark, baseColor: baseColor), // ملصق المعلومات الصغير
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BusIcon extends StatelessWidget { // ويدجت أيقونة الحافلة
  final Color primaryBlue, baseColor;
  const _BusIcon({required this.primaryBlue, required this.baseColor});

  @override // بناء الأيقونة بتصميم Neumorphic
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: baseColor, shape: BoxShape.circle,
        boxShadow: [
          const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
        ],
      ),
      child: Icon(Icons.directions_bus_rounded, color: primaryBlue, size: 28.sp),
    );
  }
}

class _MapInfoBadge extends StatelessWidget { // ويدجت ملصق المعلومات على الخريطة
  final Color textDark, baseColor;
  const _MapInfoBadge({required this.textDark, required this.baseColor});

  @override // بناء الملصق
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: baseColor, borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
        ],
      ),
      child: Text('على الطريق • 8 دقائق', style: TextStyle(fontWeight: FontWeight.w900, color: textDark, fontSize: 11.sp, fontFamily: 'Cairo')),
    );
  }
}

class _FloatingHeader extends StatelessWidget { // ويدجت الترويسة العائمة (معزولة)
  final Color baseColor, textDark, textMuted, liveRed;
  const _FloatingHeader({required this.baseColor, required this.textDark, required this.textMuted, required this.liveRed});

  @override // بناء الترويسة في الجزء العلوي
  Widget build(BuildContext context) {
    return Positioned(
      top: 50.h + MediaQuery.of(context).padding.top,
      left: 20.w, right: 20.w,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: baseColor, borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
          ],
        ),
        child: Row(
          children: [
            _BackButton(baseColor: baseColor, textDark: textDark), // زر الرجوع المنفصل
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('تتبع الحافلة', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18.sp, color: textDark, fontFamily: 'Cairo')),
                      SizedBox(width: 8.w),
                      _LiveBadge(liveRed: liveRed), // شارة البث المباشر
                    ],
                  ),
                  Text('الباص الآن في الطريق إلى منزلك', style: TextStyle(color: textMuted, fontSize: 11.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget { // ويدجت زر الرجوع المخصص
  final Color baseColor, textDark;
  const _BackButton({required this.baseColor, required this.textDark});

  @override // بناء الزر
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: baseColor, shape: BoxShape.circle,
          boxShadow: [
            const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
          ],
        ),
        child: const Directionality(textDirection: TextDirection.ltr, child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1E293B))),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget { // ويدجت شارة LIVE
  final Color liveRed;
  const _LiveBadge({required this.liveRed});

  @override // بناء الشارة باللون الأحمر الصريح
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(color: liveRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6.r), border: Border.all(color: liveRed.withValues(alpha: 0.3))),
      child: Row(
        children: [
          Container(width: 4.r, height: 4.r, decoration: BoxDecoration(color: liveRed, shape: BoxShape.circle)),
          SizedBox(width: 4.w),
          Text('LIVE', style: TextStyle(color: liveRed, fontSize: 8.sp, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _BentoSheet extends StatelessWidget { // ويدجت اللوحة السفلية Bento (معزولة)
  final Color baseColor, textDark, textMuted, primaryBlue, primaryPurple, accentOrange;

  const _BentoSheet({
    required this.baseColor,
    required this.textDark,
    required this.textMuted,
    required this.primaryBlue,
    required this.primaryPurple,
    required this.accentOrange,
  });

  @override // بناء اللوحة السفلية بتصميم أنيق
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 420.h, width: double.infinity,
        decoration: BoxDecoration(
          color: baseColor, borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -10))],
        ),
        padding: EdgeInsets.all(24.r),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2.r))), // مقبض السحب
              SizedBox(height: 24.h),
              _DriverCard(baseColor: baseColor, textDark: textDark, textMuted: textMuted, primaryBlue: primaryBlue, primaryPurple: primaryPurple), // بطاقة السائق
              SizedBox(height: 24.h),
              Row( // إحصائيات الوقت والمسافة
                children: [
                  Expanded(child: _StatItem(label: 'الوقت المتبقي', val: '8 دقائق', icon: Icons.timer_outlined, color: accentOrange, baseColor: baseColor, textDark: textDark, textMuted: textMuted)),
                  SizedBox(width: 16.w),
                  Expanded(child: _StatItem(label: 'المسافة', val: '1.2 كم', icon: Icons.location_on_outlined, color: primaryBlue, baseColor: baseColor, textDark: textDark, textMuted: textMuted)),
                ],
              ),
              SizedBox(height: 24.h),
              _RouteTimeline(baseColor: baseColor, textDark: textDark, textMuted: textMuted), // الخط الزمنى للمحطات
            ],
          ),
        ),
      ),
    );
  }
}

class _DriverCard extends StatelessWidget { // ويدجت بطاقة السائق (معزولة)
  final Color baseColor, textDark, textMuted, primaryBlue, primaryPurple;
  const _DriverCard({required this.baseColor, required this.textDark, required this.textMuted, required this.primaryBlue, required this.primaryPurple});

  @override // بناء بطاقة السائق وأزرار التواصل
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: baseColor, borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
        ],
      ),
      child: Row(
        children: [
          _DriverAvatar(baseColor: baseColor, primaryBlue: primaryBlue), // الصورة الرمزية
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ك. محمد طه', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp, color: textDark, fontFamily: 'Cairo')),
                Text('باص رقم #102 • خط جسر السويس', style: TextStyle(color: textMuted, fontSize: 11.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              ],
            ),
          ),
          _CircleAction(icon: Icons.call, color: Colors.green, baseColor: baseColor), // زر الاتصال
          SizedBox(width: 12.w),
          _CircleAction(icon: Icons.chat_bubble_rounded, color: primaryPurple, baseColor: baseColor), // زر الشات
        ],
      ),
    );
  }
}

class _DriverAvatar extends StatelessWidget { // ويدجت صورة السائق
  final Color baseColor, primaryBlue;
  const _DriverAvatar({required this.baseColor, required this.primaryBlue});

  @override // بناء الصورة بالظل
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2.r),
      decoration: BoxDecoration(
        color: baseColor, shape: BoxShape.circle,
        boxShadow: [
          const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
        ],
      ),
      child: CircleAvatar(radius: 25.r, backgroundColor: primaryBlue.withValues(alpha: 0.1), child: Icon(Icons.person, color: primaryBlue, size: 25.sp)),
    );
  }
}

class _StatItem extends StatelessWidget { // ويدجت عنصر إحصائي (معزول)
  final String label, val;
  final IconData icon;
  final Color color, baseColor, textDark, textMuted;

  const _StatItem({
    required this.label, required this.val, required this.icon, required this.color,
    required this.baseColor, required this.textDark, required this.textMuted
  });

  @override // بناء العنصر الإحصائي
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: baseColor, borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10.sp, color: textMuted, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              Text(val, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: textDark, fontFamily: 'Cairo')),
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteTimeline extends StatelessWidget { // ويدجت الخط الزمني للمحطات (معزول)
  final Color baseColor, textDark, textMuted;
  const _RouteTimeline({required this.baseColor, required this.textDark, required this.textMuted});

  @override // بناء الجدول الزمني للمحطات
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: baseColor, borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
        ],
      ),
      child: Column(
        children: [
          _TimelineStep(title: 'نادي الجزيرة - نقطة الانتظار', time: 'منذ 5 دقائق', isPast: true, textDark: textDark, textMuted: textMuted),
          Padding(
            padding: EdgeInsets.only(right: 9.w),
            child: Align(alignment: Alignment.centerRight, child: Container(width: 2.w, height: 20.h, color: Colors.green.withValues(alpha: 0.3))),
          ),
          _TimelineStep(title: 'المنزل (فيلا 12)', time: 'الموعد المتوقع: 3:15 م', isPast: false, textDark: textDark, textMuted: textMuted),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget { // خطوة واحدة في الخط الزمني
  final String title, time;
  final bool isPast;
  final Color textDark, textMuted;

  const _TimelineStep({required this.title, required this.time, required this.isPast, required this.textDark, required this.textMuted});

  @override // بناء الخطوة
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(isPast ? Icons.check_circle_rounded : Icons.radio_button_off_rounded, color: isPast ? Colors.green : textMuted, size: 18.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: textDark, fontFamily: 'Cairo')),
              Text(time, style: TextStyle(color: isPast ? Colors.green : textMuted, fontSize: 10.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
            ],
          ),
        ),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget { // ويدجت زر دائري للإجراءات
  final IconData icon;
  final Color color, baseColor;
  const _CircleAction({required this.icon, required this.color, required this.baseColor});

  @override // بناء الزر Neumorphic
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: baseColor, shape: BoxShape.circle,
        boxShadow: [
          const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
        ],
      ),
      child: Icon(icon, color: color, size: 18.sp),
    );
  }
}

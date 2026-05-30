/*
🧠 اسم الملف: teacher_daily_report_screen.dart

📌 بيعمل إيه؟
شاشة لكتابة التقرير اليومي العام للفصل، إيه اللي اتشرح وإيه الملاحظات العامة.

👤 موجه لمين؟
- مدرسين

💡 فكرته:
توثيق سير العملية التعليمية يوم بيوم وإطلاع الإدارة وأولياء الأمور على المستجدات.
*/

import 'dart:convert';
import 'package:flutter/material.dart'; // استيراد مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة التحكم في أحجام الشاشة
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/api_config.dart';
import '../../widgets/wesal_background.dart';

class TeacherDailyReportScreen extends StatefulWidget { // تعريف كلاس شاشة التقرير اليومي كـ StatefulWidget
  const TeacherDailyReportScreen({super.key}); // مشيد الكلاس

  @override // إنشاء حالة الشاشة
  State<TeacherDailyReportScreen> createState() => _TeacherDailyReportScreenState();
}

class _TeacherDailyReportScreenState extends State<TeacherDailyReportScreen> { // كلاس حالة شاشة التقرير اليومي
  // ── Design tokens ─────────────────────────────────────────────────────────
  static const Color primaryBlue   = Color(0xFF2563EB); // اللون الأزرق الأساسي
  static const Color primaryPurple = Color(0xFF9333EA); // اللون البنفسجي الأساسي
  static const Color baseColor     = Color(0xFFF0F3F8); // لون الخلفية الرمادي الفاتح
  static const Color textDark      = Color(0xFF1E293B); // لون النص الداكن
  static const Color textMuted     = Color(0xFF64748B); // لون النص الباهت
  static const Color presentColor  = Color(0xFF22C55E); // لون النجاح (أخضر)

  // ── State ──────────────────────────────────────────────────────────────────
  double attentionLevel = 3; // مستوى الانتباه الحالي (من 1 إلى 5)
  double participationLevel = 3; // مستوى المشاركة الحالي (من 1 إلى 5)
  String? interactionRating; // تقييم التفاعل العام المختار
  final TextEditingController summaryController = TextEditingController(); // متحكم حقل ملخص اليوم

  List<Map<String, dynamic>> _classes = []; // فصول المعلم المحمّلة من الـ API
  String? _classId; // الفصل المختار حالياً
  bool _submitting = false; // حالة الإرسال الجاري

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  // تحميل فصول المعلم من الـ backend لاختيار الفصل
  Future<void> _loadClasses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('mobile_token') ?? '';
      if (token.isEmpty) return;
      final res = await http.get(
        Uri.parse('${ApiConfig.getBaseUrl()}/teachers/mobile/classes'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200 || !mounted) return;
      final classes =
          (jsonDecode(res.body)['data'] as List? ?? []).cast<Map<String, dynamic>>();
      if (classes.isEmpty) return;
      setState(() {
        _classes = classes;
        _classId = classes.first['id'] as String?;
      });
    } catch (_) {}
  }

  // إرسال التقرير اليومي الحقيقي للـ backend
  Future<void> _submit() async {
    if (_submitting) return;
    if (_classId == null) {
      _toast('يرجى اختيار الفصل أولاً', const Color(0xFFEF4444));
      return;
    }
    if (interactionRating == null || summaryController.text.trim().isEmpty) {
      _toast('يرجى اختيار التفاعل وكتابة ملخص اليوم', const Color(0xFFF59E0B));
      return;
    }
    setState(() => _submitting = true);
    bool ok = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('mobile_token') ?? '';
      final res = await http.post(
        Uri.parse('${ApiConfig.getBaseUrl()}/daily-reports/mobile'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({
          'classId': _classId,
          'interactionLevel': interactionRating,
          'attentionPercent': ((attentionLevel / 5) * 100).round(),
          'participationPercent': ((participationLevel / 5) * 100).round(),
          'summary': summaryController.text.trim(),
        }),
      ).timeout(const Duration(seconds: 15));
      ok = res.statusCode == 200 || res.statusCode == 201;
    } catch (_) {
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
    if (!mounted) return;
    _toast(ok ? 'تم إرسال التقرير بنجاح' : 'تعذّر إرسال التقرير، حاول مرة أخرى',
        ok ? presentColor : const Color(0xFFEF4444));
    if (ok) Navigator.pop(context);
  }

  void _toast(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  final List<Map<String, dynamic>> interactionOptions = [ // خيارات تقييم التفاعل المتاحة
    {'label': 'ممتاز', 'icon': Icons.sentiment_very_satisfied_rounded, 'color': const Color(0xFF22C55E)},
    {'label': 'جيد', 'icon': Icons.sentiment_satisfied_rounded, 'color': const Color(0xFF3B82F6)},
    {'label': 'متوسط', 'icon': Icons.sentiment_neutral_rounded, 'color': const Color(0xFFF59E0B)},
    {'label': 'ضعيف', 'icon': Icons.sentiment_dissatisfied_rounded, 'color': const Color(0xFFEF4444)},
  ];

  List<BoxShadow> get _raiseShadow => [ // دالة للحصول على تأثير الظل Neumorphic المرتفع
    const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)), // ظل إضاءة علوي
    BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)), // ظل عمق سفلي
  ];

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
                        _buildSectionTitle('الفصل'), // عنوان قسم اختيار الفصل
                        _buildClassPicker(), // اختيار الفصل المحمّل من الـ API
                        SizedBox(height: 24.h), // مسافة رأسية

                        _buildSectionTitle('مستوى التفاعل العام'), // عنوان قسم التفاعل
                        _buildInteractionRating(), // بناء أزرار تقييم التفاعل
                        SizedBox(height: 24.h), // مسافة رأسية
                        
                        _buildSectionTitle('نسبة الانتباه'), // عنوان قسم نسبة الانتباه
                        _buildSliderBox( // بناء شريط منزلق لاختيار النسبة
                          value: attentionLevel,
                          onChanged: (v) => setState(() => attentionLevel = v),
                          color: const Color(0xFF3B82F6),
                        ),
                        SizedBox(height: 24.h), // مسافة رأسية
                        
                        _buildSectionTitle('نسبة المشاركة'), // عنوان قسم نسبة المشاركة
                        _buildSliderBox( // بناء شريط منزلق لاختيار النسبة
                          value: participationLevel,
                          onChanged: (v) => setState(() => participationLevel = v),
                          color: const Color(0xFF22C55E),
                        ),
                        SizedBox(height: 24.h), // مسافة رأسية
                        
                        _buildSectionTitle('ملخص اليوم'), // عنوان قسم ملخص اليوم
                        _buildNoteField(), // بناء حقل كتابة الملخص
                        SizedBox(height: 120.h), // مسافة سفلية إضافية للتمرير
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // زر عائم في الأسفل الوسط
          floatingActionButton: _buildSubmitButton(), // بناء زر إرسال التقرير
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
          Text('التقرير اليومي', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: textDark, fontFamily: 'Cairo')),
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

  Widget _buildClassPicker() { // دالة بناء شريط اختيار الفصل أفقياً
    if (_classes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(20.r), boxShadow: _raiseShadow),
        child: Text('لا توجد فصول متاحة', style: TextStyle(fontSize: 12.sp, color: textMuted, fontFamily: 'Cairo')),
      );
    }
    return SizedBox(
      height: 48.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _classes.length,
        itemBuilder: (context, index) {
          final c = _classes[index];
          final active = _classId == c['id'];
          return GestureDetector(
            onTap: () => setState(() => _classId = c['id'] as String?),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(left: 10.w),
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? primaryBlue : baseColor,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: active
                    ? [BoxShadow(color: primaryBlue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
                    : _raiseShadow,
              ),
              child: Text('${c['name'] ?? ''}',
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: active ? Colors.white : textDark, fontFamily: 'Cairo')),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInteractionRating() { // دالة بناء أزرار تقييم التفاعل الرمزي (Emojis)
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(20.r), boxShadow: _raiseShadow),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: interactionOptions.map((opt) {
          final active = interactionRating == opt['label']; // هل هذا الخيار هو المختار؟
          final Color color = opt['color'];
          return GestureDetector(
            onTap: () => setState(() => interactionRating = opt['label']), // تحديث التقييم
            child: AnimatedContainer( // زر التقييم بتصميم تفاعلي
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
              decoration: BoxDecoration(
                color: active ? color : baseColor,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: active ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : _raiseShadow,
              ),
              child: Column(
                children: [
                  Icon(opt['icon'] as IconData, color: active ? Colors.white : color, size: 28.sp),
                  SizedBox(height: 6.h),
                  Text(opt['label'] as String, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: active ? Colors.white : textDark, fontFamily: 'Cairo')),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSliderBox({required double value, required Function(double) onChanged, required Color color}) { // دالة بناء صندوق يحتوي على شريط منزلق (Slider) للتقييم الرقمي
    final percentage = ((value / 5) * 100).round(); // تحويل القيمة لنسبة مئوية للعرض
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(20.r), boxShadow: _raiseShadow),
      child: Column(
        children: [
          Row( // عرض حدود النطاق والنسبة الحالية المكتوبة
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('منخفض', style: TextStyle(fontSize: 11.sp, color: textMuted, fontFamily: 'Cairo')),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10.r)),
                child: Text('$percentage%', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: color, fontFamily: 'Outfit')),
              ),
              Text('مرتفع', style: TextStyle(fontSize: 11.sp, color: textMuted, fontFamily: 'Cairo')),
            ],
          ),
          SliderTheme( // تخصيص مظهر الشريط المنزلق
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.15),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(value: value, min: 1, max: 5, divisions: 4, onChanged: onChanged), // شريط الاختيار
          ),
        ],
      ),
    );
  }

  Widget _buildNoteField() { // دالة بناء حقل إدخال ملخص اليوم المكتوب
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(20.r), boxShadow: _raiseShadow),
      child: TextField(
        controller: summaryController,
        maxLines: 4, // السماح بـ 4 أسطر للكتابة
        decoration: InputDecoration(
          hintText: 'اكتب ملخص اليوم هنا...',
          hintStyle: TextStyle(color: textMuted, fontSize: 13.sp, fontFamily: 'Cairo'),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() { // دالة بناء زر إرسال التقرير النهائي بتدرج لوني
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: GestureDetector(
        onTap: _submitting ? null : _submit, // إرسال التقرير الحقيقي للـ backend
        child: Container(
          height: 56.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [primaryBlue, primaryPurple]),
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [BoxShadow(color: primaryPurple.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Center(child: Text(_submitting ? 'جارٍ الإرسال...' : 'إرسال التقرير', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo'))),
        ),
      ),
    );
  }
}

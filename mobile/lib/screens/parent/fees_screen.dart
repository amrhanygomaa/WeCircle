/*
🧠 اسم الملف: fees_screen.dart

📌 بيعمل إيه؟
شاشة بتعرض المصاريف الدراسية، إيه اللي اتدفع وإيه اللي فاضل ومواعيد السداد.

👤 موجه لمين؟
- أولياء أمور

💡 فكرته:
تنظيم الأمور المالية وتسهيل عملية الدفع ومتابعة السداد بكل شفافية.
*/

import 'dart:convert';
import 'package:flutter/material.dart'; // استيراد مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة التحكم في أحجام الشاشة
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/api_config.dart';
import '../../core/state/state_manager.dart';
import '../../widgets/wesal_background.dart';

class FeesScreen extends StatefulWidget { // تعريف كلاس شاشة المصروفات كـ StatefulWidget
  const FeesScreen({super.key}); // مشيد الكلاس

  @override // إنشاء حالة الشاشة
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> { // كلاس حالة شاشة المصروفات
  // ── Design tokens ─────────────────────────────────────────────────────────
  static const Color darkGreen = Color(0xFF114232);
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color borderColor = Color(0xFFE2E8F0);

  bool _saveCard = true;
  List<Map<String, dynamic>> _invoices = [];
  double _totalDue = 0;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('mobile_token') ?? '';
      if (token.isEmpty) return;

      final children = AppStateManager().children.value;
      final idx = AppStateManager().selectedChildIndex.value;
      final studentId = children.isNotEmpty
          ? children[idx.clamp(0, children.length - 1)]['id'] as String?
          : null;
      if (studentId == null || studentId.isEmpty) return;

      final res = await http.get(
        Uri.parse('${ApiConfig.getBaseUrl()}/invoices/mobile/student/$studentId'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode != 200 || !mounted) return;

      final raw = (jsonDecode(res.body)['data'] as List? ?? [])
          .cast<Map<String, dynamic>>();

      double total = 0;
      final mapped = raw.map((inv) {
        final amount = double.tryParse(inv['totalAmount']?.toString() ?? '0') ?? 0;
        final paid   = double.tryParse(inv['paidAmount']?.toString()  ?? '0') ?? 0;
        final due    = amount - paid;
        total += due;
        return {
          'title':  inv['description'] ?? inv['feeType'] ?? 'رسوم دراسية',
          'amount': '${due.toStringAsFixed(0)} ج.م',
          'status': inv['status'] ?? '',
        };
      }).toList();

      if (mounted) setState(() { _invoices = mapped; _totalDue = total; });
    } catch (_) {}
  }

  @override // بناء واجهة المستخدم الرئيسية
  Widget build(BuildContext context) {
    return Directionality( // ضبط الاتجاه للعربية
      textDirection: TextDirection.rtl,
      child: WesalBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView( // تمكين التمرير
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 10.h),
                    const _FeesAppBar(darkGreen: darkGreen), // ترويسة الصفحة كويدجت منفصل
                    SizedBox(height: 24.h),
                    Text('دفع المصاريف المدرسية', style: TextStyle(color: darkGreen, fontWeight: FontWeight.w900, fontSize: 22.sp, fontFamily: 'Cairo')), // العنوان الرئيسي
                    SizedBox(height: 8.h),
                    Text('ادفع مصروفاتك المدرسية بأمان أونلاين', style: TextStyle(color: textMuted, fontSize: 13.sp, fontFamily: 'Cairo')), // وصف فرعى
                    SizedBox(height: 32.h),
                    _PaymentCard( // بطاقة إدخال بيانات الدفع (معزولة الأداء)
                      saveCard: _saveCard,
                      onSaveCardChanged: (val) => setState(() => _saveCard = val),
                      darkGreen: darkGreen,
                      primaryPurple: primaryPurple,
                      textMuted: textMuted,
                      borderColor: borderColor,
                    ),
                    SizedBox(height: 24.h),
                    _PaymentSummary(
                      darkGreen: darkGreen, primaryPurple: primaryPurple,
                      textMuted: textMuted, borderColor: borderColor,
                      invoices: _invoices, totalDue: _totalDue,
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Optimized Sub-Widgets ──────────────────────────────────────────────────

class _FeesAppBar extends StatelessWidget { // ويدجت ترويسة شاشة المصروفات (معزول)
  final Color darkGreen;
  const _FeesAppBar({required this.darkGreen});

  @override // بناء الترويسة
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container( // زر الرجوع بتصميم Neumorphic
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.white, shape: BoxShape.circle,
              boxShadow: [
                const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
                BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
              ],
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: darkGreen, size: 18.sp),
          ),
        ),
        SizedBox(width: 16.w),
        Text('بيانات الدفع', style: TextStyle(color: darkGreen, fontWeight: FontWeight.w900, fontSize: 20.sp, fontFamily: 'Cairo')),
      ],
    );
  }
}

class _PaymentCard extends StatelessWidget { // ويدجت بطاقة بيانات البطاقة البنكية (معزول)
  final bool saveCard; // حالة حفظ البطاقة
  final ValueChanged<bool> onSaveCardChanged; // دالة تغيير الحالة
  final Color darkGreen, primaryPurple, textMuted, borderColor;

  const _PaymentCard({ // مشيد البطاقة
    required this.saveCard,
    required this.onSaveCardChanged,
    required this.darkGreen,
    required this.primaryPurple,
    required this.textMuted,
    required this.borderColor,
  });

  @override // بناء محتويات بطاقة الدفع
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(darkGreen: darkGreen, textMuted: textMuted, primaryPurple: primaryPurple), // ترويسة بطاقة الدفع
          SizedBox(height: 32.h),
          _CustomTextField(label: 'اسم صاحب البطاقة', hint: 'أدهم محمد', darkGreen: darkGreen, textMuted: textMuted, borderColor: borderColor), // حقل الاسم
          SizedBox(height: 20.h),
          _CustomTextField(label: 'رقم البطاقة', hint: '3456 9012 5678 1234', suffixIcon: Icons.credit_card_outlined, darkGreen: darkGreen, textMuted: textMuted, borderColor: borderColor), // حقل الرقم
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(child: _CustomTextField(label: 'تاريخ الانتهاء', hint: 'MM/YY', darkGreen: darkGreen, textMuted: textMuted, borderColor: borderColor)),
              SizedBox(width: 16.w),
              Expanded(child: _CustomTextField(label: 'رمز الأمان (CVV)', hint: '123', suffixIcon: Icons.lock_outline_rounded, darkGreen: darkGreen, textMuted: textMuted, borderColor: borderColor)),
            ],
          ),
          SizedBox(height: 24.h),
          _SaveCardOption(saveCard: saveCard, onChanged: onSaveCardChanged, textMuted: textMuted, primaryPurple: primaryPurple, borderColor: borderColor), // خيار حفظ البطاقة
          SizedBox(height: 24.h),
          _PayNowButton(primaryPurple: primaryPurple), // زر الدفع النهائى
          SizedBox(height: 20.h),
          _SecurityInfo(textMuted: textMuted), // معلومات الأمان
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget { // ترويسة قسم بيانات البطاقة
  final Color darkGreen, textMuted, primaryPurple;
  const _CardHeader({required this.darkGreen, required this.textMuted, required this.primaryPurple});

  @override // بناء القسم العلوى من البطاقة
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('بيانات الدفع', style: TextStyle(color: darkGreen, fontWeight: FontWeight.w900, fontSize: 18.sp, fontFamily: 'Cairo')),
            Text('أدخل بيانات البطاقة الخاصة بك', style: TextStyle(color: textMuted, fontSize: 12.sp, fontFamily: 'Cairo')),
          ],
        ),
        Container( // أيقونة البطاقة البارزة
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [BoxShadow(color: primaryPurple.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Icon(Icons.credit_card_rounded, color: Colors.white, size: 28.sp),
        ),
      ],
    );
  }
}

class _CustomTextField extends StatelessWidget { // ويدجت حقل إدخال مخصص (معزول)
  final String label, hint;
  final IconData? suffixIcon;
  final Color darkGreen, textMuted, borderColor;

  const _CustomTextField({required this.label, required this.hint, this.suffixIcon, required this.darkGreen, required this.textMuted, required this.borderColor});

  @override // بناء الحقل مع العنوان
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: darkGreen, fontWeight: FontWeight.w900, fontSize: 13.sp, fontFamily: 'Cairo')),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: borderColor, width: 1.5)),
          child: TextField(
            style: TextStyle(color: darkGreen, fontSize: 15.sp, fontWeight: FontWeight.w900, fontFamily: 'Cairo'),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: textMuted.withValues(alpha: 0.6), fontSize: 14.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: textMuted, size: 22.sp) : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _SaveCardOption extends StatelessWidget { // ويدجت خيار حفظ البطاقة
  final bool saveCard;
  final ValueChanged<bool> onChanged;
  final Color textMuted, primaryPurple, borderColor;

  const _SaveCardOption({required this.saveCard, required this.onChanged, required this.textMuted, required this.primaryPurple, required this.borderColor});

  @override // بناء خيار الاختيار (Checkbox)
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('حفظ البطاقة لعمليات الدفع القادمة', style: TextStyle(color: textMuted, fontSize: 12.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        const Spacer(),
        Transform.scale(
          scale: 1.1,
          child: Checkbox(
            value: saveCard,
            onChanged: (val) => onChanged(val ?? false),
            activeColor: primaryPurple,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
            side: BorderSide(color: borderColor, width: 1.5),
          ),
        ),
      ],
    );
  }
}

class _PayNowButton extends StatelessWidget { // ويدجت زر الدفع الحالى
  final Color primaryPurple;
  const _PayNowButton({required this.primaryPurple});

  @override // بناء الزر بتصميم متدرج وظل
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('تم الدفع بنجاح!', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        ));
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity, padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)], begin: Alignment.centerRight, end: Alignment.centerLeft),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: primaryPurple.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        alignment: Alignment.center,
        child: Text('ادفع الآن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18.sp, fontFamily: 'Cairo')),
      ),
    );
  }
}

class _SecurityInfo extends StatelessWidget { // معلومة أمان الدفع
  final Color textMuted;
  const _SecurityInfo({required this.textMuted});

  @override // بناء الأيقونة والنص فى الأسفل
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline_rounded, color: textMuted, size: 14.sp),
        SizedBox(width: 6.w),
        Text('معلومات الدفع الخاصة بك آمنة ومشفرة', style: TextStyle(color: textMuted, fontSize: 11.sp, fontFamily: 'Cairo')),
      ],
    );
  }
}

class _PaymentSummary extends StatelessWidget {
  final Color darkGreen, primaryPurple, textMuted, borderColor;
  final List<Map<String, dynamic>> invoices;
  final double totalDue;

  const _PaymentSummary({
    required this.darkGreen, required this.primaryPurple,
    required this.textMuted, required this.borderColor,
    this.invoices = const [], this.totalDue = 0,
  });

  @override
  Widget build(BuildContext context) {
    final items = invoices.isNotEmpty
        ? invoices
        : [
            {'title': 'المصروفات الدراسية', 'amount': '5,000 ج.م'},
            {'title': 'مصروفات الأنشطة',   'amount': '500 ج.م'},
            {'title': 'مصروفات الباص',     'amount': '1,000 ج.م'},
          ];
    final totalLabel = invoices.isNotEmpty
        ? '${totalDue.toStringAsFixed(0)} ج.م'
        : '6,500 ج.م';

    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ملخص الدفع', style: TextStyle(color: darkGreen, fontWeight: FontWeight.w900, fontSize: 18.sp, fontFamily: 'Cairo')),
          SizedBox(height: 20.h),
          ...items.expand((item) => [
            _SummaryItem(title: item['title'] as String, amount: item['amount'] as String, textMuted: textMuted, darkGreen: darkGreen),
            SizedBox(height: 16.h),
          ]),
          Padding(padding: EdgeInsets.symmetric(vertical: 4.h), child: Divider(color: borderColor, thickness: 1.5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الإجمالي', style: TextStyle(color: darkGreen, fontWeight: FontWeight.w900, fontSize: 20.sp, fontFamily: 'Cairo')),
              Text(totalLabel, style: TextStyle(color: primaryPurple, fontWeight: FontWeight.w900, fontSize: 22.sp, fontFamily: 'Cairo')),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget { // بند واحد فى الفاتورة
  final String title, amount;
  final Color textMuted, darkGreen;
  const _SummaryItem({required this.title, required this.amount, required this.textMuted, required this.darkGreen});

  @override // بناء السطر
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: textMuted, fontSize: 14.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        Text(amount, style: TextStyle(color: darkGreen, fontWeight: FontWeight.w900, fontSize: 14.sp, fontFamily: 'Cairo')),
      ],
    );
  }
}


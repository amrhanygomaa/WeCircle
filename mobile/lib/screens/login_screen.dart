/*
🧠 اسم الملف: login_screen.dart

📌 بيعمل إيه؟
دي بوابة الدخول للتطبيق، بتخلي كل مستخدم (سواء طالب أو ولي أمر أو مدرس) يدخل على حسابه برقم الهوية وكلمة السر.

👤 موجه لمين؟
- الكل (طلاب / مدرسين / أولياء أمور / سواقين)

💡 فكرته:
تنظيم عملية الدخول والتأكد إن كل واحد رايح للمكان الصح اللي يخصه في التطبيق.
*/

import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart'; // استيراد مكتبة فلاتر الأساسية
import 'package:flutter/services.dart'; // استيراد خدمات النظام (لوحة المفاتيح)
import 'package:flutter_animate/flutter_animate.dart'; // استيراد مكتبة الحركات
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wesal/core/config/api_config.dart';
import 'package:wesal/core/state/state_manager.dart';
import 'package:wesal/services/push_service.dart';

class LoginScreen extends StatefulWidget { // تعريف كلاس شاشة تسجيل الدخول
  const LoginScreen({super.key}); // مشيد الكلاس

  @override // إعادة تعريف دالة إنشاء الحالة
  State<LoginScreen> createState() => _LoginScreenState(); // إنشاء الحالة
}

class _LoginScreenState extends State<LoginScreen> { // كلاس حالة شاشة تسجيل الدخول
  final _idController = TextEditingController(); // متحكم حقل رقم الهوية
  final _passController = TextEditingController(); // متحكم حقل كلمة المرور

  bool _obscurePassword = true; // متغير للتحكم في إظهار/إخفاء كلمة المرور
  bool _isLoading = false; // متغير لحالة التحميل أثناء تسجيل الدخول
  bool _rememberMe = false; // متغير لخيار "تذكرني"

  String? _idError; // متغير لتخزين خطأ حقل الهوية
  String? _passError; // متغير لتخزين خطأ حقل كلمة المرور
  String _role = 'parent'; // الدور الافتراضي للمستخدم
  String _gradeRange = '1-3'; // الفئة العمرية/الصفية للطالب

  final FocusNode _idFocus = FocusNode(); // عقدة التركيز لحقل الهوية
  final FocusNode _passFocus = FocusNode(); // عقدة التركيز لحقل كلمة المرور

  // استخدام ValueNotifier لتحسين الأداء وتجنب إعادة بناء الشاشة بالكامل عند التركيز
  final ValueNotifier<bool> _isIdFocused = ValueNotifier<bool>(false); 
  final ValueNotifier<bool> _isPassFocused = ValueNotifier<bool>(false);

  @override // دالة التهيئة الأولية
  void initState() {
    super.initState();
    _idFocus.addListener(() => _isIdFocused.value = _idFocus.hasFocus); // تحديث حالة التركيز للهوية
    _passFocus.addListener(() => _isPassFocused.value = _passFocus.hasFocus); // تحديث حالة التركيز لكلمة المرور
  }

  // ── الألوان المطابقة تماماً للتصميم ─────────────────────────────────────────
  static const Color primaryBlue = Color(0xFF2563EB); // أزرق التدرج
  static const Color primaryPurple = Color(0xFF9333EA); // بنفسجي التدرج
  static const Color textDark = Color(0xFF1E293B); // لون النص الداكن
  static const Color textMuted = Color(0xFF64748B); // لون النص الباهت
  static const Color baseColor = Color(0xFFF0F3F8); // لون الخلفية والبطاقة الأساسي
  static const String _fontFamily = 'Cairo'; // نوع الخط المستخدم

  @override // دالة التخلص من الموارد
  void dispose() {
    _idController.dispose(); // التخلص من متحكم الهوية لتجنب تسريب الذاكرة
    _passController.dispose(); // التخلص من متحكم كلمة المرور
    _idFocus.dispose(); // التخلص من عقدة تركيز الهوية
    _passFocus.dispose(); // التخلص من عقدة تركيز كلمة المرور
    _isIdFocused.dispose(); // التخلص من مراقب تركيز الهوية
    _isPassFocused.dispose(); // التخلص من مراقب تركيز كلمة المرور
    super.dispose();
  }

  void _handleLogin() async {
    final idVal = _idController.text.trim();
    final passVal = _passController.text.trim();

    setState(() {
      _idError = idVal.isEmpty ? 'رقم الهوية مطلوب' : null;
      _passError = passVal.isEmpty ? 'كلمة المرور مطلوبة' : null;
    });

    if (_idError != null || _passError != null) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getBaseUrl()}/auth/mobile/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'loginId': idVal, 'password': passVal}),
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200 || body['success'] != true) {
        setState(() {
          _idError = (body['message'] as String?) ?? 'بيانات الدخول غير صحيحة';
          _isLoading = false;
        });
        return;
      }

      final data = body['data'] as Map<String, dynamic>?;
      final token = data?['token'] as String?;
      if (data == null || token == null || token.isEmpty) {
        setState(() {
          _idError = 'استجابة غير متوقعة من الخادم. حاول مرة أخرى.';
          _isLoading = false;
        });
        return;
      }
      final user = (data['user'] as Map<String, dynamic>?) ?? {};
      final role = ((user['role'] as String?) ?? 'parent').toLowerCase();

      // Pick the role-specific entity ID used by chat and other authenticated calls.
      final String entityId;
      switch (role) {
        case 'parent':
          entityId = (user['parentId'] as String?) ?? (user['id'] as String? ?? '');
          break;
        case 'student':
          entityId = (user['studentId'] as String?) ?? (user['id'] as String? ?? '');
          break;
        case 'teacher':
          entityId = (user['teacherId'] as String?) ?? (user['id'] as String? ?? '');
          break;
        case 'driver':
          entityId = (user['driverId'] as String?) ?? (user['id'] as String? ?? '');
          break;
        default:
          entityId = (user['id'] as String?) ?? '';
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mobile_token', token);
      await prefs.setString('mobile_entity_id', entityId);
      await prefs.setString('mobile_role', role);
      await prefs.setString('mobile_user_id', (user['id'] as String?) ?? '');

      // Register this device for push notifications (no-op if Firebase not configured).
      await PushService.registerToken();

      if (!mounted) return;
      setState(() => _isLoading = false);

      switch (role) {
        case 'parent':
          Navigator.pushReplacementNamed(context, '/parent_dashboard');
          break;
        case 'student':
          AppStateManager().selectedGradeLevel.value = _gradeRange;
          Navigator.pushReplacementNamed(context, '/student_avatar_selection');
          break;
        case 'teacher':
          Navigator.pushReplacementNamed(context, '/teacher_dashboard');
          break;
        case 'driver':
          Navigator.pushReplacementNamed(context, '/driver_dashboard');
          break;
        default:
          Navigator.pushReplacementNamed(context, '/parent_dashboard');
      }
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _idError = 'انتهت مهلة الاتصال بالخادم';
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _idError = 'خطأ في الاتصال بالخادم';
        _isLoading = false;
      });
    }
  }

  String _getRoleName(String role) { // دالة لتحويل كود الدور إلى نص عربي
    switch(role) {
      case 'parent': return 'ولي الأمر';
      case 'student': return 'طالب';
      case 'teacher': return 'معلم';
      case 'driver': return 'سائق';
      default: return 'ولي الأمر';
    }
  }

  @override // دالة بناء واجهة الشاشة
  Widget build(BuildContext context) {
    return Directionality( // تعيين اتجاه التطبيق للعربية
      textDirection: TextDirection.rtl, 
      child: Scaffold( // هيكل الصفحة
        body: Container( // الحاوية الرئيسية مع الخلفية
          decoration: BoxDecoration(
            color: baseColor,
            image: const DecorationImage(
              image: AssetImage('assets/images/login_bg.png'), // صورة الخلفية
              fit: BoxFit.cover,
              opacity: 0.3, // تقليل الشفافية
            ),
          ),
          child: Stack( // مكدس لوضع العناصر فوق بعضها
            children: [
              Positioned( // تحديد موقع زر الرجوع
                top: 20,
                left: 20,
                child: SafeArea(
                  child: GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, '/onboarding'), // العودة لشاشات الترحيب
                    child: Container( // شكل زر الرجوع
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
                      ),
                      child: const Directionality(
                        textDirection: TextDirection.ltr,
                        child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: textDark),
                      ),
                    ),
                  ),
                ),
              ),

              Center( // توسط محتوى تسجيل الدخول
                child: SingleChildScrollView( // تمكين التمرير
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    child: Container( // بطاقة تسجيل الدخول الـ Neumorphic
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(10, 15)), // ظل سفلي
                          const BoxShadow(color: Colors.white, blurRadius: 15, offset: Offset(-8, -8)), // إضاءة علوية
                        ],
                      ),
                      child: Column( // ترتيب محتوى البطاقة
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(alignment: Alignment.centerLeft, child: _buildRoleSelectorPill()), // اختيار نوع الحساب
                          const SizedBox(height: 32),
                          
                          // حقل رقم الهوية
                          ValueListenableBuilder<bool>( // تحديث إطار الحقل فقط عند التركيز دون إعادة بناء الشاشة بالكامل
                            valueListenable: _isIdFocused,
                            builder: (context, isFocused, _) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildCleanField(isFocused: isFocused, hasError: _idError != null, child: _buildIdField()),
                                  if (_idError != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6, right: 12),
                                      child: Text(_idError!, style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: _fontFamily)),
                                    ).animate().fade().slideY(begin: -0.2, end: 0),
                                ],
                              );
                            },
                          ).animate().fade(delay: 200.ms).slideY(begin: 0.1, end: 0),
                          
                          const SizedBox(height: 20),
                          
                          // حقل كلمة المرور
                          ValueListenableBuilder<bool>( // تحديث إطار الحقل فقط عند التركيز
                            valueListenable: _isPassFocused,
                            builder: (context, isFocused, _) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildCleanField(isFocused: isFocused, hasError: _passError != null, child: _buildPasswordField()),
                                  if (_passError != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6, right: 12),
                                      child: Text(_passError!, style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: _fontFamily)),
                                    ).animate().fade().slideY(begin: -0.2, end: 0),
                                ],
                              );
                            },
                          ).animate().fade(delay: 300.ms).slideY(begin: 0.1, end: 0),
                          
                          if (_role == 'student') ...[
                            const SizedBox(height: 24),
                            _buildGradeSelector(),
                          ],

                          const SizedBox(height: 16),
                          
                          // تذكرني ونسيت كلمة المرور
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _rememberMe = !_rememberMe),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedContainer( // مربع اختيار مخصص
                                      duration: const Duration(milliseconds: 200),
                                      width: 24, height: 24,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: _rememberMe ? Colors.transparent : textMuted.withValues(alpha: 0.5), width: 2),
                                        gradient: _rememberMe ? const LinearGradient(colors: [primaryBlue, primaryPurple]) : null,
                                        boxShadow: _rememberMe ? [BoxShadow(color: primaryBlue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                                      ),
                                      child: _rememberMe ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('تذكرني', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textDark, fontFamily: _fontFamily)),
                                  ],
                                ),
                              ),
                              GestureDetector(onTap: () {}, child: const Text('نسيت كلمة المرور؟', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E40AF), fontFamily: _fontFamily))),
                            ],
                          ),
                            
                          const SizedBox(height: 40),
                          _buildLoginButton(), // زر تسجيل الدخول
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelectorPill() { // بناء زر اختيار نوع الحساب
    return PopupMenuButton<String>(
      onSelected: (val) => setState(() => _role = val),
      color: baseColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8, offset: const Offset(0, 50),
      child: Container( // شكل الزر المنبثق
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: baseColor, borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
            const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_outline_rounded, size: 20, color: primaryBlue),
            const SizedBox(width: 10),
            Text(_getRoleName(_role), style: const TextStyle(fontSize: 14, color: textDark, fontWeight: FontWeight.w700, fontFamily: _fontFamily)),
            const SizedBox(width: 10),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: textMuted),
          ],
        ),
      ),
      itemBuilder: (ctx) => [
        _buildPopupItem('parent', 'ولي الأمر', Icons.family_restroom_rounded),
        _buildPopupItem('student', 'طالب', Icons.school_rounded),
        _buildPopupItem('teacher', 'معلم', Icons.cast_for_education_rounded),
        _buildPopupItem('driver', 'سائق', Icons.directions_bus_rounded),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, String text, IconData icon) { // بناء عنصر في قائمة اختيار الدور
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: primaryPurple),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textDark, fontFamily: _fontFamily)),
        ],
      ),
    );
  }

  Widget _buildCleanField({required Widget child, bool hasError = false, bool isFocused = false}) { // حاوية الحقل بتصميم نظيف ومتحرك
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: (isFocused || hasError)
            ? const LinearGradient(colors: [primaryBlue, primaryPurple])
            : LinearGradient(colors: [Colors.white.withValues(alpha: 0.5), Colors.white.withValues(alpha: 0.5)]),
        boxShadow: isFocused ? [BoxShadow(color: primaryBlue.withValues(alpha: 0.2), blurRadius: 15, spreadRadius: 2)] : [],
      ),
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(16)),
        child: child,
      ),
    );
  }

  Widget _buildIdField() { // حقل رقم الهوية
    return TextFormField(
      controller: _idController, focusNode: _idFocus,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textDark, fontFamily: _fontFamily),
      decoration: const InputDecoration(
        hintText: 'رقم الهوية',
        hintStyle: TextStyle(color: textMuted, fontSize: 14, fontFamily: _fontFamily, fontWeight: FontWeight.w600),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('National ID', style: TextStyle(color: textMuted, fontSize: 13, fontFamily: 'Roboto', fontWeight: FontWeight.w500))]),
        ),
      ),
      onChanged: (val) { if (_idError != null) setState(() => _idError = null); },
    );
  }

  Widget _buildPasswordField() { // حقل كلمة المرور
    return TextFormField(
      controller: _passController, focusNode: _passFocus,
      obscureText: _obscurePassword,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textDark, fontFamily: _fontFamily),
      decoration: InputDecoration(
        hintText: 'كلمة المرور',
        hintStyle: const TextStyle(color: textMuted, fontSize: 14, fontFamily: _fontFamily, fontWeight: FontWeight.w600),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: textMuted, size: 22),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword), // تبديل رؤية كلمة المرور
          ),
        ),
      ),
      onChanged: (val) { if (_passError != null) setState(() => _passError = null); },
    );
  }

  Widget _buildLoginButton() { // بناء زر تسجيل الدخول المتدرج
    return Container(
      height: 56, width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(colors: [primaryBlue, primaryPurple]),
        boxShadow: [
          BoxShadow(color: const Color(0xFF581C87).withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(8, 12)), // ظل يمين
          BoxShadow(color: const Color(0xFF1E3A8A).withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(-8, 12)), // ظل يسار
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleLogin,
          borderRadius: BorderRadius.circular(28),
          splashColor: Colors.white.withValues(alpha: 0.2),
          child: Center(
            child: _isLoading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) // مؤشر التحميل
                : const Text('تسجيل الدخول', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: _fontFamily)),
          ),
        ),
      ),
    );
  }

  Widget _buildGradeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'اختر المرحلة الدراسية:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textDark,
            fontFamily: _fontFamily,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildGradeOption('1-3', 'الأول - الثالث')),
            const SizedBox(width: 12),
            Expanded(child: _buildGradeOption('4-6', 'الرابع - السادس')),
          ],
        ),
      ],
    ).animate().fade().slideY(begin: 0.2, end: 0);
  }

  Widget _buildGradeOption(String range, String label) {
    bool isSelected = _gradeRange == range;
    return GestureDetector(
      onTap: () => setState(() => _gradeRange = range),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: primaryBlue.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              color: isSelected ? primaryBlue : textMuted,
              fontFamily: _fontFamily,
            ),
          ),
        ),
      ),
    );
  }
}

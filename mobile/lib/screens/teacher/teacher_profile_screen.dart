/*
🧠 اسم الملف: teacher_profile_screen.dart

📌 بيعمل إيه؟
شاشة الحساب الشخصي للمدرس، فيها بياناته، جدوله الخاص، وإعدادات حسابه.

👤 موجه لمين؟
- مدرسين

💡 فكرته:
تنظيم معلومات المدرس المهنية والشخصية وتوفير وصول سهل لجدول حصصه.
*/

import 'package:flutter/material.dart'; // استيراد مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة التحكم في أحجام الشاشة
import '../../app_theme.dart'; // استيراد ثيم التطبيق الموحد
import '../../state_manager.dart'; // استيراد مدير حالة التطبيق

class TeacherProfileScreen extends StatefulWidget { // تعريف كلاس شاشة الملف الشخصي للمعلم كـ StatefulWidget
  const TeacherProfileScreen({super.key}); // مشيد الكلاس

  @override // إنشاء حالة الشاشة
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> { // كلاس حالة شاشة الملف الشخصي
  final state = AppStateManager(); // إنشاء نسخة من مدير الحالة للتعامل مع البيانات

  void _showAccountSettings() { // دالة لإظهار نافذة إعدادات الحساب (تعديل البريد وكلمة المرور)
    String email = state.userData.value['email'] ?? 'teacher@wesal.edu'; // جلب البريد الحالي
    String oldPassword = ''; // متغير لتخزين كلمة المرور القديمة
    String newPassword = ''; // متغير لتخزين كلمة المرور الجديدة

    showModalBottomSheet( // إظهار نافذة منبثقة من الأسفل
      context: context,
      isScrollControlled: true, // السماح بالتحكم في ارتفاع النافذة (مفيد للوحة المفاتيح)
      backgroundColor: Colors.transparent, // خلفية شفافة لعمل تصميم مخصص
      builder: (context) => _buildBottomDialog( // بناء محتوى النافذة المنبثقة
        title: 'إعدادات الحساب',
        icon: Icons.person_rounded,
        color: AppTheme.royalBlue,
        onSave: () { // منطق الحفظ عند الضغط على زر التأكيد
          if (newPassword.isNotEmpty && oldPassword.isEmpty) { // التحقق من كتابة كلمة المرور القديمة أولاً
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('الرجاء كتابة كلمة المرور القديمة أولاً'),
                backgroundColor: AppTheme.softRose,
              ),
            );
            return false;
          }
          if (oldPassword.isNotEmpty && newPassword.length < 6) { // التحقق من طول كلمة المرور الجديدة
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('كلمة المرور الجديدة قصيرة جداً'),
                backgroundColor: AppTheme.softRose,
              ),
            );
            return false;
          }

          state.updateUserData(email: email); // تحديث بيانات المستخدم في مدير الحالة
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث بيانات الدخول بنجاح!'),
              backgroundColor: AppTheme.emeraldGreen,
            ),
          );
          return true;
        },
        child: Column( // حقول الإدخال داخل النافذة
          children: [
            _buildEditField(
              Icons.email_outlined,
              'البريد الإلكتروني',
              email,
              (val) => email = val,
            ),
            SizedBox(height: 20.h),
            _buildEditField(
              Icons.lock_outline_rounded,
              'كلمة المرور القديمة (الحالية)',
              oldPassword,
              (val) => oldPassword = val,
              isPassword: true,
            ),
            SizedBox(height: 20.h),
            _buildEditField(
              Icons.lock_reset_rounded,
              'كلمة المرور الجديدة',
              newPassword,
              (val) => newPassword = val,
              isPassword: true,
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings() { // دالة لإظهار نافذة إعدادات الإشعارات
    bool notifAtt = state.notifAttendance.value; // جلب حالة إشعارات الحضور
    bool notifHw = state.notifHomework.value; // جلب حالة إشعارات الواجبات
    bool notifMsg = state.notifMessages.value; // جلب حالة إشعارات الرسائل

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomDialog(
        title: 'تفضيلات الإشعارات',
        icon: Icons.notifications_active_rounded,
        color: AppTheme.accentGold,
        onSave: () { // حفظ الإعدادات في مدير الحالة
          state.updateNotifications(att: notifAtt, hw: notifHw, msg: notifMsg);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حفظ الإعدادات بنجاح'),
              backgroundColor: AppTheme.emeraldGreen,
            ),
          );
          return true;
        },
        child: StatefulBuilder( // استخدام StatefulBuilder لتحديث حالة المفاتيح داخل النافذة المنبثقة
          builder: (context, setLocalState) => Column(
            children: [
              _buildSwitchTile(
                'إشعارات النظام والإدارة',
                notifAtt,
                (val) => setLocalState(() => notifAtt = val),
              ),
              _buildSwitchTile(
                'إشعارات تسليم المهام والواجبات',
                notifHw,
                (val) => setLocalState(() => notifHw = val),
              ),
              _buildSwitchTile(
                'إشعارات رسائل أولياء الأمور',
                notifMsg,
                (val) => setLocalState(() => notifMsg = val),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAppearanceSettings() { // دالة لإظهار نافذة إعدادات المظهر (اللغة والوضع الليلي)
    String selectedLang = state.locale.value.languageCode; // اللغة الحالية
    ThemeMode selectedMode = state.themeMode.value; // وضع السمة الحالي

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return _buildBottomDialog(
              title: 'المظهر واللغة',
              icon: Icons.color_lens_rounded,
              color: AppTheme.emeraldGreen,
              onSave: () { // تطبيق تغييرات اللغة والسمة
                state.toggleLanguage(selectedLang);
                state.toggleTheme(selectedMode == ThemeMode.dark);
                return true;
              },
              child: Column(
                children: [
                  Text( // عنوان اختيار اللغة
                    'لغة التطبيق',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryDark,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row( // أزرار اختيار اللغة (عربي / انجليزي)
                    children: [
                      Expanded(
                        child: _buildChoiceBtn(
                          'العربية',
                          selectedLang == 'ar',
                          () => setLocalState(() => selectedLang = 'ar'),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildChoiceBtn(
                          'English',
                          selectedLang == 'en',
                          () => setLocalState(() => selectedLang = 'en'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),
                  Text( // عنوان اختيار وضع العرض
                    'وضع العرض',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryDark,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row( // أزرار اختيار السمة (فاتح / مظلم)
                    children: [
                      Expanded(
                        child: _buildChoiceBtn(
                          'وضع مشمس ☀️',
                          selectedMode == ThemeMode.light,
                          () => setLocalState(
                            () => selectedMode = ThemeMode.light,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildChoiceBtn(
                          'وضع مظلم 🌙',
                          selectedMode == ThemeMode.dark,
                          () => setLocalState(
                            () => selectedMode = ThemeMode.dark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override // دالة بناء واجهة الشاشة الرئيسية
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>( // الاستماع لتغييرات وضع السمة
      valueListenable: state.themeMode,
      builder: (context, themeMode, _) {
        final isDark = themeMode == ThemeMode.dark;
        return ValueListenableBuilder<Locale>( // الاستماع لتغييرات اللغة
          valueListenable: state.locale,
          builder: (context, locale, _) {
            return Directionality( // ضبط اتجاه التطبيق بناءً على اللغة
              textDirection: locale.languageCode == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Scaffold( // الهيكل الأساسي للصفحة
                backgroundColor: isDark
                    ? const Color(0xFF0F172A)
                    : AppTheme.background,
                body: Stack(
                  children: [
                    CustomScrollView( // قائمة تمرير مخصصة
                      physics: const ClampingScrollPhysics(),
                      slivers: [
                        _buildHyperPremiumHeader(context, isDark), // بناء ترويسة الشاشة المتطورة
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 100.h),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              RepaintBoundary( // عزل البطاقة لتحسين أداء الرسم
                                child: _buildProfileHeaderCard(isDark), // بناء بطاقة معلومات المعلم
                              ),
                              SizedBox(height: 48.h),
                              _buildSectionHeader('الحساب'), // عنوان قسم الحساب
                              RepaintBoundary(
                                child: _buildPremiumSettingsCard( // بطاقة إعدادات الحساب
                                  icon: Icons.person_outline_rounded,
                                  title: 'إعدادات الحساب',
                                  subtitle:
                                      'تعديل البريد الإلكتروني وكلمة المرور',
                                  color: AppTheme.royalBlue,
                                  isDark: isDark,
                                  onTap: _showAccountSettings,
                                ),
                              ),
                              SizedBox(height: 32.h),
                              _buildSectionHeader('التفضيلات'), // عنوان قسم التفضيلات
                              RepaintBoundary(
                                child: _buildPremiumSettingsCard( // بطاقة إعدادات الإشعارات
                                  icon: Icons.notifications_none_rounded,
                                  title: 'الإشعارات',
                                  subtitle: 'التحكم في تنبيهات النظام والرسائل',
                                  color: AppTheme.accentGold,
                                  isDark: isDark,
                                  onTap: _showNotificationSettings,
                                ),
                              ),
                              RepaintBoundary(
                                child: _buildPremiumSettingsCard( // بطاقة إعدادات المظهر واللغة
                                  icon: Icons.language_rounded,
                                  title: 'المظهر واللغة',
                                  subtitle: 'تغيير لغة التطبيق وتفضيلات العرض',
                                  color: AppTheme.emeraldGreen,
                                  isDark: isDark,
                                  onTap: _showAppearanceSettings,
                                ),
                              ),
                              SizedBox(height: 32.h),
                              _buildSectionHeader('الأمان'), // عنوان قسم الأمان
                              RepaintBoundary(
                                child: _buildPremiumSettingsCard( // بطاقة الخصوصية والأمان
                                  icon: Icons.security_outlined,
                                  title: 'الخصوصية والأمان',
                                  subtitle: 'بصمة الإصبع وكلمة المرور',
                                  color: AppTheme.primaryDark,
                                  isDark: isDark,
                                  onTap: () {},
                                ),
                              ),
                              SizedBox(height: 48.h),
                              _buildLogoutButton(), // زر تسجيل الخروج
                              SizedBox(height: 40.h),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Supporting Widgets for Dialogs
  Widget _buildBottomDialog({ // دالة مساعدة لبناء هيكل النافذة المنبثقة من الأسفل بشكل موحد
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
    required bool Function() onSave,
  }) {
    final locale = state.locale.value;
    return Directionality(
      textDirection: locale.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 40,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container( // مقبض سحب النافذة العلوي للتجميل
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 24.h),
              Row( // ترويسة النافذة
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 24.sp),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ],
              ),
              Divider(height: 48.h), // خط فاصل
              child, // محتوى النافذة المتغير
              SizedBox(height: 32.h),
              ElevatedButton( // زر الحفظ النهائي
                onPressed: () {
                  if (onSave()) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.emeraldGreen,
                  minimumSize: Size(double.infinity, 60.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                ),
                child: Text(
                  'حفظ التغييرات',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditField( // دالة مساعدة لبناء حقول إدخال النصوص في النوافذ
    IconData icon,
    String label,
    String value,
    Function(String) onChange, {
    bool isPassword = false,
  }) {
    return TextFormField(
      initialValue: value,
      onChanged: onChange,
      obscureText: isPassword,
      style: const TextStyle(
        color: AppTheme.primaryDark,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 14.sp),
        prefixIcon: Icon(icon, color: AppTheme.royalBlue, size: 20.sp),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) { // دالة لبناء صف مفتاح تبديل (Switch)
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14.sp,
          color: AppTheme.primaryDark,
        ),
      ),
      activeThumbColor: AppTheme.accentGold,
    );
  }

  Widget _buildChoiceBtn(String label, bool isSel, VoidCallback onTap) { // دالة لبناء زر اختيار (مثل اختيار اللغة أو السمة)
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isSel ? AppTheme.emeraldGreen : Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: isSel ? AppTheme.emeraldGreen : Colors.grey.shade200,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSel ? Colors.white : AppTheme.primaryDark,
            fontWeight: FontWeight.w900,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildHyperPremiumHeader(BuildContext context, bool isDark) { // دالة بناء ترويسة الشاشة القابلة للتمدد (SliverAppBar)
    return SliverAppBar(
      expandedHeight: 160.h,
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true, // جعل الترويسة ثابتة عند التمرير
      automaticallyImplyLeading: false,
      leading: Center( // زر الرجوع بتصميم Neumorphic مخصص
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.white, blurRadius: 8, offset: const Offset(-4, -4)),
                BoxShadow(color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
              ],
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 18.sp, color: isDark ? Colors.white : AppTheme.primaryDark),
          ),
        ),
      ),
      leadingWidth: 74.w,
      flexibleSpace: FlexibleSpaceBar( // الفراغ المرن في الترويسة للعنوان
        titlePadding: EdgeInsets.only(right: 24.w, bottom: 18.h),
        title: Text(
          'الإعدادات والملف الشخصي',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.primaryDark,
            fontWeight: FontWeight.w900,
            fontSize: 18.sp,
            fontFamily: 'Outfit',
            letterSpacing: -1,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard(bool isDark) { // دالة بناء بطاقة تعريف المعلم العلوية
    return Container(
      padding: EdgeInsets.all(32.r),
      decoration: AppTheme.premiumCardDecoration().copyWith(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
      ),
      child: Row(
        children: [
          Container( // تصميم الصورة الرمزية (الأفاتار)
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.accentGold, width: 2.w),
            ),
            child: CircleAvatar(
              radius: 35.r,
              backgroundColor: Colors.white,
              child: Text(
                'أ',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.royalBlue,
                ),
              ),
            ),
          ),
          SizedBox(width: 20.w),
          Expanded( // نصوص الاسم والتخصص
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أستاذ أحمد',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppTheme.primaryDark,
                    fontFamily: 'Outfit',
                  ),
                ),
                Text(
                  'مدرس لغة عربية',
                  style: TextStyle(fontSize: 12.sp, color: AppTheme.textSlate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) { // دالة بناء عناوين الأقسام (مثل: الحساب، التفضيلات)
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h, right: 8.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w900,
          color: AppTheme.textLight,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildPremiumSettingsCard({ // دالة بناء بطاقة خيار إعداد فردي (ListTile مخصص)
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: AppTheme.premiumCardDecoration().copyWith(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 24.w,
          vertical: 12.h,
        ),
        leading: Container( // أيقونة الخيار بخلفية ملونة شفافة
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Icon(icon, color: color, size: 24.sp),
        ),
        title: Text( // عنوان الخيار
          title,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16.sp,
            color: isDark ? Colors.white : AppTheme.primaryDark,
          ),
        ),
        subtitle: Text( // وصف مختصر للخيار
          subtitle,
          style: TextStyle(
            color: AppTheme.textSlate,
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Icon( // إزالة const هنا لأن sp تحسب في وقت التشغيل
          Icons.keyboard_arrow_left_rounded,
          size: 20.sp,
          color: const Color(0xFFF1F5F9),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() { // دالة بناء زر تسجيل الخروج بتصميم تحذيري أحمر
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        onTap: () => Navigator.pushReplacementNamed(context, '/login'), // التوجه لصفحة تسجيل الدخول
        leading: Icon(
          Icons.logout_rounded,
          color: Colors.redAccent,
          size: 22.sp,
        ),
        title: Text(
          'تسجيل الخروج',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w900,
            fontSize: 15.sp,
          ),
        ),
        trailing: Icon( // إزالة const هنا
          Icons.keyboard_arrow_left_rounded,
          size: 20.sp,
          color: Colors.redAccent,
        ),
      ),
    );
  }
}

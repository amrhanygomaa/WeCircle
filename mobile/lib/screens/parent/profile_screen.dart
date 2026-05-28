/*
🧠 اسم الملف: profile_screen.dart

📌 بيعمل إيه؟
دي شاشة الحساب الشخصي لولي الأمر، بيقدر يعدل بياناته، يغير الصورة، أو يتحكم في الإعدادات.

👤 موجه لمين؟
- أولياء أمور

💡 فكرته:
مكان واحد لولي الأمر يتحكم فيه في حسابه الشخصي ومعلوماته الأساسية.
*/

import 'package:flutter/material.dart'; // استيراد مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة التحكم في أحجام الشاشة
import 'package:wesal/core/state/state_manager.dart'; // استيراد مدير الحالة
import '../../widgets/wesal_background.dart';

class ProfileScreen extends StatefulWidget {
  // تعريف كلاس شاشة الملف الشخصي كـ StatefulWidget
  const ProfileScreen({super.key}); // مشيد الكلاس

  @override // إنشاء حالة الشاشة
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // كلاس حالة شاشة الملف الشخصي
  final state = AppStateManager(); // الوصول لمدير الحالة

  void _showAccountSettings() {
    // دالة إظهار نافذة إعدادات الحساب
    String email = state.userData.value['email']!;
    String oldPassword = '';
    String newPassword = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BottomDialog(
        // ويدجت النافذة المخصص (معزول)
        title: 'إعدادات الحساب',
        icon: Icons.person_rounded,
        color: const Color(0xFF2563EB),
        onSave: () {
          if (newPassword.isNotEmpty && oldPassword.isEmpty) {
            _showError('الرجاء كتابة كلمة المرور القديمة أولاً');
            return false;
          }
          if (oldPassword.isNotEmpty && newPassword.length < 6) {
            _showError('كلمة المرور الجديدة قصيرة جداً');
            return false;
          }
          state.updateUserData(email: email);
          _showSuccess('تم تحديث بيانات الدخول بنجاح!');
          return true;
        },
        child: Column(
          children: [
            _EditField(
              icon: Icons.email_outlined,
              label: 'البريد الإلكتروني',
              initialValue: email,
              onChange: (val) => email = val,
            ),
            SizedBox(height: 20.h),
            _EditField(
              icon: Icons.lock_outline_rounded,
              label: 'كلمة المرور القديمة (الحالية)',
              initialValue: oldPassword,
              onChange: (val) => oldPassword = val,
              isPassword: true,
            ),
            SizedBox(height: 20.h),
            _EditField(
              icon: Icons.lock_reset_rounded,
              label: 'كلمة المرور الجديدة',
              initialValue: newPassword,
              onChange: (val) => newPassword = val,
              isPassword: true,
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings() {
    // دالة إظهار نافذة إعدادات الإشعارات
    bool notifAtt = state.notifAttendance.value;
    bool notifHw = state.notifHomework.value;
    bool notifMsg = state.notifMessages.value;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _BottomDialog(
        title: 'تفضيلات الإشعارات',
        icon: Icons.notifications_active_rounded,
        color: const Color(0xFFF59E0B),
        onSave: () {
          state.updateNotifications(att: notifAtt, hw: notifHw, msg: notifMsg);
          _showSuccess('تم حفظ الإعدادات بنجاح');
          return true;
        },
        child: StatefulBuilder(
          builder: (context, setLocalState) => Column(
            children: [
              _SwitchTile(
                title: 'إشعارات الحضور والانصراف',
                value: notifAtt,
                onChanged: (val) => setLocalState(() => notifAtt = val),
              ),
              _SwitchTile(
                title: 'إشعارات الواجبات الجديدة',
                value: notifHw,
                onChanged: (val) => setLocalState(() => notifHw = val),
              ),
              _SwitchTile(
                title: 'إشعارات الرسائل والدردشة',
                value: notifMsg,
                onChanged: (val) => setLocalState(() => notifMsg = val),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAppearanceSettings() {
    // دالة إظهار نافذة إعدادات المظهر واللغة
    String selectedLang = state.locale.value.languageCode;
    ThemeMode selectedMode = state.themeMode.value;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) => _BottomDialog(
          title: 'المظهر واللغة',
          icon: Icons.color_lens_rounded,
          color: const Color(0xFF10B981),
          onSave: () {
            state.toggleLanguage(selectedLang);
            state.toggleTheme(selectedMode == ThemeMode.dark);
            return true;
          },
          child: Column(
            children: [
              _ChoiceSectionTitle(title: 'لغة التطبيق'),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _ChoiceBtn(
                      label: 'العربية',
                      isSel: selectedLang == 'ar',
                      onTap: () => setLocalState(() => selectedLang = 'ar'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _ChoiceBtn(
                      label: 'English',
                      isSel: selectedLang == 'en',
                      onTap: () => setLocalState(() => selectedLang = 'en'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              _ChoiceSectionTitle(title: 'وضع العرض'),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _ChoiceBtn(
                      label: 'وضع مشمس ☀️',
                      isSel: selectedMode == ThemeMode.light,
                      onTap: () =>
                          setLocalState(() => selectedMode = ThemeMode.light),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _ChoiceBtn(
                      label: 'وضع مظلم 🌙',
                      isSel: selectedMode == ThemeMode.dark,
                      onTap: () =>
                          setLocalState(() => selectedMode = ThemeMode.dark),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: const Color(0xFFEF4444)),
  );
  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: const Color(0xFF10B981)),
  );

  @override // بناء واجهة المستخدم الرئيسية
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: state.themeMode,
      builder: (context, themeMode, _) {
        final isDark = themeMode == ThemeMode.dark;
        return ValueListenableBuilder<Locale>(
          valueListenable: state.locale,
          builder: (context, locale, _) {
            return Directionality(
              textDirection: locale.languageCode == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: WesalBackground(
                child: Scaffold(
                  backgroundColor: Colors.transparent, // شفاف لرؤية الخلفية الموحدة
                  body: CustomScrollView(
                    physics: const ClampingScrollPhysics(),
                    slivers: [
                      _HyperPremiumHeader(
                        isDark: isDark,
                      ), // ترويسة الصفحة الفاخرة (معزولة)
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 100.h),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          ValueListenableBuilder<Map<String, String>>(
                            // بيانات المستخدم
                            valueListenable: state.userData,
                            builder: (context, userData, _) =>
                                _ProfileHeaderCard(
                                  userData: userData,
                                  isDark: isDark,
                                ),
                          ),
                          SizedBox(height: 48.h),
                          const _SectionHeader(title: 'الحساب'),
                          _PremiumSettingsCard(
                            icon: Icons.person_outline_rounded,
                            title: 'إعدادات الحساب',
                            subtitle: 'تعديل البريد الإلكتروني وكلمة المرور',
                            color: const Color(0xFF2563EB),
                            isDark: isDark,
                            onTap: _showAccountSettings,
                          ),
                          SizedBox(height: 32.h),
                          const _SectionHeader(title: 'التفضيلات'),
                          _PremiumSettingsCard(
                            icon: Icons.notifications_none_rounded,
                            title: 'الإشعارات',
                            subtitle: 'التحكم في تنبيهات الحضور والواجبات',
                            color: const Color(0xFFF59E0B),
                            isDark: isDark,
                            onTap: _showNotificationSettings,
                          ),
                          _PremiumSettingsCard(
                            icon: Icons.language_rounded,
                            title: 'المظهر واللغة',
                            subtitle: 'تغيير لغة التطبيق وتفضيلات العرض',
                            color: const Color(0xFF10B981),
                            isDark: isDark,
                            onTap: _showAppearanceSettings,
                          ),
                          SizedBox(height: 32.h),
                          const _SectionHeader(title: 'الأمان'),
                          _PremiumSettingsCard(
                            icon: Icons.security_outlined,
                            title: 'الخصوصية والأمان',
                            subtitle: 'بصمة الإصبع وكلمة المرور',
                            color: const Color(0xFF1E293B),
                            isDark: isDark,
                            onTap: () {},
                          ),
                          SizedBox(height: 48.h),
                          const _LogoutButton(), // زر تسجيل الخروج (معزول)
                          SizedBox(height: 40.h),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
}

// ── Optimized Sub-Widgets ──────────────────────────────────────────────────

class _HyperPremiumHeader extends StatelessWidget {
  // ويدجت ترويسة الصفحة (معزول)
  final bool isDark;
  const _HyperPremiumHeader({required this.isDark});

  @override // بناء شريط التطبيق المتمدد
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160.h,
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: Icon(
                Icons.keyboard_arrow_right_rounded,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                size: 32.sp,
              ),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(right: 24.w, bottom: 18.h),
        title: Text(
          'الإعدادات',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontWeight: FontWeight.w900,
            fontSize: 24.sp,
            fontFamily: 'Outfit',
            letterSpacing: -1,
          ),
        ),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  // ويدجت بطاقة ملف المستخدم (معزول)
  final Map<String, String> userData;
  final bool isDark;
  const _ProfileHeaderCard({required this.userData, required this.isDark});

  @override // بناء البطاقة العلوية بالاسم والأيقونة
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF59E0B), width: 2),
            ),
            child: CircleAvatar(
              radius: 35.r,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person_rounded,
                color: const Color(0xFF2563EB),
                size: 40.sp,
              ),
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Text(
              userData['name']!,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontFamily: 'Outfit',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  // ويدجت عنوان القسم (معزول)
  final String title;
  const _SectionHeader({required this.title});

  @override // بناء النص
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h, right: 8.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF94A3B8),
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _PremiumSettingsCard extends StatelessWidget {
  // ويدجت بطاقة الإعداد الواحد (معزول)
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _PremiumSettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override // بناء البطاقة بتصميم ListTile
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        leading: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Icon(icon, color: color, size: 24.sp),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16.sp,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: const Color(0xFF64748B),
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_left_rounded,
          size: 20.sp,
          color: const Color(0xFFF1F5F9),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  // ويدجت زر تسجيل الخروج (معزول)
  const _LogoutButton();

  @override // بناء الزر باللون الأحمر
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        onTap: () => Navigator.pushReplacementNamed(context, '/login'),
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
        trailing: Icon(
          Icons.keyboard_arrow_left_rounded,
          size: 20.sp,
          color: Colors.redAccent,
        ),
      ),
    );
  }
}

class _BottomDialog extends StatelessWidget {
  // ويدجت النافذة السفلية الموحد (معزول)
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  final bool Function() onSave;

  const _BottomDialog({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
    required this.onSave,
  });

  @override // بناء محتوى النافذة السفلية
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24.w,
        24.h,
        24.w,
        MediaQuery.of(context).viewInsets.bottom + 40.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.r),
          topRight: Radius.circular(40.r),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Row(
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
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            Divider(height: 48.h),
            child,
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: () {
                if (onSave()) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
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
    );
  }
}

class _EditField extends StatelessWidget {
  // ويدجت حقل التعديل (معزول)
  final IconData icon;
  final String label, initialValue;
  final Function(String) onChange;
  final bool isPassword;

  const _EditField({
    required this.icon,
    required this.label,
    required this.initialValue,
    required this.onChange,
    this.isPassword = false,
  });

  @override // بناء الحقل
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChange,
      obscureText: isPassword,
      style: const TextStyle(
        color: Color(0xFF1E293B),
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2563EB), size: 22.sp),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  // ويدجت خيار المفتاح (معزول)
  final String title;
  final bool value;
  final Function(bool) onChanged;

  const _SwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override // بناء المفتاح
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: const Color(0xFFF59E0B),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14.sp,
          color: const Color(0xFF1E293B),
        ),
      ),
    );
  }
}

class _ChoiceSectionTitle extends StatelessWidget {
  // عنوان قسم الاختيار
  final String title;
  const _ChoiceSectionTitle({required this.title});

  @override // بناء النص
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w900,
        color: const Color(0xFF1E293B),
        fontSize: 14.sp,
      ),
    );
  }
}

class _ChoiceBtn extends StatelessWidget {
  // ويدجت زر الاختيار (معزول)
  final String label;
  final bool isSel;
  final VoidCallback onTap;

  const _ChoiceBtn({
    required this.label,
    required this.isSel,
    required this.onTap,
  });

  @override // بناء الزر
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF10B981) : Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: isSel ? const Color(0xFF10B981) : Colors.grey.shade200,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSel ? Colors.white : const Color(0xFF1E293B),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

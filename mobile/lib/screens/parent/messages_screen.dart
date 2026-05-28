/*
🧠 اسم الملف: messages_screen.dart

📌 بيعمل إيه؟
دي "صندوق الوارد" اللي بيجمع كل المحادثات والرسائل الرسمية اللي واصلة لولي الأمر.

👤 موجه لمين؟
- أولياء أمور

💡 فكرته:
مركز تواصل بيخلي ولي الأمر متابع كل الإشعارات والرسايل في مكان واحد.
*/

import 'package:flutter/material.dart'; // استيراد مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة التحكم في أحجام الشاشة
import 'chat_detail_screen.dart'; // استيراد شاشة تفاصيل المحادثة
import '../../widgets/wesal_background.dart';

class MessagingCenterScreen extends StatefulWidget { // تعريف كلاس شاشة مركز المراسلة كـ StatefulWidget
  final bool isTab; // هل تعمل الشاشة كأحد التبويبات؟
  final VoidCallback? onBack; // دالة الرجوع
  const MessagingCenterScreen({super.key, this.isTab = true, this.onBack}); // مشيد الكلاس

  @override // إنشاء حالة الشاشة لتتبع البيانات المتغيرة
  State<MessagingCenterScreen> createState() => _MessagingCenterScreenState();
}

class _MessagingCenterScreenState extends State<MessagingCenterScreen> { // كلاس حالة شاشة مركز المراسلة
  // ── Design tokens ─────────────────────────────────────────────────────────
  static const Color primaryBlue   = Color(0xFF2563EB); // اللون الأزرق الأساسي
  static const Color primaryPurple = Color(0xFF9333EA); // اللون البنفسجي الأساسي
  static const Color baseColor     = Color(0xFFF0F3F8); // لون الخلفية الأساسي
  static const Color textDark      = Color(0xFF1E293B); // لون النص الداكن
  static const Color textMuted     = Color(0xFF64748B); // لون النص الباهت

  String _selectedFilter = 'الكل'; // متغير الحالة لاختيار الفلتر النشط
  String _searchQuery = ''; // متغير الحالة لنص البحث

  @override // بناء واجهة المستخدم الرئيسية
  Widget build(BuildContext context) {
    return Directionality( // ضبط الاتجاه للعربية
      textDirection: TextDirection.rtl,
      child: WesalBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent, // شفاف لرؤية الخلفية الموحدة
          body: SafeArea(
            child: Column(
              children: [
                _MessagingHeader(isTab: widget.isTab, onBack: widget.onBack, baseColor: baseColor, textDark: textDark, textMuted: textMuted, primaryPurple: primaryPurple, primaryBlue: primaryBlue), // ترويسة الصفحة (معزولة)
                _SearchBox(onChanged: (v) => setState(() => _searchQuery = v), baseColor: baseColor, textMuted: textMuted, primaryPurple: primaryPurple), // صندوق البحث (معزول)
                SizedBox(height: 16.h),
                _FilterBar( // شريط التصنيفات (معزول الأداء)
                  selectedFilter: _selectedFilter,
                  onChanged: (v) => setState(() => _selectedFilter = v),
                  baseColor: baseColor,
                  textDark: textDark,
                  primaryBlue: primaryBlue,
                  primaryPurple: primaryPurple,
                ),
                SizedBox(height: 16.h),
                Expanded( // قائمة المحادثات المفلترة
                  child: _ChatListView(
                    searchQuery: _searchQuery,
                    selectedFilter: _selectedFilter,
                    baseColor: baseColor,
                    textDark: textDark,
                    textMuted: textMuted,
                    primaryBlue: primaryBlue,
                    primaryPurple: primaryPurple,
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

// ── Optimized Sub-Widgets ──────────────────────────────────────────────────

class _MessagingHeader extends StatelessWidget { // ويدجت ترويسة شاشة المحادثات
  final bool isTab;
  final VoidCallback? onBack;
  final Color baseColor, textDark, textMuted, primaryPurple, primaryBlue;

  const _MessagingHeader({required this.isTab, this.onBack, required this.baseColor, required this.textDark, required this.textMuted, required this.primaryPurple, required this.primaryBlue});

  @override // بناء ترويسة الصفحة
  Widget build(BuildContext context) {
    bool canPop = Navigator.canPop(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        children: [
          if (canPop || isTab) ...[ // إظهار زر الرجوع بتصميم Neumorphic
            GestureDetector(
              onTap: () => canPop ? Navigator.pop(context) : onBack?.call(),
              child: Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Icon(Icons.arrow_back_ios_rounded, color: textDark, size: 18.sp),
              ),
            ),
            SizedBox(width: 16.w),
          ],
          Text('المحادثات', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: textDark, fontFamily: 'Cairo')),
          const Spacer(),
          _HeaderNotificationIcon(primaryPurple: primaryPurple, primaryBlue: primaryBlue, baseColor: baseColor, textDark: textDark, textMuted: textMuted), // أيقونة التنبيهات
        ],
      ),
    );
  }
}

class _HeaderNotificationIcon extends StatelessWidget { // ويدجت أيقونة التنبيهات مع القائمة المنبثقة
  final Color primaryPurple, primaryBlue, baseColor, textDark, textMuted;
  const _HeaderNotificationIcon({required this.primaryPurple, required this.primaryBlue, required this.baseColor, required this.textDark, required this.textMuted});

  @override // بناء الأيقونة بتصميم Neumorphic
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: Offset(0, 50.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      color: baseColor,
      elevation: 8,
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: baseColor, shape: BoxShape.circle,
          boxShadow: [
            const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
          ],
        ),
        child: Stack(
          children: [
            Icon(Icons.notifications_none_rounded, color: primaryPurple, size: 24.sp),
            Positioned(right: 0, top: 0, child: Container(width: 8.r, height: 8.r, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle))),
          ],
        ),
      ),
      itemBuilder: (context) => [ // تنبيهات تجريبية
        _buildPopupItem('تم تصحيح واجب الرياضيات', 'منذ 10 دقائق', Icons.assignment_turned_in_rounded, primaryBlue),
        _buildPopupItem('رسالة جديدة من مدرسة العربي', 'منذ ساعة', Icons.chat_bubble_outline_rounded, primaryPurple),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupItem(String title, String time, IconData icon, Color color) { // بناء عنصر تنبيه واحد
    return PopupMenuItem(
      child: Container(
        width: 250.w, padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Container(padding: EdgeInsets.all(8.r), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 18.sp)),
            SizedBox(width: 12.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Cairo')),
              Text(time, style: TextStyle(fontSize: 10.sp, color: textMuted, fontFamily: 'Cairo')),
            ])),
          ],
        ),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget { // ويدجت صندوق البحث (معزول)
  final ValueChanged<String> onChanged;
  final Color baseColor, textMuted, primaryPurple;
  const _SearchBox({required this.onChanged, required this.baseColor, required this.textMuted, required this.primaryPurple});

  @override // بناء حقل البحث
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        decoration: BoxDecoration(
          color: baseColor, borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
          ],
        ),
        child: TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'ابحث عن مدرس أو محادثة...',
            hintStyle: TextStyle(color: textMuted, fontSize: 13.sp, fontFamily: 'Cairo'),
            prefixIcon: Icon(Icons.search_rounded, color: primaryPurple, size: 20.sp),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15.h),
          ),
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget { // ويدجت شريط الفلترة الأفقى (معزول)
  final String selectedFilter;
  final ValueChanged<String> onChanged;
  final Color baseColor, textDark, primaryBlue, primaryPurple;
  const _FilterBar({required this.selectedFilter, required this.onChanged, required this.baseColor, required this.textDark, required this.primaryBlue, required this.primaryPurple});

  @override // بناء شريط الأزرار
  Widget build(BuildContext context) {
    final filters = ['الكل', 'المدرسين', 'الإدارة', 'السائق'];
    return SizedBox(
      height: 40.h,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, i) {
          final active = selectedFilter == filters[i];
          return GestureDetector(
            onTap: () => onChanged(filters[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(left: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              decoration: BoxDecoration(
                gradient: active ? LinearGradient(colors: [primaryBlue, primaryPurple]) : null,
                color: active ? null : baseColor,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: active ? [BoxShadow(color: primaryPurple.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))] : [
                  const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
                ],
              ),
              child: Center(child: Text(filters[i], style: TextStyle(color: active ? Colors.white : textDark, fontWeight: FontWeight.bold, fontSize: 12.sp, fontFamily: 'Cairo'))),
            ),
          );
        },
      ),
    );
  }
}

class _ChatListView extends StatelessWidget { // ويدجت قائمة المحادثات (معزول الأداء)
  final String searchQuery, selectedFilter;
  final Color baseColor, textDark, textMuted, primaryBlue, primaryPurple;

  const _ChatListView({
    required this.searchQuery, required this.selectedFilter,
    required this.baseColor, required this.textDark, required this.textMuted,
    required this.primaryBlue, required this.primaryPurple
  });

  @override // بناء القائمة باستخدام ListView.builder
  Widget build(BuildContext context) {
    final List<ChatModel> allChats = [ // بيانات تجريبية
      ChatModel(name: 'أ. مروة الشاذلي', role: 'معلمة اللغة العربية', message: 'مستوى الطالب ممتاز في القراءة والاملاء', time: '10:30 ص', unread: 2, isOnline: true, image: 'https://i.pravatar.cc/150?u=teacher1', category: 'المدرسين'),
      ChatModel(name: 'أ. أحمد علي', role: 'معلم الرياضيات', message: 'برجاء مراجعة جدول الضرب مع الطالب', time: 'أمس', unread: 0, isOnline: false, image: 'https://i.pravatar.cc/150?u=teacher2', category: 'المدرسين'),
      ChatModel(name: 'إدارة المدرسة', role: 'الإدارة العامة', message: 'تنبيه: اجتماع أولياء الأمور يوم السبت القادم', time: '9:00 ص', unread: 1, isOnline: true, image: 'https://i.pravatar.cc/150?u=admin', category: 'الإدارة'),
    ];

    final filteredChats = allChats.where((chat) { // تصفية البيانات برمجياً
      final matchesFilter = selectedFilter == 'الكل' || chat.category == selectedFilter;
      final matchesSearch = searchQuery.isEmpty || chat.name.contains(searchQuery);
      return matchesFilter && matchesSearch;
    }).toList();

    if (filteredChats.isEmpty) { // حالة عدم وجود محادثات
      return Center(child: Text('لا توجد محادثات حالياً', style: TextStyle(color: textMuted, fontSize: 14.sp, fontFamily: 'Cairo')));
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      physics: const BouncingScrollPhysics(),
      itemCount: filteredChats.length,
      itemBuilder: (context, i) => _ChatTile(chat: filteredChats[i], baseColor: baseColor, textDark: textDark, textMuted: textMuted, primaryBlue: primaryBlue, primaryPurple: primaryPurple),
    );
  }
}

class _ChatTile extends StatelessWidget { // ويدجت بطاقة المحادثة الفردية (معزول)
  final ChatModel chat;
  final Color baseColor, textDark, textMuted, primaryBlue, primaryPurple;

  const _ChatTile({required this.chat, required this.baseColor, required this.textDark, required this.textMuted, required this.primaryBlue, required this.primaryPurple});

  @override // بناء بطاقة المحادثة
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: baseColor, borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatDetailScreen(chat: chat))), // فتح التفاصيل
        child: Row(
          children: [
            _ChatAvatar(baseColor: baseColor, primaryBlue: primaryBlue), // صورة الشخص الرمزية
            SizedBox(width: 14.w),
            Expanded(child: _ChatContent(chat: chat, textDark: textDark, textMuted: textMuted, primaryBlue: primaryBlue, primaryPurple: primaryPurple)), // محتوى المحادثة
          ],
        ),
      ),
    );
  }
}

class _ChatAvatar extends StatelessWidget { // صورة المحادثة Neumorphic
  final Color baseColor, primaryBlue;
  const _ChatAvatar({required this.baseColor, required this.primaryBlue});

  @override // بناء الصورة
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
      child: Icon(Icons.person_rounded, color: primaryBlue, size: 28.sp),
    );
  }
}

class _ChatContent extends StatelessWidget { // محتوى بيانات المحادثة داخل البطاقة
  final ChatModel chat;
  final Color textDark, textMuted, primaryBlue, primaryPurple;
  const _ChatContent({required this.chat, required this.textDark, required this.textMuted, required this.primaryBlue, required this.primaryPurple});

  @override // بناء النصوص وشارات التنبيه
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(chat.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp, color: textDark, fontFamily: 'Cairo')),
            Text(chat.time, style: TextStyle(fontSize: 10.sp, color: textMuted, fontFamily: 'Cairo')),
          ],
        ),
        Text(chat.role, style: TextStyle(fontSize: 11.sp, color: primaryBlue, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        SizedBox(height: 4.h),
        Row(
          children: [
            Expanded(child: Text(chat.message, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.sp, color: textMuted, fontFamily: 'Cairo'))),
            if (chat.unread > 0) _UnreadBadge(count: chat.unread, primaryBlue: primaryBlue, primaryPurple: primaryPurple),
          ],
        ),
      ],
    );
  }
}

class _UnreadBadge extends StatelessWidget { // شارة عدد الرسائل غير المقروءة
  final int count;
  final Color primaryBlue, primaryPurple;
  const _UnreadBadge({required this.count, required this.primaryBlue, required this.primaryPurple});

  @override // بناء الدائرة الملونة
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryBlue, primaryPurple]), borderRadius: BorderRadius.circular(10.r)),
      child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class ChatModel { // كلاس موديل البيانات
  final String name, role, message, time, image, category;
  final int unread;
  final bool isOnline;

  ChatModel({required this.name, required this.role, required this.message, required this.time, required this.unread, required this.isOnline, required this.image, required this.category});
}

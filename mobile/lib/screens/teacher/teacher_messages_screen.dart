/*
🧠 اسم الملف: teacher_messages_screen.dart

📌 بيعمل إيه؟
دي "مركز الرسايل" بتاع المدرس، بيقدر يتواصل فيه مع أولياء الأمور أو زمايله المدرسين.

👤 موجه لمين؟
- مدرسين

💡 فكرته:
تسهيل التواصل الرسمي والسريع بخصوص أي حاجة تهم الطلاب أو المدرسة.
*/

import 'dart:convert';
import 'package:flutter/material.dart'; // استيراد مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة التحكم في أحجام الشاشة
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/api_config.dart';
import '../../widgets/wesal_background.dart';

class TeacherMessagesScreen extends StatefulWidget {
  // تعريف كلاس شاشة المحادثات للمعلم كـ StatefulWidget
  final bool isTab; // متغير لتحديد هل الشاشة معروضة كتبويب أم شاشة مستقلة
  const TeacherMessagesScreen({super.key, this.isTab = false}); // مشيد الكلاس

  @override // إنشاء حالة الشاشة
  State<TeacherMessagesScreen> createState() => _TeacherMessagesScreenState();
}

class _TeacherMessagesScreenState extends State<TeacherMessagesScreen> {
  // كلاس حالة شاشة المحادثات
  // ── Design tokens ─────────────────────────────────────────────────────────
  static const Color primaryBlue = Color(0xFF2563EB); // اللون الأزرق الأساسي
  static const Color primaryPurple = Color(
    0xFF9333EA,
  ); // اللون البنفسجي الأساسي
  static const Color baseColor = Color(
    0xFFF0F3F8,
  ); // لون الخلفية الرمادي الفاتح
  static const Color textDark = Color(0xFF1E293B); // لون النص الداكن
  static const Color textMuted = Color(0xFF64748B); // لون النص الباهت

  // ── State ──────────────────────────────────────────────────────────────────
  String _selectedFilter = 'الكل';
  String _searchQuery = '';

  // Mock data shown while loading or when API is unavailable
  final List<Map<String, dynamic>> _mockChats = [
    // قائمة المحادثات (بيانات تجريبية)
    {
      'name': 'والد أحمد محمد',
      'role': 'ولي أمر',
      'avatar': 'و',
      'message': 'شكراً جزيلاً أستاذ على مجهودك',
      'time': '10:30 ص',
      'unread': 2,
      'color': const Color(0xFF3B82F6),
      'category': 'أولياء الأمور',
    },
    {
      'name': 'والدة سارة عبد الله',
      'role': 'ولي أمر',
      'avatar': 'و',
      'message': 'هل تم تحديد موعد الامتحان؟',
      'time': 'أمس',
      'unread': 0,
      'color': const Color(0xFF8B5CF6),
      'category': 'أولياء الأمور',
    },
    {
      'name': 'مدير المدرسة',
      'role': 'الإدارة',
      'avatar': 'م',
      'message': 'يرجى مراجعة الخطة الأسبوعية',
      'time': '9:00 ص',
      'unread': 1,
      'color': const Color(0xFF1E293B),
      'category': 'الإدارة',
    },
  ];

  List<Map<String, dynamic>> _apiChats = [];
  List<Map<String, dynamic>> get allChats => _apiChats.isNotEmpty ? _apiChats : _mockChats;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('mobile_token') ?? '';
      if (token.isEmpty) return;

      final res = await http.get(
        Uri.parse('${ApiConfig.getBaseUrl()}/conversations/mobile/conversations'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode != 200 || !mounted) return;

      final convs = (jsonDecode(res.body)['data'] as List? ?? []).cast<Map<String, dynamic>>();
      final colorPalette = [const Color(0xFF3B82F6), const Color(0xFF8B5CF6), const Color(0xFF1E293B), const Color(0xFF10B981)];
      setState(() {
        _apiChats = convs.asMap().entries.map((e) {
          final c = e.value;
          final name = c['otherParticipant']?['name'] ?? c['participant1Id'] ?? '?';
          final role = c['otherParticipant']?['type'] ?? 'مستخدم';
          final lastMsg = c['lastMessage']?['content'] ?? '';
          final unread = (c['unreadCount'] as num?)?.toInt() ?? 0;
          return {
            'id':       c['id'] ?? '',
            'name':     name,
            'role':     role == 'PARENT' ? 'ولي أمر' : role == 'TEACHER' ? 'معلم' : 'الإدارة',
            'avatar':   (name as String).isNotEmpty ? name.substring(0, 1) : '؟',
            'message':  lastMsg,
            'time':     '',
            'unread':   unread,
            'color':    colorPalette[e.key % colorPalette.length],
            'category': role == 'PARENT' ? 'أولياء الأمور' : 'الإدارة',
          };
        }).toList();
      });
    } catch (_) {}
  }

  List<BoxShadow> get _raiseShadow => [
    // دالة للحصول على تأثير الظل Neumorphic المرتفع
    const BoxShadow(
      color: Colors.white,
      blurRadius: 8,
      offset: Offset(-4, -4),
    ), // ظل إضاءة علوي
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(4, 4),
    ), // ظل عمق سفلي
  ];

  @override // دالة بناء واجهة الشاشة
  Widget build(BuildContext context) {
    return Directionality(
      // تحديد اتجاه النصوص للعربية
      textDirection: TextDirection.rtl,
      child: WesalBackground(
        child: Scaffold(
          // هيكل الصفحة
          backgroundColor: Colors.transparent, // شفاف لرؤية الخلفية الموحدة
          body: SafeArea(
            // حماية المحتوى من الحواف
            child: Column(
              children: [
                _buildHeader(), // بناء ترويسة الشاشة
                _buildSearchBox(), // بناء حقل البحث
                SizedBox(height: 16.h), // مسافة رأسية
                _buildFilters([
                  'الكل',
                  'أولياء الأمور',
                  'الإدارة',
                ]), // بناء شريط الفلاتر
                SizedBox(height: 16.h), // مسافة رأسية
                Expanded(
                  // قائمة المحادثات المفلترة
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    physics: const BouncingScrollPhysics(),
                    itemCount: allChats.length,
                    itemBuilder: (context, i) {
                      final chat = allChats[i];
                      if (_selectedFilter != 'الكل' &&
                          chat['category'] != _selectedFilter) {
                        return const SizedBox.shrink(); // تطبيق فلتر التصنيف
                      }
                      if (_searchQuery.isNotEmpty &&
                          !chat['name'].contains(_searchQuery)) {
                        return const SizedBox.shrink(); // تطبيق فلتر البحث
                      }
                      return _buildChatTile(chat); // بناء بطاقة المحادثة الفردية
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    // دالة بناء ترويسة الشاشة (زر الرجوع والعنوان)
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Row(
        children: [
          if (!widget.isTab) ...[
            // إظهار زر الرجوع إذا لم تكن الشاشة جزءاً من تبويب
            GestureDetector(
              onTap: () => Navigator.pop(context), // العودة للشاشة السابقة
              child: Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: baseColor,
                  shape: BoxShape.circle,
                  boxShadow: _raiseShadow,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18.sp,
                  color: textDark,
                ),
              ),
            ),
            SizedBox(width: 16.w), // مسافة أفقية
          ],
          Text(
            'المحادثات',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: textDark,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    // دالة بناء حقل البحث عن المحادثات
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: _raiseShadow,
        ),
        child: TextField(
          onChanged: (v) =>
              setState(() => _searchQuery = v), // تحديث متغير البحث
          decoration: InputDecoration(
            hintText: 'ابحث عن اسم...',
            hintStyle: TextStyle(
              color: textMuted,
              fontSize: 13.sp,
              fontFamily: 'Cairo',
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: primaryPurple,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15.h),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(List<String> filters) {
    // دالة بناء شريط أزرار الفلترة الأفقية
    return SizedBox(
      height: 40.h,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, i) {
          final active =
              _selectedFilter == filters[i]; // هل هذا الفلتر هو المختار؟
          return GestureDetector(
            onTap: () => setState(
              () => _selectedFilter = filters[i],
            ), // تحديث الفلتر المختار
            child: AnimatedContainer(
              // زر الفلتر بتصميم تفاعلي
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(left: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              decoration: BoxDecoration(
                gradient: active
                    ? const LinearGradient(colors: [primaryBlue, primaryPurple])
                    : null,
                color: active ? null : baseColor,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: primaryPurple.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : _raiseShadow,
              ),
              child: Center(
                child: Text(
                  filters[i],
                  style: TextStyle(
                    color: active ? Colors.white : textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chat) {
    // دالة بناء عنصر المحادثة الفردي في القائمة
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: _raiseShadow,
      ),
      child: InkWell(
        // جعل البطاقة قابلة للضغط للانتقال لتفاصيل المحادثة
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeacherChatDetailScreen(
              name: chat['name'],
              color: chat['color'],
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              // الأفاتار (الصورة الرمزية) بتصميم Neumorphic
              padding: EdgeInsets.all(2.r),
              decoration: BoxDecoration(
                color: baseColor,
                shape: BoxShape.circle,
                boxShadow: _raiseShadow,
              ),
              child: CircleAvatar(
                radius: 24.r,
                backgroundColor: (chat['color'] as Color).withValues(
                  alpha: 0.12,
                ),
                child: Text(
                  chat['avatar'],
                  style: TextStyle(
                    color: chat['color'],
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 14.w), // مسافة أفقية
            Expanded(
              // تفاصيل المحادثة (الاسم، الوقت، الرسالة الأخيرة)
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: textDark,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        chat['time'],
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: textMuted,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat['message'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: textMuted,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                      if (chat['unread'] >
                          0) // عرض دائرة عدد الرسائل غير المقروءة إذا وجدت
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [primaryBlue, primaryPurple],
                            ),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            '${chat['unread']}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TeacherChatDetailScreen extends StatefulWidget {
  // تعريف كلاس شاشة تفاصيل المحادثة (الدردشة)
  final String name; // اسم الشخص الذي تتم مراسلته
  final Color color; // اللون المميز لهذا الشخص
  const TeacherChatDetailScreen({
    super.key,
    required this.name,
    required this.color,
  }); // مشيد الكلاس

  @override // إنشاء حالة شاشة التفاصيل
  State<TeacherChatDetailScreen> createState() =>
      _TeacherChatDetailScreenState();
}

class _TeacherChatDetailScreenState extends State<TeacherChatDetailScreen> {
  // كلاس حالة شاشة تفاصيل الدردشة
  final TextEditingController _msgController =
      TextEditingController(); // متحكم حقل إدخال الرسالة الجديدة
  final List<Map<String, dynamic>> messages = [
    // قائمة الرسائل المتبادلة (بيانات تجريبية)
    {
      'text': 'مرحباً، هل يمكنني الاستفسار عن مستوى ابني مؤخراً؟',
      'isMe': false,
    },
    {
      'text':
          'أهلاً بك، نعم بالتأكيد. مستواه في تحسن ملحوظ وشارك بشكل جيد هذا الأسبوع.',
      'isMe': true,
    },
  ];

  List<BoxShadow> get _raiseShadow => [
    // دالة الظلال للتصميم المتناسق
    const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(4, 4),
    ),
  ];

  @override // دالة بناء واجهة شاشة الدردشة
  Widget build(BuildContext context) {
    return Directionality(
      // اتجاه النصوص عربي
      textDirection: TextDirection.rtl,
      child: WesalBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent, // لون الخلفية
          appBar: AppBar(
            // شريط العلوية (Header)
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            leading: Center(
              // زر الرجوع المخصص
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F3F8),
                    shape: BoxShape.circle,
                    boxShadow: _raiseShadow,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ),
            leadingWidth: 70.w,
            title: Text(
              widget.name,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w900,
                fontSize: 18,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                // منطقة عرض فقاعات الرسائل
                child: ListView.builder(
                  padding: EdgeInsets.all(20.r),
                  itemCount: messages.length,
                  itemBuilder: (context, i) => _buildBubble(messages[i]),
                ),
              ),
              _buildInput(), // حقل إدخال الرسالة في الأسفل
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBubble(Map<String, dynamic> msg) {
    // دالة بناء فقاعة الرسالة (صادرة أو واردة)
    final isMe = msg['isMe'] as bool; // هل الرسالة من المعلم نفسه؟
    return Align(
      alignment: isMe
          ? Alignment.centerLeft
          : Alignment.centerRight, // محاذاة الرسالة حسب المرسل
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        constraints: BoxConstraints(
          maxWidth: 0.75.sw,
        ), // تحديد أقصى عرض للفقاعة
        decoration: BoxDecoration(
          gradient: isMe
              ? const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF9333EA)],
                )
              : null, // تدرج لوني لرسائلي
          color: isMe ? null : Colors.white, // لون أبيض لرسائل الطرف الآخر
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          msg['text'],
          style: TextStyle(
            color: isMe ? Colors.white : const Color(0xFF1E293B),
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }

  Widget _buildInput() {
    // دالة بناء منطقة إدخال النص وزر الإرسال
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 30.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            // حقل النص
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F3F8),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: TextField(
                controller: _msgController,
                decoration: const InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w), // مسافة أفقية
          GestureDetector(
            // زر الإرسال
            onTap: () {
              if (_msgController.text.isEmpty) return; // منع إرسال رسالة فارغة
              setState(() {
                messages.add({'text': _msgController.text, 'isMe': true});
                _msgController.clear();
              }); // إضافة الرسالة وتفريغ الحقل
            },
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF9333EA)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

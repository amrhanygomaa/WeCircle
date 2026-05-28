/*
🧠 اسم الملف: behavioral_consultation_screen.dart

📌 بيعمل إيه؟
دي شاشة متكاملة لعرض قائمة بالأطباء، مع نظام حجز مواعيد متطور وعرض الحجز النشط في أعلى الشاشة.

👤 موجه لمين؟
- أولياء أمور

💡 فكرته:
توفير تجربة حجز سلسة واحترافية مع إمكانية متابعة الحجز المؤكد مباشرة من الشاشة الرئيسية.
*/

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app_theme.dart';
import '../../widgets/wesal_background.dart';

class BehavioralConsultationScreen extends StatefulWidget {
  const BehavioralConsultationScreen({super.key});

  @override
  State<BehavioralConsultationScreen> createState() => _BehavioralConsultationScreenState();
}

class _BehavioralConsultationScreenState extends State<BehavioralConsultationScreen> {
  static const Color primaryBlue = Color(0xFF6366F1);
  static const Color primaryPurple = Color(0xFF9333EA);

  // تخزين بيانات الحجز النشط
  Map<String, String>? _activeBooking;

  // دالة مساعدة لعرض تفاصيل الحجز - تم تعديل السماكة لتكون متوازنة
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: primaryPurple),
        SizedBox(width: 10.w),
        Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, color: Colors.grey[700], fontWeight: FontWeight.w600)),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _openChat(BuildContext context, String doctorName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorChatScreen(doctorName: doctorName),
      ),
    );
  }

  Future<void> _openBooking(BuildContext context, String doctorName) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorBookingScreen(doctorName: doctorName),
      ),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        _activeBooking = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> doctors = [
      {
        'name': 'د. أحمد منصور',
        'specialty': 'استشاري تعديل سلوك وتربية إيجابية',
        'phone': '01023456789',
        'experience': 'خبرة 15 عاماً في التعامل مع المراهقين',
        'availability': 'متاح يومياً من 4 م إلى 9 م',
      },
      {
        'name': 'د. سارة محمود',
        'specialty': 'أخصائية نفسية أطفال وتنمية مهارات',
        'phone': '01123456789',
        'experience': 'متخصصة في علاج اضطرابات النطق والتوحد',
        'availability': 'متاحة (سبت - اثنين - أربعاء)',
      },
      {
        'name': 'د. محمد علي',
        'specialty': 'خبير صعوبات تعلم وإرشاد أكاديمي',
        'phone': '01223456789',
        'experience': 'دكتوراه في علم النفس التربوي',
        'availability': 'متاح للحالات المستعجلة هاتفياً',
      },
      {
        'name': 'د. ليلى حسن',
        'specialty': 'استشارية علاقات أسرية وصحة نفسية',
        'phone': '01523456789',
        'experience': 'خبيرة في حل مشكلات العنف والعدوانية',
        'availability': 'الحجز المسبق مطلوب',
      },
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: WesalBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.keyboard_arrow_right_rounded, color: primaryBlue, size: 32.sp),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [primaryBlue, primaryPurple],
                  ).createShader(bounds),
                  child: Text(
                    'استشارة سلوكية',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24.sp,
                      fontFamily: 'Cairo',
                      shadows: [
                        Shadow(
                          color: primaryBlue.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                if (_activeBooking != null) ...[
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
                            title: Column(
                              children: [
                                Icon(Icons.event_available_rounded, color: primaryBlue, size: 40.sp),
                                SizedBox(height: 10.h),
                                Text('تفاصيل حجزك', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: primaryBlue)),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16.r),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.r),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                                    ],
                                    border: Border.all(color: primaryBlue.withOpacity(0.1)),
                                  ),
                                  child: Column(
                                    children: [
                                      _buildDetailRow(Icons.person_pin_rounded, 'الطبيب:', _activeBooking!['doctor']!),
                                      SizedBox(height: 15.h),
                                      _buildDetailRow(Icons.calendar_month_rounded, 'اليوم:', _activeBooking!['day']!),
                                      SizedBox(height: 15.h),
                                      _buildDetailRow(Icons.access_time_filled_rounded, 'الموعد:', '${_activeBooking!['period']} (${_activeBooking!['time']})'),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 25.h),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [primaryBlue, primaryPurple]),
                                    borderRadius: BorderRadius.circular(15.r),
                                    boxShadow: [
                                      BoxShadow(color: primaryBlue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: EdgeInsets.symmetric(vertical: 12.h),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                                    ),
                                    child: Text('إغلاق', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14.sp)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryBlue, primaryPurple.withOpacity(0.8)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.circular(30.r),
                        boxShadow: [
                          BoxShadow(
                            color: primaryPurple.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.white, size: 16.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'حجز مؤكد',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          body: ListView.builder(
            padding: EdgeInsets.all(20.r),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return _DoctorCard(
                doctor: doctor,
                onCall: () => _makePhoneCall(doctor['phone']!),
                onChat: () => _openChat(context, doctor['name']!),
                onBook: () => _openBooking(context, doctor['name']!),
                primaryBlue: primaryBlue,
                primaryPurple: primaryPurple,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final Map<String, String> doctor;
  final VoidCallback onCall, onChat, onBook;
  final Color primaryBlue, primaryPurple;

  const _DoctorCard({
    required this.doctor,
    required this.onCall,
    required this.onChat,
    required this.onBook,
    required this.primaryBlue,
    required this.primaryPurple,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50.r,
                height: 50.r,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primaryBlue, primaryPurple]),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_pin_rounded, color: Colors.white, size: 28.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor['name']!,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    Text(
                      doctor['specialty']!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(color: Colors.grey.withOpacity(0.1)),
          SizedBox(height: 8.h),
          _buildInfoRow(Icons.history_rounded, doctor['experience']!),
          SizedBox(height: 6.h),
          _buildInfoRow(Icons.access_time_rounded, doctor['availability']!),
          SizedBox(height: 16.h),
          
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primaryBlue, primaryPurple]),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ElevatedButton(
                  onPressed: onCall,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: Size(double.infinity, 42.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone_in_talk_rounded, size: 16.sp, color: Colors.white),
                      SizedBox(width: 8.w),
                      Text('اتصال هاتفي', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: Colors.white)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onChat,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryBlue, width: 1.5),
                        minimumSize: Size(double.infinity, 42.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: 16.sp, color: primaryBlue),
                          SizedBox(width: 8.w),
                          Text('دردشة', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: primaryBlue)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onBook,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryPurple, width: 1.5),
                        minimumSize: Size(double.infinity, 42.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month_rounded, size: 16.sp, color: primaryPurple),
                          SizedBox(width: 8.w),
                          Text('حجز موعد', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: primaryPurple)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: const Color(0xFF64748B)),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF475569), fontFamily: 'Cairo', fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// ─── Chat Screen ────────────────────────────────────────────────────────────
class DoctorChatScreen extends StatefulWidget {
  final String doctorName;
  const DoctorChatScreen({super.key, required this.doctorName});

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'text': 'مرحباً بك، كيف يمكنني مساعدتك اليوم؟', 'isMe': false},
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF6366F1);
    const Color primaryPurple = Color(0xFF9333EA);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [primaryBlue, primaryPurple]),
            ),
          ),
          title: Text(widget.doctorName, style: TextStyle(fontFamily: 'Cairo', fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: EdgeInsets.all(20.r),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Align(
                    alignment: msg['isMe'] ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        gradient: msg['isMe'] ? const LinearGradient(colors: [primaryBlue, primaryPurple]) : null,
                        color: msg['isMe'] ? null : Colors.grey[200],
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: Text(
                        msg['text'],
                        style: TextStyle(color: msg['isMe'] ? Colors.white : Colors.black87, fontFamily: 'Cairo', fontSize: 14.sp, fontWeight: FontWeight.w600),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(20.r),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالتك هنا...',
                        hintStyle: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp, fontWeight: FontWeight.w600),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.r), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  GestureDetector(
                    onTap: () {
                      if (_controller.text.isEmpty) return;
                      setState(() {
                        _messages.insert(0, {'text': _controller.text, 'isMe': true});
                        _controller.clear();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [primaryBlue, primaryPurple]),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white),
                    ),
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

// ─── Modern Booking Screen ──────────────────────────────────────────────────
class DoctorBookingScreen extends StatefulWidget {
  final String doctorName;
  const DoctorBookingScreen({super.key, required this.doctorName});

  @override
  State<DoctorBookingScreen> createState() => _DoctorBookingScreenState();
}

class _DoctorBookingScreenState extends State<DoctorBookingScreen> {
  int _selectedDayIndex = 0;
  String? _selectedTime;

  final List<String> _days = ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس'];
  final List<String> _dates = ['20 مايو', '21 مايو', '22 مايو', '23 مايو', '24 مايو', '25 مايو'];

  final List<String> _morningSlots = ['09:00 ص', '10:00 ص', '11:00 ص'];
  final List<String> _eveningSlots = ['04:00 م', '05:00 م', '06:00 م', '07:00 م', '08:00 م'];

  static const Color primaryBlue = Color(0xFF6366F1);
  static const Color primaryPurple = Color(0xFF9333EA);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [primaryBlue, primaryPurple]),
            ),
          ),
          title: Text('حجز موعد الاستشارة', style: TextStyle(fontFamily: 'Cairo', fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text('اختر اليوم المفضل:', style: TextStyle(fontFamily: 'Cairo', fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    height: 100.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: _days.length,
                      itemBuilder: (context, index) {
                        bool isSelected = _selectedDayIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedDayIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 75.w,
                            margin: EdgeInsets.symmetric(horizontal: 8.w),
                            decoration: BoxDecoration(
                              gradient: isSelected ? const LinearGradient(colors: [primaryBlue, primaryPurple]) : null,
                              color: isSelected ? null : Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected ? primaryBlue.withOpacity(0.3) : Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_days[index], style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, color: isSelected ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold)),
                                SizedBox(height: 4.h),
                                Text(_dates[index], style: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp, color: isSelected ? Colors.white.withOpacity(0.8) : const Color(0xFF64748B), fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  SizedBox(height: 32.h),

                  _buildTimeSection('الفترة الصباحية', _morningSlots, Icons.wb_sunny_rounded),
                  SizedBox(height: 24.h),
                  _buildTimeSection('الفترة المسائية', _eveningSlots, Icons.nights_stay_rounded),
                ],
              ),
            ),

            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: _selectedTime != null ? const LinearGradient(colors: [primaryBlue, primaryPurple]) : null,
                  color: _selectedTime == null ? Colors.grey[300] : null,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: ElevatedButton(
                  onPressed: _selectedTime == null ? null : () {
                    String period = _morningSlots.contains(_selectedTime) ? "صباحية" : "مسائية";
                    showDialog(
                      context: context,
                      builder: (context) => Directionality(
                        textDirection: TextDirection.rtl,
                        child: AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.all(15.r),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.check_circle_rounded, color: Colors.green, size: 50.sp),
                              ),
                              SizedBox(height: 20.h),
                              Text(
                                'تم تأكيد الحجز بنجاح',
                                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 18.sp, color: primaryBlue),
                              ),
                              SizedBox(height: 16.h),
                              Container(
                                padding: EdgeInsets.all(16.r),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(15.r),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Column(
                                  children: [
                                    _buildDialogRow(Icons.person_outline_rounded, 'الطبيب:', widget.doctorName),
                                    SizedBox(height: 8.h),
                                    _buildDialogRow(Icons.calendar_today_rounded, 'اليوم:', _days[_selectedDayIndex]),
                                    SizedBox(height: 8.h),
                                    _buildDialogRow(Icons.access_time_rounded, 'الموعد:', '$period ($_selectedTime)'),
                                  ],
                                ),
                              ),
                              SizedBox(height: 24.h),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [primaryBlue, primaryPurple]),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context); // إغلاق الديالوج
                                    Navigator.pop(context, {
                                      'doctor': widget.doctorName,
                                      'day': _days[_selectedDayIndex],
                                      'time': _selectedTime!,
                                      'period': period
                                    }); // العودة مع البيانات
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                  ),
                                  child: Text('حسناً', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: Size(double.infinity, 55.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                  ),
                  child: Text('تأكيد الحجز', style: TextStyle(fontFamily: 'Cairo', fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSection(String title, List<String> slots, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            children: [
              Icon(icon, size: 20.sp, color: primaryPurple),
              SizedBox(width: 8.w),
              Text(title, style: TextStyle(fontFamily: 'Cairo', fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: slots.map((time) {
              bool isSelected = _selectedTime == time;
              return GestureDetector(
                onTap: () => setState(() => _selectedTime = time),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryBlue.withOpacity(0.1) : Colors.white,
                    border: Border.all(color: isSelected ? primaryBlue : Colors.grey.withOpacity(0.2), width: 1.5),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    time,
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp, color: isSelected ? primaryBlue : const Color(0xFF1E293B), fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: const Color(0xFF64748B)),
        SizedBox(width: 8.w),
        Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

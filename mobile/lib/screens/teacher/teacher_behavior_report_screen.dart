/*
🧠 اسم الملف: teacher_behavior_report_screen.dart

📌 بيعمل إيه؟
شاشة بتسمح للمدرس بإصدار تقارير سلوك (يومية، أسبوعية، شهرية) بنفس تصميم تقارير ولي الأمر، مع معاينة مطابقة 100% للشكل النهائي.

👤 موجه لمين؟
- مدرسين

💡 فكرته:
ضمان التطابق التام في تجربة المستخدم بين ما يرسله المعلم وما يستلمه ولي الأمر.
*/

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/wesal_background.dart';

class TeacherBehaviorReportScreen extends StatefulWidget {
  final String? studentName;
  final bool isTab;
  const TeacherBehaviorReportScreen({super.key, this.studentName, this.isTab = false});

  @override
  State<TeacherBehaviorReportScreen> createState() => _TeacherBehaviorReportScreenState();
}

class _TeacherBehaviorReportScreenState extends State<TeacherBehaviorReportScreen> {
  // ── Design tokens (Identical to Parent Screen) ──────────────────────────
  static const Color primaryPurple = Color(0xFF4F46E5);
  static const Color primaryBlue   = Color(0xFF6366F1);
  static const Color textDark      = Color(0xFF1E293B);
  static const Color textMuted     = Color(0xFF64748B);
  static const Color positiveColor = Color(0xFF10B981);
  static const Color alertColor    = Color(0xFFF59E0B);
  static const Color borderColor   = Color(0xFFE2E8F0);
  static const Color surfaceColor = Color(0xFFF8FAFC);

  // ── State ──────────────────────────────────────────────────────────────────
  int _selectedType = 0; // 0: Daily, 1: Weekly, 2: Monthly
  String? selectedClass;
  String? selectedStudent;
  
  List<Map<String, String>> dailyEntries = [
    {'title': 'المشاركة الصفية', 'status': 'إيجابي', 'desc': 'شارك بفعالية في النقاش وأجاب بدقة.'}
  ];

  List<Map<String, String>> weeklyDays = List.generate(5, (index) => {
    'day': ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس'][index],
    'positive': '',
    'negative': ''
  });
  List<String> remedialPlan = ['', '', '', ''];

  List<Map<String, String>> monthlyWeeks = List.generate(4, (index) => {
    'week': ['الأسبوع الأول', 'الأسبوع الثاني', 'الأسبوع الثالث', 'الأسبوع الرابع'][index],
    'positive': '',
    'negative': '',
    'improvement': 'مستقر'
  });

  final List<Map<String, dynamic>> classesLower = [
    {'id': '1-1', 'name': 'فصل 1-1', 'students': ['يوسف كمال', 'أمل حسن', 'مازن علي']},
    {'id': '1-2', 'name': 'فصل 1-2', 'students': ['أحمد كمال', 'سارة حسن', 'علي مازن']},
    {'id': '2-1', 'name': 'فصل 2-1', 'students': ['زياد محمد', 'حلا إبراهيم', 'فارس محمود']},
    {'id': '3-1', 'name': 'فصل 3-1', 'students': ['سيف الدين', 'لينا يوسف', 'آدم خالد']},
  ];

  final List<Map<String, dynamic>> classesUpper = [
    {'id': '4-1', 'name': 'فصل 4-1', 'students': ['إياد وليد', 'جنى تامر', 'حمزة سعيد']},
    {'id': '5-1', 'name': 'فصل 5-1', 'students': ['أحمد محمد', 'سارة عبد الله', 'ياسين محمود']},
    {'id': '6-1', 'name': 'فصل 6-1', 'students': ['نور الدين', 'رنا مجدي', 'علياء طارق']},
  ];

  @override
  void initState() {
    super.initState();
    selectedStudent = widget.studentName;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: WesalBackground(
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _buildTypeButton('يومي', Icons.calendar_today_rounded, 0),
                            SizedBox(width: 10.w),
                            _buildTypeButton('اسبوعي', Icons.calendar_month_rounded, 1),
                            SizedBox(width: 10.w),
                            _buildTypeButton('شهري', Icons.analytics_rounded, 2),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        Container(
                          margin: EdgeInsets.only(bottom: 120.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
                          ),
                          child: Column(
                            children: [
                              _buildOfficialEditorHeader(),
                              Padding(
                                padding: EdgeInsets.all(20.r),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle('أولاً: اختيار الطالب'),
                                    _buildClassPicker('صفوف (1 - 3)', classesLower),
                                    SizedBox(height: 12.h),
                                    _buildClassPicker('صفوف (4 - 6)', classesUpper),
                                    if (selectedClass != null) ...[
                                      SizedBox(height: 16.h),
                                      _buildStudentPicker(),
                                    ],

                                    if (selectedStudent != null) ...[
                                      SizedBox(height: 32.h),
                                      const Divider(color: borderColor),
                                      SizedBox(height: 24.h),
                                      _buildSectionTitle('ثانياً: إدخال بيانات التقرير'),
                                      if (_selectedType == 0) _buildDailyEditor(),
                                      if (_selectedType == 1) _buildWeeklyEditor(),
                                      if (_selectedType == 2) _buildMonthlyEditor(),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildActionButtons(),
      ),
    );
  }

  Widget _buildTypeButton(String label, IconData icon, int type) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? primaryPurple : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: isSelected ? [BoxShadow(color: primaryPurple.withOpacity(0.3), blurRadius: 10)] : [],
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : textMuted, size: 20.sp),
              SizedBox(height: 4.h),
              Text(label, style: TextStyle(color: isSelected ? Colors.white : textDark, fontSize: 12.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Row(
        children: [
          if (!widget.isTab) ...[
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(10.r),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.arrow_back_ios_new_rounded, size: 18.sp, color: textDark),
              ),
            ),
            SizedBox(width: 16.w),
          ],
          Text('بوابة تحرير التقارير', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: textDark, fontFamily: 'Cairo')),
        ],
      ),
    );
  }

  Widget _buildOfficialEditorHeader() {
    String typeText = _selectedType == 0 ? 'اليومي' : (_selectedType == 1 ? 'الأسبوعي' : 'الشهري');
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        border: const Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Icon(Icons.edit_document, color: primaryPurple, size: 22.sp),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('تحرير التقرير $typeText الرسمي', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: textDark, fontFamily: 'Cairo')),
              Text('المعلم هو المسؤول عن دقة هذه البيانات', style: TextStyle(fontSize: 10.sp, color: textMuted, fontFamily: 'Cairo')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: primaryPurple, fontFamily: 'Cairo')),
    );
  }

  Widget _buildClassPicker(String title, List<Map<String, dynamic>> classes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 10.sp, color: textMuted, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        SizedBox(height: 8.h),
        SizedBox(
          height: 60.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final c = classes[index];
              final isSelected = selectedClass == c['id'];
              return GestureDetector(
                onTap: () => setState(() { selectedClass = c['id']; selectedStudent = null; }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 100.w,
                  margin: EdgeInsets.only(left: 10.w),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryPurple : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: isSelected ? primaryPurple : borderColor),
                  ),
                  child: Center(
                    child: Text(c['name'], style: TextStyle(color: isSelected ? Colors.white : textDark, fontWeight: FontWeight.bold, fontSize: 12.sp, fontFamily: 'Cairo')),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStudentPicker() {
    final List<Map<String, dynamic>> all = [...classesLower, ...classesUpper];
    final List<String> students = all.firstWhere((c) => c['id'] == selectedClass)['students'];
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: students.map((s) {
        final isSelected = selectedStudent == s;
        return GestureDetector(
          onTap: () => setState(() => selectedStudent = s),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? primaryBlue : Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: isSelected ? primaryBlue : borderColor),
            ),
            child: Text(s, style: TextStyle(color: isSelected ? Colors.white : textDark, fontSize: 11.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
          ),
        );
      }).toList(),
    );
  }

  // --- EDITORS ---

  Widget _buildDailyEditor() {
    return Column(
      children: [
        ...dailyEntries.asMap().entries.map((entry) {
          int idx = entry.key;
          var data = entry.value;
          return Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildField('عنوان الملاحظة', (v) => data['title'] = v, initialValue: data['title']),
                    ),
                    SizedBox(width: 10.w),
                    _buildStatusToggle(data, () => setState(() {})),
                  ],
                ),
                SizedBox(height: 10.h),
                _buildField('الوصف التفصيلي', (v) => data['desc'] = v, maxLines: 2, initialValue: data['desc']),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: () => setState(() => dailyEntries.add({'title': '', 'status': 'إيجابي', 'desc': ''})),
          icon: const Icon(Icons.add_circle_outline, color: primaryPurple),
          label: const Text('إضافة ملاحظة يومية أخرى', style: TextStyle(color: primaryPurple, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildWeeklyEditor() {
    return Column(
      children: [
        ...weeklyDays.asMap().entries.map((entry) {
          var data = entry.value;
          return Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['day']!, style: const TextStyle(fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Cairo')),
                SizedBox(height: 10.h),
                _buildField('ملاحظات إيجابية', (v) => data['positive'] = v, initialValue: data['positive']),
                SizedBox(height: 8.h),
                _buildField('ملاحظات سلبية', (v) => data['negative'] = v, initialValue: data['negative']),
              ],
            ),
          );
        }),
        SizedBox(height: 20.h),
        _buildSectionTitle('خطة العلاج والتوصيات:'),
        ...remedialPlan.asMap().entries.map((entry) {
          int idx = entry.key;
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: _buildField('توصية ${idx + 1}', (v) => remedialPlan[idx] = v, initialValue: remedialPlan[idx]),
          );
        }),
      ],
    );
  }

  Widget _buildMonthlyEditor() {
    return Column(
      children: [
        ...monthlyWeeks.asMap().entries.map((entry) {
          var data = entry.value;
          return Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(data['week']!, style: const TextStyle(fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Cairo')),
                    _buildImprovementPicker(data, () => setState(() {})),
                  ],
                ),
                SizedBox(height: 10.h),
                _buildField('أهم الإيجابيات', (v) => data['positive'] = v, maxLines: 2, initialValue: data['positive']),
                SizedBox(height: 8.h),
                _buildField('أهم التنبيهات', (v) => data['negative'] = v, maxLines: 2, initialValue: data['negative']),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildField(String hint, Function(String) onChanged, {int maxLines = 1, String? initialValue}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(8.r), border: Border.all(color: borderColor)),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        maxLines: maxLines,
        style: TextStyle(fontSize: 12.sp, color: textDark, fontFamily: 'Cairo'),
        decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(fontSize: 11.sp, color: textMuted), border: InputBorder.none),
      ),
    );
  }

  Widget _buildStatusToggle(Map<String, String> data, VoidCallback onToggle) {
    bool isPos = data['status'] == 'إيجابي';
    return GestureDetector(
      onTap: () {
        data['status'] = isPos ? 'تنبيه' : 'إيجابي';
        onToggle();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: (isPos ? positiveColor : alertColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: isPos ? positiveColor : alertColor),
        ),
        child: Text(data['status']!, style: TextStyle(color: isPos ? positiveColor : alertColor, fontSize: 10.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
      ),
    );
  }

  Widget _buildImprovementPicker(Map<String, String> data, VoidCallback onUpdate) {
    List<String> options = ['تحسن ملحوظ', 'مستقر', 'تحسن جيد جداً', 'ممتاز'];
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: data['improvement'],
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: TextStyle(fontSize: 10.sp, fontFamily: 'Cairo')))).toList(),
        onChanged: (v) {
          data['improvement'] = v!;
          onUpdate();
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildButton('معاينة التقرير النهائي', Icons.visibility_outlined, primaryBlue, () => _showPreview()),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildButton('إرسال التقرير الآن', Icons.send_rounded, textDark, () => _submitReport()),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18.sp),
            SizedBox(width: 8.w),
            Text(label, style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
          ],
        ),
      ),
    );
  }

  void _submitReport() {
    if (selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار الطالب أولاً', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: alertColor));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال التقرير المعتمد بنجاح', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: positiveColor));
    if (!widget.isTab) Navigator.pop(context);
  }

  void _showPreview() {
    if (selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار الطالب للمعاينة', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: alertColor));
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          height: 0.9.sh,
          decoration: BoxDecoration(color: const Color(0xFFF0F3F8), borderRadius: BorderRadius.vertical(top: Radius.circular(30.r))),
          child: Column(
            children: [
              _buildPreviewHeader(),
              Expanded(child: SingleChildScrollView(padding: EdgeInsets.all(20.r), child: _buildIdenticalPreview())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30.r))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.remove_red_eye_rounded, color: primaryPurple),
              SizedBox(width: 8.w),
              Text('معاينة التقرير النهائي (كما يظهر لولي الأمر)', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: textDark, fontFamily: 'Cairo')),
            ],
          ),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: textDark)),
        ],
      ),
    );
  }

  Widget _buildIdenticalPreview() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20)],
      ),
      child: Column(
        children: [
          // Official Header
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.network('https://cdn-icons-png.flaticon.com/512/2940/2940651.png', width: 45.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('أكاديمية وصال التعليمية', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: primaryPurple, fontFamily: 'Cairo')),
                        Text('تقرير المتابعة السلوكية الرسمية', style: TextStyle(fontSize: 10.sp, color: textMuted, fontFamily: 'Cairo')),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                _InfoRowPreview(label: 'اسم الطالب:', value: selectedStudent!),
                _InfoRowPreview(label: 'الصف الدراسي:', value: selectedClass ?? '-'),
                _InfoRowPreview(label: 'تاريخ التقرير:', value: '16 مايو 2026'),
              ],
            ),
          ),
          
          if (_selectedType == 0) _buildDailyContentPreview(),
          if (_selectedType == 1) _buildWeeklyContentPreview(),
          if (_selectedType == 2) _buildMonthlyContentPreview(),

          // Signature Section
          Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              children: [
                const Divider(),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SignatureLine(label: 'توقيع مدير المدرسة'),
                    _SignatureLine(label: 'ختم الاعتماد الرسمي'),
                  ],
                ),
                SizedBox(height: 20.h),
                Text('صدر هذا التقرير آلياً ولا يتطلب توقيعاً يدوياً.', style: TextStyle(fontSize: 9.sp, color: textMuted, fontFamily: 'Cairo')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyContentPreview() {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        children: dailyEntries.map((e) => _BehaviorItemPreview(
          title: e['title']!,
          status: e['status']!,
          desc: e['desc']!,
          color: e['status'] == 'إيجابي' ? positiveColor : alertColor,
        )).toList(),
      ),
    );
  }

  Widget _buildWeeklyContentPreview() {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...weeklyDays.map((d) => _WeeklyCardPreview(day: d['day']!, pos: d['positive']!, neg: d['negative']!)),
          SizedBox(height: 24.h),
          Text('خطة العلاج والتوجيه:', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: textDark, fontFamily: 'Cairo')),
          SizedBox(height: 12.h),
          ...remedialPlan.where((p) => p.isNotEmpty).map((p) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(children: [
              const Icon(Icons.check_circle_outline, color: positiveColor, size: 16),
              SizedBox(width: 8.w),
              Text(p, style: TextStyle(fontSize: 12.sp, color: textDark, fontFamily: 'Cairo')),
            ]),
          )),
        ],
      ),
    );
  }

  Widget _buildMonthlyContentPreview() {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        children: monthlyWeeks.map((w) => _MonthlyCardPreview(
          week: w['week']!,
          pos: w['positive']!,
          neg: w['negative']!,
          imp: w['improvement']!,
        )).toList(),
      ),
    );
  }
}

// Preview Components (Identical to Parent Widgets)

class _InfoRowPreview extends StatelessWidget {
  final String label, value;
  const _InfoRowPreview({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(children: [
        Text(label, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontFamily: 'Cairo')),
        SizedBox(width: 8.w),
        Text(value, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), fontFamily: 'Cairo')),
      ]),
    );
  }
}

class _BehaviorItemPreview extends StatelessWidget {
  final String title, status, desc;
  final Color color;
  const _BehaviorItemPreview({required this.title, required this.status, required this.desc, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Color(0xFFE2E8F0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), fontFamily: 'Cairo')),
          Container(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4.r)), child: Text(status, style: TextStyle(fontSize: 10.sp, color: color, fontWeight: FontWeight.bold, fontFamily: 'Cairo'))),
        ]),
        SizedBox(height: 8.h),
        Text(desc, style: TextStyle(fontSize: 13.sp, color: Color(0xFF334155), fontFamily: 'Cairo', height: 1.5)),
        SizedBox(height: 12.h),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text('11:45 ص', style: TextStyle(fontSize: 10.sp, color: Color(0xFF94A3B8), fontFamily: 'Cairo')),
          SizedBox(width: 4.w),
          Icon(Icons.access_time_rounded, size: 12.sp, color: Color(0xFF94A3B8)),
          SizedBox(width: 12.w),
          Text('أ. المعلم', style: TextStyle(fontSize: 10.sp, color: Color(0xFF94A3B8), fontFamily: 'Cairo')),
          SizedBox(width: 4.w),
          Icon(Icons.person_outline_rounded, size: 12.sp, color: Color(0xFF94A3B8)),
        ]),
      ]),
    );
  }
}

class _WeeklyCardPreview extends StatelessWidget {
  final String day, pos, neg;
  const _WeeklyCardPreview({required this.day, required this.pos, required this.neg});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(color: Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Color(0xFFE2E8F0))),
      child: Row(children: [
        Container(width: 70.w, alignment: Alignment.center, child: Text(day, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: Color(0xFF4F46E5), fontFamily: 'Cairo'))),
        Container(width: 1.5, height: 40.h, color: Color(0xFFE2E8F0), margin: EdgeInsets.symmetric(horizontal: 12.w)),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (pos.isNotEmpty) Text('🟢 $pos', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Color(0xFF10B981), fontFamily: 'Cairo')),
          if (neg.isNotEmpty) Text('🔴 $neg', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B), fontFamily: 'Cairo')),
          if (pos.isEmpty && neg.isEmpty) Text('لا توجد ملاحظات مسجلة', style: TextStyle(fontSize: 11.sp, color: Color(0xFF94A3B8), fontFamily: 'Cairo')),
        ])),
      ]),
    );
  }
}

class _MonthlyCardPreview extends StatelessWidget {
  final String week, pos, neg, imp;
  const _MonthlyCardPreview({required this.week, required this.pos, required this.neg, required this.imp});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Color(0xFFE2E8F0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(week, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), fontFamily: 'Cairo')),
          Container(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h), decoration: BoxDecoration(color: Color(0xFF4F46E5).withOpacity(0.1), borderRadius: BorderRadius.circular(20.r)), child: Text(imp, style: TextStyle(fontSize: 10.sp, color: Color(0xFF4F46E5), fontWeight: FontWeight.w900, fontFamily: 'Cairo'))),
        ]),
        SizedBox(height: 12.h),
        if (pos.isNotEmpty) Padding(padding: EdgeInsets.only(bottom: 6.h), child: Text('• الإيجابيات: $pos', style: TextStyle(fontSize: 12.sp, color: Color(0xFF334155), fontFamily: 'Cairo'))),
        if (neg.isNotEmpty) Text('• التنبيهات: $neg', style: TextStyle(fontSize: 12.sp, color: Color(0xFF334155), fontFamily: 'Cairo')),
      ]),
    );
  }
}

class _SignatureLine extends StatelessWidget {
  final String label;
  const _SignatureLine({required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(width: 120.w, height: 1.5, color: Color(0xFFE2E8F0)),
      SizedBox(height: 8.h),
      Text(label, style: TextStyle(fontSize: 11.sp, color: Color(0xFF64748B), fontFamily: 'Cairo')),
    ]);
  }
}

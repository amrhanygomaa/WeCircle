import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../../state_manager.dart';
import '../../widgets/wesal_background.dart';

class BehaviorReportScreen extends StatefulWidget {
  const BehaviorReportScreen({super.key});

  @override
  State<BehaviorReportScreen> createState() => _BehaviorReportScreenState();
}

class _BehaviorReportScreenState extends State<BehaviorReportScreen> {
  int _selectedType = -1; // -1: None, 0: Daily, 1: Weekly
  late String _childName;
  late String _childGrade;

  @override
  void initState() {
    super.initState();
    final state = AppStateManager();
    _childName = state.children[state.selectedChildIndex.value]['name'];
    _childGrade = state.children[state.selectedChildIndex.value]['grade'];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: WesalBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                const _BehaviorHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _PageTitleSection(),
                        SizedBox(height: 32.h),
                        Row(
                          children: [
                            Expanded(
                              child: _ReportTypeButton(
                                label: 'يومي',
                                icon: Icons.calendar_today_rounded,
                                isSelected: _selectedType == 0,
                                onTap: () => setState(() => _selectedType = 0),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _ReportTypeButton(
                                label: 'اسبوعي',
                                icon: Icons.calendar_month_rounded,
                                isSelected: _selectedType == 1,
                                onTap: () => setState(() => _selectedType = 1),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _ReportTypeButton(
                                label: 'شهري',
                                icon: Icons.analytics_rounded,
                                isSelected: _selectedType == 2,
                                onTap: () => setState(() => _selectedType = 2),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 32.h),
                        if (_selectedType == 0)
                          _DailyReportContent(childName: _childName)
                        else if (_selectedType == 1)
                          _WeeklyReportContent(childName: _childName)
                        else if (_selectedType == 2)
                          _MonthlyReportContent(childName: _childName)
                        else
                          _EmptyStateCard(childName: _childName),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),
                if (_selectedType != -1)
                  Padding(
                    padding: EdgeInsets.all(24.r),
                    child: ElevatedButton.icon(
                      onPressed: () => _downloadReport(context),
                      icon: Icon(Icons.picture_as_pdf_rounded, size: 20.sp),
                      label: Text(
                        'تحميل التقرير كـ PDF',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 56.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadReport(BuildContext context) async {
    // إظهار مؤشر تحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
      ),
    );

    try {
      final arabicFont = await PdfGoogleFonts.cairoRegular();
      final arabicFontBold = await PdfGoogleFonts.cairoBold();

      final doc = pw.Document();

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(
            base: arabicFont,
            bold: arabicFontBold,
          ),
          textDirection: pw.TextDirection.rtl,
          build: (pw.Context context) {
            return <pw.Widget>[
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('أكاديمية وصال التعليمية',
                          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
                      pw.Text(
                        _selectedType == 0
                            ? 'تقرير المتابعة السلوكية اليومي'
                            : (_selectedType == 1 ? 'التقرير السلوكي الأسبوعي الشامل' : 'التقرير السلوكي الشهري الشامل'),
                        style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Container(
                    width: 60,
                    height: 30,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.indigo50,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Center(
                      child: pw.Text('WESAL', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 2, color: PdfColors.indigo900),
              pw.SizedBox(height: 20),

              // Title Section
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
                  ),
                  child: pw.Text(
                    _selectedType == 0
                        ? 'تقرير السلوك اليومي الرسمي'
                        : (_selectedType == 1 ? 'التقرير السلوكي الأسبوعي الشامل' : 'التقرير السلوكي الشهري الشامل'),
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900),
                  ),
                ),
              ),
              pw.SizedBox(height: 25),

              // Student Info
              pw.Directionality(
                textDirection: pw.TextDirection.rtl,
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Right Table: Name and Grade
                    pw.Expanded(
                      child: pw.Table(
                        border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                        columnWidths: const {
                          0: pw.FlexColumnWidth(2),
                          1: pw.FlexColumnWidth(1),
                        },
                        children: [
                          pw.TableRow(
                            decoration: const pw.BoxDecoration(color: PdfColors.grey50),
                            children: [
                              _pdfTableCell(_childName, false),
                              _pdfTableCell('اسم الطالب:', true),
                            ],
                          ),
                          pw.TableRow(
                            children: [
                              _pdfTableCell(_childGrade, false),
                              _pdfTableCell('المستوى الدراسي:', true),
                            ],
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 15),
                    // Left Table: Date and ID
                    pw.Expanded(
                      child: pw.Table(
                        border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                        columnWidths: const {
                          0: pw.FlexColumnWidth(2),
                          1: pw.FlexColumnWidth(1),
                        },
                        children: [
                          pw.TableRow(
                            decoration: const pw.BoxDecoration(color: PdfColors.grey50),
                            children: [
                              _pdfTableCell(
                                  _selectedType == 0
                                      ? '15 مايو 2026'
                                      : (_selectedType == 1 ? 'الأسبوع الثالث - مايو 2026' : 'مايو 2026'),
                                  false),
                              _pdfTableCell(
                                  _selectedType == 0
                                      ? 'التاريخ:'
                                      : (_selectedType == 1 ? 'الأسبوع:' : 'الشهر:'),
                                  true),
                            ],
                          ),
                          pw.TableRow(
                            children: [
                              _pdfTableCell('W-2024-0892', false),
                              _pdfTableCell('الرقم الأكاديمي:', true),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 25),

              if (_selectedType == 0) ...<pw.Widget>[
                // Daily Content
                pw.Text('سجل الأنشطة والملاحظات اليومية:',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
                pw.SizedBox(height: 15),
                _pdfProfessionalItem('التعاون الرائع', 'إيجابي',
                    'أظهر $_childName تعاوناً ممتازاً خلال مشروع المجموعة وساعد زملائه في إنجاز المهام.', 'أ. أحمد علي', '10:30 ص', PdfColors.green),
                _pdfProfessionalItem('المشاركة الصفية', 'إيجابي',
                    'شارك $_childName بفعالية في النقاش الصفي وأجاب على أسئلة المعلم بدقة.', 'أ. سارة ميلر', '11:45 ص', PdfColors.green),
                _pdfProfessionalItem('الخناق مع الأصدقاء', 'تنبيه',
                    'دخل في مشاجرة بسيطة مع زملائه خلال وقت الفسحة بسبب اختلاف في اللعب.', 'أ. أحمد علي', '01:15 م', PdfColors.orange),
              ] else if (_selectedType == 1) ...<pw.Widget>[
                // Weekly Content
                pw.Text('ملخص الأداء السلوكي اليومي:',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
                pw.SizedBox(height: 15),
                _pdfWeeklyDayItem('الأحد', 'مشاركة ممتازة في الحساب', 'تأخر 5 دقائق عن الطابور'),
                _pdfWeeklyDayItem('الاثنين', 'التعاون مع الزملاء في الفسحة', 'قام بالتنمر اللفظي على أحد زملائه الجدد'),
                _pdfWeeklyDayItem('الثلاثاء', 'هدوء تام خلال حصة العلوم', 'نقص التركيز في الحصة الأخيرة'),
                _pdfWeeklyDayItem('الأربعاء', 'مبادرة لتنظيف الفصل', 'أظهر عصبية زائدة وصرخ في وجه المعلم'),
                _pdfWeeklyDayItem('الخميس', 'أداء متميز في اختبار الإملاء', 'لا يوجد ملاحظات سلبية'),

                pw.SizedBox(height: 20),
                // Remedial Plan for Weekly
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    border: pw.Border.all(color: PdfColors.blue200),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('خطة العلاج والتوصيات التربوية المعتمدة:',
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                      pw.SizedBox(height: 10),
                      _pdfRemedialPoint('1. معالجة التأخر الصباحي: ضبط منبه الاستيقاظ قبل موعده بـ 15 دقيقة لضمان اللحاق بالطابور.'),
                      _pdfRemedialPoint('2. معالجة نسيان الأدوات: تعليق قائمة (Checklist) على باب الغرفة لمراجعة الكتب والأدوات قبل الخروج.'),
                      _pdfRemedialPoint('3. رفع مستوى التركيز: تقليل فترات استخدام الشاشات ليلاً لضمان جودة النوم وزيادة الانتباه في الحصص الأخيرة.'),
                      _pdfRemedialPoint('4. ضبط السلوك الصفي: تم الاتفاق مع المعلم على نظام (بطاقات الهدوء) لتعزيز الالتزام بالصمت أثناء الشرح.'),
                    ],
                  ),
                ),
              ] else ...<pw.Widget>[
                // Monthly Content
                pw.Text('ملخص الأداء السلوكي الشهري:',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
                pw.SizedBox(height: 15),
                _pdfMonthlyWeekRow('الأسبوع الأول', '• التزام تام بالمواعيد\n• مشاركة متميزة في الإذاعة الصباحية', '• تأخر مرة واحدة عن الطابور\n• نسيان كتاب التربية الإسلامية', 'تحسن ملحوظ'),
                _pdfMonthlyWeekRow('الأسبوع الثاني', '• تحسن ملحوظ في التعاون الجماعي\n• مساعدة الزملاء في حل المسائل', '• إصرار على العند في حصة الرياضة\n• عدم إحضار الأدوات الهندسية', 'مستقر'),
                _pdfMonthlyWeekRow('الأسبوع الثالث', '• أداء متميز في الأنشطة الصفية\n• الالتزام بالهدوء أثناء الشرح', '• تكرار الشجار مع الزملاء في الملعب\n• استخدام كلمات غير لائقة', 'تحسن جيد جداً'),
                _pdfMonthlyWeekRow('الأسبوع الرابع', '• ثبات في المستوى السلوكي العام\n• تقديم مبادرة لتشجير المدرسة', '• ملاحظة عن تشتت الانتباه\n• التأخر في تسليم الواجب', 'ممتاز'),

                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green50,
                    border: pw.Border.all(color: PdfColors.green200),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('التقييم العام للشهر:',
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
                      pw.Text('ممتاز (91%)', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
                    ],
                  ),
                ),
              ],

              pw.SizedBox(height: 20),
              pw.Divider(thickness: 1, color: PdfColors.grey200),
              
              if (_selectedType == 0) ...<pw.Widget>[
                pw.SizedBox(height: 15),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(child: _pdfEvaluationBox('نسبة السلوك الإيجابي:', '66%', PdfColors.green)),
                    pw.SizedBox(width: 20),
                    pw.Expanded(child: _pdfEvaluationBox('نسبة الملاحظات السلبية:', '33%', PdfColors.orange)),
                  ],
                ),
              ] else if (_selectedType == 2) ...<pw.Widget>[
                pw.SizedBox(height: 15),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(child: _pdfEvaluationBox('متوسط السلوك الإيجابي:', '91%', PdfColors.green)),
                    pw.SizedBox(width: 20),
                    pw.Expanded(child: _pdfEvaluationBox('إجمالي ملاحظات التنبيه:', '4 ملاحظات', PdfColors.orange)),
                  ],
                ),
              ],

              pw.Spacer(),

              // Official Footer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _pdfSignatureLine(_selectedType == 0 ? 'توقيع رائد الفصل' : 'توقيع الأخصائي النفسي'),
                  _pdfSignatureLine(_selectedType == 0 ? 'توقيع الأخصائي الاجتماعي' : 'اعتماد مدير الأكاديمية'),
                  _pdfSignatureLine('ختم الإدارة المعتمد'),
                ],
              ),
              pw.SizedBox(height: 15),
              pw.Center(
                child: pw.Text(
                  'يُرجى من ولي الأمر التوقيع على الخطة والتعاون مع المدرسة.',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'صدر هذا التقرير إلكترونياً من منصة وصال التعليمية - جميع الحقوق محفوظة © 2026',
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                ),
              ),
            ];
          },
        ),
      );

      if (context.mounted) {
        Navigator.pop(context); // إغلاق مؤشر التحميل
        
        String reportType = _selectedType == 0 ? 'Daily' : (_selectedType == 1 ? 'Weekly' : 'Monthly');
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => doc.save(),
          name: 'Behavior_Report_${reportType}_$_childName.pdf',
        );
      }
    } catch (e) {
      if (context.mounted) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في التحميل: $e', textAlign: TextAlign.center),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  pw.Widget _pdfTableCell(String text, bool isLabel) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textDirection: pw.TextDirection.rtl,
        textAlign: pw.TextAlign.right,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isLabel ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isLabel ? PdfColors.indigo900 : PdfColors.black,
        ),
      ),
    );
  }

  pw.Widget _pdfProfessionalItem(String title, String status, String desc, String teacher, String time, PdfColor color) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      decoration: pw.BoxDecoration(
        border: pw.Border(right: pw.BorderSide(color: color, width: 4)),
        color: PdfColors.grey50,
      ),
      padding: const pw.EdgeInsets.all(12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: pw.BoxDecoration(color: color, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
                child: pw.Text(status, style: pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Text(desc,
              textDirection: pw.TextDirection.rtl, textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey700, height: 1.4)),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('المعلم: $teacher', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
              pw.Text('التوقيت: $time', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfEvaluationBox(String label, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: PdfColors.grey200),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          pw.SizedBox(height: 5),
          pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  pw.Widget _pdfRemedialPoint(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 8,
            height: 8,
            margin: const pw.EdgeInsets.only(top: 3, left: 8),
            decoration: const pw.BoxDecoration(color: PdfColors.blue700, shape: pw.BoxShape.circle),
          ),
          pw.Expanded(
            child: pw.Text(text, style: pw.TextStyle(fontSize: 10, color: PdfColors.blue900)),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfWeeklyDayItem(String day, String positive, String negative) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey200),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(6),
            decoration: const pw.BoxDecoration(
              color: PdfColors.indigo900,
              borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(7)),
            ),
            child: pw.Text(day,
                textDirection: pw.TextDirection.rtl,
                style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 11)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Row(
                children: [
                  // Positive Points (Green) - Right side in RTL
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      decoration: const pw.BoxDecoration(color: PdfColors.green50),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('النقاط الإيجابية:',
                              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.green700)),
                          pw.SizedBox(height: 4),
                          pw.Text(positive, style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  // Discipline Notes (Orange) - Left side in RTL
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      decoration: const pw.BoxDecoration(color: PdfColors.orange50),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('ملاحظات الانضباط:',
                              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.orange700)),
                          pw.SizedBox(height: 4),
                          pw.Text(negative, style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfSignatureLine(String label) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 40),
        pw.Container(width: 100, height: 1, color: PdfColors.grey400),
        pw.SizedBox(height: 5),
        pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
      ],
    );
  }
  pw.Widget _pdfMonthlyWeekRow(String week, String positive, String negative, String improvement) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey200),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(6),
            decoration: const pw.BoxDecoration(
              color: PdfColors.indigo700,
              borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(7)),
            ),
            child: pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(week, style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  pw.Text('حالة التحسن: $improvement', style: pw.TextStyle(color: PdfColors.white, fontSize: 9)),
                ],
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      decoration: const pw.BoxDecoration(color: PdfColors.green50),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('الإيجابيات:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.green700)),
                          pw.SizedBox(height: 4),
                          pw.Text(positive, style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      decoration: const pw.BoxDecoration(color: PdfColors.orange50),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('التنبيهات:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.orange700)),
                          pw.SizedBox(height: 4),
                          pw.Text(negative, style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyReportContent extends StatelessWidget {
  final String childName;

  const _MonthlyReportContent({required this.childName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'أكاديمية وصال التعليمية',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    Text(
                      'التقرير السلوكي الشهري الشامل',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.analytics_rounded, color: Colors.white, size: 28.w),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                _InfoRow(label: 'اسم الطالب:', value: childName),
                _InfoRow(label: 'الشهر:', value: 'مايو 2026'),
                SizedBox(height: 10.h),
                const Divider(height: 1),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ملخص الأداء السلوكي الشهري:',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                    fontFamily: 'Cairo',
                  ),
                ),
                SizedBox(height: 16.h),
                _MonthlyWeekCard(
                  week: 'الأسبوع الأول', 
                  positive: '• التزام تام بالمواعيد\n• مشاركة متميزة في الإذاعة الصباحية', 
                  negative: '• تأخر مرة واحدة عن الطابور\n• نسيان كتاب التربية الإسلامية',
                  improvement: 'تحسن ملحوظ',
                ),
                _MonthlyWeekCard(
                  week: 'الأسبوع الثاني', 
                  positive: '• تحسن ملحوظ في التعاون الجماعي\n• مساعدة الزملاء في حل المسائل', 
                  negative: '• إصرار على العند في حصة الرياضة\n• عدم إحضار الأدوات الهندسية',
                  improvement: 'مستقر',
                ),
                _MonthlyWeekCard(
                  week: 'الأسبوع الثالث', 
                  positive: '• أداء متميز في الأنشطة الصفية\n• الالتزام بالهدوء أثناء الشرح', 
                  negative: '• تكرار الشجار مع الزملاء في الملعب\n• استخدام كلمات غير لائقة',
                  improvement: 'تحسن جيد جداً',
                ),
                _MonthlyWeekCard(
                  week: 'الأسبوع الرابع', 
                  positive: '• ثبات في المستوى السلوكي العام\n• تقديم مبادرة لتشجير المدرسة', 
                  negative: '• ملاحظة عن تشتت الانتباه\n• التأخر في تسليم الواجب',
                  improvement: 'ممتاز',
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Monthly Stats
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              children: [
                _EvaluationRow(label: 'متوسط السلوك الإيجابي:', value: '91%', color: const Color(0xFF10B981)),
                SizedBox(height: 12.h),
                _EvaluationRow(label: 'إجمالي ملاحظات التنبيه:', value: '4 ملاحظات', color: const Color(0xFFF59E0B)),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SignatureLine(label: 'توقيع رائد الفصل'),
                    _SignatureLine(label: 'اعتماد مدير الأكاديمية'),
                  ],
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyWeekCard extends StatelessWidget {
  final String week, positive, negative, improvement;
  const _MonthlyWeekCard({
    required this.week, 
    required this.positive, 
    required this.negative,
    required this.improvement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE0E7FF)),
      ),
      child: Column(
        children: [
          // Week Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Row(
              children: [
                Text(
                  week,
                  style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w900, fontFamily: 'Cairo'),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    improvement,
                    style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(16.r),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Positive Section
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFD1FAE5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: const Color(0xFF10B981), size: 16.sp),
                              SizedBox(width: 4.w),
                              Text('إيجابي', style: TextStyle(fontSize: 10.sp, color: const Color(0xFF065F46), fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            positive,
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFF064E3B), fontFamily: 'Cairo', height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Negative Section
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFFEE2E2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.error_rounded, color: const Color(0xFFEF4444), size: 16.sp),
                              SizedBox(width: 4.w),
                              Text('تنبيه', style: TextStyle(fontSize: 10.sp, color: const Color(0xFF991B1B), fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            negative,
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFF7F1D1D), fontFamily: 'Cairo', height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Improvement Status Bar
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up_rounded, color: const Color(0xFF6366F1), size: 14.sp),
                SizedBox(width: 8.w),
                Text(
                  'حالة التحسن في المشاكل السلوكية:',
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: const Color(0xFF64748B), fontFamily: 'Cairo'),
                ),
                const Spacer(),
                Text(
                  improvement,
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: const Color(0xFF6366F1), fontFamily: 'Cairo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _DailyReportContent extends StatelessWidget {
  final String childName;

  const _DailyReportContent({required this.childName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Section from Image
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'أكاديمية وصال التعليمية',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    Text(
                      'قسم شؤون الطلاب والانضباط',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF64748B),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.school_rounded, color: Colors.white, size: 28.w),
                ),
              ],
            ),
          ),

          // Title with Underline
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Column(
              children: [
                Text(
                  'تقرير السلوك اليومي الرسمي',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E293B),
                    fontFamily: 'Cairo',
                  ),
                ),
                Container(
                  width: 200.w,
                  height: 2,
                  color: const Color(0xFF1E293B).withOpacity(0.3),
                ),
              ],
            ),
          ),

          // Student Information (Right Aligned)
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              children: [
                _InfoRow(label: 'اسم الطالب:', value: childName),
                _InfoRow(label: 'التاريخ:', value: '15 مايو 2026'),
                _InfoRow(label: 'الرقم الأكاديمي:', value: 'W-2024-0892'),
              ],
            ),
          ),

          const Divider(height: 1),

          // Behavior Logs
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'السجل التفصيلي المعتمد:',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                    fontFamily: 'Cairo',
                  ),
                ),
                SizedBox(height: 16.h),
                _BehaviorItem(
                  title: 'التعاون الرائع',
                  status: 'إيجابي',
                  statusColor: const Color(0xFF10B981),
                  description: 'أظهر $childName تعاوناً ممتازاً خلال مشروع المجموعة وساعد زملائه في إنجاز المهام.',
                  teacher: 'أ. أحمد علي',
                  time: '10:30 ص',
                ),
                _BehaviorItem(
                  title: 'المشاركة الصفية',
                  status: 'إيجابي',
                  statusColor: const Color(0xFF10B981),
                  description: 'شارك $childName بفعالية في النقاش الصفي وأجاب على أسئلة المعلم بدقة.',
                  teacher: 'أ. سارة ميلر',
                  time: '11:45 ص',
                ),
                _BehaviorItem(
                  title: 'الخناق مع الأصدقاء',
                  status: 'تنبيه',
                  statusColor: const Color(0xFFF59E0B),
                  description: 'دخل في مشاجرة بسيطة مع زملائه خلال وقت الفسحة بسبب اختلاف في اللعب.',
                  teacher: 'أ. أحمد علي',
                  time: '01:15 م',
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Evaluation
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              children: [
                _EvaluationRow(label: 'نسبة السلوك الإيجابي:', value: '66%', color: const Color(0xFF10B981)),
                SizedBox(height: 12.h),
                _EvaluationRow(label: 'نسبة الملاحظات السلبية:', value: '33%', color: const Color(0xFFEF4444)),
              ],
            ),
          ),

          const Divider(height: 1),

          // Signature Section
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SignatureLine(label: 'توقيع مدير المدرسة'),
                    _SignatureLine(label: 'ختم الاعتماد الرسمي'),
                  ],
                ),
                SizedBox(height: 20.h),
                Text(
                  'صدر هذا التقرير من النظام الآلي لأكاديمية وصال ولا يتطلب توقيعاً يدوياً.',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: const Color(0xFF94A3B8),
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF475569),
              fontFamily: 'Cairo',
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}

class _BehaviorItem extends StatelessWidget {
  final String title, status, description, teacher, time;
  final Color statusColor;

  const _BehaviorItem({
    required this.title,
    required this.status,
    required this.statusColor,
    required this.description,
    required this.teacher,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 10.sp,
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
        ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            description,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
              fontFamily: 'Cairo',
              height: 1.5,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(fontSize: 10.sp, color: const Color(0xFF94A3B8), fontFamily: 'Cairo'),
              ),
              SizedBox(width: 4.w),
              Icon(Icons.access_time_rounded, size: 12.sp, color: const Color(0xFF94A3B8)),
              SizedBox(width: 12.w),
              Text(
                teacher,
                style: TextStyle(fontSize: 10.sp, color: const Color(0xFF94A3B8), fontFamily: 'Cairo'),
              ),
              SizedBox(width: 4.w),
              Icon(Icons.person_outline_rounded, size: 12.sp, color: const Color(0xFF94A3B8)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EvaluationRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const _EvaluationRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp, 
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B), 
            fontFamily: 'Cairo'
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _SignatureLine extends StatelessWidget {
  final String label;
  const _SignatureLine({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100.w,
          height: 1,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFCBD5E1),
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: const Color(0xFF94A3B8), fontFamily: 'Cairo'),
        ),
      ],
    );
  }
}

class _WeeklyReportContent extends StatelessWidget {
  final String childName;

  const _WeeklyReportContent({required this.childName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header (Same as Daily for consistency)
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'أكاديمية وصال التعليمية',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        'التقرير السلوكي الأسبوعي الشامل',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.school_rounded, color: Colors.white, size: 28.w),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                _InfoRow(label: 'اسم الطالب:', value: childName),
                _InfoRow(label: 'الأسبوع:', value: 'الأسبوع الثالث - مايو 2026'),
                SizedBox(height: 10.h),
                const Divider(height: 1),
              ],
            ),
          ),

          // Days Breakdown
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ملخص الأداء السلوكي اليومي:',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                    fontFamily: 'Cairo',
                  ),
                ),
                SizedBox(height: 16.h),
                _WeeklyDayCard(day: 'الأحد', positive: 'مشاركة ممتازة في الحساب', negative: 'تأخر 5 دقائق عن الطابور'),
                _WeeklyDayCard(day: 'الاثنين', positive: 'التعاون مع الزملاء في الفسحة', negative: 'قام بالتنمر اللفظي على أحد زملائه الجدد'),
                _WeeklyDayCard(day: 'الثلاثاء', positive: 'هدوء تام خلال حصة العلوم', negative: 'نقص التركيز في الحصة الأخيرة'),
                _WeeklyDayCard(day: 'الأربعاء', positive: 'مبادرة لتنظيف الفصل', negative: 'أظهر عصبية زائدة وصرخ في وجه المعلم'),
                _WeeklyDayCard(day: 'الخميس', positive: 'أداء متميز في اختبار الإملاء', negative: 'لا يوجد ملاحظات سلبية'),
              ],
            ),
          ),

          const Divider(height: 1),

          // Remedial Plan Section
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.assignment_turned_in_rounded, color: const Color(0xFF6366F1), size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'خطة العلاج والتوصيات التربوية:',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E293B),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _RemedialPoint(text: '1. معالجة التأخر الصباحي: ضبط منبه الاستيقاظ قبل موعده بـ 15 دقيقة لضمان اللحاق بالطابور.'),
                      _RemedialPoint(text: '2. معالجة نسيان الأدوات: تعليق قائمة (Checklist) على باب الغرفة لمراجعة الكتب والأدوات قبل الخروج.'),
                      _RemedialPoint(text: '3. رفع مستوى التركيز: تقليل فترات استخدام الشاشات ليلاً لضمان جودة النوم وزيادة الانتباه في الحصص الأخيرة.'),
                      _RemedialPoint(text: '4. ضبط السلوك الصفي: تم الاتفاق مع المعلم على نظام (بطاقات الهدوء) لتعزيز الالتزام بالصمت أثناء الشرح.'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SignatureLine(label: 'توقيع الأخصائي النفسي'),
                    _SignatureLine(label: 'اعتماد مدير الأكاديمية'),
                  ],
                ),
                SizedBox(height: 20.h),
                Text(
                  'يُرجى من ولي الأمر التوقيع على الخطة والتعاون مع المدرسة.',
                  style: TextStyle(fontSize: 10.sp, color: const Color(0xFF94A3B8), fontFamily: 'Cairo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyDayCard extends StatelessWidget {
  final String day, positive, negative;
  const _WeeklyDayCard({required this.day, required this.positive, required this.negative});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE0E7FF)),
      ),
      child: Column(
        children: [
          // Day Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Row(
              children: [
                Text(
                  day,
                  style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w900, fontFamily: 'Cairo'),
                ),
                const Spacer(),
                Icon(
                  negative == 'لا يوجد ملاحظات سلبية' ? Icons.star_rounded : Icons.trending_up_rounded,
                  color: Colors.white.withOpacity(0.9),
                  size: 20.sp,
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(16.r),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Positive Section
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFD1FAE5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: const Color(0xFF10B981), size: 16.sp),
                              SizedBox(width: 4.w),
                              Text('إيجابي', style: TextStyle(fontSize: 10.sp, color: const Color(0xFF065F46), fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            positive,
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFF064E3B), fontFamily: 'Cairo', height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Negative Section
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFFEE2E2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.error_rounded, color: const Color(0xFFEF4444), size: 16.sp),
                              SizedBox(width: 4.w),
                              Text('تنبيه', style: TextStyle(fontSize: 10.sp, color: const Color(0xFF991B1B), fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            negative,
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFF7F1D1D), fontFamily: 'Cairo', height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RemedialPoint extends StatelessWidget {
  final String text;
  const _RemedialPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, color: const Color(0xFF6366F1), size: 14.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B), fontFamily: 'Cairo', height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _BehaviorHeader extends StatelessWidget {
  const _BehaviorHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        children: [
          const _CircularIcon(
            icon: Icons.notifications_none_rounded,
            color: Color(0xFF9333EA),
            size: 22,
            hasBadge: true,
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'سارة محمد',
                style: TextStyle(
                  color: const Color(0xFF1E293B),
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Cairo',
                ),
              ),
              Text(
                'ولي أمر',
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: 12.sp,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          const _CircularIcon(
            icon: Icons.person_rounded,
            color: Color(0xFF2563EB),
            size: 22,
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const _CircularIcon(
              icon: Icons.arrow_forward_ios_rounded,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double size;
  final bool hasBadge;

  const _CircularIcon({
    required this.icon,
    this.color,
    required this.size,
    this.hasBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: color ?? const Color(0xFF1E293B), size: size.sp),
          if (hasBadge)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 8.r,
                height: 8.r,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PageTitleSection extends StatelessWidget {
  const _PageTitleSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تقارير السلوك',
          style: TextStyle(
            color: const Color(0xFF1E293B),
            fontSize: 28.sp,
            fontWeight: FontWeight.w900,
            fontFamily: 'Cairo',
          ),
        ),
        Text(
          'تتبع سلوك طفلك وانضباطه',
          style: TextStyle(
            color: const Color(0xFF64748B),
            fontSize: 14.sp,
            fontFamily: 'Cairo',
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'اختر نوع التقرير',
          style: TextStyle(
            color: const Color(0xFF64748B),
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}

class _ReportTypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReportTypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              size: 18.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final String childName;
  const _EmptyStateCard({required this.childName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(40.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              Icons.bar_chart_rounded,
              color: const Color(0xFF6366F1),
              size: 48.sp,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'بانتظار اختيارك',
            style: TextStyle(
              color: const Color(0xFF1E293B),
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              fontFamily: 'Cairo',
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'يرجى اختيار نوع التقرير من الأعلى لعرض تفاصيل سلوك $childName',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF64748B),
              fontSize: 14.sp,
              fontFamily: 'Cairo',
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

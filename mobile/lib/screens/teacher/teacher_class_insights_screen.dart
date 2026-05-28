/*
🧠 اسم الملف: teacher_class_insights_screen.dart

📌 بيعمل إيه؟
شاشة بتعرض تحليلات وإحصائيات عن مستوى الفصل ككل، مين متفوق ومين محتاج مساعدة.

👤 موجه لمين؟
- مدرسين

💡 فكرته:
إعطاء المدرس رؤية شاملة (Data-driven insights) عشان يعرف يطور أداء الفصل بتاعه.
*/

import 'package:flutter/material.dart'; // استيراد مكتبة فلاتر الأساسية للواجهات
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد مكتبة التحكم في أحجام الشاشة
import '../../app_theme.dart'; // استيراد ثيم التطبيق الموحد
import '../../services/responsive_helper.dart'; // استيراد مساعد استجابة الواجهة للأجهزة المختلفة

class TeacherClassInsightsScreen extends StatelessWidget { // تعريف كلاس شاشة تحليل أداء الفصل كـ StatelessWidget
  const TeacherClassInsightsScreen({super.key}); // مشيد الكلاس

  @override // دالة بناء واجهة الشاشة
  Widget build(BuildContext context) {
    return Directionality( // تحديد اتجاه النصوص للعربية
      textDirection: TextDirection.rtl,
      child: Scaffold( // هيكل الصفحة الأساسي
        backgroundColor: AppTheme.background, // لون الخلفية من الثيم
        body: Stack( // مكدس للعناصر (يمكن إضافة خلفيات متحركة هنا)
          children: [
            SafeArea( // حماية المحتوى من الحواف العلوية والسفلية
              child: CustomScrollView( // قائمة تمرير مخصصة لتحسين الأداء وتأثيرات التمرير
                physics: const ClampingScrollPhysics(), // منع التمدد الزائد عند أطراف القائمة
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(context)), // بناء ترويسة الشاشة
                  SliverToBoxAdapter(child: _buildOverviewCards(context)), // بناء بطاقات الإحصائيات العامة
                  SliverToBoxAdapter(child: _buildAttendanceChart()), // بناء رسم بياني لمعدل الحضور
                  SliverToBoxAdapter(child: _buildBehaviorSummary()), // بناء ملخص السلوك العام للفصل
                  SliverToBoxAdapter(child: _buildTopIssues()), // بناء قائمة بأبرز المشكلات المتكررة
                  SliverToBoxAdapter(child: SizedBox(height: 30.h)), // مسافة سفلية نهائية
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) { // دالة بناء ترويسة الشاشة (زر الرجوع والعناوين)
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context), // العودة للشاشة السابقة عند الضغط
            child: Container( // تصميم زر الرجوع بأسلوب Neumorphic
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: AppTheme.background,
                shape: BoxShape.circle,
                boxShadow: [
                  const BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-4, -4)), // ظل إضاءة
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(4, 4)), // ظل عمق
                ],
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18.sp, color: AppTheme.primaryDark),
            ),
          ),
          SizedBox(width: 16.w), // مسافة أفقية
          Column( // نصوص عنوان الترويسة
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تحليل الأداء',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryDark,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'إحصائيات وتقارير الفصل',
                style: TextStyle(fontSize: 12.sp, color: AppTheme.textSlate),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context) { // دالة بناء شبكة بطاقات الإحصائيات السريعة
    final stats = [ // بيانات الإحصائيات (بيانات تجريبية)
      {
        'label': 'نسبة الحضور',
        'value': '88%',
        'icon': Icons.how_to_reg_rounded,
        'color': AppTheme.emeraldGreen,
      },
      {
        'label': 'معدل التفاعل',
        'value': 'عالي',
        'icon': Icons.bolt_rounded,
        'color': AppTheme.royalBlue,
      },
      {
        'label': 'إيجابيو اليوم',
        'value': '18',
        'icon': Icons.thumb_up_rounded,
        'color': AppTheme.vibrantOrange,
      },
      {
        'label': 'تقارير سلوك',
        'value': '5',
        'icon': Icons.warning_amber_rounded,
        'color': AppTheme.softRose,
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GridView.count( // عرض البطاقات في شبكة متجاوبة
        crossAxisCount: context.responsive(2, tablet: 4), // عمودين للموبايل و4 للتابلت
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: context.responsive(1.4, tablet: 1.2), // نسبة أبعاد البطاقة
        shrinkWrap: true, // لتعمل داخل القائمة الكلية
        physics: const NeverScrollableScrollPhysics(), // منع التمرير الخاص بالشبكة
        children: stats.map((s) {
          final color = s['color'] as Color;
          return Container( // تصميم البطاقة الفردية
            padding: EdgeInsets.all(16.r),
            decoration: AppTheme.premiumCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container( // أيقونة الإحصائية بخلفية دائرية شفافة
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(s['icon'] as IconData, color: color, size: 18.sp),
                ),
                Column( // القيمة والوصف النصي
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(
                        s['value'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryDark,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    Text(
                      s['label'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppTheme.textSlate,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAttendanceChart() { // دالة بناء رسم بياني عمودي مبسط لمعدل الحضور الأسبوعي
    final days = [ // بيانات الحضور للأيام (بيانات تجريبية)
      {'day': 'الأحد', 'rate': 0.92},
      {'day': 'الاثنين', 'rate': 0.85},
      {'day': 'الثلاثاء', 'rate': 0.88},
      {'day': 'الأربعاء', 'rate': 0.78},
      {'day': 'الخميس', 'rate': 0.95},
    ];

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text( // عنوان قسم الرسم البياني
            'حضور الأسبوع',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryDark,
            ),
          ),
          SizedBox(height: 16.h),
          Container( // حاوية الرسم البياني
            padding: EdgeInsets.all(20.r),
            decoration: AppTheme.premiumCardDecoration(),
            child: FittedBox( // ضبط حجم الرسم البياني ليتناسب مع العرض
              fit: BoxFit.scaleDown,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end, // محاذاة الأعمدة من الأسفل
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: days.map((d) {
                  final rate = d['rate'] as double;
                  final color = rate >= 0.9 // تحديد لون العمود بناءً على النسبة
                      ? AppTheme.emeraldGreen
                      : rate >= 0.8
                          ? AppTheme.royalBlue
                          : AppTheme.softRose;

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Column(
                      children: [
                        Text( // عرض النسبة المئوية فوق كل عمود
                          '${(rate * 100).round()}%',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        AnimatedContainer( // العمود الرئيسي للرسم البياني بتأثير حركي
                          duration: const Duration(milliseconds: 600),
                          width: 36.w,
                          height: 90.h * rate, // ارتفاع العمود بناءً على النسبة
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: color.withValues(alpha: 0.4)),
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container( // الجزء السفلي الممتلئ من العمود لجمالية التصميم
                              height: (90.h * rate) * 0.3,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text( // اسم اليوم تحت كل عمود
                          d['day'] as String,
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: AppTheme.textSlate,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBehaviorSummary() { // دالة بناء ملخص توزيع السلوكيات في الفصل باستخدام أشرطة التقدم
    final behaviors = [ // بيانات السلوكيات (بيانات تجريبية)
      {'label': 'تعاون', 'count': 12, 'isPositive': true},
      {'label': 'مشاركة', 'count': 9, 'isPositive': true},
      {'label': 'عدم تركيز', 'count': 6, 'isPositive': false},
      {'label': 'مشاغبة', 'count': 3, 'isPositive': false},
      {'label': 'عناد', 'count': 2, 'isPositive': false},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text( // عنوان قسم ملخص السلوك
            'السلوك العام للفصل',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryDark,
            ),
          ),
          SizedBox(height: 16.h),
          Container( // بطاقة تحتوي على إحصائيات السلوك
            padding: EdgeInsets.all(20.r),
            decoration: AppTheme.premiumCardDecoration(),
            child: Column(
              children: behaviors.map((b) {
                final isPositive = b['isPositive'] as bool;
                final count = b['count'] as int;
                const maxCount = 12; // الحد الأقصى للقيمة للتمثيل النسبي
                final color = isPositive
                    ? AppTheme.emeraldGreen
                    : AppTheme.softRose;

                return Padding(
                  padding: EdgeInsets.only(bottom: 14.h),
                  child: Row(
                    children: [
                      SizedBox( // اسم السلوك
                        width: 80.w,
                        child: Text(
                          b['label'] as String,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                      ),
                      Expanded( // شريط التقدم الذي يمثل تكرار السلوك
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: LinearProgressIndicator(
                            value: count / maxCount,
                            backgroundColor: color.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 10.h,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Container( // ملصق يحتوي على العدد الفعلي للتكرار
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopIssues() { // دالة بناء قائمة بأكثر المشكلات تكراراً (قائمة مرتبة)
    final issues = [ // بيانات المشكلات المتكررة (بيانات تجريبية)
      {
        'rank': '01',
        'issue': 'عدم التركيز أثناء الشرح',
        'frequency': '6 مرات هذا الأسبوع',
        'color': AppTheme.vibrantOrange,
      },
      {
        'rank': '02',
        'issue': 'الكلام أثناء شرح المعلم',
        'frequency': '3 مرات',
        'color': AppTheme.softRose,
      },
      {
        'rank': '03',
        'issue': 'التأخر في تسليم الواجبات',
        'frequency': '2 مرات',
        'color': AppTheme.skyBlue,
      },
    ];

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text( // عنوان قسم المشكلات المتكررة
            'أبرز المشكلات المتكررة',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryDark,
            ),
          ),
          SizedBox(height: 16.h),
          ...issues.map((issue) {
            final color = issue['color'] as Color;
            return Container( // بطاقة كل مشكلة فردية
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(16.r),
              decoration: AppTheme.premiumCardDecoration(),
              child: Row(
                children: [
                  Container( // رقم الترتيب (رتبة المشكلة) بخلفية دائرية ملونة
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        issue['rank'] as String,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w900,
                          color: color,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded( // تفاصيل المشكلة وتكرارها
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          issue['issue'] as String,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          issue['frequency'] as String,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppTheme.textSlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.trending_up_rounded, color: color, size: 20.sp), // أيقونة تشير إلى تصاعد أو رصد المشكلة
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

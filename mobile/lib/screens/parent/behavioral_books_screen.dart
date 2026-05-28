/*
🧠 اسم الملف: behavioral_books_screen.dart

📌 بيعمل إيه؟
دي شاشة بتعرض مقالات سلوكية قصيرة ومفيدة لأولياء الأمور مع تصميم بنفسجي متناسق وتفاعلي.

👤 موجه لمين؟
- أولياء أمور

💡 فكرته:
تقديم نصائح تربوية مباشرة بتصميم عصري وألوان بنفسجية متناغمة مع هوية التطبيق.
*/

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/wesal_background.dart';

class BehavioralBooksScreen extends StatelessWidget {
  const BehavioralBooksScreen({super.key});

  // ألوان التطبيق البنفسجية
  static const Color primaryPurple = Color(0xFF9333EA);
  static const Color secondaryPurple = Color(0xFFA855F7);
  static const Color lightPurple = Color(0xFFF3E8FF);

  void _readArticle(BuildContext context, Map<String, String> article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleContentScreen(article: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> articles = [
      {
        'title': 'التعامل مع نوبات الغضب',
        'category': 'تعديل سلوك',
        'summary': 'كيف تتعامل مع صراخ الطفل وغضبه المفاجئ بطريقة تربوية هادئة.',
        'content': 'عندما يمر طفلك بنوبة غضب، تذكر أنها وسيلة للتعبير عن مشاعر لا يستطيع وصفها بالكلمات. الخطوة الأولى هي الحفاظ على هدوئك الشخصي. لا تصرخ ولا تحاول الجدال أثناء النوبة.\n\nانتظر حتى يهدأ الطفل تماماً، ثم اقترب منه واحتضنه. عندما يشعر بالأمان، ابدأ بالتحدث معه عن مشاعره بكلمات بسيطة. علمه بدائل للتعبير عن إحباطه، مثل قول "أنا غاضب لأن اللعبة انكسرت" بدلاً من البكاء والصراخ. الثبات على الهدوء هو مفتاحك للسيطرة على الموقف.',
      },
      {
        'title': 'قوة التشجيع الإيجابي',
        'category': 'تحفيز',
        'summary': 'لماذا ينجح المديح في تغيير السلوك أكثر من العقاب؟ وكيف تطبقه؟',
        'content': 'التشجيع الإيجابي يركز على تسليط الضوء على السلوكيات الجيدة وتكرارها. بدلاً من التركيز فقط على توبيخ الطفل عند ارتكاب الأخطاء، ابحث عن اللحظات التي يتصرف فيها بشكل جيد وامدحه عليها.\n\nمن المهم أن تمدح "الجهد" وليس "النتيجة" فقط. فمثلاً، بدلاً من قول "أنت عبقري لأنك حصلت على درجة كاملة"، قل "أنا فخور بك لأنك درست بجد واجتهدت". هذا النوع من التشجيع يبني لدى الطفل عقلية النمو ويزيد من ثقته بقدرته على التطور ومواجهة التحديات.',
      },
      {
        'title': 'وضع الحدود الذكية',
        'category': 'انضباط',
        'summary': 'كيف تضع قوانين منزلية يحترمها الطفل بدون صراخ أو تهديد.',
        'content': 'الأطفال يشعرون بالأمان الحقيقي عندما يعرفون أن هناك حدوداً وقوانين تحميهم وتنظم حياتهم. وضع الحدود لا يعني القسوة، بل يعني الحزم الممزوج باللطف.\n\nابدأ بوضع قوانين واضحة وبسيطة للمنزل (مثل وقت النوم، أو ترتيب الألعاب). اشرح للطفل سبب وجود هذه القوانين، وما هي العواقب المنطقية في حال مخالفتها. كن ثابتاً في تطبيق هذه العواقب دائماً دون غضب، ليعرف الطفل أن كلمتك واحدة، مما يقلل من محاولاته لتجاوز الحدود مستقبلاً.',
      },
      {
        'title': 'تنمية الذكاء العاطفي',
        'category': 'ذكاء عاطفي',
        'summary': 'ساعد طفلك على فهم مشاعره والتعامل معها بذكاء.',
        'content': 'الذكاء العاطفي هو القدرة على التعرف على المشاعر الذاتية ومشاعر الآخرين وإدارتها. الأطفال الذين يتمتعون بذكاء عاطفي هم أكثر نجاحاً في بناء العلاقات ومواجهة ضغوط الحياة.\n\nساعد طفلك على تسمية مشاعره. اسأله: "هل تشعر بالحزن؟ هل أنت محبط؟". عندما يدرك الطفل مسمى الشعور، يسهل عليه التحكم فيه. كن قدوة له في التعبير عن مشاعرك بهدوء، واستمع له باهتمام عندما يحاول إخبارك بما يشعر به دون إطلاق أحكام مسبقة.',
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
              icon: Icon(Icons.keyboard_arrow_right_rounded, color: primaryPurple, size: 32.sp),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'مقالات سلوكية',
              style: TextStyle(
                color: primaryPurple,
                fontWeight: FontWeight.w900,
                fontSize: 22.sp,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          body: ListView.builder(
            padding: EdgeInsets.all(20.r),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return _ArticleCard(
                article: article,
                onTap: () => _readArticle(context, article),
                primaryPurple: primaryPurple,
                secondaryPurple: secondaryPurple,
                lightPurple: lightPurple,
              );
            },
          ),
        ),
      ),
    );
  }
}

class ArticleContentScreen extends StatelessWidget {
  final Map<String, String> article;
  const ArticleContentScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF9333EA);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: WesalBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.keyboard_arrow_right_rounded, color: primaryPurple, size: 32.sp),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'قراءة المقال',
              style: TextStyle(
                color: primaryPurple,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(24.r),
            child: Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: [
                  BoxShadow(
                    color: primaryPurple.withValues(alpha: 0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: primaryPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      article['category']!,
                      style: TextStyle(
                        color: primaryPurple,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    article['title']!,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E293B),
                      fontFamily: 'Cairo',
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Divider(color: primaryPurple.withValues(alpha: 0.1)),
                  SizedBox(height: 20.h),
                  Text(
                    article['content']!,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: const Color(0xFF334155),
                      height: 1.8,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  SizedBox(height: 40.h),
                  Center(
                    child: Text(
                      'تمت القراءة • منصة وصال',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: primaryPurple.withValues(alpha: 0.5),
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArticleCard extends StatefulWidget {
  final Map<String, String> article;
  final VoidCallback onTap;
  final Color primaryPurple, secondaryPurple, lightPurple;
  
  const _ArticleCard({
    required this.article, 
    required this.onTap,
    required this.primaryPurple,
    required this.secondaryPurple,
    required this.lightPurple,
  });

  @override
  State<_ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<_ArticleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isHovered ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isHovered = true),
        onTapUp: (_) => setState(() => _isHovered = false),
        onTapCancel: () => setState(() => _isHovered = false),
        onTap: widget.onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: _isHovered ? widget.lightPurple.withValues(alpha: 0.5) : Colors.white,
            borderRadius: BorderRadius.circular(25.r),
            border: Border.all(
              color: _isHovered ? widget.primaryPurple.withValues(alpha: 0.2) : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.primaryPurple.withValues(alpha: _isHovered ? 0.1 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: widget.primaryPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      widget.article['category']!,
                      style: TextStyle(
                        color: widget.primaryPurple,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded, 
                    color: widget.primaryPurple.withValues(alpha: 0.5), 
                    size: 16.sp
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                widget.article['title']!,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E293B),
                  fontFamily: 'Cairo',
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                widget.article['summary']!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF64748B),
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

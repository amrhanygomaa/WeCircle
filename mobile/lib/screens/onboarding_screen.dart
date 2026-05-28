/*
🧠 اسم الملف: onboarding_screen.dart

📌 بيعمل إيه؟
دي الشاشات الترحيبية اللي بتعرف المستخدم بمميزات تطبيق "وصال" أول ما ينزله، زي تتبع الباص والمساعد الذكي.

👤 موجه لمين؟
- المستخدمين الجدد

💡 فكرته:
بيشرح قيمة التطبيق في خطوات بسيطة وسهلة عشان يشجع المستخدم يبدأ رحلته معانا.
*/

// شاشات الترحيب والتعريف بمميزات التطبيق (Onboarding) عند الفتح لأول مرة
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _floatController;

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryPurple = Color(0xFF9333EA);
  static const Color baseColor = Color(0xFFF0F3F8);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);

  final List<OnboardingData> _onboardingItems = [
    OnboardingData(
      title: 'مرحباً بك في وصال',
      description:
          'منصة تعليمية متكاملة تربط بين ولي الأمر والمعلم لمتابعة أفضل لأبنائكم',
      icon: Icons.auto_awesome_rounded,
      color: primaryBlue,
      lottieUrl: 'assets/animations/tkH9axfbKB.json',
    ),
    OnboardingData(
      title: 'تواصل مشرق',
      description:
          'قناة اتصال واضحة ومباشرة بين المنزل والمدرسة لضمان أفضل تجربة تعليمية.',
      icon: Icons.forum_rounded,
      color: primaryPurple,
      lottieUrl: 'assets/animations/hRC6CaUyWO.json',
    ),
    OnboardingData(
      title: 'تحليلات النمو',
      description:
          'تقارير سلوكية شاملة وسجلات نشاط يومية لتنمية مهارات وإمكانيات الطلاب.',
      icon: Icons.emoji_events_rounded,
      color: primaryBlue,
      lottieUrl: 'assets/animations/BWg31TluCb.json',
    ),
    OnboardingData(
      title: 'مسار أكاديمي',
      description:
          'إدارة الواجبات المنزلية ومتابعة الأداء الدراسي بكل سهولة لتحقيق أفضل النتائج.',
      icon: Icons.assignment_rounded,
      color: primaryPurple,
      lottieUrl: 'assets/animations/iwhWmtbRmI.json',
    ),
    OnboardingData(
      title: 'مساعد وصال الذكي',
      description:
          'ذكاء اصطناعي تعليمي متطور يوفر دروساً خصوصية ودعماً فورياً على مدار الساعة.',
      icon: Icons.psychology_rounded,
      color: primaryBlue,
      lottieUrl: 'assets/animations/7QCKUxijOP.json',
    ),
    OnboardingData(
      title: 'تتبع الباص',
      description:
          'تتبع خط سير الحافلة المدرسية مباشرة واعرف موعد وصول طفلك بدقة وأمان.',
      icon: Icons.directions_bus_rounded,
      color: primaryPurple,
      lottieUrl: 'assets/animations/n8DjVZa3cP.json',
    ),
    OnboardingData(
      title: 'تحضير ذكي',
      description:
          'متابعة لحظية مع دمج ذكي للقياسات الحيوية وتنبيهات فورية لأولياء الأمور.',
      icon: Icons.how_to_reg_rounded,
      color: primaryBlue,
      lottieUrl: 'assets/animations/9rYw9T50wO.json',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _preloadAllLottie();
  }

  Future<void> _preloadAllLottie() async {
    final urls = _onboardingItems
        .where((e) => e.lottieUrl != null)
        .map((e) => e.lottieUrl!);
    for (var url in urls) {
      AssetLottie(url).load();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _onNextTap() {
    if (_currentPage < _onboardingItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutQuart,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            color: baseColor,
            image: DecorationImage(
              image: AssetImage('assets/images/login_bg.png'),
              fit: BoxFit.cover,
              opacity: 0.3, // تقليل الشفافية لراحة العين
            ),
          ),
          child: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    // --- Header ---
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 20.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Spacer(),
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(
                              context,
                              '/login',
                            ),
                            child: Text(
                              'تخطي',
                              style: TextStyle(
                                color: textMuted,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) =>
                            setState(() => _currentPage = index),
                        itemCount: _onboardingItems.length,
                        itemBuilder: (context, index) {
                          final item = _onboardingItems[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // --- 3D Neumorphic Container for Animation ---
                                AnimatedBuilder(
                                  animation: _floatController,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(
                                        0,
                                        math.sin(
                                              _floatController.value *
                                                  math.pi *
                                                  2,
                                            ) *
                                            10,
                                      ),
                                      child: child,
                                    );
                                  },
                                  child: Container(
                                    width: 300.r,
                                    height: 300.r,
                                    decoration: BoxDecoration(
                                      color: baseColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.08,
                                          ),
                                          blurRadius: 20,
                                          offset: const Offset(10, 10),
                                        ),
                                        const BoxShadow(
                                          color: Colors.white,
                                          blurRadius: 20,
                                          offset: Offset(-10, -10),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Lottie.asset(
                                        item.lottieUrl!,
                                        width: 240.r,
                                        height: 240.r,
                                        fit: BoxFit.contain,
                                        animate: _currentPage == index,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 50.h),

                                // --- Text Content ---
                                Text(
                                  item.title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: textDark,
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                  ),
                                  child: Text(
                                    item.description,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: textMuted,
                                      fontSize: 16.sp,
                                      height: 1.6,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // --- Bottom Controls ---
                    Padding(
                      padding: EdgeInsets.fromLTRB(32.w, 0, 32.w, 50.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Indicators
                          Row(
                            children: List.generate(
                              _onboardingItems.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: EdgeInsets.only(left: 6.w),
                                height: 8.h,
                                width: _currentPage == index ? 24.w : 8.w,
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? primaryBlue
                                      : textMuted.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),

                          // Next Button (Gradient)
                          GestureDetector(
                            onTap: _onNextTap,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    _currentPage == _onboardingItems.length - 1
                                    ? 32.w
                                    : 20.w,
                                vertical: 16.h,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [primaryBlue, primaryPurple],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryPurple.withValues(alpha: 0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _currentPage == _onboardingItems.length - 1
                                        ? 'ابدأ الآن'
                                        : 'التالي',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                  if (_currentPage <
                                      _onboardingItems.length - 1) ...[
                                    SizedBox(width: 8.w),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
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
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String? lottieUrl;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.lottieUrl,
  });
}

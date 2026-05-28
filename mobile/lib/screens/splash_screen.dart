// شاشة البداية (Splash Screen) تعرض شعار التطبيق أثناء تحميل البيانات
/*
🧠 اسم الملف: splash_screen.dart

📌 بيعمل إيه؟
دي الشاشة الافتتاحية اللي بتظهر أول ما تفتح التطبيق، بتعرض اللوجو وتعمل شوية تحضيرات في الخلفية.

👤 موجه لمين؟
- الكل

💡 فكرته:
بتدي انطباع أول احترافي وبتحمل البيانات الأساسية قبل ما المستخدم يبدأ يستخدم التطبيق.
*/

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'onboarding_screen.dart';

// All Lottie URLs that should be pre-warmed before Onboarding opens
const _kOnboardingLottieUrls = [
  // First page — must be ready instantly
  'assets/animations/tkH9axfbKB.json',
  // Onboarding background
  'assets/animations/X5gMVIK9Yy.json',
  // Remaining pages (lower priority — loaded opportunistically)
  'assets/animations/hRC6CaUyWO.json',
  'assets/animations/BWg31TluCb.json',
  'assets/animations/iwhWmtbRmI.json',
  'assets/animations/7QCKUxijOP.json',
  'assets/animations/n8DjVZa3cP.json',
  'assets/animations/9rYw9T50wO.json',
];

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _entranceController;
  late AnimationController _mainLottieController;

  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<Offset> _entranceSlide;
  late Animation<Offset> _floatOffset;

  @override
  void initState() {
    super.initState();

    // Environment floating animations
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..forward();



    // Main Cinematic Controller for Lottie & Flow
    _mainLottieController = AnimationController(vsync: this);
    _mainLottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToOnboarding();
      }
    });

    // Cinematic Entrance Controller (Background/Gradients)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Animations setup (Choreographed Timeline)


    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.8, curve: Curves.easeOutQuad),
      ),
    );

    _logoScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _entranceSlide =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
          ),
        );

    _floatOffset =
        Tween<Offset>(
          begin: const Offset(0, 0.015),
          end: const Offset(0, -0.015),
        ).animate(
          CurvedAnimation(
            parent: _floatController,
            curve: Curves.easeInOutSine,
          ),
        );

    // Orchestrating Flow
    _entranceController.forward();
    FlutterNativeSplash.remove();

    // Pre-warm animations with a slight delay to let the splash entrance finish smoothly
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _prewarmOnboardingLottie();
    });
  }

  /// Loads animations one by one with a small gap to prevent CPU spikes
  Future<void> _prewarmOnboardingLottie() async {
    // 1. High-priority: first page animation
    try {
      await AssetLottie(_kOnboardingLottieUrls[0]).load();
    } catch (_) {}

    // 2. Background: remaining animations (spaced out)
    for (int i = 1; i < _kOnboardingLottieUrls.length; i++) {
      if (!mounted) break;
      // Small gap between loads to keep the UI thread breathing
      await Future.delayed(const Duration(milliseconds: 300));
      AssetLottie(_kOnboardingLottieUrls[i]).load().ignore();
    }
  }

  void _navigateToOnboarding() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    _mainLottieController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F3F8), // baseColor
      body: Stack(
        children: [
          // 3. New User-Provided Lottie Animation (The Masterpiece)
          Center(
            child: SlideTransition(
              position: _entranceSlide,
              child: SlideTransition(
                position: _floatOffset,
                child: FadeTransition(
                  opacity: _logoOpacity,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Lottie.asset(
                      'assets/animations/FLFb4ISBBv.json',
                      controller: _mainLottieController,
                      onLoaded: (composition) {
                        _mainLottieController
                          ..duration =
                              composition.duration *
                              0.70 // أسرع بنسبة 30%
                          ..forward();
                      },
                      width: size.width * 1.0,
                      fit: BoxFit.contain,
                      repeat: false,
                      frameRate: FrameRate.max, // لحل مشكلة التقطيع
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



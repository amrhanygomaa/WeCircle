// النقطة الأساسية لتشغيل التطبيق (Entry Point) وتعريف المسارات (Routes) المتاحة
/*
🧠 اسم الملف: main.dart

📌 بيعمل إيه؟
ده "قلب" التطبيق ونقطة البداية، هو اللي بيشغل كل حاجة وبيرتب المسارات (Routes) والثيمات.

👤 موجه لمين؟
- المبرمجين (السيستم نفسه)

💡 فكرته:
تجميع كل أجزاء التطبيق وربطها ببعض عشان يشتغل ككتلة واحدة متجانسة.
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wesal/core/theme/app_theme.dart';
import 'package:wesal/core/state/state_manager.dart';
import 'package:wesal/screens/splash_screen.dart';
import 'package:wesal/screens/login_screen.dart';
import 'package:wesal/screens/onboarding_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:wesal/screens/driver/driver_dashboard.dart';
import 'package:wesal/screens/parent/parent_dashboard.dart';
import 'package:wesal/screens/student1-3/student_dashboard.dart';
import 'package:wesal/screens/student4-6/student_dashboard_group_b.dart';
import 'package:wesal/screens/student1-3/student_avatar_selection_screen.dart';
import 'package:wesal/screens/student1-3/achievements_screen.dart';
import 'package:wesal/screens/student4-6/home_task_screen.dart';
import 'package:wesal/screens/student4-6/hero_challenge_screen.dart';
import 'package:wesal/screens/student4-6/focus_lock_screen.dart';
import 'package:wesal/screens/teacher/teacher_dashboard.dart';

import 'package:wesal/screens/attendance_screen.dart';
import 'package:wesal/screens/parent/homework_screen.dart';
import 'package:wesal/screens/parent/bus_tracker_screen.dart';
import 'package:wesal/screens/parent/messages_screen.dart';
import 'package:wesal/screens/parent/results_screen.dart';
import 'package:wesal/screens/parent/profile_screen.dart';
import 'package:wesal/screens/parent/fees_screen.dart';
import 'package:wesal/screens/parent/behavioral_books_screen.dart';
import 'package:wesal/screens/parent/behavioral_consultation_screen.dart';
import 'package:wesal/screens/parent/tips_screen.dart';
import 'package:wesal/screens/parent/behavior_report_screen.dart';
import 'package:wesal/screens/student_shared/student_chatbot_screen.dart';
import 'package:wesal/screens/parent/activities_screen.dart';

class WesalScrollBehavior extends MaterialScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Performance: lock to portrait, reduce GPU overdraw ───────────────────
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const WesalApp());
}

class WesalApp extends StatelessWidget {
  const WesalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateManager();

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: state.themeMode,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: state.locale,
          builder: (context, locale, _) {
            return ScreenUtilInit(
              designSize: const Size(393, 852),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (context, child) {
                return MaterialApp(
                  title: 'Wesal',
                  theme: AppTheme.lightTheme,
                  scrollBehavior: WesalScrollBehavior(),
                  darkTheme: ThemeData.dark().copyWith(
                    primaryColor: AppTheme.primaryDark,
                    scaffoldBackgroundColor: const Color(0xFF0F172A),
                    bottomNavigationBarTheme:
                        const BottomNavigationBarThemeData(
                          backgroundColor: Color(0xFF1E293B),
                        ),
                  ),
                  themeMode: themeMode,
                  locale: locale,
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('ar', 'SA'),
                    Locale('en', 'US'),
                  ],
                  debugShowCheckedModeBanner: false,
                  builder: (context, widget) {
                    // Prevent device font scaling from breaking the app UI globally
                    final mediaQueryData = MediaQuery.of(context);
                    final double scale = mediaQueryData.textScaler
                        .scale(1.0)
                        .toDouble();
                    return MediaQuery(
                      data: mediaQueryData.copyWith(
                        textScaler: TextScaler.linear(scale.clamp(0.8, 1.2)),
                      ),
                      child: widget!,
                    );
                  },
                  initialRoute: '/',
                  routes: {
                    '/': (context) => const SplashScreen(),
                    '/onboarding': (context) => const OnboardingScreen(),
                    '/login': (context) => const LoginScreen(),
                    '/parent_dashboard': (context) =>
                        const ParentDashboardScreen(),
                    '/student_avatar_selection': (context) =>
                        const StudentAvatarSelectionScreen(),
                    '/student_dashboard': (context) =>
                        const StudentDashboardScreen(),
                    '/student_dashboard_group_b': (context) =>
                        const StudentDashboardGroupBScreen(),
                    '/home_task': (context) => const HomeTaskScreen(),
                    '/hero_challenge': (context) => const HeroChallengeScreen(),
                    '/achievements': (context) => const AchievementsScreen(),
                    '/focus_lock': (context) => const FocusLockScreen(),

                    '/attendance': (context) {
                      final args = ModalRoute.of(context)?.settings.arguments;
                      int index = 0;
                      Map<String, dynamic>? child;
                      bool singleMode = false;

                      if (args is Map<String, dynamic>) {
                        index = args['index'] ?? 0;
                        child = args['child'];
                        singleMode = true;
                      } else if (args is int) {
                        index = args;
                        singleMode = true;
                      }

                      return AttendanceScreen(
                        initialIndex: index,
                        isSingleMode: singleMode,
                        childData: child,
                      );
                    },
                    '/homework': (context) => const HomeworkScreen(),
                    '/bus_tracker': (context) => const BusTrackerScreen(),
                    '/messages': (context) => const MessagingCenterScreen(),
                    '/results': (context) {
                      final child =
                          ModalRoute.of(context)?.settings.arguments
                              as Map<String, dynamic>?;
                      return ResultsScreen(childData: child);
                    },
                    '/profile': (context) => const ProfileScreen(),
                    '/fees': (context) => const FeesScreen(),
                    '/tips': (context) => const EducationalTipsScreen(),
                    '/behavior_report': (context) =>
                        const BehaviorReportScreen(),
                    '/behavioral_books': (context) => const BehavioralBooksScreen(),
                    '/behavioral_consultation': (context) => const BehavioralConsultationScreen(),
                    '/chatbot': (context) => const StudentChatbotScreen(),
                    '/activities': (context) => const ActivitiesScreen(),

                    '/driver_dashboard': (context) =>
                        const DriverDashboardScreen(),
                    '/teacher_dashboard': (context) => const TeacherDashboard(),
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

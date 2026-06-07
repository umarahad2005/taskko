import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/view/admin_entry_screen.dart';
import '../features/focus/view/focus_timer_screen.dart';
import '../features/auth/view/login_screen.dart';
import '../features/auth/view/signup_screen.dart';
import '../features/chat/view/chat_screen.dart';
import '../features/history/view/history_screen.dart';
import '../features/home/view/home_screen.dart';
import '../features/hub/view/hub_screen.dart';
import '../features/onboarding/view/onboarding_screen.dart';
import '../features/plan/view/plan_screen.dart';
import '../features/planday/view/plan_day_screen.dart';
import '../features/profile/view/profile_screen.dart';
import '../features/quiz/view/quiz_screen.dart';
import '../features/settings/view/settings_screen.dart';
import '../features/splash/view/splash_screen.dart';

/// App navigation (SRS §2 — all 8 phone screens + admin entry).
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
    GoRoute(path: '/signup', builder: (_, _) => const SignUpScreen()),
    GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
    GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
    GoRoute(path: '/plan', builder: (_, _) => const PlanScreen()),
    GoRoute(path: '/hub', builder: (_, _) => const HubScreen()),
    GoRoute(path: '/chat', builder: (_, _) => const ChatScreen()),
    GoRoute(path: '/admin', builder: (_, _) => const AdminEntryScreen()),
    GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
    GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
    GoRoute(path: '/history', builder: (_, _) => const HistoryScreen()),
    GoRoute(path: '/quiz', builder: (_, _) => const QuizScreen()),
    GoRoute(
      path: '/planday',
      builder: (context, state) {
        final args = state.extra;
        if (args is PlanDayArgs) return PlanDayScreen(args: args);
        return const Scaffold(body: Center(child: Text('No tasks to plan')));
      },
    ),
    GoRoute(
      path: '/focus',
      builder: (context, state) {
        final args = state.extra;
        if (args is FocusArgs) return FocusTimerScreen(args: args);
        return const Scaffold(body: Center(child: Text('No task selected')));
      },
    ),
  ],
);

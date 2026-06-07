import 'package:go_router/go_router.dart';

import '../features/admin/view/admin_entry_screen.dart';
import '../features/auth/view/login_screen.dart';
import '../features/auth/view/signup_screen.dart';
import '../features/chat/view/chat_screen.dart';
import '../features/home/view/home_screen.dart';
import '../features/hub/view/hub_screen.dart';
import '../features/onboarding/view/onboarding_screen.dart';
import '../features/plan/view/plan_screen.dart';
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
  ],
);

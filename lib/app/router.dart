import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../cubits/auth/auth_cubit.dart';
import '../features/admin/view/admin_panel_screen.dart';
import '../features/focus/view/focus_timer_screen.dart';
import '../features/auth/view/login_screen.dart';
import '../features/auth/view/signup_screen.dart';
import '../features/auth/view/verify_email_screen.dart';
import '../features/chat/view/chat_screen.dart';
import '../features/history/view/history_screen.dart';
import '../features/home/view/home_screen.dart';
import '../features/hub/view/hub_screen.dart';
import '../features/legal/view/legal_screen.dart';
import '../features/onboarding/view/onboarding_screen.dart';
import '../features/plan/view/plan_screen.dart';
import '../features/planday/view/plan_day_screen.dart';
import '../features/profile/view/edit_profile_screen.dart';
import '../features/profile/view/profile_screen.dart';
import '../models/app_user.dart';
import '../features/quiz/view/quiz_screen.dart';
import '../features/settings/view/settings_screen.dart';
import '../features/splash/view/splash_screen.dart';

/// App navigation (SRS §2 — all 8 phone screens + admin entry).
///
/// Built with the [AuthCubit] so a single [redirect] guard enforces the auth +
/// email-verification rules for the whole app — no screen can be reached by a
/// user who shouldn't be there, regardless of how navigation is triggered.
/// `refreshListenable` re-runs the guard whenever auth state changes.
GoRouter createAppRouter(AuthCubit auth) => GoRouter(
      initialLocation: '/splash',
      refreshListenable: GoRouterRefreshStream(auth.stream),
      redirect: (context, state) => _guard(auth, state.matchedLocation),
      routes: _routes,
    );

/// Routes a user away from screens their auth state doesn't permit.
/// Returns a path to redirect to, or `null` to allow the current location.
String? _guard(AuthCubit auth, String loc) {
  final status = auth.state.status;

  // Session still resolving — let the splash/screen logic run (no redirect).
  if (status == AuthStatus.unknown || status == AuthStatus.authenticating) {
    return null;
  }

  // Signed in but email NOT verified → the app is off-limits. Only the verify
  // screen (and legal pages / the splash beat) are reachable. This is what
  // guarantees only a real, working email gets into the app.
  if (status == AuthStatus.unverified) {
    const allowed = {'/splash', '/verify-email', '/terms', '/privacy'};
    return allowed.contains(loc) ? null : '/verify-email';
  }

  // Signed out (or a transient failure) → keep out of the authenticated app.
  if (status != AuthStatus.authenticated) {
    const open = {'/splash', '/onboarding', '/login', '/signup', '/verify-email', '/terms', '/privacy'};
    return open.contains(loc) ? null : '/login';
  }

  // Authenticated: don't linger on the auth/verify screens.
  if (loc == '/login' || loc == '/signup' || loc == '/verify-email') {
    return auth.state.isAdmin ? '/admin' : '/home';
  }
  // Only admins may open the admin panel.
  if (loc == '/admin' && !auth.state.isAdmin) return '/home';
  return null;
}

final List<RouteBase> _routes = [
    GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
    GoRoute(path: '/signup', builder: (_, _) => const SignUpScreen()),
    GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
    GoRoute(path: '/verify-email', builder: (_, _) => const VerifyEmailScreen()),
    GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
    GoRoute(path: '/plan', builder: (_, _) => const PlanScreen()),
    GoRoute(path: '/hub', builder: (_, _) => const HubScreen()),
    GoRoute(path: '/chat', builder: (_, _) => const ChatScreen()),
    GoRoute(path: '/admin', builder: (_, _) => const AdminPanelScreen()),
    GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) {
        final user = state.extra;
        if (user is AppUser) return EditProfileScreen(user: user);
        return const Scaffold(body: Center(child: Text('No profile to edit')));
      },
    ),
    GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
    GoRoute(path: '/history', builder: (_, _) => const HistoryScreen()),
    GoRoute(path: '/quiz', builder: (_, _) => const QuizScreen()),
    GoRoute(path: '/terms', builder: (_, _) => const LegalScreen(doc: kTermsDoc)),
    GoRoute(path: '/privacy', builder: (_, _) => const LegalScreen(doc: kPrivacyDoc)),
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
];

/// Bridges the [AuthCubit] state stream to a [Listenable] so GoRouter re-runs
/// its [redirect] guard whenever auth state changes (login, logout, verify).
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

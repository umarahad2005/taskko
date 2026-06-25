import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/auth/auth_cubit.dart';
import '../cubits/gamification/gamification_cubit.dart';
import '../repositories/admin_repository.dart';
import '../repositories/ai_tools_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/chat_history_repository.dart';
import '../repositories/chat_repository.dart';
import '../repositories/gamification_repository.dart';
import '../repositories/backend/admin_api_client.dart';
import '../repositories/backend/admin_repository_http.dart';
import '../repositories/backend/ai_api_client.dart';
import '../repositories/backend/ai_tools_repository_http.dart';
import '../repositories/backend/chat_repository_http.dart';
import '../repositories/backend/plan_repository_http.dart';
import '../repositories/firebase/auth_repository_firebase.dart';
import '../repositories/firebase/chat_history_repository_firestore.dart';
import '../repositories/firebase/gamification_repository_firestore.dart';
import '../repositories/firebase/session_repository_firestore.dart';
import '../repositories/firebase/settings_repository_firestore.dart';
import '../repositories/firebase/tasks_repository_firestore.dart';
import '../repositories/mock/auth_repository_mock.dart';
import '../repositories/mock/chat_history_repository_mock.dart';
import '../repositories/mock/chat_repository_mock.dart';
import '../repositories/mock/gamification_repository_mock.dart';
import '../repositories/mock/plan_repository_mock.dart';
import '../repositories/mock/admin_repository_mock.dart';
import '../repositories/mock/ai_tools_repository_mock.dart';
import '../repositories/mock/session_repository_mock.dart';
import '../repositories/mock/settings_repository_mock.dart';
import '../repositories/mock/tasks_repository_mock.dart';
import '../repositories/plan_repository.dart';
import '../repositories/session_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/tasks_repository.dart';
import '../theme/app_theme.dart';
import 'router.dart';

/// Root widget. Wires the (mock for now) repositories and app-level cubits via
/// dependency injection so M9 can swap mock → real impls without UI changes.
class TaskkoApp extends StatefulWidget {
  const TaskkoApp({super.key});

  /// Use real Firebase Auth by default; build/test with `--dart-define=USE_FIREBASE=false`
  /// to fall back to the in-memory mock (offline demos, widget tests).
  static const bool useFirebase = bool.fromEnvironment('USE_FIREBASE', defaultValue: true);

  /// Route Plan/Chat AI through the backend (real Gemini). Off by default so the
  /// app runs on mocks without a server; enable with `--dart-define=USE_BACKEND=true`
  /// (also set BACKEND_URL). Requires a signed-in Firebase user + the backend's
  /// FIREBASE_SERVICE_ACCOUNT so it can verify the token.
  static const bool useBackend = bool.fromEnvironment('USE_BACKEND', defaultValue: true);

  @override
  State<TaskkoApp> createState() => _TaskkoAppState();
}

class _TaskkoAppState extends State<TaskkoApp> {
  // Built once, from the AuthCubit, so the router's redirect guard can read live
  // auth state and re-run on every auth change (refreshListenable).
  GoRouter? _router;

  bool get useFirebase => TaskkoApp.useFirebase;
  bool get useBackend => TaskkoApp.useBackend;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => useFirebase ? FirebaseAuthRepository() : AuthRepositoryMock(),
        ),
        RepositoryProvider<TasksRepository>(
          create: (_) => useFirebase ? TasksRepositoryFirestore() : TasksRepositoryMock(),
        ),
        RepositoryProvider<GamificationRepository>(
          create: (_) => useFirebase ? GamificationRepositoryFirestore() : GamificationRepositoryMock(),
        ),
        RepositoryProvider<PlanRepository>(
          create: (_) => useBackend ? PlanRepositoryHttp(AiApiClient()) : PlanRepositoryMock(),
        ),
        RepositoryProvider<ChatRepository>(
          create: (_) => useBackend ? ChatRepositoryHttp(AiApiClient()) : ChatRepositoryMock(),
        ),
        RepositoryProvider<ChatHistoryRepository>(
          create: (_) => useFirebase ? ChatHistoryRepositoryFirestore() : ChatHistoryRepositoryMock(),
        ),
        RepositoryProvider<SettingsRepository>(
          create: (_) => useFirebase ? SettingsRepositoryFirestore() : SettingsRepositoryMock(),
        ),
        RepositoryProvider<SessionRepository>(
          create: (_) => useFirebase ? SessionRepositoryFirestore() : SessionRepositoryMock(),
        ),
        RepositoryProvider<AiToolsRepository>(
          create: (_) => useBackend ? AiToolsRepositoryHttp(AiApiClient()) : AiToolsRepositoryMock(),
        ),
        RepositoryProvider<AdminRepository>(
          create: (_) => useBackend ? AdminRepositoryHttp(AdminApiClient()) : AdminRepositoryMock(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(create: (ctx) => AuthCubit(ctx.read<AuthRepository>())),
          BlocProvider<GamificationCubit>(create: (ctx) => GamificationCubit(ctx.read<GamificationRepository>())),
        ],
        child: Builder(
          builder: (context) {
            final router = _router ??= createAppRouter(context.read<AuthCubit>());
            return MaterialApp.router(
              title: 'Taskko',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              routerConfig: router,
            );
          },
        ),
      ),
    );
  }
}

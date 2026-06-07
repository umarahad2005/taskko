import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/cubits/auth/auth_cubit.dart';
import 'package:project/features/auth/view/signup_screen.dart';
import 'package:project/repositories/mock/auth_repository_mock.dart';
import 'package:project/widgets/primary_button.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget harness() {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, _) => const SignUpScreen()),
    ]);
    return BlocProvider(
      create: (_) => AuthCubit(AuthRepositoryMock()),
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('renders the sign up form (SRS FR-3.1)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(440, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(harness());
    await tester.pump();

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('Create account is disabled until the form is valid + terms agreed', (tester) async {
    await tester.binding.setSurfaceSize(const Size(440, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(harness());
    await tester.pump();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Sara Khan');
    await tester.enterText(fields.at(1), 'sara@uni.edu');
    await tester.enterText(fields.at(2), 'secret123');
    await tester.pump();

    PrimaryButton button() => tester.widget<PrimaryButton>(find.byType(PrimaryButton));

    // Valid fields but terms not agreed → button stays disabled (onPressed null).
    expect(button().onPressed, isNull);

    // Agreeing to terms enables it.
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(button().onPressed, isNotNull);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../common/validators.dart';
import '../../../cubits/auth/auth_cubit.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/taskko_logo.dart';
import '../widgets/auth_divider.dart';
import '../widgets/labeled_field.dart';
import '../widgets/social_button.dart';
import 'signup_screen.dart' show AuthBackground;

/// Login (SRS FR-3.2, FR-3.3, FR-3.7, FR-3.8).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController(text: 'sara@uni.edu');
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _valid => Validators.email(_email.text) == null && _password.text.isNotEmpty;

  void _login() => context.read<AuthCubit>().signInWithEmail(_email.text, _password.text);

  void _tryAdmin() {
    _email.text = 'admin@taskko.app';
    _password.text = 'demo-admin';
    setState(() {});
    context.read<AuthCubit>().signInWithEmail(_email.text, _password.text);
  }

  void _forgot() {
    context.read<AuthCubit>().sendPasswordReset(_email.text);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('If that email exists, a reset link is on its way.')));
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select((AuthCubit c) => c.state.status == AuthStatus.authenticating);
    final emailErr = _email.text.isEmpty ? null : Validators.email(_email.text);

    return Scaffold(
      body: AuthBackground(
        child: BlocListener<AuthCubit, AuthState>(
          listener: _onAuth,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TaskkoLogo(size: 30, showWordmark: true),
                  const SizedBox(height: AppSpacing.xxxl),
                  const Center(child: TaskkoLogo(size: 72)),
                  const SizedBox(height: AppSpacing.lg),
                  Center(child: Text('Welcome back', style: AppTypography.display(28))),
                  const SizedBox(height: 4),
                  Center(
                    child: Text("Your streak's waiting.",
                        style: AppTypography.ui(14, color: AppColors.ink3, weight: FontWeight.w500)),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SocialButton.google(onPressed: loading ? null : () => context.read<AuthCubit>().signInWithGoogle()),
                  const SizedBox(height: AppSpacing.xl),
                  const AuthDivider(label: 'Or'),
                  const SizedBox(height: AppSpacing.lg),
                  LabeledField(
                    label: 'Email',
                    controller: _email,
                    hint: 'sara@uni.edu',
                    keyboardType: TextInputType.emailAddress,
                    errorText: emailErr,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  LabeledField(
                    label: 'Password',
                    controller: _password,
                    hint: 'Your password',
                    isPassword: true,
                    trailing: GestureDetector(
                      onTap: _forgot,
                      child: Text('Forgot?', style: AppTypography.ui(13, color: AppColors.primary, weight: FontWeight.w700)),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(label: 'Log in', loading: loading, onPressed: _valid ? _login : null),
                  const SizedBox(height: AppSpacing.md),
                  _AdminDemoButton(onTap: loading ? null : _tryAdmin),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/signup'),
                      child: Text.rich(TextSpan(
                        text: 'New here? ',
                        style: AppTypography.ui(13, color: AppColors.ink3, weight: FontWeight.w500),
                        children: [
                          TextSpan(text: 'Create account', style: AppTypography.ui(13, color: AppColors.primary, weight: FontWeight.w800)),
                        ],
                      )),
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

  void _onAuth(BuildContext context, AuthState state) {
    if (state.status == AuthStatus.authenticated) {
      context.go(state.isAdmin ? '/admin' : '/home');
    } else if (state.status == AuthStatus.failure && state.error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.error!)));
    }
  }
}

class _AdminDemoButton extends StatelessWidget {
  const _AdminDemoButton({required this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.cardRadius,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: AppRadii.cardRadius,
            border: Border.all(color: AppColors.line2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield_outlined, size: 16, color: AppColors.ink3),
              const SizedBox(width: AppSpacing.sm),
              Text('Try as admin (demo)', style: AppTypography.ui(13, color: AppColors.ink2, weight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

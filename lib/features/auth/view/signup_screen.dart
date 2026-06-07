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
import '../widgets/password_strength_bar.dart';
import '../widgets/social_button.dart';

/// Sign up (SRS FR-3.1, FR-3.3, FR-3.4, FR-3.5, FR-3.6).
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _agree = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _valid =>
      Validators.name(_name.text) == null &&
      Validators.email(_email.text) == null &&
      Validators.password(_password.text) == null &&
      _agree;

  void _submit() => context.read<AuthCubit>().signUp(
        name: _name.text,
        email: _email.text,
        password: _password.text,
      );

  @override
  Widget build(BuildContext context) {
    final loading = context.select((AuthCubit c) => c.state.status == AuthStatus.authenticating);
    final emailErr = _email.text.isEmpty ? null : Validators.email(_email.text);
    final passErr = _password.text.isEmpty ? null : Validators.password(_password.text);

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
                  const SizedBox(height: AppSpacing.xxl),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TaskkoLogo(size: 52),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Create your account', style: AppTypography.display(24)),
                            const SizedBox(height: 4),
                            Text('Set up your AI study buddy in 30 seconds.',
                                style: AppTypography.ui(13, color: AppColors.ink3, weight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SocialButton.google(onPressed: loading ? null : () => context.read<AuthCubit>().signInWithGoogle()),
                  const SizedBox(height: AppSpacing.md),
                  SocialButton.apple(onPressed: loading ? null : () => context.read<AuthCubit>().signInWithGoogle()),
                  const SizedBox(height: AppSpacing.xl),
                  const AuthDivider(label: 'Or sign up with email'),
                  const SizedBox(height: AppSpacing.lg),
                  LabeledField(
                    label: 'Name',
                    controller: _name,
                    hint: 'Sara Khan',
                    onChanged: (_) => setState(() {}),
                  ),
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
                    hint: 'At least 6 characters',
                    isPassword: true,
                    errorText: passErr,
                    onChanged: (_) => setState(() {}),
                  ),
                  if (_password.text.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    PasswordStrengthBar(strength: _password.text.passwordStrength),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  _TermsRow(value: _agree, onChanged: (v) => setState(() => _agree = v)),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: 'Create account',
                    loading: loading,
                    onPressed: _valid ? _submit : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text.rich(TextSpan(
                        text: 'Already on Taskko? ',
                        style: AppTypography.ui(13, color: AppColors.ink3, weight: FontWeight.w500),
                        children: [
                          TextSpan(text: 'Log in', style: AppTypography.ui(13, color: AppColors.primary, weight: FontWeight.w800)),
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

/// Soft auth background gradient shared by sign up / login.
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      DecoratedBox(decoration: const BoxDecoration(gradient: AppColors.authGradient), child: child);
}

class _TermsRow extends StatelessWidget {
  const _TermsRow({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.sm)),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text.rich(TextSpan(
              text: "I agree to Taskko's ",
              style: AppTypography.ui(13, color: AppColors.ink3, weight: FontWeight.w500),
              children: [
                TextSpan(text: 'Terms', style: AppTypography.ui(13, color: AppColors.primary, weight: FontWeight.w700)),
                const TextSpan(text: ' and '),
                TextSpan(text: 'Privacy Policy', style: AppTypography.ui(13, color: AppColors.primary, weight: FontWeight.w700)),
                const TextSpan(text: '.'),
              ],
            )),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../common/validators.dart';
import '../../../cubits/auth/auth_cubit.dart';
import '../../../repositories/auth_repository.dart';
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
  final _email = TextEditingController(text: 'sharjeel@uni.edu');
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _valid => Validators.email(_email.text) == null && _password.text.isNotEmpty;

  void _login() => context.read<AuthCubit>().signInWithEmail(_email.text, _password.text);

  /// Open a small dialog to confirm the email, then send a reset link with
  /// real success/error feedback (the old inline version sent silently and
  /// always claimed success — it didn't validate or surface failures).
  Future<void> _forgot() async {
    final controller = TextEditingController(text: _email.text.trim());
    final sent = await showDialog<bool>(
      context: context,
      builder: (_) => _ForgotPasswordDialog(controller: controller),
    );
    controller.dispose();
    if (sent == true && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Reset link sent — check your inbox (and spam).')));
    }
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
                    hint: 'sharjeel@uni.edu',
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
    } else if (state.status == AuthStatus.unverified) {
      context.go('/verify-email');
    } else if (state.status == AuthStatus.failure && state.error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.error!)));
    }
  }
}

/// Collects/confirms an email and sends a password-reset link, showing inline
/// validation, a loading state, and a friendly error before closing on success.
class _ForgotPasswordDialog extends StatefulWidget {
  const _ForgotPasswordDialog({required this.controller});
  final TextEditingController controller;

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  bool _busy = false;
  String? _error;

  Future<void> _send() async {
    final email = widget.controller.text.trim();
    final invalid = Validators.email(email);
    if (invalid != null) {
      setState(() => _error = invalid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AuthCubit>().sendPasswordReset(email);
      if (mounted) Navigator.of(context).pop(true);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = "Couldn't send the link. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset your password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Enter your account email and we'll send you a link to set a new password.",
            style: AppTypography.ui(13, color: AppColors.ink3, weight: FontWeight.w500),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: widget.controller,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => _busy ? null : _send(),
            decoration: const InputDecoration(labelText: 'Email', isDense: true),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(_error!, style: AppTypography.ui(12, color: AppColors.rose, weight: FontWeight.w600)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _busy ? null : _send,
          child: _busy
              ? const SizedBox(
                  width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Send link'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../cubits/auth/auth_cubit.dart';
import '../../../repositories/auth_repository.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/taskko_logo.dart';
import 'signup_screen.dart' show AuthBackground;

/// Verify email (SRS FR-3.*). Shown after an email/password signup (or login
/// with an unverified account). Google sign-ins are auto-verified and never land
/// here. Gates entry to the app until the address is confirmed.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _checking = false;
  bool _resending = false;

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _check() async {
    setState(() => _checking = true);
    final verified = await context.read<AuthCubit>().refreshVerification();
    if (!mounted) return;
    setState(() => _checking = false);
    // When verified, the BlocListener routes onward; otherwise nudge the user.
    if (!verified) {
      _snack("Not verified yet — open the link in your inbox, then tap again.");
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      await context.read<AuthCubit>().resendVerification();
      _snack('Verification email sent. Check your inbox (and spam).');
    } on AuthException catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack("Couldn't send the email. Please try again in a moment.");
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  void _useAnotherAccount() => context.read<AuthCubit>().signOut();

  @override
  Widget build(BuildContext context) {
    final email = context.select((AuthCubit c) => c.state.user?.email) ?? 'your email';

    return Scaffold(
      body: AuthBackground(
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              context.go(state.isAdmin ? '/admin' : '/home');
            } else if (state.status == AuthStatus.unauthenticated) {
              context.go('/login');
            }
          },
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TaskkoLogo(size: 30, showWordmark: true),
                  const SizedBox(height: AppSpacing.xxxl),
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                      ),
                      child: const Icon(Icons.mark_email_unread_rounded,
                          size: 40, color: AppColors.primaryDeep),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Center(child: Text('Verify your email', style: AppTypography.display(26))),
                  const SizedBox(height: AppSpacing.sm),
                  Text.rich(
                    TextSpan(
                      text: 'We sent a verification link to ',
                      style: AppTypography.ui(14, color: AppColors.ink3, weight: FontWeight.w500),
                      children: [
                        TextSpan(
                          text: email,
                          style: AppTypography.ui(14, color: AppColors.ink, weight: FontWeight.w800),
                        ),
                        const TextSpan(
                            text: '. Open it to confirm your account, then come back here.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  PrimaryButton(
                    label: "I've verified — continue",
                    loading: _checking,
                    onPressed: _checking ? null : _check,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _OutlinedAction(
                    icon: Icons.refresh_rounded,
                    label: _resending ? 'Sending…' : 'Resend email',
                    onTap: _resending ? null : _resend,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: GestureDetector(
                      onTap: _useAnotherAccount,
                      child: Text.rich(TextSpan(
                        text: 'Wrong account? ',
                        style: AppTypography.ui(13, color: AppColors.ink3, weight: FontWeight.w500),
                        children: [
                          TextSpan(
                            text: 'Use a different one',
                            style: AppTypography.ui(13, color: AppColors.primary, weight: FontWeight.w800),
                          ),
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
}

/// Bordered secondary action button matching the auth screens' style.
class _OutlinedAction extends StatelessWidget {
  const _OutlinedAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
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
              Icon(icon, size: 16, color: enabled ? AppColors.ink2 : AppColors.ink4),
              const SizedBox(width: AppSpacing.sm),
              Text(label,
                  style: AppTypography.ui(13,
                      color: enabled ? AppColors.ink2 : AppColors.ink4, weight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

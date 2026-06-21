import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../models/app_user.dart';
import '../../../models/mood.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/chat_history_repository.dart';
import '../../../repositories/gamification_repository.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/primary_button.dart';
import '../../auth/widgets/labeled_field.dart';

/// Edit profile (profile CRUD) — update the display name and current mood, then
/// persist to Firestore via [GamificationRepository.updateProfile]. Pops the
/// updated [AppUser] so the caller can refresh.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name = TextEditingController(text: widget.user.name);
  late Mood _mood = widget.user.mood;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Name cannot be empty');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated =
          await context.read<GamificationRepository>().updateProfile(name: name, mood: _mood);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Profile updated')));
      context.pop(updated);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = "Couldn't save changes. Try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Google-only accounts have no password to confirm with, so the email /
    // password change flows (which re-authenticate with a password) don't apply.
    final hasPassword = context.read<AuthRepository>().currentProviders().contains('password');
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, AppSpacing.xxl),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _saving ? null : () => context.canPop() ? context.pop() : context.go('/profile'),
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
                  ),
                  Text('Edit profile', style: AppTypography.ui(18, weight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: _mood.color,
                  child: Text(
                    _name.text.trim().isNotEmpty ? _name.text.trim()[0].toUpperCase() : '?',
                    style: AppTypography.display(30, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              LabeledField(
                label: 'Display name',
                controller: _name,
                hint: 'Your name',
                errorText: _error,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Mood', style: AppTypography.ui(13, color: AppColors.ink2, weight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final m in Mood.values) _MoodChip(mood: m, selected: m == _mood, onTap: () => setState(() => _mood = m)),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(label: 'Save changes', loading: _saving, onPressed: _saving ? null : _save),
              const SizedBox(height: AppSpacing.xxl),
              Text('Account & security',
                  style: AppTypography.ui(13, color: AppColors.ink2, weight: FontWeight.w800)),
              const SizedBox(height: AppSpacing.sm),
              if (hasPassword) ...[
                _ActionTile(icon: Icons.alternate_email_rounded, label: 'Change email', onTap: _changeEmail),
                const SizedBox(height: AppSpacing.sm),
                _ActionTile(icon: Icons.lock_outline_rounded, label: 'Change password', onTap: _changePassword),
                const SizedBox(height: AppSpacing.sm),
              ] else ...[
                const _InfoTile(
                  icon: Icons.verified_user_rounded,
                  text: 'You signed in with Google — your email and password are '
                      'managed in your Google Account.',
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              _ActionTile(
                icon: Icons.delete_outline_rounded,
                label: 'Delete account',
                color: AppColors.rose,
                onTap: () => _deleteAccount(hasPassword),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _changeEmail() async {
    final email = TextEditingController();
    final pass = TextEditingController();
    final ok = await _showCredDialog(
      title: 'Change email',
      submitLabel: 'Send verification',
      fields: [
        _Field('New email', email, email: true),
        _Field('Current password', pass, obscure: true),
      ],
      action: () => context
          .read<AuthRepository>()
          .updateEmail(newEmail: email.text, currentPassword: pass.text),
    );
    email.dispose();
    pass.dispose();
    if (ok && mounted) _snack('Verification link sent — confirm it to finish changing your email.');
  }

  Future<void> _changePassword() async {
    final current = TextEditingController();
    final next = TextEditingController();
    final ok = await _showCredDialog(
      title: 'Change password',
      submitLabel: 'Update',
      fields: [
        _Field('Current password', current, obscure: true),
        _Field('New password (min 6 chars)', next, obscure: true),
      ],
      action: () => context
          .read<AuthRepository>()
          .updatePassword(newPassword: next.text, currentPassword: current.text),
    );
    current.dispose();
    next.dispose();
    if (ok && mounted) _snack('Password updated');
  }

  Future<void> _deleteAccount(bool hasPassword) async {
    final auth = context.read<AuthRepository>();
    final chatHistory = context.read<ChatHistoryRepository>();
    // Wipe the user's Tako chat history as part of the deletion, while still
    // signed in (Firestore rules block it once the account is gone).
    Future<void> cleanup() => chatHistory.clearAll();

    final bool ok;
    if (hasPassword) {
      final pass = TextEditingController();
      ok = await _showCredDialog(
        title: 'Delete account?',
        message: 'This permanently deletes your account and your Tako chat history. '
            'This cannot be undone.',
        submitLabel: 'Delete forever',
        destructive: true,
        fields: [_Field('Confirm password', pass, obscure: true)],
        action: () => auth.deleteAccount(currentPassword: pass.text, onReauthenticated: cleanup),
      );
      pass.dispose();
    } else {
      // Google account — re-authentication happens via the Google picker inside
      // deleteAccount(), so no password field is needed here.
      ok = await _showCredDialog(
        title: 'Delete account?',
        message: 'This permanently deletes your account and your Tako chat history. '
            "This cannot be undone. You'll be asked to confirm with Google.",
        submitLabel: 'Delete forever',
        destructive: true,
        fields: const [],
        action: () => auth.deleteAccount(onReauthenticated: cleanup),
      );
    }
    if (ok && mounted) {
      _snack('Your account and chat history have been deleted.');
      context.go('/login');
    }
  }

  Future<bool> _showCredDialog({
    required String title,
    required String submitLabel,
    required List<_Field> fields,
    required Future<void> Function() action,
    String? message,
    bool destructive = false,
  }) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => _CredDialog(
        title: title,
        message: message,
        submitLabel: submitLabel,
        fields: fields,
        action: action,
        destructive: destructive,
      ),
    );
    return res ?? false;
  }
}

/// One field spec for [_CredDialog].
class _Field {
  _Field(this.label, this.controller, {this.obscure = false, this.email = false});
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final bool email;
}

/// A small modal that collects credentials, runs an async [action], and shows
/// inline loading + a friendly error (from [AuthException]) before closing.
class _CredDialog extends StatefulWidget {
  const _CredDialog({
    required this.title,
    required this.submitLabel,
    required this.fields,
    required this.action,
    required this.destructive,
    this.message,
  });
  final String title;
  final String? message;
  final String submitLabel;
  final List<_Field> fields;
  final Future<void> Function() action;
  final bool destructive;

  @override
  State<_CredDialog> createState() => _CredDialogState();
}

class _CredDialogState extends State<_CredDialog> {
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.action();
      if (mounted) Navigator.of(context).pop(true);
    } on AuthCancelledException {
      // User dismissed the Google re-auth sheet — close without an error.
      if (mounted) Navigator.of(context).pop(false);
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
        _error = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.message != null) ...[
            Text(widget.message!, style: AppTypography.ui(13, color: AppColors.ink3, weight: FontWeight.w500)),
            const SizedBox(height: AppSpacing.md),
          ],
          for (final f in widget.fields)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: TextField(
                controller: f.controller,
                obscureText: f.obscure,
                keyboardType: f.email ? TextInputType.emailAddress : null,
                decoration: InputDecoration(labelText: f.label, isDense: true),
              ),
            ),
          if (_error != null)
            Text(_error!, style: AppTypography.ui(12, color: AppColors.rose, weight: FontWeight.w600)),
        ],
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        FilledButton(
          onPressed: _busy ? null : _submit,
          style: widget.destructive ? FilledButton.styleFrom(backgroundColor: AppColors.rose) : null,
          child: _busy
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(widget.submitLabel),
        ),
      ],
    );
  }
}

/// A read-only informational row (e.g. explaining Google-managed credentials).
class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withValues(alpha: 0.4),
        borderRadius: AppRadii.cardRadius,
        border: Border.all(color: AppColors.line2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primaryDeep),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(text,
                style: AppTypography.ui(12.5, color: AppColors.ink2, weight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

/// A tappable account-action row used in the Edit Profile screen.
class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label, required this.onTap, this.color});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.ink2;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.cardRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.cardRadius,
            border: Border.all(color: AppColors.line2),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: c),
              const SizedBox(width: AppSpacing.md),
              Text(label, style: AppTypography.ui(14, color: c, weight: FontWeight.w700)),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.ink4),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({required this.mood, required this.selected, required this.onTap});
  final Mood mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.pillRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? mood.color.withValues(alpha: 0.16) : Colors.white,
            borderRadius: AppRadii.pillRadius,
            border: Border.all(color: selected ? mood.color : AppColors.line2, width: selected ? 1.6 : 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(mood.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                mood.label,
                style: AppTypography.ui(13,
                    color: selected ? AppColors.ink : AppColors.ink3, weight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

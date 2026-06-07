import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../cubits/auth/auth_cubit.dart';
import '../../../models/app_user.dart';
import '../../../repositories/gamification_repository.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/bento_card.dart';
import '../../../widgets/secondary_button.dart';

/// User profile (SRS — opened from the Home avatar). Real data from Firestore.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<GamificationRepository>();
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: FutureBuilder<AppUser>(
            future: repo.profile(),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final user = snap.data;
              if (user == null) {
                return const Center(child: Text('Could not load profile'));
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, AppSpacing.xxl),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
                        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
                      ),
                      Text('Profile', style: AppTypography.ui(18, weight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.energy,
                          child: Text(user.initials,
                              style: AppTypography.display(34, color: Colors.white)),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(user.name, style: AppTypography.display(26)),
                        Text(user.email, style: AppTypography.ui(13, color: AppColors.ink3, weight: FontWeight.w500)),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                          decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: AppRadii.pillRadius),
                          child: Text('${user.mood.emoji}  Feeling ${user.mood.label.toLowerCase()}',
                              style: AppTypography.ui(12, color: AppColors.primaryDeep, weight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(children: [
                    Expanded(child: _StatCard(label: 'Rank', value: user.rank.label, color: AppColors.primary)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _StatCard(label: 'Points', value: '${user.points}', color: AppColors.primaryDeep, mono: true)),
                  ]),
                  const SizedBox(height: AppSpacing.md),
                  Row(children: [
                    Expanded(child: _StatCard(label: 'Streak', value: '${user.streakDays} d', color: AppColors.energy, mono: true)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _StatCard(label: 'Shields', value: '${user.shields}', color: AppColors.mint, mono: true)),
                  ]),
                  const SizedBox(height: AppSpacing.xl),
                  SecondaryButton(label: 'Session history', onPressed: () => context.push('/history')),
                  const SizedBox(height: AppSpacing.md),
                  SecondaryButton(label: 'Reminders & notifications', onPressed: () => context.push('/settings')),
                  const SizedBox(height: AppSpacing.md),
                  if (user.isAdmin) ...[
                    SecondaryButton(label: 'Open admin portal', onPressed: () => context.go('/admin'), filled: true),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  SecondaryButton(
                    label: 'Sign out',
                    color: AppColors.rose,
                    onPressed: () async {
                      await context.read<AuthCubit>().signOut();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.color, this.mono = false});
  final String label;
  final String value;
  final Color color;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTypography.ui(11, color: AppColors.ink3, weight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(value,
              style: mono ? AppTypography.mono(22, color: color) : AppTypography.display(22, color: color)),
        ],
      ),
    );
  }
}

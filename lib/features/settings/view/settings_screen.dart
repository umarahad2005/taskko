import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../models/reminder_prefs.dart';
import '../../../repositories/settings_repository.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/bento_card.dart';
import '../cubit/settings_cubit.dart';

/// Reminders & notifications settings (SRS FR-10).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => SettingsCubit(ctx.read<SettingsRepository>())..load(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: BlocBuilder<SettingsCubit, ReminderPrefs>(
            builder: (context, p) {
              final time = TimeOfDay(hour: p.planHour, minute: p.planMinute);
              return ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, AppSpacing.xxl),
                children: [
                  Row(children: [
                    IconButton(
                      onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
                      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
                    ),
                    Text('Reminders', style: AppTypography.ui(18, weight: FontWeight.w800)),
                  ]),
                  const SizedBox(height: AppSpacing.md),
                  BentoCard(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          activeTrackColor: AppColors.primary,
                          title: Text('Daily plan reminder', style: AppTypography.ui(15, weight: FontWeight.w700)),
                          subtitle: Text('A nudge each day to plan with Taskko',
                              style: AppTypography.ui(12, color: AppColors.ink3, weight: FontWeight.w500)),
                          value: p.planDaily,
                          onChanged: cubit.setPlanDaily,
                        ),
                        if (p.planDaily)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('Reminder time', style: AppTypography.ui(14, weight: FontWeight.w600)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                              decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: AppRadii.pillRadius),
                              child: Text(time.format(context),
                                  style: AppTypography.mono(14, color: AppColors.primaryDeep)),
                            ),
                            onTap: () async {
                              final picked = await showTimePicker(context: context, initialTime: time);
                              if (picked != null) cubit.setPlanTime(picked.hour, picked.minute);
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BentoCard(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeTrackColor: AppColors.energy,
                      title: Text('Streak saver', style: AppTypography.ui(15, weight: FontWeight.w700)),
                      subtitle: Text('Evening nudge (8 PM) so you never break your streak 🔥',
                          style: AppTypography.ui(12, color: AppColors.ink3, weight: FontWeight.w500)),
                      value: p.streakSaver,
                      onChanged: cubit.setStreakSaver,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Break reminders appear automatically after each focus session.',
                    style: AppTypography.ui(12, color: AppColors.ink4, weight: FontWeight.w500),
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

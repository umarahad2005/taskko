import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../common/view_status.dart';
import '../../../models/app_user.dart';
import '../../../repositories/gamification_repository.dart';
import '../../../repositories/tasks_repository.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/tab_scaffold.dart';
import '../../../widgets/taskko_logo.dart';
import '../../focus/view/focus_timer_screen.dart';
import '../cubit/home_cubit.dart';
import '../widgets/home_widgets.dart';

/// Home / Dashboard (SRS FR-4).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => HomeCubit(
        gamification: ctx.read<GamificationRepository>(),
        tasks: ctx.read<TasksRepository>(),
      )..load(),
      child: const TabScaffold(currentTab: TaskkoTab.home, body: _HomeBody()),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.status == ViewStatus.failure) {
          return _ErrorRetry(onRetry: () => context.read<HomeCubit>().load());
        }
        final user = state.user;
        if (state.status != ViewStatus.success || user == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final cubit = context.read<HomeCubit>();
        return ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, AppSpacing.xxl),
          children: [
            _Header(user: user),
            const SizedBox(height: AppSpacing.lg),
            _Greeting(name: user.name, remaining: state.remaining),
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: StreakCard(days: user.streakDays, shields: user.shields)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: RankCard(rank: user.rank, points: user.points, pointsToNext: user.pointsToNext)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            MoodPicker(selected: user.mood, onSelect: cubit.setMood),
            const SizedBox(height: AppSpacing.md),
            NextUpCard(
              task: state.nextTask,
              onStart: () async {
                final task = state.nextTask;
                if (task == null) return;
                final done = await context.push<bool>('/focus', extra: FocusArgs(task: task, mood: user.mood));
                if (done == true) cubit.toggleTask(task.id);
              },
              onSkip: () => _snack(context, 'Skipped — I\'ll resurface it later.'),
            ),
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(
              title: "Today's tasks",
              trailing: Text(
                '${state.doneCount}/${state.total} done · ${(state.percent * 100).round()}%',
                style: AppTypography.ui(13, color: AppColors.primaryDeep, weight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final task in state.tasks) ...[
              TaskTile(task: task, onToggle: () => cubit.toggleTask(task.id)),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        );
      },
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const TaskkoLogo(size: 28, showWordmark: true),
        const Spacer(),
        if (user.isAdmin) ...[
          _AdminChip(onTap: () => context.go('/admin')),
          const SizedBox(width: AppSpacing.sm),
        ],
        _CircleIcon(icon: Icons.notifications_none_rounded, onTap: () {}),
        const SizedBox(width: AppSpacing.sm),
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.energy,
            child: Text(user.initials, style: AppTypography.ui(15, color: Colors.white, weight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }
}

class _AdminChip extends StatelessWidget {
  const _AdminChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.pillRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
        decoration: BoxDecoration(color: AppColors.ink, borderRadius: AppRadii.pillRadius),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.shield_rounded, color: Colors.white, size: 13),
          const SizedBox(width: 4),
          Text('Admin', style: AppTypography.ui(12, color: Colors.white, weight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
        child: Icon(icon, color: AppColors.ink2, size: 20),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.name, required this.remaining});
  final String name;
  final int remaining;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    final part = hour < 12 ? 'Morning' : (hour < 17 ? 'Afternoon' : 'Evening');
    final dateLine = '${_weekdays[now.weekday - 1]} · ${_months[now.month - 1]} ${now.day}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(dateLine.toUpperCase(),
            style: AppTypography.ui(12, color: AppColors.ink3, weight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('$part, $name 👋', style: AppTypography.display(30)),
        const SizedBox(height: 4),
        Text(
          remaining == 0 ? 'All caught up — nice work.' : "You've got $remaining tasks left today — let's go.",
          style: AppTypography.ui(14, color: AppColors.ink3, weight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.ink4, size: 40),
          const SizedBox(height: AppSpacing.md),
          Text('Could not load your dashboard', style: AppTypography.ui(15, weight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

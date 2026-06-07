import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../common/view_status.dart';
import '../../../repositories/gamification_repository.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/tab_scaffold.dart';
import '../../../widgets/tako_mascot.dart';
import '../../../models/mood.dart';
import '../cubit/hub_cubit.dart';
import '../widgets/hub_widgets.dart';

/// Gamification Hub (SRS FR-6).
class HubScreen extends StatelessWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => HubCubit(ctx.read<GamificationRepository>())..load(),
      child: const TabScaffold(currentTab: TaskkoTab.hub, body: _HubBody()),
    );
  }
}

class _HubBody extends StatelessWidget {
  const _HubBody();

  void _share(String text) => SharePlus.instance.share(ShareParams(text: text));

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HubCubit, HubState>(
      builder: (context, state) {
        final cubit = context.read<HubCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trophy room', style: AppTypography.display(28)),
                        const SizedBox(height: 2),
                        Text('Earn it, share it, lord it over your squad.',
                            style: AppTypography.ui(13, color: AppColors.ink3, weight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const TakoMascot(size: 44, mood: Mood.firedUp),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
              child: HubTabs(selected: state.tab, onSelect: cubit.setTab),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(child: _content(context, state)),
          ],
        );
      },
    );
  }

  Widget _content(BuildContext context, HubState state) {
    if (state.status == ViewStatus.failure) {
      return Center(
        child: TextButton(onPressed: () => context.read<HubCubit>().load(), child: const Text('Retry')),
      );
    }
    if (state.status != ViewStatus.success) {
      return const Center(child: CircularProgressIndicator());
    }
    return switch (state.tab) {
      HubTab.badges => _badges(context, state),
      HubTab.squad => _squad(state),
      HubTab.report => _report(context, state),
    };
  }

  Widget _badges(BuildContext context, HubState state) {
    final latest = state.latestBadge;
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.xxl),
      children: [
        if (latest != null) ...[
          NewBadgeCard(
            badge: latest,
            onShare: () => _share('I just unlocked the "${latest.title}" badge on Taskko! ${latest.emoji}'),
            onView: () => _toast(context, 'Viewing ${latest.title}'),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        SectionHeader(
          title: 'All badges',
          trailing: Text('${state.unlockedCount}/${state.badges.length}',
              style: AppTypography.ui(13, color: AppColors.primaryDeep, weight: FontWeight.w700)),
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.82,
          children: [
            for (var i = 0; i < state.badges.length; i++) BadgeTile(badge: state.badges[i], index: i),
          ],
        ),
      ],
    );
  }

  Widget _squad(HubState state) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.xxl),
      children: [LeaderboardList(entries: state.leaderboard)],
    );
  }

  Widget _report(BuildContext context, HubState state) {
    final report = state.report;
    if (report == null) return const SizedBox.shrink();
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.xxl),
      children: [ReportCardView(report: report, onShare: () => _share(report.shareText))],
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}

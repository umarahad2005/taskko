import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../common/view_status.dart';
import '../../../models/focus_session.dart';
import '../../../repositories/session_repository.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/bento_card.dart';
import '../cubit/history_cubit.dart';

/// Focus history & stats (SRS FR-10.3/10.4) — real session data.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => HistoryCubit(ctx.read<SessionRepository>())..load(),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: BlocBuilder<HistoryCubit, HistoryState>(
            builder: (context, state) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, AppSpacing.xxl),
                children: [
                  Row(children: [
                    IconButton(
                      onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
                      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
                    ),
                    Text('Your focus history', style: AppTypography.ui(18, weight: FontWeight.w800)),
                  ]),
                  const SizedBox(height: AppSpacing.md),
                  if (state.status == ViewStatus.loading)
                    const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
                  else ...[
                    Row(children: [
                      Expanded(child: _Stat(value: _fmtMinutes(state.totalMinutes), label: 'Total focus')),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: _Stat(value: '${state.sessionCount}', label: 'Sessions')),
                    ]),
                    const SizedBox(height: AppSpacing.lg),
                    BentoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('LAST 7 DAYS · focus minutes',
                              style: AppTypography.ui(11, color: AppColors.ink3, weight: FontWeight.w800)),
                          const SizedBox(height: AppSpacing.lg),
                          _WeekBars(minutes: state.last7Minutes, dayLabels: _dayLabels),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('RECENT SESSIONS',
                        style: AppTypography.ui(11, color: AppColors.ink3, weight: FontWeight.w800)),
                    const SizedBox(height: AppSpacing.sm),
                    if (state.sessions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        child: Center(
                          child: Text('No sessions yet — start a focus session!',
                              style: AppTypography.ui(14, color: AppColors.ink3, weight: FontWeight.w500)),
                        ),
                      )
                    else
                      for (final s in state.sessions.take(15)) ...[
                        _SessionTile(session: s),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static String _fmtMinutes(int m) => m >= 60 ? '${m ~/ 60}h ${m % 60}m' : '${m}m';
}

class _WeekBars extends StatelessWidget {
  const _WeekBars({required this.minutes, required this.dayLabels});
  final List<int> minutes;
  final List<String> dayLabels;

  @override
  Widget build(BuildContext context) {
    final maxM = minutes.fold<int>(1, (m, v) => v > m ? v : m);
    return SizedBox(
      height: 130,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(minutes[i] > 0 ? '${minutes[i]}' : '',
                      style: AppTypography.mono(10, color: AppColors.ink3)),
                  const SizedBox(height: 2),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: (90 * (minutes[i] / maxM)).clamp(4, 90).toDouble(),
                    decoration: BoxDecoration(
                      gradient: minutes[i] > 0 ? AppColors.primaryGradient : null,
                      color: minutes[i] > 0 ? null : AppColors.line2,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(dayLabels[i], style: AppTypography.ui(11, color: AppColors.ink3, weight: FontWeight.w700)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTypography.display(24, color: AppColors.primaryDeep)),
          Text(label, style: AppTypography.ui(12, color: AppColors.ink3, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});
  final FocusSession session;

  static const _ratingEmoji = {1: '😫', 2: '😐', 3: '😀'};

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(children: [
        Text(session.mood.emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(session.taskTitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: AppTypography.ui(14, weight: FontWeight.w700)),
              Text('${session.minutes} min · ${_date(session.startedAt)}',
                  style: AppTypography.ui(12, color: AppColors.ink3, weight: FontWeight.w500)),
            ],
          ),
        ),
        if (session.rating != null)
          Text(_ratingEmoji[session.rating] ?? '', style: const TextStyle(fontSize: 18)),
      ]),
    );
  }

  static String _date(DateTime d) => '${d.day}/${d.month}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

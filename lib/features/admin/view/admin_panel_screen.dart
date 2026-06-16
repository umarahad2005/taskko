import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../common/view_status.dart';
import '../../../models/admin_metrics.dart';
import '../../../models/admin_user.dart';
import '../../../repositories/admin_repository.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/bento_card.dart';
import '../cubit/admin_cubit.dart';

/// In-app admin console (SRS FR-11) — opened automatically for admin accounts.
/// Core scope: live KPI dashboard + user management, backed by `/api/admin/*`.
class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminCubit>(
      create: (ctx) => AdminCubit(ctx.read<AdminRepository>())
        ..loadDashboard()
        ..loadUsers(),
      child: const _AdminPanelView(),
    );
  }
}

class _AdminPanelView extends StatelessWidget {
  const _AdminPanelView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppColors.bgGradient),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.sm, AppSpacing.sm, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(AppRadii.md)),
                        child: const Icon(Icons.shield_rounded, color: AppColors.primaryDeep, size: 20),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Admin console', style: AppTypography.ui(17, weight: FontWeight.w800)),
                          Text('Taskko · live data', style: AppTypography.ui(11, color: AppColors.ink3, weight: FontWeight.w600)),
                        ],
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => context.go('/home'),
                        icon: const Icon(Icons.exit_to_app_rounded, size: 18),
                        label: const Text('Student app'),
                      ),
                    ],
                  ),
                ),
                const TabBar(
                  labelColor: AppColors.primaryDeep,
                  unselectedLabelColor: AppColors.ink3,
                  indicatorColor: AppColors.primary,
                  tabs: [Tab(text: 'Dashboard'), Tab(text: 'Users')],
                ),
                const Expanded(
                  child: TabBarView(children: [_DashboardTab(), _UsersTab()]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dashboard
// ---------------------------------------------------------------------------

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      buildWhen: (a, b) => a.metricsStatus != b.metricsStatus || a.metrics != b.metrics,
      builder: (context, state) {
        if (state.metricsStatus.isLoading || state.metricsStatus == ViewStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.metricsStatus.isFailure || state.metrics == null) {
          return _ErrorState(
            message: state.error ?? 'Could not load dashboard',
            onRetry: () => context.read<AdminCubit>().loadDashboard(),
          );
        }
        final m = state.metrics!;
        final kpis = <(String, String, Color)>[
          ('Active today', '${m.dau}', AppColors.primary),
          ('Signups today', '${m.signupsToday}', AppColors.energy),
          ('Active streaks', '${m.activeStreaks}', AppColors.mint),
          ('AI calls today', '${m.aiCallsToday}', AppColors.primaryDeep),
          ('Avg tasks/user', m.avgTasksPerUser.toStringAsFixed(1), AppColors.lavender),
        ];
        return RefreshIndicator(
          onRefresh: () => context.read<AdminCubit>().loadDashboard(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, AppSpacing.xxl),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.7,
                children: [for (final k in kpis) _KpiCard(label: k.$1, value: k.$2, color: k.$3)],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (m.rankDistribution.isNotEmpty) ...[
                _SectionTitle('Rank distribution'),
                const SizedBox(height: AppSpacing.sm),
                BentoCard(
                  child: Column(
                    children: [
                      for (final r in m.rankDistribution) _RankRow(r),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (m.topGoals.isNotEmpty) ...[
                _SectionTitle('Top goals'),
                const SizedBox(height: AppSpacing.sm),
                BentoCard(
                  child: Column(
                    children: [
                      for (final g in m.topGoals)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.flag_rounded, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(child: Text(g.goal, style: AppTypography.ui(13, weight: FontWeight.w600))),
                              Text('${g.users}', style: AppTypography.mono(13, color: AppColors.ink3)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (m.activityFeed.isNotEmpty) ...[
                _SectionTitle('Recent activity'),
                const SizedBox(height: AppSpacing.sm),
                BentoCard(
                  child: Column(
                    children: [
                      for (final a in m.activityFeed)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.person_add_alt_1_rounded, size: 16, color: AppColors.mint),
                              const SizedBox(width: 8),
                              Expanded(child: Text(a.text, style: AppTypography.ui(13, weight: FontWeight.w600))),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: AppTypography.display(26, color: color)),
          const SizedBox(height: 2),
          Text(label.toUpperCase(),
              style: AppTypography.ui(10.5, color: AppColors.ink3, weight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow(this.rank);
  final RankCount rank;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(rank.rank, style: AppTypography.ui(13, weight: FontWeight.w700))),
          Text('${rank.count}', style: AppTypography.mono(13, color: AppColors.ink3)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Users
// ---------------------------------------------------------------------------

class _UsersTab extends StatefulWidget {
  const _UsersTab();

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  static const _filters = ['all', 'active', 'flagged', 'suspended'];

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AdminCubit>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, AppSpacing.sm),
          child: TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            onChanged: cubit.setQuery,
            onSubmitted: (_) => cubit.loadUsers(),
            decoration: InputDecoration(
              hintText: 'Search name or email',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                onPressed: cubit.loadUsers,
              ),
            ),
          ),
        ),
        BlocBuilder<AdminCubit, AdminState>(
          buildWhen: (a, b) => a.filter != b.filter,
          builder: (context, state) => SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
              children: [
                for (final f in _filters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f[0].toUpperCase() + f.substring(1)),
                      selected: state.filter == f,
                      onSelected: (_) => cubit.setFilter(f),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: BlocConsumer<AdminCubit, AdminState>(
            listenWhen: (a, b) => a.error != b.error && b.error != null,
            listener: (context, state) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.error!)));
            },
            buildWhen: (a, b) =>
                a.usersStatus != b.usersStatus || a.users != b.users || a.busyUserId != b.busyUserId,
            builder: (context, state) {
              if (state.usersStatus.isLoading || state.usersStatus == ViewStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.usersStatus.isFailure) {
                return _ErrorState(
                  message: state.error ?? 'Could not load users',
                  onRetry: cubit.loadUsers,
                );
              }
              if (state.users.isEmpty) {
                return Center(
                  child: Text('No users match', style: AppTypography.ui(14, color: AppColors.ink3)),
                );
              }
              return RefreshIndicator(
                onRefresh: cubit.loadUsers,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, AppSpacing.xxl),
                  itemCount: state.users.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) => _UserRow(user: state.users[i], busy: state.busyUserId == state.users[i].id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user, required this.busy});
  final AdminUser user;
  final bool busy;

  Color get _statusColor => switch (user.status) {
        'suspended' => AppColors.rose,
        'flagged' => AppColors.energy,
        _ => AppColors.mint,
      };

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AdminCubit>();
    return BentoCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primarySoft,
            child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: AppTypography.ui(15, color: AppColors.primaryDeep, weight: FontWeight.w800)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: AppTypography.ui(14, weight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(user.email, style: AppTypography.ui(11.5, color: AppColors.ink3), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _Pill(text: user.rank, color: AppColors.primary),
                    const SizedBox(width: 6),
                    _Pill(text: '${user.points} pts', color: AppColors.ink3),
                    const SizedBox(width: 6),
                    _Pill(text: user.status, color: _statusColor),
                  ],
                ),
              ],
            ),
          ),
          if (busy)
            const Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: AppColors.ink3),
              onSelected: (v) async {
                if (v == 'grant') {
                  final pts = await _askPoints(context);
                  if (pts != null) cubit.act(userId: user.id, action: 'grant_points', points: pts);
                } else {
                  cubit.act(userId: user.id, action: v);
                }
              },
              itemBuilder: (_) => [
                if (user.isSuspended)
                  const PopupMenuItem(value: 'reinstate', child: Text('Reinstate'))
                else
                  const PopupMenuItem(value: 'suspend', child: Text('Suspend')),
                const PopupMenuItem(value: 'grant', child: Text('Grant points…')),
              ],
            ),
        ],
      ),
    );
  }

  Future<int?> _askPoints(BuildContext context) {
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Grant points'),
        content: Wrap(
          spacing: 8,
          children: [
            for (final p in [25, 50, 100, 250])
              ActionChip(label: Text('+$p'), onPressed: () => Navigator.of(ctx).pop(p)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel'))],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: AppRadii.pillRadius),
      child: Text(text,
          style: AppTypography.ui(10.5, color: color == AppColors.ink3 ? AppColors.ink2 : color, weight: FontWeight.w700)),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTypography.ui(13, color: AppColors.ink2, weight: FontWeight.w800));
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 40, color: AppColors.ink4),
            const SizedBox(height: AppSpacing.sm),
            Text(message, textAlign: TextAlign.center, style: AppTypography.ui(13, color: AppColors.ink3)),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

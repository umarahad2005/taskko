import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../common/validators.dart';
import '../../../common/view_status.dart';
import '../../../models/admin_metrics.dart';
import '../../../models/admin_settings.dart';
import '../../../models/admin_user.dart';
import '../../../models/ai_insights.dart';
import '../../../models/moderation_item.dart';
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
      length: 5,
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
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: AppColors.primaryDeep,
                  unselectedLabelColor: AppColors.ink3,
                  indicatorColor: AppColors.primary,
                  tabs: [
                    Tab(text: 'Dashboard'),
                    Tab(text: 'Users'),
                    Tab(text: 'Moderation'),
                    Tab(text: 'AI insights'),
                    Tab(text: 'Settings'),
                  ],
                ),
                const Expanded(
                  child: TabBarView(children: [
                    _DashboardTab(),
                    _UsersTab(),
                    _ModerationTab(),
                    _AiInsightsTab(),
                    _SettingsTab(),
                  ]),
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
          child: Row(
            children: [
              Expanded(
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
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: () => _UserFormDialog.show(context, cubit),
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                  label: const Text('New'),
                ),
              ),
            ],
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
                switch (v) {
                  case 'edit':
                    _UserFormDialog.show(context, cubit, existing: user);
                  case 'delete':
                    _confirmDelete(context, cubit, user);
                  case 'grant':
                    final pts = await _askPoints(context);
                    if (pts != null) cubit.act(userId: user.id, action: 'grant_points', points: pts);
                  default:
                    cubit.act(userId: user.id, action: v);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: _MenuRow(icon: Icons.edit_outlined, label: 'Edit user…')),
                if (user.isSuspended)
                  const PopupMenuItem(value: 'reinstate', child: _MenuRow(icon: Icons.play_arrow_rounded, label: 'Reinstate'))
                else
                  const PopupMenuItem(value: 'suspend', child: _MenuRow(icon: Icons.block_rounded, label: 'Suspend')),
                const PopupMenuItem(value: 'grant', child: _MenuRow(icon: Icons.add_circle_outline_rounded, label: 'Grant points…')),
                const PopupMenuItem(
                  value: 'delete',
                  child: _MenuRow(icon: Icons.delete_outline_rounded, label: 'Delete', color: AppColors.rose),
                ),
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

/// Icon + label row for the user actions popup menu.
class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label, this.color});
  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.ink2;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: c),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: AppTypography.ui(13.5, color: c, weight: FontWeight.w600)),
      ],
    );
  }
}

/// Confirm + run a permanent user deletion (CRUD — delete).
Future<void> _confirmDelete(BuildContext context, AdminCubit cubit, AdminUser user) async {
  final messenger = ScaffoldMessenger.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete user?'),
      content: Text('Permanently delete ${user.name} (${user.email})? This cannot be undone.',
          style: AppTypography.ui(13.5, color: AppColors.ink2, weight: FontWeight.w500)),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.rose),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (ok != true) return;
  final success = await cubit.deleteUser(user.id);
  if (success) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Deleted ${user.name}')));
  }
  // On failure the Users tab listener surfaces the error.
}

/// Create / edit user form (CRUD — create + update). Passed the [AdminCubit]
/// directly so it works from the dialog's detached context.
class _UserFormDialog extends StatefulWidget {
  const _UserFormDialog({required this.cubit, this.existing});
  final AdminCubit cubit;
  final AdminUser? existing;

  static void show(BuildContext context, AdminCubit cubit, {AdminUser? existing}) {
    showDialog<void>(
      context: context,
      builder: (_) => _UserFormDialog(cubit: cubit, existing: existing),
    );
  }

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  late final TextEditingController _name = TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController _email = TextEditingController(text: widget.existing?.email ?? '');
  final TextEditingController _password = TextEditingController();
  late final TextEditingController _points =
      TextEditingController(text: '${widget.existing?.points ?? 0}');
  late bool _pro = widget.existing?.plan == 'pro';
  late String _status = widget.existing?.status ?? 'active';
  bool _busy = false;
  String? _error;

  bool get _isEdit => widget.existing != null;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _points.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final emailErr = Validators.email(email);
    if (emailErr != null) {
      setState(() => _error = emailErr);
      return;
    }
    if (!_isEdit && _password.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    final points = int.tryParse(_points.text.trim()) ?? 0;
    final plan = _pro ? 'pro' : 'free';
    final ok = _isEdit
        ? await widget.cubit.updateUser(
            userId: widget.existing!.id,
            name: _name.text.trim(),
            email: email,
            points: points,
            plan: plan,
            status: _status,
          )
        : await widget.cubit.createUser(
            name: _name.text.trim(),
            email: email,
            password: _password.text,
            points: points,
            plan: plan,
          );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(_isEdit ? 'User updated' : 'User created')));
    } else {
      setState(() {
        _busy = false;
        _error = widget.cubit.state.error ?? 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'Edit user' : 'New user'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field(_name, 'Name'),
            const SizedBox(height: AppSpacing.sm),
            _field(_email, 'Email', email: true),
            if (!_isEdit) ...[
              const SizedBox(height: AppSpacing.sm),
              _field(_password, 'Password (min 6 chars)', obscure: true),
            ],
            const SizedBox(height: AppSpacing.sm),
            _field(_points, 'Points', number: true),
            const SizedBox(height: AppSpacing.md),
            Text('Plan', style: AppTypography.ui(12, color: AppColors.ink3, weight: FontWeight.w700)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                for (final p in const ['free', 'pro'])
                  ChoiceChip(
                    label: Text(p == 'pro' ? 'Pro' : 'Free'),
                    selected: (_pro ? 'pro' : 'free') == p,
                    onSelected: (_) => setState(() => _pro = p == 'pro'),
                  ),
              ],
            ),
            if (_isEdit) ...[
              const SizedBox(height: AppSpacing.md),
              Text('Status', style: AppTypography.ui(12, color: AppColors.ink3, weight: FontWeight.w700)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  for (final s in const ['active', 'flagged', 'suspended'])
                    ChoiceChip(
                      label: Text(s[0].toUpperCase() + s.substring(1)),
                      selected: _status == s,
                      onSelected: (_) => setState(() => _status = s),
                    ),
                ],
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(_error!, style: AppTypography.ui(12, color: AppColors.rose, weight: FontWeight.w600)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(_isEdit ? 'Save' : 'Create'),
        ),
      ],
    );
  }

  Widget _field(TextEditingController c, String label, {bool obscure = false, bool email = false, bool number = false}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      keyboardType: email
          ? TextInputType.emailAddress
          : number
              ? TextInputType.number
              : null,
      decoration: InputDecoration(labelText: label, isDense: true),
    );
  }
}

// ---------------------------------------------------------------------------
// Moderation (FR-11.5)
// ---------------------------------------------------------------------------

class _ModerationTab extends StatefulWidget {
  const _ModerationTab();

  @override
  State<_ModerationTab> createState() => _ModerationTabState();
}

class _ModerationTabState extends State<_ModerationTab> {
  static const _filters = ['all', 'high', 'medium', 'low'];

  @override
  void initState() {
    super.initState();
    final cubit = context.read<AdminCubit>();
    if (cubit.state.moderationStatus == ViewStatus.initial) cubit.loadModeration();
  }

  static Color _tone(String severity) => switch (severity) {
        'high' => AppColors.energy,
        'medium' => AppColors.gold,
        _ => AppColors.mint,
      };

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AdminCubit>();
    return Column(
      children: [
        BlocBuilder<AdminCubit, AdminState>(
          buildWhen: (a, b) => a.severity != b.severity,
          builder: (context, state) => SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, AppSpacing.sm),
              children: [
                for (final f in _filters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f[0].toUpperCase() + f.substring(1)),
                      selected: state.severity == f,
                      onSelected: (_) => cubit.setSeverity(f),
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
                a.moderationStatus != b.moderationStatus ||
                a.moderation != b.moderation ||
                a.busyModId != b.busyModId,
            builder: (context, state) {
              if (state.moderationStatus.isLoading || state.moderationStatus == ViewStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.moderationStatus.isFailure) {
                return _ErrorState(
                  message: state.error ?? 'Could not load the moderation queue',
                  onRetry: cubit.loadModeration,
                );
              }
              if (state.moderation.isEmpty) {
                return Center(
                  child: Text('Queue is clear — nothing to review.',
                      style: AppTypography.ui(14, color: AppColors.ink3)),
                );
              }
              return RefreshIndicator(
                onRefresh: cubit.loadModeration,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, AppSpacing.xxl),
                  itemCount: state.moderation.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) => _ModRow(
                    item: state.moderation[i],
                    busy: state.busyModId == state.moderation[i].id,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ModRow extends StatelessWidget {
  const _ModRow({required this.item, required this.busy});
  final ModerationItem item;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AdminCubit>();
    final tone = _ModerationTabState._tone(item.severity);
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: tone.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(AppRadii.sm)),
                child: Icon(Icons.flag_rounded, size: 18, color: tone),
              ),
              const SizedBox(width: AppSpacing.sm),
              _Pill(text: item.severity, color: tone),
              const SizedBox(width: 6),
              Expanded(
                child: Text('target ${item.targetUser}',
                    style: AppTypography.ui(11.5, color: AppColors.ink3), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              if (!item.isOpen) _Pill(text: item.status, color: AppColors.ink3),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(item.reason, style: AppTypography.ui(13.5, weight: FontWeight.w700)),
          if (item.isOpen) ...[
            const SizedBox(height: AppSpacing.md),
            busy
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : Row(
                    children: [
                      _ModBtn(label: 'Dismiss', color: AppColors.mint, filled: true, onTap: () => cubit.moderate(itemId: item.id, action: 'dismiss')),
                      const SizedBox(width: 6),
                      _ModBtn(label: 'Warn', color: AppColors.ink3, onTap: () => cubit.moderate(itemId: item.id, action: 'warn')),
                      const SizedBox(width: 6),
                      _ModBtn(label: 'Suspend', color: AppColors.energy, onTap: () => cubit.moderate(itemId: item.id, action: 'suspend')),
                    ],
                  ),
          ],
        ],
      ),
    );
  }
}

class _ModBtn extends StatelessWidget {
  const _ModBtn({required this.label, required this.color, required this.onTap, this.filled = false});
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: filled ? color : color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: filled ? null : Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Text(label,
              style: AppTypography.ui(12, color: filled ? Colors.white : color, weight: FontWeight.w700)),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AI insights (FR-11.6)
// ---------------------------------------------------------------------------

class _AiInsightsTab extends StatefulWidget {
  const _AiInsightsTab();

  @override
  State<_AiInsightsTab> createState() => _AiInsightsTabState();
}

class _AiInsightsTabState extends State<_AiInsightsTab> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<AdminCubit>();
    if (cubit.state.aiStatus == ViewStatus.initial) cubit.loadAiInsights();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      buildWhen: (a, b) => a.aiStatus != b.aiStatus || a.ai != b.ai,
      builder: (context, state) {
        if (state.aiStatus.isLoading || state.aiStatus == ViewStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.aiStatus.isFailure || state.ai == null) {
          return _ErrorState(
            message: state.error ?? 'Could not load AI insights',
            onRetry: () => context.read<AdminCubit>().loadAiInsights(),
          );
        }
        final ai = state.ai!;
        final kpis = <(String, String, Color)>[
          ('Calls today', '${ai.callsToday}', AppColors.primary),
          ('Calls (7d)', '${ai.calls7d}', AppColors.primary2),
          ('Avg latency', '${(ai.avgLatencyMs / 1000).toStringAsFixed(2)}s', AppColors.mint),
          ('Fallback rate', '${(ai.fallbackRate * 100).toStringAsFixed(1)}%', AppColors.energy),
        ];
        return RefreshIndicator(
          onRefresh: () => context.read<AdminCubit>().loadAiInsights(),
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
              if (ai.quality.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                _SectionTitle('Tako quality by feature'),
                const SizedBox(height: AppSpacing.sm),
                BentoCard(
                  child: Column(
                    children: [for (final q in ai.quality) _QualityBar(q)],
                  ),
                ),
              ],
              if (ai.stuckPhrases.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                _SectionTitle('Where students get stuck'),
                const SizedBox(height: AppSpacing.sm),
                BentoCard(
                  child: Column(
                    children: [
                      for (final p in ai.stuckPhrases)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.help_outline_rounded, size: 16, color: AppColors.energy),
                              const SizedBox(width: 8),
                              Expanded(child: Text('"$p"', style: AppTypography.ui(13, weight: FontWeight.w600))),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              if (ai.recentPrompts.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                _SectionTitle('Recent prompts'),
                const SizedBox(height: AppSpacing.sm),
                BentoCard(
                  child: Column(
                    children: [
                      for (final p in ai.recentPrompts)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Pill(text: p.feature, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(child: Text(p.label, style: AppTypography.ui(13, weight: FontWeight.w600))),
                              if (p.at != null)
                                Text(p.at!, style: AppTypography.ui(10.5, color: AppColors.ink4)),
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

class _QualityBar extends StatelessWidget {
  const _QualityBar(this.q);
  final AiQuality q;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(q.feature, style: AppTypography.ui(12.5, weight: FontWeight.w700))),
              Text('${(q.good * 100).round()}% good · ${(q.fallback * 100).round()}% fallback',
                  style: AppTypography.mono(11, color: AppColors.ink3)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: q.good.clamp(0, 1),
              minHeight: 7,
              backgroundColor: AppColors.line,
              color: AppColors.mint,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Settings — feature flags + admin team (FR-11.8)
// ---------------------------------------------------------------------------

class _SettingsTab extends StatefulWidget {
  const _SettingsTab();

  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<AdminCubit>();
    if (cubit.state.settingsStatus == ViewStatus.initial) cubit.loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AdminCubit>();
    return BlocConsumer<AdminCubit, AdminState>(
      listenWhen: (a, b) => a.error != b.error && b.error != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.error!)));
      },
      buildWhen: (a, b) =>
          a.settingsStatus != b.settingsStatus || a.settings != b.settings || a.savingFlag != b.savingFlag,
      builder: (context, state) {
        if (state.settingsStatus.isLoading || state.settingsStatus == ViewStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.settingsStatus.isFailure || state.settings == null) {
          return _ErrorState(
            message: state.error ?? 'Could not load settings',
            onRetry: cubit.loadSettings,
          );
        }
        final s = state.settings!;
        final flagKeys = s.flags.keys.toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, AppSpacing.xxl),
          children: [
            _SectionTitle('Feature flags'),
            Text('Toggles affect the live mobile app immediately.',
                style: AppTypography.ui(11.5, color: AppColors.ink3, weight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.sm),
            BentoCard(
              child: Column(
                children: [
                  for (var i = 0; i < flagKeys.length; i++)
                    _FlagRow(
                      flagKey: flagKeys[i],
                      value: s.flags[flagKeys[i]] ?? false,
                      saving: state.savingFlag == flagKeys[i],
                      divider: i != flagKeys.length - 1,
                      onChanged: () => cubit.toggleFlag(flagKeys[i]),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionTitle('Admin team'),
            const SizedBox(height: AppSpacing.sm),
            BentoCard(
              child: Column(
                children: [
                  for (final a in s.adminTeam)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primarySoft,
                            child: Text(a.email.isNotEmpty ? a.email[0].toUpperCase() : '?',
                                style: AppTypography.ui(12, color: AppColors.primaryDeep, weight: FontWeight.w800)),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(a.email,
                                style: AppTypography.ui(13, weight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          _Pill(text: a.role, color: a.role == 'owner' ? AppColors.primary : AppColors.energy),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FlagRow extends StatelessWidget {
  const _FlagRow({
    required this.flagKey,
    required this.value,
    required this.saving,
    required this.divider,
    required this.onChanged,
  });
  final String flagKey;
  final bool value;
  final bool saving;
  final bool divider;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final meta = AdminSettings.labels[flagKey];
    final label = meta?.$1 ?? flagKey;
    final desc = meta?.$2 ?? '';
    return Container(
      decoration: BoxDecoration(
        border: divider ? const Border(bottom: BorderSide(color: AppColors.line)) : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.ui(13.5, weight: FontWeight.w700)),
                if (desc.isNotEmpty)
                  Text(desc, style: AppTypography.ui(11.5, color: AppColors.ink3, weight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (saving)
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          else
            Switch(
              value: value,
              activeThumbColor: AppColors.primary,
              onChanged: (_) => onChanged(),
            ),
        ],
      ),
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

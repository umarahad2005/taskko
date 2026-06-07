import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../models/day_block.dart';
import '../../../models/mood.dart';
import '../../../models/task_item.dart';
import '../../../repositories/ai_tools_repository.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/bento_card.dart';

/// Arguments for the AI day planner (passed via go_router `extra`).
class PlanDayArgs {
  const PlanDayArgs({required this.tasks, required this.mood});
  final List<TaskItem> tasks;
  final Mood mood;
}

/// "Plan my day" — Gemini time-blocks today's tasks (M13).
class PlanDayScreen extends StatefulWidget {
  const PlanDayScreen({super.key, required this.args});
  final PlanDayArgs args;

  @override
  State<PlanDayScreen> createState() => _PlanDayScreenState();
}

class _PlanDayScreenState extends State<PlanDayScreen> {
  late Future<List<DayBlock>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<DayBlock>> _load() => context.read<AiToolsRepository>().planDay(
        tasks: widget.args.tasks,
        availableMinutes: 120,
        mood: widget.args.mood,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, 0),
                child: Row(children: [
                  IconButton(
                    onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
                  ),
                  Text('Your day, planned', style: AppTypography.ui(18, weight: FontWeight.w800)),
                ]),
              ),
              Expanded(
                child: FutureBuilder<List<DayBlock>>(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Text('Could not build a plan right now.',
                                style: AppTypography.ui(15, weight: FontWeight.w700), textAlign: TextAlign.center),
                            TextButton(onPressed: () => setState(() => _future = _load()), child: const Text('Retry')),
                          ]),
                        ),
                      );
                    }
                    final blocks = snap.data ?? const [];
                    if (blocks.isEmpty) {
                      return Center(
                        child: Text('Add some tasks first, then plan your day.',
                            style: AppTypography.ui(14, color: AppColors.ink3, weight: FontWeight.w500)),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, AppSpacing.xxl),
                      itemCount: blocks.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) => _BlockTile(block: blocks[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlockTile extends StatelessWidget {
  const _BlockTile({required this.block});
  final DayBlock block;

  @override
  Widget build(BuildContext context) {
    final isBreak = block.isBreak;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 92,
          child: Text('${block.start}–${block.end}',
              style: AppTypography.mono(12, color: AppColors.ink3)),
        ),
        Expanded(
          child: BentoCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: isBreak ? AppColors.mintSoft : AppColors.surface,
            child: Row(children: [
              Icon(isBreak ? Icons.coffee_rounded : Icons.bolt_rounded,
                  size: 16, color: isBreak ? AppColors.mint : AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(block.taskTitle,
                    style: AppTypography.ui(14, weight: FontWeight.w700)),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

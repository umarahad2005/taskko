import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../repositories/plan_repository.dart';
import '../../../repositories/tasks_repository.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/tab_scaffold.dart';
import '../../../widgets/tako_mascot.dart';
import '../cubit/plan_cubit.dart';
import '../widgets/plan_widgets.dart';

/// AI Plan Studio (SRS FR-5).
class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => PlanCubit(
        plan: ctx.read<PlanRepository>(),
        tasks: ctx.read<TasksRepository>(),
      ),
      child: const TabScaffold(currentTab: TaskkoTab.plan, body: _PlanBody()),
    );
  }
}

class _PlanBody extends StatefulWidget {
  const _PlanBody();

  @override
  State<_PlanBody> createState() => _PlanBodyState();
}

class _PlanBodyState extends State<_PlanBody> {
  final _goalCtrl = TextEditingController();

  @override
  void dispose() {
    _goalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlanCubit, PlanState>(
      listener: (context, state) {
        if (state.committed) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text('Added ${state.tasks.length} tasks to today 🎉')));
          context.go('/home');
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 18),
                const SizedBox(width: 6),
                Text('AI Plan Studio', style: AppTypography.ui(18, weight: FontWeight.w800)),
              ]),
              const SizedBox(height: AppSpacing.md),
              PlanStepIndicator(step: state.step),
              const SizedBox(height: AppSpacing.xl),
              Expanded(child: _phase(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _phase(BuildContext context, PlanState state) {
    switch (state.step) {
      case PlanStep.input:
        return _InputPhase(controller: _goalCtrl, error: state.error);
      case PlanStep.generating:
        return const _GeneratingPhase();
      case PlanStep.review:
        return _ReviewPhase(state: state);
    }
  }
}

class _InputPhase extends StatelessWidget {
  const _InputPhase({required this.controller, required this.error});
  final TextEditingController controller;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlanCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text("What's your goal?", style: AppTypography.display(26)),
        const SizedBox(height: 6),
        Text('Drop a big goal — Tako breaks it into bite-sized tasks.',
            style: AppTypography.ui(14, color: AppColors.ink3, weight: FontWeight.w500)),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: controller,
          minLines: 3,
          maxLines: 5,
          onChanged: cubit.updateGoal,
          decoration: const InputDecoration(hintText: 'e.g. Prep for CS-201 midterm by Friday'),
          style: AppTypography.ui(15, weight: FontWeight.w600),
        ),
        if (error != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(error!, style: AppTypography.ui(13, color: AppColors.rose, weight: FontWeight.w600)),
        ],
        const Spacer(),
        BlocBuilder<PlanCubit, PlanState>(
          buildWhen: (a, b) => a.goal != b.goal,
          builder: (context, state) => PrimaryButton(
            label: 'Break it down',
            icon: Icons.auto_awesome_rounded,
            onPressed: state.goal.trim().length < 3 ? null : cubit.generate,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

class _GeneratingPhase extends StatelessWidget {
  const _GeneratingPhase();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const TakoMascot(size: 72),
          const SizedBox(height: AppSpacing.xl),
          Text('Breaking it down…', style: AppTypography.display(20)),
          const SizedBox(height: 6),
          Text('Tako is shaping your plan', style: AppTypography.ui(13, color: AppColors.ink3, weight: FontWeight.w500)),
          const SizedBox(height: AppSpacing.xl),
          const SizedBox(
            width: 120,
            child: LinearProgressIndicator(minHeight: 4, backgroundColor: AppColors.line, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _ReviewPhase extends StatelessWidget {
  const _ReviewPhase({required this.state});
  final PlanState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlanCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('YOUR PLAN', style: AppTypography.ui(11, color: AppColors.ink3, weight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(state.goal, style: AppTypography.display(20)),
                ],
              ),
            ),
            _RegenButton(onTap: cubit.generate),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: ListView(
            children: [
              for (var i = 0; i < state.tasks.length; i++) ...[
                PlanTaskCard(
                  index: i,
                  task: state.tasks[i],
                  onEdit: () => showEditPlanTask(context, state.tasks[i],
                      (title, minutes, points) => cubit.editTask(state.tasks[i].id, title: title, minutes: minutes, points: points)),
                  onDelete: () => cubit.deleteTask(state.tasks[i].id),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              _AddTaskButton(onTap: cubit.addTask),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        PrimaryButton(
          label: 'Add ${state.tasks.length} tasks to today',
          icon: Icons.check_rounded,
          onPressed: state.tasks.isEmpty ? null : cubit.commit,
        ),
      ],
    );
  }
}

class _RegenButton extends StatelessWidget {
  const _RegenButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.pillRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: AppRadii.pillRadius,
            border: Border.all(color: AppColors.line2),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.refresh_rounded, size: 16, color: AppColors.ink2),
            const SizedBox(width: 4),
            Text('Regen', style: AppTypography.ui(13, color: AppColors.ink2, weight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}

class _AddTaskButton extends StatelessWidget {
  const _AddTaskButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.cardRadius,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: AppRadii.cardRadius,
          border: Border.all(color: AppColors.line2, style: BorderStyle.solid),
          color: AppColors.surface.withValues(alpha: 0.4),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.add_rounded, size: 18, color: AppColors.ink3),
          const SizedBox(width: 4),
          Text('Add a task', style: AppTypography.ui(14, color: AppColors.ink3, weight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

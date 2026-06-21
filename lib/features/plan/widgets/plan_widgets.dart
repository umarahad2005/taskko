import 'package:flutter/material.dart';

import '../../../models/plan_task.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/bento_card.dart';
import '../../../widgets/primary_button.dart';
import '../cubit/plan_cubit.dart';

/// Three-step progress header: Goal · Break down · Customize (SRS FR-5.1).
///
/// The flow has four states (input → clarify → generating → review) but only
/// three visible stages, so they're mapped on: input/clarify = Goal, generating
/// = Break down, review = Customize. The active bar is driven by an explicit
/// [AnimationController] — it fills left-to-right when a step settles and pulses
/// while Tako is working — so the header tracks the real work instead of jumping
/// straight to full.
class PlanStepIndicator extends StatefulWidget {
  const PlanStepIndicator({super.key, required this.step});
  final PlanStep step;

  @override
  State<PlanStepIndicator> createState() => _PlanStepIndicatorState();
}

class _PlanStepIndicatorState extends State<PlanStepIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 850));

  static const _labels = ['Goal', 'Break down', 'Customize'];

  int get _active => switch (widget.step) {
        PlanStep.input || PlanStep.clarify => 0,
        PlanStep.generating => 1,
        PlanStep.review => 2,
      };

  bool get _working => widget.step == PlanStep.generating;

  @override
  void initState() {
    super.initState();
    _drive();
  }

  @override
  void didUpdateWidget(PlanStepIndicator old) {
    super.didUpdateWidget(old);
    if (old.step != widget.step) _drive();
  }

  /// While Tako is working, the active bar pulses (indeterminate); on a settled
  /// step it fills once, left to right, then holds.
  void _drive() {
    if (_working) {
      _c.repeat(reverse: true);
    } else {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = _active;
    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StepBar(
                  controller: _c,
                  done: i < active,
                  active: i == active,
                  working: i == active && _working,
                ),
                const SizedBox(height: 6),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: AppTypography.ui(11,
                      color: i <= active ? AppColors.primaryDeep : AppColors.ink4,
                      weight: FontWeight.w700),
                  child: Text(_labels[i]),
                ),
              ],
            ),
          ),
          if (i < 2) const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

/// One segment of [PlanStepIndicator]. Past stages are solid; the active stage
/// animates its fill from the shared [controller].
class _StepBar extends StatelessWidget {
  const _StepBar({
    required this.controller,
    required this.done,
    required this.active,
    required this.working,
  });

  final AnimationController controller;
  final bool done;
  final bool active;
  final bool working;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: SizedBox(
        height: 4,
        child: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: AppColors.line2)),
            if (done)
              const Positioned.fill(child: ColoredBox(color: AppColors.primary))
            else if (active)
              AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  // Working: oscillate 25%→100% (pulse). Settled: fill 0→100% once.
                  final fill = working ? 0.25 + controller.value * 0.75 : controller.value;
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: fill.clamp(0.0, 1.0),
                      heightFactor: 1,
                      child: const ColoredBox(color: AppColors.primary),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// One editable task row in the review step (SRS FR-5.5).
class PlanTaskCard extends StatelessWidget {
  const PlanTaskCard({
    super.key,
    required this.index,
    required this.task,
    required this.onEdit,
    required this.onDelete,
  });

  final int index;
  final PlanTask task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(10)),
            child: Text('${index + 1}', style: AppTypography.ui(14, color: AppColors.primaryDeep, weight: FontWeight.w800)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: AppTypography.ui(15, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('⏱ ${task.minutes}m   +${task.points} pts',
                    style: AppTypography.mono(12, color: AppColors.primaryDeep)),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.ink3),
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.ink3),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

/// Bottom-sheet editor for a single plan task (SRS FR-5.5).
Future<void> showEditPlanTask(
  BuildContext context,
  PlanTask task,
  void Function(String title, int minutes, int points) onSave,
) {
  final titleCtrl = TextEditingController(text: task.title);
  final minCtrl = TextEditingController(text: '${task.minutes}');
  final ptsCtrl = TextEditingController(text: '${task.points}');

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
    ),
    builder: (sheetCtx) => Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
        bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edit task', style: AppTypography.display(20)),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: titleCtrl,
            decoration: const InputDecoration(hintText: 'Task title'),
            style: AppTypography.ui(15, weight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            Expanded(
              child: TextField(
                controller: minCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Minutes'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextField(
                controller: ptsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Points'),
              ),
            ),
          ]),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: 'Save',
            onPressed: () {
              final title = titleCtrl.text.trim().isEmpty ? task.title : titleCtrl.text.trim();
              final minutes = int.tryParse(minCtrl.text) ?? task.minutes;
              final points = int.tryParse(ptsCtrl.text) ?? task.points;
              onSave(title, minutes, points);
              Navigator.of(sheetCtx).pop();
            },
          ),
        ],
      ),
    ),
  );
}

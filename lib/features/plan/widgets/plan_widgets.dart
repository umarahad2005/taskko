import 'package:flutter/material.dart';

import '../../../models/plan_task.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/bento_card.dart';
import '../../../widgets/primary_button.dart';
import '../cubit/plan_cubit.dart';

/// Three-step progress header: Goal · Break down · Customize (SRS FR-5.1).
class PlanStepIndicator extends StatelessWidget {
  const PlanStepIndicator({super.key, required this.step});
  final PlanStep step;

  static const _labels = ['Goal', 'Break down', 'Customize'];

  @override
  Widget build(BuildContext context) {
    final current = step.index;
    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= current ? AppColors.primary : AppColors.line2,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _labels[i],
                  style: AppTypography.ui(11,
                      color: i <= current ? AppColors.primaryDeep : AppColors.ink4, weight: FontWeight.w700),
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

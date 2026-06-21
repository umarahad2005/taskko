import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../models/clarify_question.dart';
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
            ..showSnackBar(SnackBar(
              duration: const Duration(seconds: 2),
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.mint, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text('Added ${state.tasks.length} tasks to today 🎉')),
                ],
              ),
            ));
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
      case PlanStep.clarify:
        return _ClarifyPhase(state: state);
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
        const SizedBox(height: AppSpacing.md),
        const _OrDivider(),
        const SizedBox(height: AppSpacing.md),
        _ScanPhotoButton(onTap: () => _pickAndScan(context)),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  /// Let the student pick a source, then snap/choose a photo of their syllabus,
  /// notes or whiteboard and hand the (compressed) image to the cubit to turn
  /// into tasks. The cubit drives the generating → review flow from here.
  Future<void> _pickAndScan(BuildContext context) async {
    final cubit = context.read<PlanCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final source = await _chooseSource(context);
    if (source == null) return;

    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 70,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      final base64 = base64Encode(bytes);
      cubit.generateFromImage(base64, _mimeFor(file));
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text("Couldn't open the photo. Please try again.")));
    }
  }

  /// Bottom sheet to choose Camera vs Gallery; returns null if dismissed.
  Future<ImageSource?> _chooseSource(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            Text('Scan a photo into tasks', style: AppTypography.ui(15, weight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Snap a syllabus, assignment sheet or whiteboard.',
                style: AppTypography.ui(13, color: AppColors.ink3, weight: FontWeight.w500)),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded, color: AppColors.primary),
              title: Text('Take a photo', style: AppTypography.ui(15, weight: FontWeight.w700)),
              onTap: () => Navigator.pop(sheetCtx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              title: Text('Choose from gallery', style: AppTypography.ui(15, weight: FontWeight.w700)),
              onTap: () => Navigator.pop(sheetCtx, ImageSource.gallery),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  String _mimeFor(XFile file) {
    final declared = file.mimeType;
    if (declared != null && declared.isNotEmpty) return declared;
    final name = file.name.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    if (name.endsWith('.heic') || name.endsWith('.heif')) return 'image/heic';
    return 'image/jpeg';
  }
}

/// "or" separator between the type-a-goal and scan-a-photo entry points.
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.line2)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text('or', style: AppTypography.ui(12, color: AppColors.ink3, weight: FontWeight.w700)),
        ),
        const Expanded(child: Divider(color: AppColors.line2)),
      ],
    );
  }
}

/// Secondary CTA that opens the camera/gallery picker to scan tasks from a photo.
class _ScanPhotoButton extends StatelessWidget {
  const _ScanPhotoButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.cardRadius,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: AppRadii.cardRadius,
          color: AppColors.surface,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.document_scanner_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('Scan a photo',
              style: AppTypography.ui(15, color: AppColors.primary, weight: FontWeight.w800)),
        ]),
      ),
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
            _RegenButton(onTap: cubit.regenerate),
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

/// Step between goal and breakdown: Tako's clarifying questions (SRS FR-5.2).
class _ClarifyPhase extends StatelessWidget {
  const _ClarifyPhase({required this.state});
  final PlanState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlanCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('A few quick questions', style: AppTypography.display(24)),
        const SizedBox(height: 4),
        Text('So Tako can tailor your plan to exactly what you need.',
            style: AppTypography.ui(14, color: AppColors.ink3, weight: FontWeight.w500)),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: ListView.separated(
            itemCount: state.questions.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
            itemBuilder: (context, i) {
              final q = state.questions[i];
              return _ClarifyQuestionTile(
                key: ValueKey(q.question),
                question: q,
                answer: state.answers[q.question],
                onAnswer: (v) => cubit.answerQuestion(q.question, v),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        PrimaryButton(label: 'Generate my plan', icon: Icons.auto_awesome_rounded, onPressed: cubit.submitClarify),
        const SizedBox(height: 6),
        Center(
          child: TextButton(
            onPressed: cubit.skipClarify,
            child: Text('Skip — just use my goal',
                style: AppTypography.ui(13, color: AppColors.ink3, weight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}

/// One clarifying question: option chips plus an "Other…" escape hatch that
/// reveals a free-text field, so the student can answer manually when none of
/// Tako's options fit (SRS FR-5.2). Questions with no options are text-only.
class _ClarifyQuestionTile extends StatefulWidget {
  const _ClarifyQuestionTile({
    super.key,
    required this.question,
    required this.answer,
    required this.onAnswer,
  });

  final ClarifyQuestion question;
  final String? answer;
  final ValueChanged<String> onAnswer;

  @override
  State<_ClarifyQuestionTile> createState() => _ClarifyQuestionTileState();
}

class _ClarifyQuestionTileState extends State<_ClarifyQuestionTile> {
  late final TextEditingController _custom;
  final FocusNode _focus = FocusNode();
  late bool _customMode;

  @override
  void initState() {
    super.initState();
    final ans = widget.answer;
    // Pre-select "Other" if a previous answer was typed (not one of the options),
    // or if the question has no options to choose from.
    final isCustom = ans != null && ans.isNotEmpty && !widget.question.options.contains(ans);
    _customMode = widget.question.options.isEmpty || isCustom;
    _custom = TextEditingController(text: isCustom ? ans : '');
  }

  @override
  void dispose() {
    _custom.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _selectOption(String option) {
    setState(() => _customMode = false);
    widget.onAnswer(option);
  }

  void _enterCustomMode() {
    setState(() => _customMode = true);
    final text = _custom.text.trim();
    if (text.isNotEmpty) widget.onAnswer(text);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final hasOptions = q.options.isNotEmpty;
    final selected = widget.answer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(q.question, style: AppTypography.ui(15, weight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.sm),
        if (hasOptions)
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final o in q.options)
                _ClarifyChip(
                  label: o,
                  selected: !_customMode && selected == o,
                  onTap: () => _selectOption(o),
                ),
              _ClarifyChip(
                label: 'Other…',
                icon: Icons.edit_rounded,
                selected: _customMode,
                onTap: _enterCustomMode,
              ),
            ],
          ),
        if (_customMode) ...[
          if (hasOptions) const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _custom,
            focusNode: _focus,
            decoration: InputDecoration(
              hintText: hasOptions ? 'Type your own answer' : 'Your answer',
            ),
            onChanged: (v) => widget.onAnswer(v.trim()),
          ),
        ],
      ],
    );
  }
}

class _ClarifyChip extends StatelessWidget {
  const _ClarifyChip({required this.label, required this.selected, required this.onTap, this.icon});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.ink2;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: AppRadii.pillRadius,
          border: Border.all(color: selected ? AppColors.primary : AppColors.line2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 4),
            ],
            Text(label, style: AppTypography.ui(13, color: fg, weight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

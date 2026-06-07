import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../models/quiz_question.dart';
import '../../../repositories/ai_tools_repository.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/bento_card.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/tako_mascot.dart';
import '../cubit/quiz_cubit.dart';

/// AI Quiz generator (M13).
class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => QuizCubit(ctx.read<AiToolsRepository>()),
      child: const _QuizView(),
    );
  }
}

class _QuizView extends StatelessWidget {
  const _QuizView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            child: BlocBuilder<QuizCubit, QuizState>(
              builder: (context, state) {
                return switch (state.step) {
                  QuizStep.input => _InputPhase(error: state.error),
                  QuizStep.loading => const _Loading(),
                  QuizStep.taking => _TakingPhase(state: state),
                  QuizStep.result => _ResultPhase(state: state),
                };
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _InputPhase extends StatefulWidget {
  const _InputPhase({required this.error});
  final String? error;

  @override
  State<_InputPhase> createState() => _InputPhaseState();
}

class _InputPhaseState extends State<_InputPhase> {
  final _ctrl = TextEditingController();
  int _count = 5;
  String _difficulty = 'medium';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<QuizCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          IconButton(
            onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
            icon: const Icon(Icons.close_rounded, color: AppColors.ink),
          ),
          Text('Quiz me', style: AppTypography.ui(18, weight: FontWeight.w800)),
        ]),
        const SizedBox(height: AppSpacing.lg),
        Text('What do you want to be quizzed on?', style: AppTypography.display(24)),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _ctrl,
          onChanged: cubit.setTopic,
          decoration: const InputDecoration(hintText: 'e.g. Binary search trees'),
          style: AppTypography.ui(15, weight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('QUESTIONS', style: AppTypography.ui(11, color: AppColors.ink3, weight: FontWeight.w800)),
        const SizedBox(height: AppSpacing.sm),
        Wrap(spacing: AppSpacing.sm, children: [
          for (final c in [3, 5, 10])
            _Chip(label: '$c', selected: _count == c, onTap: () => setState(() => _count = c)),
        ]),
        const SizedBox(height: AppSpacing.lg),
        Text('DIFFICULTY', style: AppTypography.ui(11, color: AppColors.ink3, weight: FontWeight.w800)),
        const SizedBox(height: AppSpacing.sm),
        Wrap(spacing: AppSpacing.sm, children: [
          for (final d in ['easy', 'medium', 'hard'])
            _Chip(label: d, selected: _difficulty == d, onTap: () => setState(() => _difficulty = d)),
        ]),
        if (widget.error != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(widget.error!, style: AppTypography.ui(13, color: AppColors.rose, weight: FontWeight.w600)),
        ],
        const Spacer(),
        PrimaryButton(
          label: 'Generate quiz',
          icon: Icons.auto_awesome_rounded,
          onPressed: () => cubit.generate(count: _count, difficulty: _difficulty),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const TakoMascot(size: 72),
        const SizedBox(height: AppSpacing.xl),
        Text('Writing your quiz…', style: AppTypography.display(20)),
      ]),
    );
  }
}

class _TakingPhase extends StatelessWidget {
  const _TakingPhase({required this.state});
  final QuizState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<QuizCubit>();
    final q = state.current!;
    final picked = state.selected[state.currentIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Question ${state.currentIndex + 1} of ${state.questions.length}',
            style: AppTypography.ui(12, color: AppColors.ink3, weight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: (state.currentIndex + 1) / state.questions.length,
            minHeight: 6,
            backgroundColor: AppColors.line,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(q.question, style: AppTypography.display(22)),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: ListView(
            children: [
              for (var i = 0; i < q.options.length; i++) ...[
                _OptionTile(text: q.options[i], selected: picked == i, onTap: () => cubit.select(i)),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        ),
        PrimaryButton(
          label: state.isLast ? 'See results' : 'Next',
          onPressed: picked == null ? null : cubit.next,
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

class _ResultPhase extends StatelessWidget {
  const _ResultPhase({required this.state});
  final QuizState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<QuizCubit>();
    final total = state.questions.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.md),
        Center(child: Text('${state.score}/$total', style: AppTypography.display(44, color: AppColors.primaryDeep))),
        Center(child: Text('You scored ${((state.score / total) * 100).round()}%',
            style: AppTypography.ui(14, color: AppColors.ink3, weight: FontWeight.w600))),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: ListView(
            children: [
              for (var i = 0; i < total; i++) ...[
                _ReviewTile(
                  index: i,
                  question: state.questions[i],
                  picked: i < state.selected.length ? state.selected[i] : null,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        ),
        PrimaryButton(label: 'New quiz', icon: Icons.refresh_rounded, onPressed: cubit.restart),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.text, required this.selected, required this.onTap});
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: AppRadii.cardRadius,
          border: Border.all(color: selected ? AppColors.primary : AppColors.line2, width: selected ? 1.6 : 1),
        ),
        child: Text(text, style: AppTypography.ui(15, weight: FontWeight.w600)),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.index, required this.question, required this.picked});
  final int index;
  final QuizQuestion question;
  final int? picked;

  @override
  Widget build(BuildContext context) {
    final correct = picked == question.answerIndex;
    return BentoCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: correct ? AppColors.mint : AppColors.rose, size: 18),
            const SizedBox(width: 6),
            Expanded(child: Text(question.question, style: AppTypography.ui(14, weight: FontWeight.w700))),
          ]),
          const SizedBox(height: 4),
          Text('Answer: ${question.options[question.answerIndex]}',
              style: AppTypography.ui(13, color: AppColors.mint, weight: FontWeight.w700)),
          if (!correct && picked != null)
            Text('You picked: ${question.options[picked!]}',
                style: AppTypography.ui(12, color: AppColors.ink3, weight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: AppRadii.pillRadius,
          border: Border.all(color: selected ? AppColors.primary : AppColors.line2),
        ),
        child: Text(label,
            style: AppTypography.ui(13, color: selected ? Colors.white : AppColors.ink2, weight: FontWeight.w700)),
      ),
    );
  }
}

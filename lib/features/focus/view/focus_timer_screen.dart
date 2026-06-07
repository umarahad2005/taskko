import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../models/mood.dart';
import '../../../models/task_item.dart';
import '../../../repositories/session_repository.dart';
import '../../../services/joke_service.dart';
import '../../../services/music_service.dart';
import '../../../services/notification_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/bento_card.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/secondary_button.dart';

/// Arguments for the focus timer (passed via go_router `extra`).
class FocusArgs {
  const FocusArgs({required this.task, required this.mood});
  final TaskItem task;
  final Mood mood;
}

enum _Phase { setup, running, done }

/// Focus session (SRS FR-4.5 / FR-10): pick a duration, run a live countdown,
/// then on completion fire a system + in-app notification, play mood music,
/// and surface a joke to refresh the user. Returns `true` if the user marks the
/// task done.
class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key, required this.args});
  final FocusArgs args;

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  static const _options = [1, 10, 15, 20, 25, 45]; // 1 = quick test

  _Phase _phase = _Phase.setup;
  late int _minutes = widget.args.task.minutes.clamp(5, 90);
  int _remaining = 0;
  int _total = 1;
  bool _paused = false;
  Timer? _timer;
  String _joke = '';
  int? _rating;

  @override
  void dispose() {
    _timer?.cancel();
    MusicService.instance.stop();
    super.dispose();
  }

  void _start() {
    _total = _minutes * 60;
    _remaining = _total;
    _phase = _Phase.running;
    _paused = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_paused) return;
      if (_remaining <= 1) {
        t.cancel();
        _complete();
      } else {
        setState(() => _remaining--);
      }
    });
    setState(() {});
  }

  Future<void> _complete() async {
    _timer?.cancel();
    setState(() {
      _remaining = 0;
      _phase = _Phase.done;
    });
    await NotificationService.instance.show(
      'Focus session complete 🎉',
      'Nice work on "${widget.args.task.title}". Take a refreshing break!',
    );
    await MusicService.instance.playForMood(widget.args.mood);
    final joke = await JokeService.random();
    if (mounted) setState(() => _joke = joke);
  }

  Future<void> _finish(bool markDone) async {
    final sessions = context.read<SessionRepository>();
    await MusicService.instance.stop();
    try {
      await sessions.logSession(
        taskTitle: widget.args.task.title,
        minutes: _minutes,
        mood: widget.args.mood,
        rating: _rating,
      );
    } catch (_) {}
    if (mounted) context.pop(markDone);
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            child: switch (_phase) {
              _Phase.setup => _setup(),
              _Phase.running => _running(),
              _Phase.done => _done(),
            },
          ),
        ),
      ),
    );
  }

  Widget _setup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          IconButton(
            onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
            icon: const Icon(Icons.close_rounded, color: AppColors.ink),
          ),
          Text('Focus session', style: AppTypography.ui(18, weight: FontWeight.w800)),
        ]),
        const Spacer(),
        Text('NEXT UP', style: AppTypography.ui(11, color: AppColors.primary, weight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(widget.args.task.title, style: AppTypography.display(26)),
        const SizedBox(height: AppSpacing.xl),
        Text('How long do you want to focus?',
            style: AppTypography.ui(14, color: AppColors.ink3, weight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final m in {..._options, _minutes}.toList()..sort())
              _DurationChip(minutes: m, selected: m == _minutes, onTap: () => setState(() => _minutes = m)),
          ],
        ),
        const Spacer(),
        PrimaryButton(label: 'Start now', icon: Icons.play_arrow_rounded, onPressed: _start),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  Widget _running() {
    final progress = _total == 0 ? 0.0 : 1 - (_remaining / _total);
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(widget.args.task.title,
              maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTypography.ui(16, weight: FontWeight.w700)),
        ),
        const Spacer(),
        SizedBox(
          width: 240,
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 240,
                height: 240,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  backgroundColor: AppColors.line,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_fmt(_remaining), style: AppTypography.mono(48, color: AppColors.ink)),
                  Text(_paused ? 'paused' : 'stay with it',
                      style: AppTypography.ui(13, color: AppColors.ink3, weight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        Row(children: [
          Expanded(
            child: SecondaryButton(
              label: _paused ? 'Resume' : 'Pause',
              filled: true,
              onPressed: () => setState(() => _paused = !_paused),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: SecondaryButton(
              label: 'Give up',
              color: AppColors.rose,
              onPressed: () => context.canPop() ? context.pop(false) : context.go('/home'),
            ),
          ),
        ]),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  Widget _done() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        const Icon(Icons.celebration_rounded, color: AppColors.mint, size: 56),
        const SizedBox(height: AppSpacing.md),
        Text('Session complete!', textAlign: TextAlign.center, style: AppTypography.display(28)),
        const SizedBox(height: 4),
        Text('Mind-refresh music is playing 🎶 Take a breather.',
            textAlign: TextAlign.center,
            style: AppTypography.ui(14, color: AppColors.ink3, weight: FontWeight.w500)),
        const SizedBox(height: AppSpacing.xl),
        BentoCard(
          color: AppColors.goldSoft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Text('😄', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text('A joke to refresh you',
                    style: AppTypography.ui(12, color: AppColors.ink2, weight: FontWeight.w800)),
              ]),
              const SizedBox(height: AppSpacing.sm),
              Text(_joke.isEmpty ? 'Loading a joke…' : _joke,
                  style: AppTypography.ui(15, weight: FontWeight.w500, height: 1.4)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('How did that go?',
            textAlign: TextAlign.center,
            style: AppTypography.ui(13, color: AppColors.ink3, weight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final e in const [(1, '😫'), (2, '😐'), (3, '😀')]) ...[
              _ReflectChip(emoji: e.$2, selected: _rating == e.$1, onTap: () => setState(() => _rating = e.$1)),
              const SizedBox(width: AppSpacing.md),
            ],
          ],
        ),
        const Spacer(),
        PrimaryButton(
          label: 'Mark "${_short(widget.args.task.title)}" done  +${widget.args.task.points}',
          icon: Icons.check_rounded,
          onPressed: () => _finish(true),
        ),
        const SizedBox(height: AppSpacing.sm),
        SecondaryButton(label: 'Not yet — just stop the music', onPressed: () => _finish(false)),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  String _short(String s) => s.length <= 18 ? s : '${s.substring(0, 17)}…';
}

class _ReflectChip extends StatelessWidget {
  const _ReflectChip({required this.emoji, required this.selected, required this.onTap});
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: selected ? AppColors.primary : AppColors.line2, width: selected ? 2 : 1),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({required this.minutes, required this.selected, required this.onTap});
  final int minutes;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: AppRadii.pillRadius,
          border: Border.all(color: selected ? AppColors.primary : AppColors.line2),
        ),
        child: Text('$minutes min',
            style: AppTypography.ui(14,
                color: selected ? Colors.white : AppColors.ink2, weight: FontWeight.w700)),
      ),
    );
  }
}

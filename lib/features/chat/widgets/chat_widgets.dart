import 'package:flutter/material.dart';

import '../../../models/chat_message.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/tako_mascot.dart';

/// A chat bubble: user (right, gradient) or Tako (left, white) — plus the
/// special nudge variant with action buttons (SRS FR-7.1/7.5).
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message, required this.onAction});
  final ChatMessage message;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final isMe = message.from == ChatSender.me;
    if (message.kind == ChatKind.nudge) return _NudgeCard(message: message, onAction: onAction);

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: isMe ? AppColors.primaryGradient : null,
        color: isMe ? null : AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppRadii.lg),
          topRight: const Radius.circular(AppRadii.lg),
          bottomLeft: Radius.circular(isMe ? AppRadii.lg : 6),
          bottomRight: Radius.circular(isMe ? 6 : AppRadii.lg),
        ),
      ),
      child: Text(
        message.text,
        style: AppTypography.ui(14, color: isMe ? Colors.white : AppColors.ink, weight: FontWeight.w500, height: 1.4),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[const TakoMascot(size: 26), const SizedBox(width: AppSpacing.sm)],
          Flexible(child: bubble),
        ],
      ),
    );
  }
}

class _NudgeCard extends StatelessWidget {
  const _NudgeCard({required this.message, required this.onAction});
  final ChatMessage message;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const TakoMascot(size: 26),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.bolt_rounded, size: 14, color: AppColors.primaryDeep),
                    const SizedBox(width: 4),
                    Text('NUDGE', style: AppTypography.ui(10, color: AppColors.primaryDeep, weight: FontWeight.w800)),
                  ]),
                  const SizedBox(height: 6),
                  Text(message.text, style: AppTypography.ui(14, weight: FontWeight.w600, height: 1.4)),
                  if (message.actions.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final a in message.actions)
                          GestureDetector(
                            onTap: () => onAction(a),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 9),
                              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: AppRadii.pillRadius),
                              child: Text(a, style: AppTypography.ui(13, color: Colors.white, weight: FontWeight.w700)),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated three-dot typing indicator (SRS FR-7.3).
class TypingBubble extends StatefulWidget {
  const TypingBubble({super.key});

  @override
  State<TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<TypingBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(children: [
        const TakoMascot(size: 26),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++) ...[
                  _dot(i),
                  if (i < 2) const SizedBox(width: 5),
                ],
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _dot(int i) {
    final t = (_c.value + i * 0.2) % 1.0;
    final opacity = 0.3 + 0.7 * (t < 0.5 ? t * 2 : (1 - t) * 2);
    return Opacity(
      opacity: opacity.clamp(0.3, 1.0),
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(color: AppColors.ink4, shape: BoxShape.circle),
      ),
    );
  }
}

/// Horizontal quick-prompt chips (SRS FR-7.4).
class QuickPromptChips extends StatelessWidget {
  const QuickPromptChips({super.key, required this.onTap});
  final ValueChanged<String> onTap;

  static const prompts = ["I'm stuck", 'Plan my evening', 'Motivate me', 'I want a break'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        children: [
          for (final p in prompts) ...[
            GestureDetector(
              onTap: () => onTap(p),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.pillRadius,
                  border: Border.all(color: AppColors.line2),
                ),
                child: Text(p, style: AppTypography.ui(13, color: AppColors.ink2, weight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

/// Bottom input bar with a send button (SRS FR-7.1).
class ChatInputBar extends StatelessWidget {
  const ChatInputBar({super.key, required this.controller, required this.onSend});
  final TextEditingController controller;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    void submit() {
      final text = controller.text;
      if (text.trim().isEmpty) return;
      onSend(text);
      controller.clear();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => submit(),
              decoration: InputDecoration(
                hintText: 'Message Tako…',
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                border: OutlineInputBorder(borderRadius: AppRadii.pillRadius, borderSide: const BorderSide(color: AppColors.line2)),
                enabledBorder: OutlineInputBorder(borderRadius: AppRadii.pillRadius, borderSide: const BorderSide(color: AppColors.line2)),
                focusedBorder: OutlineInputBorder(borderRadius: AppRadii.pillRadius, borderSide: const BorderSide(color: AppColors.primary, width: 1.6)),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: submit,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

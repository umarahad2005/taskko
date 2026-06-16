import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/view_status.dart';
import '../../../repositories/chat_history_repository.dart';
import '../../../repositories/chat_repository.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/tab_scaffold.dart';
import '../../../widgets/tako_mascot.dart';
import '../cubit/chat_cubit.dart';
import '../widgets/chat_widgets.dart';

/// Tako AI chat (SRS FR-7).
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => ChatCubit(
        ctx.read<ChatRepository>(),
        history: ctx.read<ChatHistoryRepository>(),
      )..load(),
      child: const TabScaffold(currentTab: TaskkoTab.tako, body: _ChatBody()),
    );
  }
}

class _ChatBody extends StatefulWidget {
  const _ChatBody();

  @override
  State<_ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<_ChatBody> {
  final _scroll = ScrollController();
  final _input = TextEditingController();

  @override
  void dispose() {
    _scroll.dispose();
    _input.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatCubit>();
    return Column(
      children: [
        const _ChatHeader(),
        Expanded(
          child: BlocConsumer<ChatCubit, ChatState>(
            listener: (_, _) => _scrollToBottom(),
            builder: (context, state) {
              if (state.status != ViewStatus.success) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, AppSpacing.md),
                children: [
                  for (final m in state.messages)
                    ChatBubble(message: m, onAction: (a) => _onNudge(context, a)),
                  if (state.isTyping) const TypingBubble(),
                ],
              );
            },
          ),
        ),
        QuickPromptChips(onTap: cubit.send),
        const SizedBox(height: AppSpacing.sm),
        ChatInputBar(controller: _input, onSend: cubit.send),
      ],
    );
  }

  void _onNudge(BuildContext context, String action) {
    final msg = action.toLowerCase().contains('start')
        ? 'Starting a focus session — go get it.'
        : "Okay, I'll nudge you again later.";
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, AppSpacing.md),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          const TakoMascot(size: 34),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('Tako', style: AppTypography.ui(17, weight: FontWeight.w800)),
                  const SizedBox(width: 6),
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.mint, shape: BoxShape.circle)),
                ]),
                Text('Your AI study buddy · focused mode',
                    style: AppTypography.ui(12, color: AppColors.ink3, weight: FontWeight.w500)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Chat history',
            icon: const Icon(Icons.more_horiz_rounded, color: AppColors.ink3),
            onPressed: () => _openHistory(context),
          ),
        ],
      ),
    );
  }
}

/// Open the chat history menu: start a new chat or reopen a past session.
void _openHistory(BuildContext context) {
  final cubit = context.read<ChatCubit>();
  cubit.refreshSessions();
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
    ),
    builder: (_) => BlocProvider<ChatCubit>.value(value: cubit, child: const _ChatHistorySheet()),
  );
}

class _ChatHistorySheet extends StatelessWidget {
  const _ChatHistorySheet();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatCubit>();
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.md),
        child: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text('Chats', style: AppTypography.ui(16, weight: FontWeight.w800)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        cubit.newChat();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('New chat'),
                    ),
                  ],
                ),
                const Divider(height: 1),
                if (state.sessions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Text(
                      'No past chats yet — start talking to Tako!',
                      textAlign: TextAlign.center,
                      style: AppTypography.ui(13, color: AppColors.ink3, weight: FontWeight.w500),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: state.sessions.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final s = state.sessions[i];
                        final selected = s.id == state.currentSessionId;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: selected ? AppColors.primary : AppColors.primarySoft,
                            child: Icon(Icons.chat_bubble_outline_rounded,
                                size: 16, color: selected ? Colors.white : AppColors.primaryDeep),
                          ),
                          title: Text(s.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.ui(14, weight: FontWeight.w700)),
                          subtitle: Text(s.preview,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.ui(12, color: AppColors.ink3)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.ink4),
                            onPressed: () => cubit.deleteSession(s.id),
                          ),
                          onTap: () {
                            cubit.openSession(s.id);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

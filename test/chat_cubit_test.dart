import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/common/view_status.dart';
import 'package:project/features/chat/cubit/chat_cubit.dart';
import 'package:project/models/chat_message.dart';
import 'package:project/repositories/mock/chat_repository_mock.dart';

void main() {
  group('ChatCubit (SRS FR-7)', () {
    blocTest<ChatCubit, ChatState>(
      'load fetches the conversation history',
      build: () => ChatCubit(ChatRepositoryMock()),
      act: (c) => c.load(),
      verify: (c) {
        expect(c.state.status, ViewStatus.success);
        expect(c.state.messages, isNotEmpty);
      },
    );

    blocTest<ChatCubit, ChatState>(
      'send appends the user message then a Tako reply, clearing typing (FR-7.2/7.3)',
      build: () => ChatCubit(ChatRepositoryMock()),
      act: (c) async {
        await c.load();
        await c.send('Can you motivate me?');
      },
      verify: (c) {
        expect(c.state.isTyping, isFalse);
        expect(c.state.messages[c.state.messages.length - 2].from, ChatSender.me);
        expect(c.state.messages.last.from, ChatSender.tako);
      },
    );
  });
}

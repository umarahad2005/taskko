import 'package:flutter_test/flutter_test.dart';
import 'package:project/common/view_status.dart';
import 'package:project/features/history/cubit/history_cubit.dart';
import 'package:project/models/mood.dart';
import 'package:project/repositories/mock/session_repository_mock.dart';

void main() {
  group('HistoryCubit (SRS FR-10.3)', () {
    test('load aggregates real session data', () async {
      final repo = SessionRepositoryMock();
      await repo.logSession(taskTitle: 'Read notes', minutes: 25, mood: Mood.focused, rating: 3);
      await repo.logSession(taskTitle: 'Practice', minutes: 15, mood: Mood.chill);

      final cubit = HistoryCubit(repo);
      await cubit.load();

      expect(cubit.state.status, ViewStatus.success);
      expect(cubit.state.sessionCount, 2);
      expect(cubit.state.totalMinutes, 40);
      expect(cubit.state.last7Minutes.length, 7);
      expect(cubit.state.last7Minutes.last, 40); // both logged today
    });
  });
}

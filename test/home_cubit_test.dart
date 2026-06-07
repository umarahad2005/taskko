import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/common/view_status.dart';
import 'package:project/features/home/cubit/home_cubit.dart';
import 'package:project/repositories/mock/gamification_repository_mock.dart';
import 'package:project/repositories/mock/tasks_repository_mock.dart';

void main() {
  HomeCubit build() => HomeCubit(
        gamification: GamificationRepositoryMock(),
        tasks: TasksRepositoryMock(),
      );

  group('HomeCubit (SRS FR-4)', () {
    blocTest<HomeCubit, HomeState>(
      'load emits loading then success with the seeded dashboard',
      build: build,
      act: (c) => c.load(),
      expect: () => [
        isA<HomeState>().having((s) => s.status, 'status', ViewStatus.loading),
        isA<HomeState>()
            .having((s) => s.status, 'status', ViewStatus.success)
            .having((s) => s.total, 'total', 5)
            .having((s) => s.doneCount, 'doneCount', 2),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'completing a task awards its points and marks it done (FR-4.7/FR-8.1)',
      build: build,
      act: (c) async {
        await c.load();
        await c.toggleTask('t3'); // 30 pts, initially not done
      },
      verify: (c) {
        expect(c.state.user!.points, 1240 + 30);
        expect(c.state.tasks.firstWhere((t) => t.id == 't3').done, isTrue);
        expect(c.state.doneCount, 3);
      },
    );
  });
}

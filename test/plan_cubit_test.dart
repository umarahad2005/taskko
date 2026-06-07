import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/features/plan/cubit/plan_cubit.dart';
import 'package:project/repositories/mock/plan_repository_mock.dart';
import 'package:project/repositories/mock/tasks_repository_mock.dart';

void main() {
  group('PlanCubit (SRS FR-5)', () {
    blocTest<PlanCubit, PlanState>(
      'generates an editable plan from a valid goal (FR-5.3)',
      build: () => PlanCubit(plan: PlanRepositoryMock(), tasks: TasksRepositoryMock()),
      act: (c) async {
        c.updateGoal('Prep for CS-201 midterm by Friday');
        await c.generate();
      },
      verify: (c) {
        expect(c.state.step, PlanStep.review);
        expect(c.state.tasks.length, 6);
      },
    );

    blocTest<PlanCubit, PlanState>(
      'rejects a too-short goal without generating (FR-5.2 constraints)',
      build: () => PlanCubit(plan: PlanRepositoryMock(), tasks: TasksRepositoryMock()),
      act: (c) async {
        c.updateGoal('a');
        await c.generate();
      },
      verify: (c) {
        expect(c.state.step, PlanStep.input);
        expect(c.state.error, isNotNull);
      },
    );

    test('commit adds the plan tasks into today (FR-5.6)', () async {
      final tasksRepo = TasksRepositoryMock();
      final cubit = PlanCubit(plan: PlanRepositoryMock(), tasks: tasksRepo);
      cubit.updateGoal('Prep for CS-201 midterm by Friday');
      await cubit.generate();
      expect(cubit.state.tasks.length, 6);

      await cubit.commit();
      expect(cubit.state.committed, isTrue);

      final today = await tasksRepo.todayTasks();
      expect(today.length, 5 + 6); // 5 seeded + 6 committed
    });
  });
}

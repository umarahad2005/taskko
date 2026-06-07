import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/common/view_status.dart';
import 'package:project/features/hub/cubit/hub_cubit.dart';
import 'package:project/repositories/mock/gamification_repository_mock.dart';

void main() {
  group('HubCubit (SRS FR-6)', () {
    blocTest<HubCubit, HubState>(
      'load fetches badges, leaderboard and report',
      build: () => HubCubit(GamificationRepositoryMock()),
      act: (c) => c.load(),
      verify: (c) {
        expect(c.state.status, ViewStatus.success);
        expect(c.state.badges.length, 9);
        expect(c.state.unlockedCount, 4);
        expect(c.state.leaderboard.any((e) => e.isYou), isTrue);
        expect(c.state.report, isNotNull);
      },
    );

    blocTest<HubCubit, HubState>(
      'setTab switches the active tab (FR-6.1)',
      build: () => HubCubit(GamificationRepositoryMock()),
      act: (c) => c.setTab(HubTab.squad),
      verify: (c) => expect(c.state.tab, HubTab.squad),
    );
  });
}

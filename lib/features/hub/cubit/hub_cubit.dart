import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/view_status.dart';
import '../../../models/badge_item.dart';
import '../../../models/leaderboard_entry.dart';
import '../../../models/weekly_report.dart';
import '../../../repositories/gamification_repository.dart';

part 'hub_state.dart';

/// Gamification Hub (SRS FR-6): badges, squad leaderboard, weekly report card.
class HubCubit extends Cubit<HubState> {
  HubCubit(this._repo) : super(const HubState());

  final GamificationRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final badges = await _repo.badges();
      final leaderboard = await _repo.leaderboard();
      final report = await _repo.weeklyReport();
      emit(state.copyWith(
        status: ViewStatus.success,
        badges: badges,
        leaderboard: leaderboard,
        report: report,
      ));
    } catch (_) {
      emit(state.copyWith(status: ViewStatus.failure));
    }
  }

  void setTab(HubTab tab) => emit(state.copyWith(tab: tab));
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/view_status.dart';
import '../../../models/focus_session.dart';
import '../../../repositories/session_repository.dart';

part 'history_state.dart';

/// Loads focus-session history for the stats screen (SRS FR-10.3/10.4).
class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit(this._repo) : super(const HistoryState());

  final SessionRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final sessions = await _repo.recent();
      emit(state.copyWith(status: ViewStatus.success, sessions: sessions));
    } catch (_) {
      emit(state.copyWith(status: ViewStatus.failure));
    }
  }
}

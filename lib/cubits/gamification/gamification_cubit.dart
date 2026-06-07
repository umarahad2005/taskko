import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/view_status.dart';
import '../../models/app_user.dart';
import '../../models/badge_item.dart';
import '../../repositories/gamification_repository.dart';

part 'gamification_state.dart';

/// App-level gamification state: points, rank, streak, badges (SRS FR-8).
class GamificationCubit extends Cubit<GamificationState> {
  GamificationCubit(this._repo) : super(const GamificationState());

  final GamificationRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final user = await _repo.profile();
      final badges = await _repo.badges();
      emit(state.copyWith(status: ViewStatus.success, user: user, badges: badges));
    } catch (_) {
      emit(state.copyWith(status: ViewStatus.failure));
    }
  }
}

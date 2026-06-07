import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/app_user.dart';
import '../../repositories/auth_repository.dart';

part 'auth_state.dart';

/// App-level authentication state (SRS FR-3.*). Depends only on the
/// [AuthRepository] interface so the mock/real impl can be swapped freely.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(const AuthState());

  final AuthRepository _repo;

  Future<void> signInWithEmail(String email, String password) =>
      _run(() => _repo.signInWithEmail(email, password));

  Future<void> signUp({required String name, required String email, required String password}) =>
      _run(() => _repo.signUp(name: name, email: email, password: password));

  Future<void> signInWithGoogle() => _run(_repo.signInWithGoogle);

  Future<void> sendPasswordReset(String email) => _repo.sendPasswordReset(email);

  Future<void> signOut() async {
    await _repo.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> _run(Future<AppUser> Function() action) async {
    emit(state.copyWith(status: AuthStatus.authenticating));
    try {
      final user = await action();
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.failure, error: 'Something went wrong. Please try again.'));
    }
  }
}

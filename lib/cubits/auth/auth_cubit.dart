import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/app_user.dart';
import '../../repositories/auth_repository.dart';

part 'auth_state.dart';

/// App-level authentication state (SRS FR-3.*). Depends only on the
/// [AuthRepository] interface so the mock/real impl can be swapped freely.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(const AuthState()) {
    // Restore a persisted session on startup and follow every auth change so
    // the user stays logged in across restarts (like Instagram/Facebook).
    _sub = _repo.authStateChanges().listen(
      (user) {
        emit(user == null ? const AuthState(status: AuthStatus.unauthenticated) : _resolve(user));
      },
      onError: (Object _) {
        // Build a fresh state (not copyWith) so the stale user is dropped:
        // a failure status must never coexist with an authenticated user.
        emit(const AuthState(
          status: AuthStatus.failure,
          error: 'Something went wrong. Please try again.',
        ));
      },
    );
  }

  final AuthRepository _repo;
  StreamSubscription<AppUser?>? _sub;

  Future<void> signInWithEmail(String email, String password) =>
      _run(() => _repo.signInWithEmail(email, password));

  Future<void> signUp({required String name, required String email, required String password}) =>
      _run(() => _repo.signUp(name: name, email: email, password: password));

  Future<void> signInWithGoogle() => _run(_repo.signInWithGoogle);

  Future<void> sendPasswordReset(String email) => _repo.sendPasswordReset(email);

  /// (Re)send the verification email to the signed-in (unverified) user.
  Future<void> resendVerification() => _repo.sendEmailVerification();

  /// Reload the user from the server and re-resolve auth state. Returns `true`
  /// once the email is verified (so the caller can prompt "still not verified").
  Future<bool> refreshVerification() async {
    final user = await _repo.reloadUser();
    if (user == null) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return false;
    }
    emit(_resolve(user));
    return user.emailVerified;
  }

  Future<void> signOut() async {
    await _repo.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  /// Map a signed-in user to the right app state. Email/password accounts must
  /// verify their email first (FR-3.*); Google sign-ins are auto-verified, so
  /// their [AppUser.emailVerified] is always true and they pass straight through.
  AuthState _resolve(AppUser user) => user.emailVerified
      ? AuthState(status: AuthStatus.authenticated, user: user)
      : AuthState(status: AuthStatus.unverified, user: user);

  Future<void> _run(Future<AppUser> Function() action) async {
    emit(state.copyWith(status: AuthStatus.authenticating));
    try {
      final user = await action();
      emit(_resolve(user));
    } on AuthCancelledException {
      // User dismissed the provider sheet — silently return to the form.
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    } on AuthException catch (e) {
      // Known sign-in failure with a clear, user-facing message.
      emit(state.copyWith(status: AuthStatus.failure, error: e.message));
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.failure, error: 'Something went wrong. Please try again.'));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

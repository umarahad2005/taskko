import 'dart:async';

import '../../models/app_user.dart';
import '../auth_repository.dart';
import 'seed.dart';

/// In-memory mock auth (SRS §2.6). Recognizes the demo admin email; everything
/// else becomes a demo student. Simulates latency so loading states are real.
class AuthRepositoryMock implements AuthRepository {
  static const _latency = Duration(milliseconds: 700);

  // Broadcast the current session so the cubit can restore/clear it like the
  // real impl. Seeded signed-out; replays the latest value to new listeners.
  final _session = StreamController<AppUser?>.broadcast();
  AppUser? _current;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _current;
    yield* _session.stream;
  }

  void _emit(AppUser? user) {
    _current = user;
    _session.add(user);
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    await Future<void>.delayed(_latency);
    final user = _userFor(email);
    _emit(user);
    return user;
  }

  @override
  Future<AppUser> signUp({required String name, required String email, required String password}) async {
    await Future<void>.delayed(_latency);
    final user = email.trim().toLowerCase() == Seed.admin.email
        ? Seed.admin
        : AppUser(id: 'u-${email.hashCode}', name: name.trim().isEmpty ? 'Student' : name.trim(), email: email.trim());
    _emit(user);
    return user;
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    await Future<void>.delayed(_latency);
    _emit(Seed.user);
    return Seed.user;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await Future<void>.delayed(_latency);
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _emit(null);
  }

  AppUser _userFor(String email) =>
      email.trim().toLowerCase() == Seed.admin.email ? Seed.admin : Seed.user;
}

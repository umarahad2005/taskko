import '../../models/app_user.dart';
import '../auth_repository.dart';
import 'seed.dart';

/// In-memory mock auth (SRS §2.6). Recognizes the demo admin email; everything
/// else becomes a demo student. Simulates latency so loading states are real.
class AuthRepositoryMock implements AuthRepository {
  static const _latency = Duration(milliseconds: 700);

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    await Future<void>.delayed(_latency);
    return _userFor(email);
  }

  @override
  Future<AppUser> signUp({required String name, required String email, required String password}) async {
    await Future<void>.delayed(_latency);
    if (email.trim().toLowerCase() == Seed.admin.email) return Seed.admin;
    return AppUser(id: 'u-${email.hashCode}', name: name.trim().isEmpty ? 'Student' : name.trim(), email: email.trim());
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    await Future<void>.delayed(_latency);
    return Seed.user;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await Future<void>.delayed(_latency);
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  AppUser _userFor(String email) =>
      email.trim().toLowerCase() == Seed.admin.email ? Seed.admin : Seed.user;
}

import '../models/app_user.dart';

/// Authentication boundary (SRS FR-3.*). Cubits depend on this interface only;
/// the mock impl stands in until the Firebase impl lands in M9 (SRS §2.6).
abstract interface class AuthRepository {
  Future<AppUser> signInWithEmail(String email, String password);
  Future<AppUser> signUp({required String name, required String email, required String password});
  Future<AppUser> signInWithGoogle();
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
}

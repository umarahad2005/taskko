import '../models/app_user.dart';

/// Authentication boundary (SRS FR-3.*). Cubits depend on this interface only;
/// the mock impl stands in until the Firebase impl lands in M9 (SRS §2.6).
abstract interface class AuthRepository {
  /// Emits the signed-in user on startup + every auth change, or `null` when
  /// signed out. Lets the app restore a persisted session (stay logged in).
  Stream<AppUser?> authStateChanges();

  Future<AppUser> signInWithEmail(String email, String password);
  Future<AppUser> signUp({required String name, required String email, required String password});
  Future<AppUser> signInWithGoogle();
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
}

/// Thrown when the user dismisses a provider sheet (e.g. closes the Google
/// account picker). Treated as a no-op so we don't flash an error.
class AuthCancelledException implements Exception {
  const AuthCancelledException();
}

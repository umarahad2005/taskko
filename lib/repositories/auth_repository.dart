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

  /// Send a verification email to the signed-in user (no-op if already verified).
  Future<void> sendEmailVerification();

  /// Change the account email (re-authenticates with [currentPassword] first).
  /// Sends a verification link to [newEmail]; the change applies once confirmed.
  Future<void> updateEmail({required String newEmail, required String currentPassword});

  /// Change the account password (re-authenticates with [currentPassword] first).
  Future<void> updatePassword({required String newPassword, required String currentPassword});

  /// Permanently delete the signed-in account (re-authenticates first).
  Future<void> deleteAccount({required String currentPassword});
}

/// Thrown when the user dismisses a provider sheet (e.g. closes the Google
/// account picker). Treated as a no-op so we don't flash an error.
class AuthCancelledException implements Exception {
  const AuthCancelledException();
}

/// A sign-in/up failure with a user-facing [message]. Lets the repository map
/// provider-specific errors (e.g. Google DEVELOPER_ERROR / network) to a clear
/// message the cubit can show, instead of a generic "something went wrong".
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../models/app_user.dart';
import '../auth_repository.dart';

/// Real Firebase Authentication (SRS FR-3.*, M9). Implements the same
/// [AuthRepository] interface as the mock, so the UI/cubits are unchanged.
///
/// Profile gamification fields (points/streak/badges) are loaded separately
/// from Firestore in a later M9 slice; here we map the auth identity + the
/// `admin` custom claim (FR-3.7 / NFR-2 — admin decided server-side).
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// The Firebase **web** OAuth client id (from google-services.json, client_type 3).
  /// Required on Android so google_sign_in returns an id-token Firebase accepts.
  static const _webClientId =
      '260736761827-qap6159ljmthqe791sh03gqvkh1hf9uf.apps.googleusercontent.com';
  bool _googleReady = false;

  /// Firebase persists the session on disk, so this stream fires the cached user
  /// on cold start — the app stays logged in until an explicit sign-out.
  @override
  Stream<AppUser?> authStateChanges() =>
      _auth.authStateChanges().asyncMap((user) => user == null ? null : _toAppUser(user));

  Future<AppUser> _toAppUser(User user) async {
    final token = await user.getIdTokenResult();
    final claims = token.claims ?? const <String, dynamic>{};
    final isAdmin = claims['admin'] == true || claims['isAdmin'] == true;
    final displayName = user.displayName?.trim();
    final name = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : (user.email?.split('@').first ?? 'Student');
    return AppUser(
      id: user.uid,
      name: name,
      email: user.email ?? '',
      isAdmin: isAdmin,
      emailVerified: user.emailVerified,
    );
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
    return _toAppUser(cred.user!);
  }

  @override
  Future<AppUser> signUp({required String name, required String email, required String password}) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
    await cred.user!.updateDisplayName(name.trim());
    // Send a verification email on signup (best-effort — don't block the flow).
    try {
      await cred.user!.sendEmailVerification();
    } catch (_) {}
    await cred.user!.reload();
    return _toAppUser(_auth.currentUser ?? cred.user!);
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    // Native Google account picker (google_sign_in 7) → exchange the id-token
    // for a Firebase credential. Far more reliable than the web/Custom-Tab
    // signInWithProvider redirect, which errored right after account selection.
    final google = GoogleSignIn.instance;
    if (!_googleReady) {
      await google.initialize(serverClientId: _webClientId);
      _googleReady = true;
    }

    final GoogleSignInAccount account;
    try {
      account = await google.authenticate(scopeHint: const ['email']);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthCancelledException();
      }
      // Surface a clearer reason (e.g. config/SHA-1 or Play services issue)
      // instead of a generic failure, so problems are diagnosable on-device.
      throw AuthException('Google sign-in failed (${e.code.name}). ${e.description ?? ''}'.trim());
    }

    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const AuthException(
          'Google did not return an ID token — check the SHA-1 and web client ID configuration.');
    }
    try {
      final cred = await _auth.signInWithCredential(GoogleAuthProvider.credential(idToken: idToken));
      return _toAppUser(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException('Firebase rejected the Google sign-in: ${e.message ?? e.code}');
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendly(e));
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException('You are not signed in.');
    if (user.emailVerified) return;
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendly(e));
    }
  }

  @override
  Future<AppUser?> reloadUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    await user.reload();
    final refreshed = _auth.currentUser;
    return refreshed == null ? null : _toAppUser(refreshed);
  }

  @override
  Set<String> currentProviders() =>
      _auth.currentUser?.providerData.map((p) => p.providerId).toSet() ?? const {};

  @override
  Future<void> signOut() async {
    // Sign out of Google too so the picker reappears on the next login.
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  /// Re-authenticate with the account password — required by Firebase before
  /// sensitive changes (email/password/delete) when the session isn't fresh.
  Future<User> _reauth(String currentPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException('You are not signed in.');
    final email = user.email;
    if (email == null || email.isEmpty) {
      throw const AuthException('This account has no password sign-in to confirm with.');
    }
    try {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: currentPassword),
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendly(e));
    }
    return user;
  }

  /// Re-authenticate a Google account via the native account picker — required
  /// before deleting a Google-only account (which has no password to confirm).
  Future<User> _reauthGoogle() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException('You are not signed in.');
    final google = GoogleSignIn.instance;
    if (!_googleReady) {
      await google.initialize(serverClientId: _webClientId);
      _googleReady = true;
    }
    final GoogleSignInAccount account;
    try {
      account = await google.authenticate(scopeHint: const ['email']);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) throw const AuthCancelledException();
      throw AuthException('Google re-authentication failed (${e.code.name}).');
    }
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const AuthException('Google did not return an ID token. Please try again.');
    }
    try {
      await user.reauthenticateWithCredential(GoogleAuthProvider.credential(idToken: idToken));
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendly(e));
    }
    return user;
  }

  @override
  Future<void> updateEmail({required String newEmail, required String currentPassword}) async {
    final user = await _reauth(currentPassword);
    try {
      // Firebase 6.x: sends a verification link to the new address; the email
      // changes only after the user confirms it (more secure than updateEmail).
      await user.verifyBeforeUpdateEmail(newEmail.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendly(e));
    }
  }

  @override
  Future<void> updatePassword({required String newPassword, required String currentPassword}) async {
    final user = await _reauth(currentPassword);
    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendly(e));
    }
  }

  @override
  Future<void> deleteAccount({String? currentPassword, Future<void> Function()? onReauthenticated}) async {
    // Re-authenticate with whatever credential the account actually has: a
    // password if one was supplied, otherwise the native Google picker.
    final User user;
    if (currentPassword != null && currentPassword.isNotEmpty) {
      user = await _reauth(currentPassword);
    } else if (currentProviders().contains('google.com')) {
      user = await _reauthGoogle();
    } else {
      // No credential available — surface a clear password error.
      user = await _reauth(currentPassword ?? '');
    }
    // Wipe owned data while still signed in (Firestore rules block this once the
    // account is gone). Abort the deletion if cleanup fails.
    await onReauthenticated?.call();
    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendly(e));
    }
    // Drop the Google session too so the picker reappears on the next sign-in.
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }

  /// Map common Firebase auth error codes to clear, user-facing messages.
  String _friendly(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Current password is incorrect.';
      case 'weak-password':
        return 'New password is too weak (use at least 6 characters).';
      case 'email-already-in-use':
        return 'That email is already in use by another account.';
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-not-found':
        return 'No account found with that email.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'requires-recent-login':
        return 'Please sign out and back in, then try again.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}

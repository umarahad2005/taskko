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
    return AppUser(id: user.uid, name: name, email: user.email ?? '', isAdmin: isAdmin);
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
      rethrow;
    }

    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw FirebaseAuthException(code: 'missing-google-id-token');
    }
    final cred = await _auth.signInWithCredential(GoogleAuthProvider.credential(idToken: idToken));
    return _toAppUser(cred.user!);
  }

  @override
  Future<void> sendPasswordReset(String email) => _auth.sendPasswordResetEmail(email: email.trim());

  @override
  Future<void> signOut() async {
    // Sign out of Google too so the picker reappears on the next login.
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    await _auth.signOut();
  }
}

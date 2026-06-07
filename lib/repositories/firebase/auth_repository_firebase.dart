import 'package:firebase_auth/firebase_auth.dart';

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
    // Native provider flow (uses the OAuth client created when the SHA-1 was
    // added in Firebase). No google_sign_in package needed.
    final cred = await _auth.signInWithProvider(GoogleAuthProvider());
    return _toAppUser(cred.user!);
  }

  @override
  Future<void> sendPasswordReset(String email) => _auth.sendPasswordResetEmail(email: email.trim());

  @override
  Future<void> signOut() => _auth.signOut();
}

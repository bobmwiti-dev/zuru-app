import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Authentication Data Source
class FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthDataSource() : _firebaseAuth = FirebaseAuth.instance;

  /// Get current Firebase user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Update display name
  Future<void> updateDisplayName({required String displayName}) async {
    await currentUser?.updateDisplayName(displayName);
  }

  /// Update profile photo
  Future<void> updatePhotoURL({required String photoURL}) async {
    await currentUser?.updatePhotoURL(photoURL);
  }

  /// Listen to auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;
}
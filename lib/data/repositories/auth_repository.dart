import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/auth_user.dart';
import '../../core/exceptions/firebase_exceptions.dart';

/// Abstract auth repository
abstract class AuthRepository {
  /// Sign in with email and password
  Future<AuthUser> signIn(String email, String password);

  /// Sign up with email, password, and name
  Future<AuthUser> signUp(String email, String password, String name);

  /// Sign in with Google
  Future<AuthUser> signInWithGoogle();

  /// Sign in with Apple
  Future<AuthUser> signInWithApple();

  /// Sign out
  Future<void> signOut();

  /// Get current user
  Future<AuthUser?> getCurrentUser();

  /// Check if user is signed in
  Future<bool> isSignedIn();

  /// Reset password
  Future<void> resetPassword(String email);
}

/// Auth repository implementation
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl() : _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<AuthUser> signIn(String email, String password) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return AuthUser(
        id: result.user!.uid,
        email: result.user!.email!,
        name: result.user!.displayName,
        avatarUrl: result.user!.photoURL,
        createdAt: result.user!.metadata.creationTime!,
        lastLoginAt: result.user!.metadata.lastSignInTime,
      );
    } on FirebaseAuthException catch (e) {
      throw FirebaseExceptions.handleFirebaseException(e);
    }
  }

  @override
  Future<AuthUser> signUp(String email, String password, String name) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name if provided
      if (name.isNotEmpty) {
        await result.user!.updateDisplayName(name);
      }

      return AuthUser(
        id: result.user!.uid,
        email: result.user!.email!,
        name: name.isNotEmpty ? name : result.user!.displayName,
        avatarUrl: result.user!.photoURL,
        createdAt: result.user!.metadata.creationTime!,
        lastLoginAt: result.user!.metadata.lastSignInTime,
      );
    } on FirebaseAuthException catch (e) {
      throw FirebaseExceptions.handleFirebaseException(e);
    }
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    // TODO: Implement Google Sign-In
    throw UnimplementedError('Google Sign-In not yet implemented');
  }

  @override
  Future<AuthUser> signInWithApple() async {
    // TODO: Implement Apple Sign-In
    throw UnimplementedError('Apple Sign-In not yet implemented');
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    return AuthUser(
      id: user.uid,
      email: user.email!,
      name: user.displayName,
      avatarUrl: user.photoURL,
      createdAt: user.metadata.creationTime!,
      lastLoginAt: user.metadata.lastSignInTime,
    );
  }

  @override
  Future<bool> isSignedIn() async {
    return _firebaseAuth.currentUser != null;
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw FirebaseExceptions.handleFirebaseException(e);
    }
  }
}
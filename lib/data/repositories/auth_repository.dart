import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../domain/models/auth_user.dart';
import '../../core/exceptions/firebase_exceptions.dart';
import '../../core/exceptions/app_exception.dart';
import '../../app/config/environment.dart';
import '../models/user_model.dart';
import 'user_repository.dart';

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
    // Check if we're in development with placeholder Firebase config
    final firebaseConfig = Environment.config.firebaseConfig;
    if (Environment.isDevelopment &&
        (firebaseConfig.apiKey.contains('dev-api-key') ||
            firebaseConfig.projectId == 'zuru-dev')) {
      // Simulate successful signin for development
      await Future.delayed(
        const Duration(seconds: 1),
      ); // Simulate network delay

      return AuthUser(
        id: 'dev-user-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: 'Dev User',
        avatarUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        lastLoginAt: DateTime.now(),
      );
    }

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
    // Check if we're in development with placeholder Firebase config
    final firebaseConfig = Environment.config.firebaseConfig;
    if (Environment.isDevelopment &&
        (firebaseConfig.apiKey.contains('dev-api-key') ||
            firebaseConfig.projectId == 'zuru-dev')) {
      // Simulate successful signup for development
      await Future.delayed(
        const Duration(seconds: 1),
      ); // Simulate network delay

      final userId = 'dev-user-${DateTime.now().millisecondsSinceEpoch}';

      // Create user profile in Firestore
      final userProfile = UserModel(
        id: userId,
        email: email,
        displayName: name,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      final userRepository = UserRepository();
      await userRepository.createOrUpdateUserProfile(userProfile);

      return AuthUser(
        id: userId,
        email: email,
        name: name,
        avatarUrl: null,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
    }

    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name if provided
      if (name.isNotEmpty) {
        await result.user!.updateDisplayName(name);
      }

      final userId = result.user!.uid;

      // Create user profile in Firestore
      final userProfile = UserModel(
        id: userId,
        email: result.user!.email!,
        displayName: name.isNotEmpty ? name : result.user!.displayName,
        photoUrl: result.user!.photoURL,
        isEmailVerified: result.user!.emailVerified,
        createdAt: result.user!.metadata.creationTime ?? DateTime.now(),
        lastLoginAt: result.user!.metadata.lastSignInTime ?? DateTime.now(),
      );

      final userRepository = UserRepository();
      await userRepository.createOrUpdateUserProfile(userProfile);

      return AuthUser(
        id: userId,
        email: result.user!.email!,
        name: name.isNotEmpty ? name : result.user!.displayName,
        avatarUrl: result.user!.photoURL,
        createdAt: result.user!.metadata.creationTime!,
        lastLoginAt: result.user!.metadata.lastSignInTime,
      );
    } catch (e) {
      // Check if it's a Firebase configuration issue
      if (e.toString().contains('apiKey') ||
          e.toString().contains('projectId') ||
          e.toString().contains('invalid') ||
          e.toString().contains('configuration')) {
        throw AuthenticationException(
          message:
              'Firebase is not properly configured. Please check your Firebase project settings.',
          code: 'firebase_config_error',
          originalException: e,
        );
      }

      // Re-throw as Firebase exception for proper handling
      if (e is FirebaseAuthException) {
        throw FirebaseExceptions.handleFirebaseException(e);
      }

      // Handle other exceptions
      throw AuthenticationException(
        message: 'Sign up failed: ${e.toString()}',
        code: 'signup_failed',
        originalException: e,
      );
    }
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    try {
      // Initialize Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Start the sign-in process
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw AuthenticationException(
          message: 'Google Sign-In was cancelled',
          code: 'google_signin_cancelled',
        );
      }

      // Get authentication credentials
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user == null) {
        throw AuthenticationException(
          message: 'Google Sign-In failed: No user returned',
          code: 'google_signin_no_user',
        );
      }

      // Create AuthUser from Firebase user
      return AuthUser(
        email: user.email ?? '',
        name: user.displayName ?? 'Google User',
        avatarUrl: user.photoURL,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
        lastLoginAt: user.metadata.lastSignInTime ?? DateTime.now(),
      );
    } catch (e) {
      if (e is AuthenticationException) {
        rethrow;
      }
      throw AuthenticationException(
        message: 'Google Sign-In failed: ${e.toString()}',
        code: 'google_signin_failed',
        originalException: e,
      );
    }
  }

  @override
  Future<AuthUser> signInWithApple() async {
    try {
      // Request Apple Sign-In credentials
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential for Firebase
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with the Apple credential
      final userCredential = await _firebaseAuth.signInWithCredential(
        oauthCredential,
      );
      final user = userCredential.user;

      if (user == null) {
        throw AuthenticationException(
          message: 'Apple Sign-In failed: No user returned',
          code: 'apple_signin_no_user',
        );
      }

      // Create AuthUser from Firebase user
      // Apple may not always provide name/email on subsequent sign-ins
      final displayName =
          user.displayName ??
          (appleCredential.givenName != null &&
                  appleCredential.familyName != null
              ? '${appleCredential.givenName} ${appleCredential.familyName}'
              : 'Apple User');

      final email = user.email ?? appleCredential.email ?? '';

      return AuthUser(
        email: email,
        name: displayName,
        avatarUrl: user.photoURL,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
        lastLoginAt: user.metadata.lastSignInTime ?? DateTime.now(),
      );
    } catch (e) {
      if (e is SignInWithAppleAuthorizationException) {
        throw AuthenticationException(
          message: 'Apple Sign-In was cancelled or failed: ${e.message}',
          code: 'apple_signin_cancelled',
          originalException: e,
        );
      }
      throw AuthenticationException(
        message: 'Apple Sign-In failed: ${e.toString()}',
        code: 'apple_signin_failed',
        originalException: e,
      );
    }
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

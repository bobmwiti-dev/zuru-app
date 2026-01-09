import '../../domain/models/auth_user.dart';

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
  // TODO: Implement with Firebase Auth
  @override
  Future<AuthUser> signIn(String email, String password) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));

    return AuthUser(
      id: 'user_123',
      email: email,
      name: 'Test User',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<AuthUser> signUp(String email, String password, String name) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));

    return AuthUser(
      id: 'user_123',
      email: email,
      name: name,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));

    return AuthUser(
      id: 'user_google_123',
      email: 'user@gmail.com',
      name: 'Google User',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<AuthUser> signInWithApple() async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));

    return AuthUser(
      id: 'user_apple_123',
      email: 'user@icloud.com',
      name: 'Apple User',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> signOut() async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    // Mock implementation - return null for not signed in
    return null;
  }

  @override
  Future<bool> isSignedIn() async {
    // Mock implementation
    return false;
  }

  @override
  Future<void> resetPassword(String email) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
  }
}
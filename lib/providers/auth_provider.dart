import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zuru_app/data/repositories/auth_repository.dart';
import 'package:zuru_app/domain/models/auth_user.dart';

// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError(
      'authRepositoryProvider was not overridden. Make sure to override it in main.dart');
});

// Provider for the authentication state
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

// AuthNotifier handles the authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState.initial()) {
    // Check if user is already authenticated when the app starts
    _checkAuthStatus();
  }

  // Check authentication status
  Future<void> _checkAuthStatus() async {
    state = const AuthState.loading();
    try {
      final isAuthenticated = await _authRepository.isAuthenticated();
      if (isAuthenticated) {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          state = AuthState.authenticated(user);
          return;
        }
      }
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error('Failed to check authentication status');
    }
  }

  // Sign in with email and password
  Future<void> signIn(String email, String password) async {
    state = const AuthState.loading();
    try {
      final user = await _authRepository.signIn(email, password);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
      rethrow;
    }
  }

  // Sign up with email, password, and name
  Future<void> signUp(String email, String password, String name) async {
    state = const AuthState.loading();
    try {
      final user = await _authRepository.signUp(email, password, name);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    state = const AuthState.loading();
    try {
      await _authRepository.signOut();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error('Failed to sign out');
      rethrow;
    }
  }

  // Clear any authentication errors
  void clearError() {
    if (state is AuthError) {
      state = const AuthState.unauthenticated();
    }
  }
}

// AuthState represents the different states of authentication
sealed class AuthState {
  const AuthState();
  
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.authenticated(AuthUser user) = AuthAuthenticated;
  const factory AuthState.unauthenticated() = AuthUnauthenticated;
  const factory AuthState.error(String message) = AuthError;

  // Helper methods to check the current state
  bool get isLoading => this is AuthLoading;
  bool get isAuthenticated => this is AuthAuthenticated;
  bool get isUnauthenticated => this is AuthUnauthenticated;
  bool get hasError => this is AuthError;

  // Getters to safely access user data
  AuthUser? get user {
    return switch (this) {
      AuthAuthenticated(user: final user) => user,
      _ => null,
    };
  }

  String? get error {
    return switch (this) {
      AuthError(message: final message) => message,
      _ => null,
    };
  }
}

// Concrete state classes
class AuthInitial extends AuthState {
  const AuthInitial() : super();
}

class AuthLoading extends AuthState {
  const AuthLoading() : super();
}

class AuthAuthenticated extends AuthState {
  @override
  final AuthUser user;
  const AuthAuthenticated(this.user) : super();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated() : super();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message) : super();
}
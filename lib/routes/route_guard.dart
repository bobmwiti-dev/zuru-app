import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../domain/models/auth_user.dart';

/// Route Guard - Protects routes based on authentication state
class RouteGuard {
  /// Check if user is authenticated
  static bool isAuthenticated(WidgetRef ref) {
    final authState = ref.read(authStateProvider);
    return authState.isAuthenticated;
  }

  /// Get current user if authenticated
  static AuthUser? getCurrentUser(WidgetRef ref) {
    final authState = ref.read(authStateProvider);
    return authState.user;
  }

  /// Check if route requires authentication
  static bool requiresAuth(String routeName) {
    // Routes that require authentication
    const protectedRoutes = [
      '/memory-feed-screen',
      '/add-journal-screen',
      '/interactive-map-view',
      '/mood-analytics-screen',
      '/ai-insights-screen',
      '/profile-screen',
      '/settings-screen',
      '/share-screen',
      '/friends-screen',
    ];

    return protectedRoutes.contains(routeName);
  }

  /// Guard route access - returns appropriate route based on auth state
  static Route<dynamic> guardRoute(
    RouteSettings settings,
    WidgetRef ref,
    Route<dynamic> Function(RouteSettings) routeBuilder,
  ) {
    final routeName = settings.name ?? '';
    final requiresAuth = RouteGuard.requiresAuth(routeName);
    final isAuthenticated = RouteGuard.isAuthenticated(ref);

    // If route requires auth but user is not authenticated
    if (requiresAuth && !isAuthenticated) {
      // Redirect to authentication screen
      return MaterialPageRoute(
        builder: (_) => _buildAuthRequiredScreen(settings),
        settings: settings,
      );
    }

    // If user is authenticated or route doesn't require auth
    return routeBuilder(settings);
  }

  /// Build screen shown when authentication is required
  static Widget _buildAuthRequiredScreen(RouteSettings settings) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'Authentication Required',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Please sign in to access your memories and continue journaling.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to auth screen
                    // This would be handled by the navigator
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Check if user has permission for specific actions
  static bool hasPermission(WidgetRef ref, String permission) {
    final user = getCurrentUser(ref);
    if (user == null) return false;

    // Basic permission checks - can be extended
    switch (permission) {
      case 'create_memory':
        return true; // All authenticated users can create memories
      case 'view_analytics':
        return true; // All authenticated users can view their analytics
      case 'share_public':
        return true; // All authenticated users can share publicly
      case 'manage_friends':
        return true; // All authenticated users can manage friends
      default:
        return false;
    }
  }

  /// Get redirect route after authentication
  static String getRedirectRoute(String? attemptedRoute) {
    // If no attempted route or it's auth route, redirect to feed
    if (attemptedRoute == null ||
        attemptedRoute == '/' ||
        attemptedRoute == '/authentication-screen') {
      return '/memory-feed-screen';
    }

    // If attempted route requires auth, redirect there
    if (requiresAuth(attemptedRoute)) {
      return attemptedRoute;
    }

    // Otherwise, redirect to feed
    return '/memory-feed-screen';
  }

  /// Handle logout - clear any cached route state
  static void onLogout() {
    // Clear any cached navigation state
    // This could be extended to clear navigation history
  }
}

/// Auth Guard Widget - Wraps widgets that require authentication
class AuthGuard extends ConsumerWidget {
  final Widget child;
  final Widget? loadingWidget;
  final Widget? unauthenticatedWidget;

  const AuthGuard({
    super.key,
    this.loadingWidget,
    this.unauthenticatedWidget,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return switch (authState) {
      AuthInitial() => loadingWidget ?? const _LoadingWidget(),
      AuthLoading() => loadingWidget ?? const _LoadingWidget(),
      AuthAuthenticated() => child,
      AuthError(message: final message) => unauthenticatedWidget ?? _buildErrorWidget(message),
      AuthUnauthenticated() => unauthenticatedWidget ?? const _UnauthenticatedWidget(),
    };
  }

  Widget _buildErrorWidget(String message) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Authentication Error',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _UnauthenticatedWidget extends StatelessWidget {
  const _UnauthenticatedWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_circle_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to Zuru',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Sign in to start documenting your memories and experiences.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/authentication-screen');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
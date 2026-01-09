import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../domain/models/auth_user.dart';

/// Authentication guard for route protection
/// Ensures users are authenticated before accessing protected screens
class AuthGuard extends ConsumerWidget {
  final Widget child;
  final Widget? loadingWidget;
  final Widget? unauthorizedWidget;
  final List<String>? publicRoutes;

  const AuthGuard({
    super.key,
    this.loadingWidget,
    this.unauthorizedWidget,
    this.publicRoutes,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    // Check if current route is public
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isPublicRoute = publicRoutes?.contains(currentRoute) ?? false;

    return switch (authState) {
      AuthAuthenticated() => child,
      AuthLoading() =>
        loadingWidget ??
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      AuthError(message: final message) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Authentication Error',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Retry authentication check
                  ref.invalidate(authStateProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      AuthUnauthenticated() =>
        isPublicRoute
            ? child
            : unauthorizedWidget ??
                Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Authentication Required',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please sign in to access this feature',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/authentication-screen',
                            );
                          },
                          child: const Text('Sign In'),
                        ),
                      ],
                    ),
                  ),
                ),
      AuthInitial() =>
        loadingWidget ??
            const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
  }
}

/// Route wrapper that applies authentication guard to protected routes
class ProtectedRoute extends ConsumerWidget {
  final Widget child;
  final List<String> publicRoutes;

  const ProtectedRoute({
    super.key,
    required this.child,
    this.publicRoutes = const [
      '/',
      '/authentication-screen',
      '/welcome-screen',
      '/onboarding-screen',
    ],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AuthGuard(publicRoutes: publicRoutes, child: child);
  }
}

/// Extension to check if user is authenticated
extension AuthStateExtensions on AuthState {
  bool get isAuthenticated {
    return this is AuthAuthenticated;
  }

  bool get isLoading {
    return this is AuthLoading;
  }

  bool get hasError {
    return this is AuthError;
  }

  AuthUser? get user {
    if (this is AuthAuthenticated) {
      return (this as AuthAuthenticated).user;
    }
    return null;
  }
}

/// Route generator with authentication guards
class AuthGuardedRouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Define public routes that don't require authentication
    const publicRoutes = [
      '/',
      '/authentication-screen',
      '/welcome-screen',
      '/onboarding-screen',
      '/privacy-policy',
      '/terms-of-service',
    ];

    // Check if route is public
    final isPublicRoute = publicRoutes.contains(settings.name);

    // Get the actual route
    final route = _getRoute(settings);

    if (route == null) {
      return MaterialPageRoute(
        builder:
            (_) => Scaffold(
              body: Center(
                child: Text('No route defined for ${settings.name}'),
              ),
            ),
      );
    }

    // If route is public, return it directly
    if (isPublicRoute) {
      return route;
    }

    // For protected routes, wrap with AuthGuard
    if (route is MaterialPageRoute) {
      return MaterialPageRoute(
        builder:
            (context) => AuthGuard(
              publicRoutes: publicRoutes,
              child: route.builder(context),
            ),
        settings: settings,
      );
    }

    // Fallback for other route types
    return route;
  }

  static Route<dynamic>? _getRoute(RouteSettings settings) {
    // This would contain your existing route generation logic
    // For now, return null to let the existing system handle it
    return null;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zuru_app/presentation/screens/authentication_screen/screen.dart';
import 'package:zuru_app/providers/auth_provider.dart';

class RouteGuard extends ConsumerWidget {
  final Widget child;

  const RouteGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return switch (authState) {
      AuthAuthenticated() => child,
      AuthError(message: final message) => AuthenticationScreen(error: message),
      AuthLoading() || AuthInitial() => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      _ => const AuthenticationScreen(),
    };
  }
}
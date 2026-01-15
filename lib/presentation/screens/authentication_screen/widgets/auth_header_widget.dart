import 'package:flutter/material.dart';

/// Header widget for authentication screen
/// Displays Zuru logo and welcome message
class AuthHeaderWidget extends StatelessWidget {
  final bool isSignUpMode;

  const AuthHeaderWidget({
    super.key,
    required this.isSignUpMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final logoSize =
            (constraints.maxWidth * 0.28).clamp(84.0, 112.0).toDouble();

        return Column(
          children: [
            // Zuru logo
            Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.35),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  'Z',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Welcome text
            Text(
              isSignUpMode ? 'Create Your Account' : 'Welcome Back',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              isSignUpMode
                  ? 'Your moments matter. Start your journey.'
                  : 'Sign in to continue your story',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}

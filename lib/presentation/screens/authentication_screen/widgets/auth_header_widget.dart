import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

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

    return Column(
      children: [
        // Zuru logo
        Container(
          width: 25.w,
          height: 25.w,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Z',
              style: theme.textTheme.displayMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // Welcome text
        Text(
          isSignUpMode ? 'Create Your Account' : 'Welcome Back',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 1.h),

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
  }
}

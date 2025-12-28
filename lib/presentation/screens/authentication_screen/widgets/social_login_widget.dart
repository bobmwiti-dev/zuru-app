import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../../widgets/custom_icon_widget.dart';

/// Social login widget for authentication screen
/// Displays Google and Apple Sign-In buttons
class SocialLoginWidget extends StatelessWidget {
  final VoidCallback onGoogleSignIn;
  final VoidCallback onAppleSignIn;
  final bool isLoading;

  const SocialLoginWidget({
    super.key,
    required this.onGoogleSignIn,
    required this.onAppleSignIn,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool showAppleSignIn = kIsWeb || Platform.isIOS;

    return Column(
      children: [
        // Google Sign-In button
        _buildSocialButton(
          context: context,
          label: 'Continue with Google',
          icon: 'g_translate',
          backgroundColor: theme.colorScheme.surface,
          textColor: theme.colorScheme.onSurface,
          borderColor: theme.colorScheme.outline,
          onTap: isLoading ? null : onGoogleSignIn,
        ),

        if (showAppleSignIn) ...[
          SizedBox(height: 2.h),

          // Apple Sign-In button
          _buildSocialButton(
            context: context,
            label: 'Continue with Apple',
            icon: 'apple',
            backgroundColor: theme.brightness == Brightness.light
                ? Colors.black
                : Colors.white,
            textColor: theme.brightness == Brightness.light
                ? Colors.white
                : Colors.black,
            borderColor: Colors.transparent,
            onTap: isLoading ? null : onAppleSignIn,
          ),
        ],
      ],
    );
  }

  /// Build social login button
  Widget _buildSocialButton({
    required BuildContext context,
    required String label,
    required String icon,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    required VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 6.h,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: textColor,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

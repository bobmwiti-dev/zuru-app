import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../../widgets/custom_icon_widget.dart';

/// Form widget for authentication screen
/// Handles email, password, and name input fields
class AuthFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final bool isSignUpMode;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isPasswordVisible;
  final VoidCallback onPasswordVisibilityToggle;
  final VoidCallback onForgotPassword;

  const AuthFormWidget({
    super.key,
    required this.formKey,
    required this.isSignUpMode,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.isPasswordVisible,
    required this.onPasswordVisibilityToggle,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name field (only for sign up)
          if (isSignUpMode) ...[
            _buildTextField(
              context: context,
              controller: nameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              prefixIcon: 'person_outline',
              keyboardType: TextInputType.name,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 2.h),
          ],

          // Email field
          _buildTextField(
            context: context,
            controller: emailController,
            label: 'Email',
            hint: 'Enter your email',
            prefixIcon: 'email_outlined',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value.trim())) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          SizedBox(height: 2.h),

          // Password field
          _buildTextField(
            context: context,
            controller: passwordController,
            label: 'Password',
            hint: 'Enter your password',
            prefixIcon: 'lock_outline',
            obscureText: !isPasswordVisible,
            suffixIcon: isPasswordVisible ? 'visibility_off' : 'visibility',
            onSuffixIconTap: onPasswordVisibilityToggle,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (isSignUpMode && value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),

          // Password strength indicator (only for sign up)
          if (isSignUpMode && passwordController.text.isNotEmpty) ...[
            SizedBox(height: 1.h),
            _buildPasswordStrengthIndicator(context),
          ],

          // Forgot password link (only for sign in)
          if (!isSignUpMode) ...[
            SizedBox(height: 1.h),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onForgotPassword,
                child: Text(
                  'Forgot Password?',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build text field with consistent styling
  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required String prefixIcon,
    String? suffixIcon,
    VoidCallback? onSuffixIconTap,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: prefixIcon,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        suffixIcon: suffixIcon != null
            ? GestureDetector(
                onTap: onSuffixIconTap,
                child: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: suffixIcon,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              )
            : null,
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2,
          ),
        ),
      ),
      validator: validator,
    );
  }

  /// Build password strength indicator
  Widget _buildPasswordStrengthIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final password = passwordController.text;

    // Calculate password strength
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    Color strengthColor;
    String strengthText;

    if (strength <= 1) {
      strengthColor = theme.colorScheme.error;
      strengthText = 'Weak';
    } else if (strength == 2) {
      strengthColor = Colors.orange;
      strengthText = 'Fair';
    } else if (strength == 3) {
      strengthColor = Colors.yellow.shade700;
      strengthText = 'Good';
    } else {
      strengthColor = Colors.green;
      strengthText = 'Strong';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: strength / 4,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              strengthText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: strengthColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

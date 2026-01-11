import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './widgets/auth_form_widget.dart';
import './widgets/auth_header_widget.dart';
import './widgets/social_login_widget.dart';
import '../../../providers/auth_provider.dart';
import '../../../domain/models/auth_user.dart';

/// Authentication Screen for Zuru journaling app
/// Handles user registration and login with email/password and social authentication
class AuthenticationScreen extends ConsumerStatefulWidget {
  const AuthenticationScreen({super.key, this.error});

  final String? error;

  @override
  ConsumerState<AuthenticationScreen> createState() =>
      _AuthenticationScreenState();
}

class _AuthenticationScreenState extends ConsumerState<AuthenticationScreen>
    with SingleTickerProviderStateMixin {
  // Auth mode toggle
  bool _isSignUpMode = true;

  // Form controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // Form validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Password visibility
  bool _isPasswordVisible = false;

  // Loading state
  bool _isLoading = false;

  // Error message
  String? _errorMessage;

  // Animation controllers for premium interactions
  late AnimationController _animationController;
  late AnimationController _bounceController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _animationController = AnimationController(
      duration: AnimationUtils.slow,
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: AnimationUtils.medium,
      vsync: this,
    );

    // Create animations
    _fadeAnimation = AnimationUtils.createFadeTween(_animationController);
    _scaleAnimation = AnimationUtils.createScaleTween(_bounceController);

    // Start animations
    _animationController.forward();
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });

    // Initialize error message from widget parameter
    _errorMessage = widget.error;

    // Listen to auth state changes to update error messages
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next is AuthError && mounted) {
        setState(() {
          _errorMessage = next.message;
        });
      } else if (next is AuthLoading && mounted) {
        setState(() {
          _errorMessage = null; // Clear errors when loading starts
        });
      }
    });
  }

  @override
  void didUpdateWidget(AuthenticationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update error message when widget parameter changes
    if (oldWidget.error != widget.error) {
      setState(() {
        _errorMessage = widget.error;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _animationController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  /// Toggle between sign up and sign in modes with premium animations
  void _toggleAuthMode() {
    AnimationUtils.mediumImpact();

    setState(() {
      _isSignUpMode = !_isSignUpMode;
      _errorMessage = null;
      _formKey.currentState?.reset();
    });

    // Bounce animation for mode switch
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });

    // Reset and restart main animation
    _animationController.reset();
    _animationController.forward();
  }

  /// Handle email/password authentication with premium interactions
  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) {
      AnimationUtils.lightImpact();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Premium haptic feedback for authentication start
    AnimationUtils.mediumImpact();

    try {
      final authNotifier = ref.read(authStateProvider.notifier);

      if (_isSignUpMode) {
        await authNotifier.signUp(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );
      } else {
        await authNotifier.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }

      // Success haptic feedback
      AnimationUtils.heavyImpact();

      // Navigation will be handled by main.dart based on auth state
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });

      // Error haptic feedback
      AnimationUtils.vibrate();

      // Shake animation for error
      _bounceController.forward().then((_) {
        _bounceController.reverse();
      });
    }
  }

  /// Handle Google Sign-In with premium interactions
  Future<void> _handleGoogleSignIn() async {
    AnimationUtils.lightImpact();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Initialize Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Start the sign-in process
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        setState(() {
          _isLoading = false;
        });
        return;
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
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        // Create AuthUser from Firebase user
        final authUser = AuthUser(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? 'User',
          avatarUrl: user.photoURL,
          lastLoginAt: DateTime.now(),
        );

        // Update auth state using the notifier
        final authNotifier = ref.read(authStateProvider.notifier);
        authNotifier.signInWithExternalAuth(authUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome back, ${authUser.name}!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.all(16),
            ),
          );

          // Navigate to main screen after successful sign-in
          Navigator.pushReplacementNamed(context, '/');
        }
      }

      AnimationUtils.selectionClick();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to sign in with Google';
      });
      AnimationUtils.vibrate();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handle Apple Sign-In with premium interactions
  Future<void> _handleAppleSignIn() async {
    AnimationUtils.lightImpact();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Sign in with Apple using the auth provider
      await ref.read(authStateProvider.notifier).signInWithApple();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome! Signed in with Apple.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.all(16),
          ),
        );
        AnimationUtils.selectionClick();

        // Navigate to main screen after successful sign-in
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to sign in with Apple: ${e.toString()}';
      });
      AnimationUtils.vibrate();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handle forgot password with premium interactions
  void _handleForgotPassword() {
    AnimationUtils.lightImpact();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Reset Password'),
            content: const Text(
              'Password reset link will be sent to your email.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  AnimationUtils.selectionClick();
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              AnimationUtils.createAnimatedButton(
                onPressed: () {
                  AnimationUtils.mediumImpact();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Password reset email sent!'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: EdgeInsets.all(16),
                    ),
                  );
                },
                child: const Text('Send'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Update loading state based on auth state
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next is AuthLoading) {
        setState(() {
          _isLoading = true;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }

      // Handle error state
      if (next is AuthError) {
        setState(() {
          _errorMessage = next.message;
        });
        // Trigger bounce animation for error
        _bounceController.forward().then((_) {
          _bounceController.reverse();
        });
      }
    });

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 4.h),

                  // Header with logo and title
                  AuthHeaderWidget(isSignUpMode: _isSignUpMode),

                  SizedBox(height: 4.h),

                  // Segmented control for Sign Up / Sign In
                  _buildSegmentedControl(theme),

                  SizedBox(height: 3.h),

                  // Error message display
                  if (_errorMessage != null) ...[
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'error_outline',
                            color: theme.colorScheme.error,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],

                  // Auth form
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: AuthFormWidget(
                      formKey: _formKey,
                      isSignUpMode: _isSignUpMode,
                      nameController: _nameController,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      isPasswordVisible: _isPasswordVisible,
                      onPasswordVisibilityToggle: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      onForgotPassword: _handleForgotPassword,
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Primary action button
                  _buildPrimaryButton(theme),

                  SizedBox(height: 3.h),

                  // Divider with "Or continue with"
                  _buildDivider(theme),

                  SizedBox(height: 3.h),

                  // Social login buttons
                  SocialLoginWidget(
                    onGoogleSignIn: _handleGoogleSignIn,
                    onAppleSignIn: _handleAppleSignIn,
                    isLoading: _isLoading,
                  ),

                  SizedBox(height: 4.h),

                  // Toggle auth mode text
                  _buildToggleAuthModeText(theme),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build segmented control for Sign Up / Sign In
  Widget _buildSegmentedControl(ThemeData theme) {
    return Container(
      height: 6.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_isSignUpMode) _toggleAuthMode();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color:
                      _isSignUpMode
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Sign Up',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color:
                          _isSignUpMode
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          _isSignUpMode ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isSignUpMode) _toggleAuthMode();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color:
                      !_isSignUpMode
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Sign In',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color:
                          !_isSignUpMode
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          !_isSignUpMode ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build primary action button
  Widget _buildPrimaryButton(ThemeData theme) {
    return SizedBox(
      height: 6.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleEmailAuth,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child:
            _isLoading
                ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.onPrimary,
                    ),
                  ),
                )
                : Text(
                  _isSignUpMode ? 'Create Account' : 'Sign In',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }

  /// Build divider with "Or continue with" text
  Widget _buildDivider(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: theme.colorScheme.outline, thickness: 1),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Or continue with',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: theme.colorScheme.outline, thickness: 1),
        ),
      ],
    );
  }

  /// Build toggle auth mode text
  Widget _buildToggleAuthModeText(ThemeData theme) {
    return Center(
      child: GestureDetector(
        onTap: _toggleAuthMode,
        child: RichText(
          text: TextSpan(
            text:
                _isSignUpMode
                    ? 'Already have an account? '
                    : "Don't have an account? ",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            children: [
              TextSpan(
                text: _isSignUpMode ? 'Sign In' : 'Sign Up',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

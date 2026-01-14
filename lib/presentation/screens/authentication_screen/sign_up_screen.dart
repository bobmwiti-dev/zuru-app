import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../providers/auth_provider.dart';
import '../../common/error_mapper.dart';
import './widgets/auth_form_widget.dart';
import './widgets/auth_header_widget.dart';
import './widgets/social_login_widget.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key, this.error});

  final String? error;

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _animationController;
  late AnimationController _bounceController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: AnimationUtils.slow,
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: AnimationUtils.medium,
      vsync: this,
    );

    _fadeAnimation = AnimationUtils.createFadeTween(_animationController);
    _scaleAnimation = AnimationUtils.createScaleTween(_bounceController);

    _animationController.forward();
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });

    _errorMessage = widget.error;

    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (!mounted) return;

      if (next is AuthLoading) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
        return;
      }

      setState(() {
        _isLoading = false;
      });

      if (next is AuthError) {
        setState(() {
          _errorMessage = next.message;
        });
        _bounceController.forward().then((_) {
          _bounceController.reverse();
        });
      }

      if (next is AuthAuthenticated) {
        final current = ModalRoute.of(context)?.settings.name;
        if (current != '/') {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant SignUpScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
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

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      AnimationUtils.lightImpact();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    AnimationUtils.mediumImpact();

    try {
      await ref.read(authStateProvider.notifier).signUp(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
          );

      AnimationUtils.heavyImpact();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = ErrorMapper.mapError(e);
      });
      AnimationUtils.vibrate();
      _bounceController.forward().then((_) {
        _bounceController.reverse();
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    AnimationUtils.lightImpact();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authStateProvider.notifier).signInWithGoogle();
      AnimationUtils.selectionClick();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = ErrorMapper.mapError(e);
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

  Future<void> _handleAppleSignIn() async {
    AnimationUtils.lightImpact();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authStateProvider.notifier).signInWithApple();
      AnimationUtils.selectionClick();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = ErrorMapper.mapError(e);
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

  void _goToSignIn() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);

    if (authState is AuthLoading || authState is AuthInitial) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
              SizedBox(height: 2.h),
              Text('Loading...', style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      );
    }

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
                  const AuthHeaderWidget(isSignUpMode: true),
                  SizedBox(height: 4.h),
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
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: AuthFormWidget(
                      formKey: _formKey,
                      isSignUpMode: true,
                      nameController: _nameController,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      isPasswordVisible: _isPasswordVisible,
                      onPasswordVisibilityToggle: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      onForgotPassword: () {},
                    ),
                  ),
                  SizedBox(height: 3.h),
                  SizedBox(
                    height: 6.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
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
                              'Sign up',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  _buildDivider(theme),
                  SizedBox(height: 3.h),
                  SocialLoginWidget(
                    onGoogleSignIn: _handleGoogleSignIn,
                    onAppleSignIn: _handleAppleSignIn,
                    isLoading: _isLoading,
                  ),
                  SizedBox(height: 4.h),
                  Center(
                    child: GestureDetector(
                      onTap: _goToSignIn,
                      child: RichText(
                        text: TextSpan(
                          text: 'Have an account? ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          children: [
                            TextSpan(
                              text: 'Log in',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: theme.colorScheme.outline, thickness: 1),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Or',
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
}

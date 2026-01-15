import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

import '../../../core/app_export.dart';
import '../../../providers/auth_provider.dart';
import '../../common/error_mapper.dart';
import './widgets/auth_form_widget.dart';
import './widgets/auth_header_widget.dart';
import './widgets/social_login_widget.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key, this.error});

  final String? error;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  ProviderSubscription<AuthState>? _authStateSubscription;

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

    _authStateSubscription = ref.listenManual<AuthState>(
      authStateProvider,
      (previous, next) {
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
      },
    );
  }

  @override
  void didUpdateWidget(covariant SignInScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.error != widget.error) {
      setState(() {
        _errorMessage = widget.error;
      });
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.close();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _animationController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
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
      await ref.read(authStateProvider.notifier).signIn(
            _emailController.text.trim(),
            _passwordController.text,
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

  void _goToForgotPassword() {
    Navigator.pushNamed(context, '/forgot-password');
  }

  void _goToSignUp() {
    Navigator.pushNamed(context, '/sign-up');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final intensity = switch (width) {
      <= 380 => 0.82,
      >= 520 => 1.0,
      _ => 0.82 + (width - 380) * (1.0 - 0.82) / (520 - 380),
    };
    final tintStrength = 0.12 * intensity;
    final blobBlurSigma = switch (width) {
      <= 380 => 30.0,
      >= 520 => 40.0,
      _ => 30.0 + (width - 380) * (40.0 - 30.0) / (520 - 380),
    };

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
              const SizedBox(height: 16),
              Text('Loading...', style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.surface,
                  Color.lerp(
                        theme.colorScheme.surfaceContainerHighest,
                        theme.colorScheme.primary,
                        tintStrength,
                      ) ??
                      theme.colorScheme.surfaceContainerHighest,
                ],
              ),
            ),
          ),
          Positioned(
            top: -140,
            left: -140,
            child: _BlurBlob(
              size: 320,
              blurSigma: blobBlurSigma,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.42 * intensity),
                theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.18 * intensity,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: -180,
            right: -180,
            child: _BlurBlob(
              size: 380,
              blurSigma: blobBlurSigma,
              colors: [
                theme.colorScheme.secondary.withValues(alpha: 0.26 * intensity),
                theme.colorScheme.primary.withValues(alpha: 0.14 * intensity),
              ],
            ),
          ),
          Positioned(
            top: 140,
            right: -120,
            child: _BlurBlob(
              size: 240,
              blurSigma: blobBlurSigma,
              colors: [
                theme.colorScheme.tertiary.withValues(alpha: 0.18 * intensity),
                theme.colorScheme.secondaryContainer.withValues(
                  alpha: 0.10 * intensity,
                ),
              ],
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 24,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface
                                .withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 32,
                                offset: const Offset(0, 18),
                              ),
                            ],
                            border: Border.all(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.08),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const AuthHeaderWidget(isSignUpMode: false),
                              const SizedBox(height: 24),
                              if (_errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.error
                                        .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: theme.colorScheme.error
                                          .withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'error_outline',
                                        color: theme.colorScheme.error,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme.colorScheme.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: AuthFormWidget(
                                  formKey: _formKey,
                                  isSignUpMode: false,
                                  nameController: _nameController,
                                  emailController: _emailController,
                                  passwordController: _passwordController,
                                  isPasswordVisible: _isPasswordVisible,
                                  onPasswordVisibilityToggle: () {
                                    setState(() {
                                      _isPasswordVisible =
                                          !_isPasswordVisible;
                                    });
                                  },
                                  onForgotPassword: _goToForgotPassword,
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed:
                                      _isLoading ? null : _handleSignIn,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        theme.colorScheme.primary,
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 8,
                                    shadowColor: theme.colorScheme.primary
                                        .withValues(alpha: 0.35),
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              theme.colorScheme.onPrimary,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          'Log in',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            color:
                                                theme.colorScheme.onPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildDivider(theme),
                              const SizedBox(height: 24),
                              SocialLoginWidget(
                                onGoogleSignIn: _handleGoogleSignIn,
                                onAppleSignIn: _handleAppleSignIn,
                                isLoading: _isLoading,
                              ),
                              const SizedBox(height: 24),
                              Center(
                                child: GestureDetector(
                                  onTap: _goToSignUp,
                                  child: RichText(
                                    text: TextSpan(
                                      text: "Don't have an account? ",
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: theme.colorScheme
                                            .onSurfaceVariant,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Sign up',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color:
                                                theme.colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildDivider(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: theme.colorScheme.outline, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
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

class _BlurBlob extends StatelessWidget {
  const _BlurBlob({required this.size, required this.colors, this.blurSigma = 40});

  final double size;
  final List<Color> colors;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: colors,
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

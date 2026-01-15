import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_export.dart';
import '../../../providers/auth_provider.dart';
import '../../common/error_mapper.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ProviderSubscription<AuthState>? _authStateSubscription;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

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
        }
      },
    );
  }

  @override
  void dispose() {
    _authStateSubscription?.close();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      AnimationUtils.lightImpact();
      return;
    }

    final email = _emailController.text.trim();

    try {
      AnimationUtils.mediumImpact();
      await ref.read(authStateProvider.notifier).resetPassword(email);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password reset email sent!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = ErrorMapper.mapError(e);
      });
      AnimationUtils.vibrate();
    }
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot password'),
      ),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 28,
                              offset: const Offset(0, 16),
                            ),
                          ],
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Enter the email associated with your account and we\'ll send you a link to reset your password.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (_errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.error.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: theme.colorScheme.error,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
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
                              const SizedBox(height: 16),
                            ],
                            Form(
                              key: _formKey,
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'Enter your email',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  final emailRegex =
                                      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                  if (!emailRegex.hasMatch(value.trim())) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 6,
                                  shadowColor: theme.colorScheme.primary
                                      .withValues(alpha: 0.35),
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
                                        'Send reset link',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: theme.colorScheme.onPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
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
        ],
      ),
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

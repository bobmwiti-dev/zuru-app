import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    final bool showAppleSignIn =
        kIsWeb || defaultTargetPlatform == TargetPlatform.iOS;

    const buttonBackground = Colors.white;
    const buttonText = Color(0xFF111111);

    return Column(
      children: [
        // Google Sign-In button
        _AnimatedSocialButton(
          context: context,
          label: 'Continue with Google',
          icon: _BrandIcon(
            assetPath: 'assets/icons/google.png',
            fallbackIcon: FontAwesomeIcons.google,
            size: 18,
            fallbackColor: buttonText,
          ),
          backgroundColor: buttonBackground,
          textColor: buttonText,
          borderColor: theme.colorScheme.outline,
          onTap: isLoading ? null : onGoogleSignIn,
        ),

        if (showAppleSignIn) ...[
          const SizedBox(height: 16),

          // Apple Sign-In button
          _AnimatedSocialButton(
            context: context,
            label: 'Continue with Apple',
            icon: _BrandIcon(
              assetPath: 'assets/icons/apple.png',
              fallbackIcon: FontAwesomeIcons.apple,
              size: 18,
              fallbackColor: buttonText,
            ),
            backgroundColor: buttonBackground,
            textColor: buttonText,
            borderColor: theme.colorScheme.outline,
            onTap: isLoading ? null : onAppleSignIn,
          ),
        ],
      ],
    );
  }
}

class _AnimatedSocialButton extends StatefulWidget {
  const _AnimatedSocialButton({
    required this.context,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.onTap,
  });

  final BuildContext context;
  final String label;
  final Widget icon;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  State<_AnimatedSocialButton> createState() => _AnimatedSocialButtonState();
}

class _AnimatedSocialButtonState extends State<_AnimatedSocialButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(widget.context);
    final enabled = widget.onTap != null;

    final scale = _pressed
        ? 0.98
        : (_hovered && enabled)
            ? 1.01
            : 1.0;

    final shadowOpacity = (_hovered && enabled) ? 0.10 : 0.06;

    return MouseRegion(
      onEnter: (_) {
        if (!enabled) return;
        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
          _pressed = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) {
          if (!enabled) return;
          setState(() {
            _pressed = true;
          });
        },
        onTapCancel: () {
          setState(() {
            _pressed = false;
          });
        },
        onTapUp: (_) {
          setState(() {
            _pressed = false;
          });
        },
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: shadowOpacity),
                        blurRadius: _hovered ? 18 : 14,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : [],
            ),
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: widget.onTap,
                style: OutlinedButton.styleFrom(
                  backgroundColor: widget.backgroundColor,
                  side: BorderSide(
                    color: widget.borderColor.withValues(alpha: 0.8),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.icon,
                    const SizedBox(width: 12),
                    Text(
                      widget.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: widget.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandIcon extends StatefulWidget {
  const _BrandIcon({
    required this.assetPath,
    required this.fallbackIcon,
    required this.size,
    required this.fallbackColor,
  });

  final String assetPath;
  final IconData fallbackIcon;
  final double size;
  final Color fallbackColor;

  @override
  State<_BrandIcon> createState() => _BrandIconState();
}

class _BrandIconState extends State<_BrandIcon> {
  late final Future<bool> _existsFuture;

  @override
  void initState() {
    super.initState();
    _existsFuture = rootBundle
        .load(widget.assetPath)
        .then((_) => true)
        .catchError((_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _existsFuture,
      builder: (context, snapshot) {
        final exists = snapshot.data ?? false;
        if (!exists) {
          return FaIcon(
            widget.fallbackIcon,
            size: widget.size,
            color: widget.fallbackColor,
          );
        }

        final lower = widget.assetPath.toLowerCase();
        if (lower.endsWith('.png') ||
            lower.endsWith('.jpg') ||
            lower.endsWith('.jpeg') ||
            lower.endsWith('.webp')) {
          return Image.asset(
            widget.assetPath,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return FaIcon(
                widget.fallbackIcon,
                size: widget.size,
                color: widget.fallbackColor,
              );
            },
          );
        }

        return SvgPicture.asset(
          widget.assetPath,
          width: widget.size,
          height: widget.size,
        );
      },
    );
  }
}

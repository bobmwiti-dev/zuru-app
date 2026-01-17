import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';

/// Custom button variants
enum CustomButtonVariant {
  /// Primary filled button
  primary,

  /// Secondary outlined button
  secondary,

  /// Tertiary text button
  tertiary,

  /// Danger/error button
  danger,

  /// Success button
  success,

  /// Ghost button with minimal styling
  ghost,
}

/// Custom button sizes
enum CustomButtonSize {
  /// Small button
  small,

  /// Medium button (default)
  medium,

  /// Large button
  large,

  /// Extra large button
  extraLarge,
}

/// Custom button widget with consistent styling and animations
class CustomButton extends StatefulWidget {
  /// Button text
  final String text;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Button variant
  final CustomButtonVariant variant;

  /// Button size
  final CustomButtonSize size;

  /// Leading icon name (for CustomIconWidget)
  final String? leadingIcon;

  /// Trailing icon name (for CustomIconWidget)
  final String? trailingIcon;

  /// Whether the button is in loading state
  final bool isLoading;

  /// Custom loading text (defaults to button text)
  final String? loadingText;

  /// Whether the button should take full width
  final bool isFullWidth;

  /// Custom border radius
  final double? borderRadius;

  /// Custom padding
  final EdgeInsetsGeometry? padding;

  /// Custom text style
  final TextStyle? textStyle;

  /// Custom background color override
  final Color? backgroundColor;

  /// Custom foreground color override
  final Color? foregroundColor;

  /// Custom border color override
  final Color? borderColor;

  /// Custom elevation
  final double? elevation;

  /// Whether to enable haptic feedback
  final bool enableHaptics;

  /// Custom width
  final double? width;

  /// Custom height
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = CustomButtonVariant.primary,
    this.size = CustomButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.loadingText,
    this.isFullWidth = false,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.elevation,
    this.enableHaptics = true,
    this.width,
    this.height,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AnimationUtils.fast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AnimationUtils.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get _isInteractive => !widget.isLoading && widget.onPressed != null;

  void _handlePressDown() {
    if (!_isInteractive) return;
    if (widget.enableHaptics) {
      AnimationUtils.lightImpact();
    }
    _animationController.forward();
  }

  void _handlePressUp() {
    if (!_isInteractive) return;
    _animationController.reverse();
  }

  void _handlePressCancel() {
    if (!_isInteractive) return;
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get button configuration based on variant and size
    final config = _getButtonConfig(theme);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => _handlePressDown(),
            onPointerUp: (_) => _handlePressUp(),
            onPointerCancel: (_) => _handlePressCancel(),
            child: SizedBox(
              width:
                  widget.width ?? (widget.isFullWidth ? double.infinity : null),
              height: widget.height ?? config.height,
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : widget.onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: config.backgroundColor,
                  foregroundColor: config.foregroundColor,
                  elevation: config.elevation,
                  shadowColor: config.shadowColor,
                  padding: config.padding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(config.borderRadius),
                    side: config.borderSide ?? BorderSide.none,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: _buildButtonContent(config),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent(_ButtonConfig config) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: config.iconSize,
            height: config.iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(config.foregroundColor),
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            widget.loadingText ?? widget.text,
            style: config.textStyle,
          ),
        ] else ...[
          if (widget.leadingIcon != null) ...[
            CustomIconWidget(
              iconName: widget.leadingIcon!,
              color: config.foregroundColor,
              size: config.iconSize,
            ),
            SizedBox(width: 1.w),
          ],
          Text(
            widget.text,
            style: config.textStyle,
          ),
          if (widget.trailingIcon != null) ...[
            SizedBox(width: 1.w),
            CustomIconWidget(
              iconName: widget.trailingIcon!,
              color: config.foregroundColor,
              size: config.iconSize,
            ),
          ],
        ],
      ],
    );

    if (widget.isFullWidth) {
      return content;
    }

    return content;
  }

  _ButtonConfig _getButtonConfig(ThemeData theme) {
    // Size configuration
    double height;
    double iconSize;
    EdgeInsetsGeometry padding;
    double borderRadius;
    TextStyle textStyle;

    switch (widget.size) {
      case CustomButtonSize.small:
        height = AppSizes.buttonHeightSm;
        iconSize = AppSizes.iconSm;
        padding = EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h);
        borderRadius = AppSizes.radiusMd;
        textStyle = GoogleFonts.inter(
          fontSize: AppSizes.fontSm,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        );
        break;

      case CustomButtonSize.large:
        height = AppSizes.buttonHeightLg;
        iconSize = AppSizes.iconMd;
        padding = EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h);
        borderRadius = AppSizes.radiusMd;
        textStyle = GoogleFonts.inter(
          fontSize: AppSizes.fontLg,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        );
        break;

      case CustomButtonSize.extraLarge:
        height = 56;
        iconSize = AppSizes.iconLg;
        padding = EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h);
        borderRadius = AppSizes.radiusLg;
        textStyle = GoogleFonts.inter(
          fontSize: AppSizes.fontXl,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        );
        break;

      case CustomButtonSize.medium:
        height = AppSizes.buttonHeightMd;
        iconSize = AppSizes.iconMd;
        padding = EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.25.h);
        borderRadius = AppSizes.radiusMd;
        textStyle = GoogleFonts.inter(
          fontSize: AppSizes.fontMd,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.25,
        );
        break;
    }

    // Variant configuration
    Color backgroundColor;
    Color foregroundColor;
    Color? shadowColor;
    double elevation;
    BorderSide? borderSide;

    switch (widget.variant) {
      case CustomButtonVariant.primary:
        backgroundColor = widget.backgroundColor ?? AppColors.primary;
        foregroundColor = widget.foregroundColor ?? AppColors.white;
        shadowColor = AppColors.shadow;
        elevation = widget.elevation ?? AppSizes.elevationSm;
        break;

      case CustomButtonVariant.secondary:
        backgroundColor = widget.backgroundColor ?? AppColors.secondary;
        foregroundColor = widget.foregroundColor ?? AppColors.white;
        shadowColor = AppColors.shadow;
        elevation = widget.elevation ?? AppSizes.elevationSm;
        break;

      case CustomButtonVariant.tertiary:
        backgroundColor = widget.backgroundColor ?? AppColors.surface;
        foregroundColor = widget.foregroundColor ?? AppColors.primary;
        borderSide = BorderSide(
          color: widget.borderColor ?? AppColors.primary.withValues(alpha: 0.5),
          width: AppSizes.borderWidthNormal,
        );
        elevation = widget.elevation ?? 0;
        break;

      case CustomButtonVariant.danger:
        backgroundColor = widget.backgroundColor ?? AppColors.error;
        foregroundColor = widget.foregroundColor ?? AppColors.white;
        shadowColor = AppColors.shadow;
        elevation = widget.elevation ?? AppSizes.elevationSm;
        break;

      case CustomButtonVariant.success:
        backgroundColor = widget.backgroundColor ?? AppColors.accent;
        foregroundColor = widget.foregroundColor ?? AppColors.white;
        shadowColor = AppColors.shadow;
        elevation = widget.elevation ?? AppSizes.elevationSm;
        break;

      case CustomButtonVariant.ghost:
        backgroundColor = widget.backgroundColor ?? Colors.transparent;
        foregroundColor = widget.foregroundColor ?? AppColors.onSurface;
        elevation = widget.elevation ?? 0;
        break;
    }

    // Apply custom overrides
    if (widget.borderRadius != null) {
      borderRadius = widget.borderRadius!;
    }

    if (widget.padding != null) {
      padding = widget.padding!;
    }

    if (widget.textStyle != null) {
      textStyle = widget.textStyle!;
    }

    // Apply foreground color to text style
    textStyle = textStyle.copyWith(color: foregroundColor);

    return _ButtonConfig(
      height: widget.height ?? height,
      iconSize: iconSize,
      padding: padding,
      borderRadius: borderRadius,
      textStyle: textStyle,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      shadowColor: shadowColor,
      elevation: elevation,
      borderSide: borderSide,
    );
  }
}

class _ButtonConfig {
  final double height;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final TextStyle textStyle;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? shadowColor;
  final double elevation;
  final BorderSide? borderSide;

  const _ButtonConfig({
    required this.height,
    required this.iconSize,
    required this.padding,
    required this.borderRadius,
    required this.textStyle,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.shadowColor,
    required this.elevation,
    this.borderSide,
  });
}
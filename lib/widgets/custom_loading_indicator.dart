import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';

/// Loading indicator variants
enum CustomLoadingVariant {
  /// Circular progress indicator
  circular,

  /// Linear progress indicator
  linear,

  /// Shimmer loading effect
  shimmer,

  /// Pulsing dots
  dots,

  /// Spinning dots
  spinningDots,
}

/// Custom loading indicator widget with various styles
class CustomLoadingIndicator extends StatefulWidget {
  /// Loading variant
  final CustomLoadingVariant variant;

  /// Size of the indicator
  final double? size;

  /// Color of the indicator
  final Color? color;

  /// Background color (for circular variants)
  final Color? backgroundColor;

  /// Stroke width for circular indicators
  final double? strokeWidth;

  /// Number of dots for dot-based indicators
  final int dotCount;

  /// Spacing between dots
  final double? dotSpacing;

  /// Text to display alongside the indicator
  final String? text;

  /// Whether to center the indicator
  final bool centered;

  /// Custom padding
  final EdgeInsetsGeometry? padding;

  const CustomLoadingIndicator({
    super.key,
    this.variant = CustomLoadingVariant.circular,
    this.size,
    this.color,
    this.backgroundColor,
    this.strokeWidth,
    this.dotCount = 3,
    this.dotSpacing,
    this.text,
    this.centered = true,
    this.padding,
  });

  @override
  State<CustomLoadingIndicator> createState() => _CustomLoadingIndicatorState();
}

class _CustomLoadingIndicatorState extends State<CustomLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _dotsController;

  late Animation<double> _spinAnimation;
  late Animation<double> _dotsAnimation;

  @override
  void initState() {
    super.initState();

    // Spin animation for circular indicators
    _spinController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _spinAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _spinController,
      curve: Curves.linear,
    ));

    // Dots animation for sequential effects
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _dotsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_dotsController);
  }

  @override
  void dispose() {
    _spinController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultColor = widget.color ?? theme.colorScheme.primary;
    final defaultSize = widget.size ?? 24.0;

    Widget indicator;

    switch (widget.variant) {
      case CustomLoadingVariant.circular:
        indicator = _buildCircularIndicator(defaultColor, defaultSize);
        break;

      case CustomLoadingVariant.linear:
        indicator = _buildLinearIndicator(defaultColor);
        break;

      case CustomLoadingVariant.shimmer:
        indicator = _buildShimmerIndicator(defaultSize);
        break;

      case CustomLoadingVariant.dots:
        indicator = _buildDotsIndicator(defaultColor, defaultSize);
        break;

      case CustomLoadingVariant.spinningDots:
        indicator = _buildSpinningDotsIndicator(defaultColor, defaultSize);
        break;
    }

    // Add text if provided
    if (widget.text != null) {
      indicator = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          SizedBox(width: 2.w),
          Text(
            widget.text!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    // Apply centering if requested
    if (widget.centered) {
      indicator = Center(child: indicator);
    }

    // Apply padding
    final padding = widget.padding ?? EdgeInsets.all(2.w);
    indicator = Padding(
      padding: padding,
      child: indicator,
    );

    return indicator;
  }

  Widget _buildCircularIndicator(Color color, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
        backgroundColor: widget.backgroundColor,
        strokeWidth: widget.strokeWidth ?? 3.0,
      ),
    );
  }

  Widget _buildLinearIndicator(Color color) {
    return SizedBox(
      width: widget.size ?? double.infinity,
      height: 4,
      child: LinearProgressIndicator(
        backgroundColor: widget.backgroundColor ?? color.withValues(alpha: 0.2),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  Widget _buildShimmerIndicator(double size) {
    return ShimmerContainer(
      width: size * 3,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }

  Widget _buildDotsIndicator(Color color, double size) {
    return AnimatedBuilder(
      animation: _dotsAnimation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.dotCount, (index) {
            final delay = index / widget.dotCount;
            final animationValue = (_dotsAnimation.value - delay).clamp(0.0, 1.0);
            final opacity = animationValue;

            return Container(
              width: size / 3,
              height: size / 3,
              margin: EdgeInsets.symmetric(
                horizontal: widget.dotSpacing ?? (size / 6),
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildSpinningDotsIndicator(Color color, double size) {
    return AnimatedBuilder(
      animation: _spinAnimation,
      builder: (context, child) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: List.generate(widget.dotCount, (index) {
              final angle = (index / widget.dotCount) * 2 * 3.14159;
              final x = size / 2 + (size / 3) * cos(angle + _spinAnimation.value * 2 * 3.14159);
              final y = size / 2 + (size / 3) * sin(angle + _spinAnimation.value * 2 * 3.14159);

              return Positioned(
                left: x - (size / 6),
                top: y - (size / 6),
                child: Container(
                  width: size / 3,
                  height: size / 3,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
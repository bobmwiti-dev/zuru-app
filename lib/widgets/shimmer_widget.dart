import 'package:flutter/material.dart';

/// Custom shimmer widget for smooth loading states
class ShimmerWidget extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const ShimmerWidget({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              transform: GradientRotation(_animation.value * 3.14159 / 2),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Shimmer container for placeholder content
class ShimmerContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const ShimmerContainer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: ShimmerWidget(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

/// Shimmer text placeholder
class ShimmerText extends StatelessWidget {
  final String? text;
  final double? width;
  final TextStyle? style;
  final int maxLines;

  const ShimmerText({
    super.key,
    this.text,
    this.width,
    this.style,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    if (text != null) {
      return ShimmerWidget(
        child: Text(
          text!,
          style: style,
          maxLines: maxLines,
        ),
      );
    }

    return ShimmerContainer(
      width: width,
      height: style?.fontSize ?? 16,
      borderRadius: BorderRadius.circular(4),
    );
  }
}

/// Shimmer list item for list placeholders
class ShimmerListItem extends StatelessWidget {
  final double? avatarSize;
  final double? itemHeight;
  final EdgeInsets? padding;

  const ShimmerListItem({
    super.key,
    this.avatarSize = 40,
    this.itemHeight = 60,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: itemHeight,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ShimmerContainer(
            width: avatarSize,
            height: avatarSize,
            borderRadius: BorderRadius.circular(avatarSize! / 2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerText(
                  width: double.infinity,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                ShimmerText(
                  width: double.infinity,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

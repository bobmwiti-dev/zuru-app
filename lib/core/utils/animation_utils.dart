import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Utility class for premium animations and haptic feedback
class AnimationUtils {
  // Duration constants for smooth transitions
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration extraSlow = Duration(milliseconds: 800);

  // Curve constants for natural motion
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve bounceIn = Curves.bounceIn;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;

  // Haptic feedback methods
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  static void vibrate() {
    HapticFeedback.vibrate();
  }

  // Animation controllers
  static AnimationController createBounceController(TickerProvider vsync) {
    return AnimationController(
      duration: medium,
      vsync: vsync,
    );
  }

  static AnimationController createFadeController(TickerProvider vsync) {
    return AnimationController(
      duration: slow,
      vsync: vsync,
    );
  }

  static AnimationController createScaleController(TickerProvider vsync) {
    return AnimationController(
      duration: fast,
      vsync: vsync,
    );
  }

  // Tween animations
  static Animation<double> createBounceTween(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: bounceOut,
    ));
  }

  static Animation<double> createFadeTween(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: easeInOut,
    ));
  }

  static Animation<double> createScaleTween(AnimationController controller) {
    return Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: elasticOut,
    ));
  }

  static Animation<Offset> createSlideTween(AnimationController controller, {Offset begin = const Offset(0, 0.3)}) {
    return Tween<Offset>(
      begin: begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: fastOutSlowIn,
    ));
  }

  // Page route transitions
  static Route<T> createBounceRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: medium,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: fastOutSlowIn,
        ));
        
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: easeInOut,
        ));
        
        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }

  static Route<T> createFadeRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: slow,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: easeInOut,
        ));
        
        final scaleAnimation = Tween<double>(
          begin: 0.95,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: elasticOut,
        ));
        
        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
    );
  }

  // Widget animation builders
  static Widget animateBounceIn(Widget child, AnimationController controller) {
    return ScaleTransition(
      scale: createScaleTween(controller),
      child: FadeTransition(
        opacity: createFadeTween(controller),
        child: child,
      ),
    );
  }

  static Widget animateSlideIn(Widget child, AnimationController controller, {Offset begin = const Offset(0, 0.3)}) {
    return SlideTransition(
      position: createSlideTween(controller, begin: begin),
      child: FadeTransition(
        opacity: createFadeTween(controller),
        child: child,
      ),
    );
  }

  static Widget animateFadeIn(Widget child, AnimationController controller) {
    return FadeTransition(
      opacity: createFadeTween(controller),
      child: child,
    );
  }

  // Staggered animations for lists
  static List<Animation<double>> createStaggeredAnimations(
    AnimationController controller,
    int itemCount, {
    double staggerDelay = 0.1,
  }) {
    return List.generate(itemCount, (index) {
      final start = index * staggerDelay;
      final end = start + 1.0;
      
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(
          start.clamp(0.0, 1.0),
          end.clamp(0.0, 1.0),
          curve: easeInOut,
        ),
      ));
    });
  }

  // Button press animation
  static Widget createAnimatedButton({
    required Widget child,
    required VoidCallback onPressed,
    Duration duration = fast,
    Curve curve = easeInOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, scale, child) {
        return GestureDetector(
          onTapDown: (_) {
            lightImpact();
            // Scale down animation would need a controller
          },
          onTapUp: (_) {
            onPressed();
          },
          onTapCancel: () {
            // Scale up animation would need a controller
          },
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
    );
  }
}

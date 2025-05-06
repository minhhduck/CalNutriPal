import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Service providing standard animation settings and haptic feedback
class AnimationService {
  /// Standard duration for most animations
  static const Duration standardDuration = Duration(milliseconds: 300);

  /// Short duration for quick animations
  static const Duration shortDuration = Duration(milliseconds: 150);

  /// Long duration for elaborate animations
  static const Duration longDuration = Duration(milliseconds: 500);

  /// Standard curve for most animations
  static const Curve standardCurve = Curves.easeInOut;

  /// Curve for entrance animations
  static const Curve entranceCurve = Curves.easeOutBack;

  /// Curve for exit animations
  static const Curve exitCurve = Curves.easeIn;

  /// Provides light haptic feedback for button presses
  static void buttonFeedback() {
    HapticFeedback.lightImpact();
  }

  /// Provides medium haptic feedback for more significant actions
  static void selectionFeedback() {
    HapticFeedback.mediumImpact();
  }

  /// Provides heavy haptic feedback for important events
  static void notificationFeedback() {
    HapticFeedback.heavyImpact();
  }

  /// Provides success haptic pattern
  static void successFeedback() {
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.lightImpact();
    });
  }

  /// Provides error haptic pattern
  static void errorFeedback() {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.heavyImpact();
    });
  }

  /// Animation controller factory for standard animations
  static AnimationController createController({
    required TickerProvider vsync,
    Duration? duration,
  }) {
    return AnimationController(
      vsync: vsync,
      duration: duration ?? standardDuration,
    );
  }

  /// Create a scale animation for button press effect
  static Animation<double> createButtonScaleAnimation(
      AnimationController controller) {
    return Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  /// Create a loading spinner animation
  static Animation<double> createSpinnerAnimation(
      AnimationController controller) {
    controller.repeat();
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(controller);
  }

  /// Widget extension that adds a scale animation on tap
  static Widget addScaleTapAnimation({
    required Widget child,
    required VoidCallback onTap,
    double scaleValue = 0.95,
    Duration duration = const Duration(milliseconds: 150),
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isPressed = false;

        return GestureDetector(
          onTapDown: (_) {
            setState(() => isPressed = true);
            buttonFeedback();
          },
          onTapUp: (_) {
            setState(() => isPressed = false);
            onTap();
          },
          onTapCancel: () {
            setState(() => isPressed = false);
          },
          child: AnimatedScale(
            scale: isPressed ? scaleValue : 1.0,
            duration: duration,
            curve: Curves.easeOutCubic,
            child: child,
          ),
        );
      },
    );
  }

  /// Create a success animation sequence (checkmark with scale)
  static Widget buildSuccessAnimation({
    double size = 100.0,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Container(
          width: size * value,
          height: size * value,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.check_circle,
              color: Colors.green,
              size: (size * 0.6) * value,
            ),
          ),
        );
      },
    );
  }

  /// Create an error animation sequence (X mark with shake)
  static Widget buildErrorAnimation({
    double size = 100.0,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Container(
          width: size * value,
          height: size * value,
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.error,
              color: Colors.red,
              size: (size * 0.6) * value,
            ),
          ),
        );
      },
    );
  }

  /// Create a loading animation
  static Widget buildLoadingAnimation({
    double size = 100.0,
    Color color = Colors.blue,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: size / 10,
        color: color,
      ),
    );
  }

  /// Add scroll physics that feel more iOS-native
  static ScrollPhysics get iosScrollPhysics => const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      );

  /// Card entrance animation from bottom with opacity
  static Widget buildCardEntranceAnimation({
    required Widget child,
    required int index,
    Duration? delay,
  }) {
    final delayDuration =
        Duration(milliseconds: (index * 50) + (delay?.inMilliseconds ?? 0));

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

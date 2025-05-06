import 'package:flutter/material.dart';
import '../../core/services/animation_service.dart';

/// An animated button that provides visual feedback and haptic response
class AnimatedButton extends StatefulWidget {
  /// The child widget to display
  final Widget child;

  /// Called when the button is tapped
  final VoidCallback onPressed;

  /// Button color
  final Color? color;

  /// Button border radius
  final BorderRadius? borderRadius;

  /// Button elevation
  final double elevation;

  /// Button padding
  final EdgeInsetsGeometry padding;

  /// Whether to include haptic feedback
  final bool hapticFeedback;

  /// Animation duration
  final Duration duration;

  /// Scale value when pressed (1.0 = no scale)
  final double scaleValue;

  const AnimatedButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.color,
    this.borderRadius,
    this.elevation = 0,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    this.hapticFeedback = true,
    this.duration = const Duration(milliseconds: 150),
    this.scaleValue = 0.97,
  }) : super(key: key);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    if (widget.hapticFeedback) {
      AnimationService.buttonFeedback();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onPressed();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.color ?? Theme.of(context).primaryColor;
    final radius = widget.borderRadius ?? BorderRadius.circular(12);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleValue : 1.0,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: radius,
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: backgroundColor.withOpacity(0.3),
                      blurRadius: widget.elevation * 2,
                      spreadRadius: widget.elevation / 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// A button styled like an iOS button with proper animations
class IosStyleButton extends StatelessWidget {
  /// The text to display
  final String text;

  /// Called when the button is tapped
  final VoidCallback onPressed;

  /// Button color
  final Color? color;

  /// Text color
  final Color? textColor;

  /// Whether this is a primary button
  final bool isPrimary;

  /// Whether this is a destructive button
  final bool isDestructive;

  /// Button padding
  final EdgeInsetsGeometry? padding;

  const IosStyleButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.isPrimary = false,
    this.isDestructive = false,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color buttonColor;
    Color buttonTextColor;

    // Determine colors based on button type
    if (isDestructive) {
      buttonColor = color ?? Colors.red.shade50;
      buttonTextColor = textColor ?? Colors.red;
    } else if (isPrimary) {
      buttonColor = color ?? Theme.of(context).primaryColor;
      buttonTextColor = textColor ?? Colors.white;
    } else {
      buttonColor = color ?? Colors.grey.shade200;
      buttonTextColor = textColor ?? Theme.of(context).primaryColor;
    }

    return AnimatedButton(
      color: buttonColor,
      borderRadius: BorderRadius.circular(10),
      padding: padding ??
          EdgeInsets.symmetric(
            vertical: 14,
            horizontal: isPrimary ? 24 : 16,
          ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: buttonTextColor,
          fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
          fontSize: isPrimary ? 16 : 15,
        ),
      ),
    );
  }
}

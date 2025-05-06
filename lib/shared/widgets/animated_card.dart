import 'package:flutter/material.dart';

/// A widget that wraps its child in an animated card with a slide and fade animation
class AnimatedCard extends StatefulWidget {
  /// Creates an AnimatedCard
  const AnimatedCard({
    Key? key,
    required this.child,
    this.animate = true,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 300),
    this.onTap,
  }) : super(key: key);

  /// The widget to wrap with animation
  final Widget child;

  /// Whether to animate the card
  final bool animate;

  /// The delay before starting the animation
  final Duration delay;

  /// The duration of the animation
  final Duration duration;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    if (widget.animate) {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: InkWell(
            onTap: widget.onTap,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

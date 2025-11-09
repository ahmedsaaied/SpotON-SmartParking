import 'package:flutter/material.dart';

/// A class that provides reusable button animation effects
class ButtonAnimations {
  /// Creates a scale animation controller for buttons
  static AnimationController createScaleController(TickerProvider vsync) {
    return AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.9,
      upperBound: 1.0,
    );
  }

  /// Creates a bounce animation controller for buttons
  static AnimationController createBounceController(TickerProvider vsync) {
    return AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );
  }

  /// Creates a bounce animation for buttons
  static Animation<double> createBounceAnimation(
      AnimationController controller) {
    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.95)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30.0,
      ),
    ]).animate(controller);
  }

  /// Adds a ripple effect to a widget
  static Widget addRippleEffect({
    required Widget child,
    required VoidCallback onTap,
    BorderRadius? borderRadius,
    Color? splashColor,
    Color? highlightColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        splashColor: splashColor ?? Colors.white.withOpacity(0.3),
        highlightColor: highlightColor ?? Colors.white.withOpacity(0.1),
        child: child,
      ),
    );
  }
}

/// A stateful widget that applies a scale animation to its child when pressed
class ScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Duration duration;
  final bool addRippleEffect;
  final BorderRadius? borderRadius;
  final Color? splashColor;
  final Color? highlightColor;

  const ScaleButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.duration = const Duration(milliseconds: 150),
    this.addRippleEffect = true,
    this.borderRadius,
    this.splashColor,
    this.highlightColor,
  });

  @override
  State<ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget result = GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) {
        _controller.forward();
        widget.onPressed();
      },
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(
        scale: _controller,
        child: widget.child,
      ),
    );

    if (widget.addRippleEffect) {
      result = ButtonAnimations.addRippleEffect(
        onTap: widget.onPressed,
        borderRadius: widget.borderRadius,
        splashColor: widget.splashColor,
        highlightColor: widget.highlightColor,
        child: ScaleTransition(
          scale: _controller,
          child: widget.child,
        ),
      );
    }

    return result;
  }
}

/// A stateful widget that applies a bounce animation to its child when pressed
class BounceButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final bool addRippleEffect;
  final BorderRadius? borderRadius;
  final Color? splashColor;
  final Color? highlightColor;

  const BounceButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.addRippleEffect = true,
    this.borderRadius,
    this.splashColor,
    this.highlightColor,
  });

  @override
  State<BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<BounceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = ButtonAnimations.createBounceController(this);
    _animation = ButtonAnimations.createBounceAnimation(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget result = GestureDetector(
      onTap: () {
        _controller.forward(from: 0.0);
        widget.onPressed();
      },
      child: ScaleTransition(
        scale: _animation,
        child: widget.child,
      ),
    );

    if (widget.addRippleEffect) {
      result = ButtonAnimations.addRippleEffect(
        onTap: () {
          _controller.forward(from: 0.0);
          widget.onPressed();
        },
        borderRadius: widget.borderRadius,
        splashColor: widget.splashColor,
        highlightColor: widget.highlightColor,
        child: ScaleTransition(
          scale: _animation,
          child: widget.child,
        ),
      );
    }

    return result;
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'config.dart';
import 'widget.dart';

/// The Stateful Widget handling animation logic.
class HyperSnackBarContainer extends StatefulWidget {
  final HyperConfig config;
  final VoidCallback onDismiss;

  const HyperSnackBarContainer({
    super.key,
    required this.config,
    required this.onDismiss,
  });

  @override
  State<HyperSnackBarContainer> createState() => HyperSnackBarContainerState();
}

class HyperSnackBarContainerState extends State<HyperSnackBarContainer>
    with SingleTickerProviderStateMixin {
  late HyperConfig config;
  late AnimationController _controller;
  late Animation<double> _animation; // Curve for entry animation is already applied
  Timer? _timer;

  // Whether it is in the middle of exit animation
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    config = widget.config;
    _controller = AnimationController(
      vsync: this,
      duration: config.enterAnimationDuration,
    );

    // Apply curve for entry animation
    _animation = CurvedAnimation(parent: _controller, curve: config.enterCurve);

    _controller.forward();

    if (config.displayDuration != null) {
      _timer = Timer(config.displayDuration!, () {
        dismiss();
      });
    }
  }

  void updateConfig(HyperConfig newConfig) {
    setState(() {
      config = newConfig;

      // Process to restore if an update comes during exit
      if (_isExiting) {
        _isExiting = false;
        _controller.stop();
        _controller.duration = config.enterAnimationDuration;
        _controller.forward();
      }
    });

    _timer?.cancel();
    if (config.displayDuration != null) {
      _timer = Timer(config.displayDuration!, () {
        dismiss();
      });
    }
  }

  void dismiss() {
    if (!mounted || _isExiting) return;

    _timer?.cancel();

    setState(() {
      _isExiting = true;
    });

    _controller.stop();
    _controller.duration = config.exitAnimationDuration;
    _controller.reset();

    _controller.forward().then((_) {
      // If it is still in exit mode upon completion, execute deletion
      if (mounted && _isExiting) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = HyperSnackBarContent(
      config: config,
      onDismiss: dismiss,
    );

    if (config.enableSwipe) {
      child = Dismissible(
        key: ValueKey(config.id ?? DateTime.now().toString()),
        direction: DismissDirection.horizontal,
        onDismissed: (_) {
          widget.onDismiss();
        },
        child: child,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return _isExiting
            ? _applyExitAnimation(child!)
            : _applyEnterAnimation(child!);
      },
      child: child,
    );
  }

  // ---------------------------------------------------------------------------
  // Enter animation
  // ---------------------------------------------------------------------------
  Widget _applyEnterAnimation(Widget child) {
    // config.enterCurve is already applied to _animation

    switch (config.enterAnimationType) {
      case HyperSnackAnimationType.scale:
        return ScaleTransition(
          scale: _animation,
          child: child,
        );

      case HyperSnackAnimationType.fromLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(_animation),
          child: child,
        );

      case HyperSnackAnimationType.fromRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(_animation),
          child: child,
        );

      case HyperSnackAnimationType.fromTop:
        return SizeTransition(
          sizeFactor: _animation,
          axisAlignment: -1.0, // Based on the top edge
          child: FadeTransition(opacity: _animation, child: child),
        );

      case HyperSnackAnimationType.fromBottom:
        return SizeTransition(
          sizeFactor: _animation,
          axisAlignment: 1.0, // Based on the bottom edge
          child: FadeTransition(opacity: _animation, child: child),
        );

      case HyperSnackAnimationType.fade:
      default:
        return FadeTransition(opacity: _animation, child: child);
    }
  }

  // ---------------------------------------------------------------------------
  // Exit animation
  // ---------------------------------------------------------------------------
  Widget _applyExitAnimation(Widget child) {
    // Use a controller that goes from 0.0 -> 1.0 for exit,
    // but in terms of animation, it means "Current -> Gone",
    // so adjust with Tween etc.

    final exitAnim =
        CurvedAnimation(parent: _controller, curve: config.exitCurve);

    switch (config.exitAnimationType) {
      case HyperSnackAnimationType.scale:
        // Scale down from 1.0 -> 0.0
        return ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 0.0).animate(exitAnim),
          child: child,
        );

      case HyperSnackAnimationType.toLeft:
        // Disappear to the left
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(-1.0, 0.0),
          ).animate(exitAnim),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.0).animate(exitAnim),
            child: child,
          ),
        );

      case HyperSnackAnimationType.toRight:
        // Disappear to the right
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(1.0, 0.0),
          ).animate(exitAnim),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.0).animate(exitAnim),
            child: child,
          ),
        );

      // Fallback for when an entry animation type is specified (reverse-like behavior)
      case HyperSnackAnimationType.fromTop:
      case HyperSnackAnimationType.fromBottom:
        return SizeTransition(
          sizeFactor: Tween<double>(begin: 1.0, end: 0.0).animate(exitAnim),
          axisAlignment:
              (config.exitAnimationType == HyperSnackAnimationType.fromTop)
                  ? -1.0
                  : 1.0,
          child: FadeTransition(
              opacity: Tween<double>(begin: 1.0, end: 0.0).animate(exitAnim),
              child: child),
        );

      case HyperSnackAnimationType.fade:
      default:
        return FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.0).animate(exitAnim),
            child: child);
    }
  }
}

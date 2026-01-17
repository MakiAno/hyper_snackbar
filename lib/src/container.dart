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
    with TickerProviderStateMixin {
  /// The current configuration of the snackbar.
  late HyperConfig config;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Deprecated Timer, managing time with _durationController
  late AnimationController _durationController;

  // Whether it is in the middle of exit animation
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    config = widget.config;

    // 1. Controller for entry/exit animations
    _animationController = AnimationController(
      vsync: this,
      duration: config.enterAnimationDuration,
    );

    _animation =
        CurvedAnimation(parent: _animationController, curve: config.enterCurve);

    // 2. Controller for display duration management
    _durationController = AnimationController(
      vsync: this,
      // If null, set a reasonably long duration (it won't run, so it's fine)
      duration: config.displayDuration ?? const Duration(days: 365),
    );

    // Close when animation completes
    _durationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        dismiss();
      }
    });

    _startEntryAnimation();
  }

  void _startEntryAnimation() {
    _animationController.forward();
    _startDurationTimer(); // Start timer (controller) here!
  }

  // Method to start Controller instead of Timer
  void _startDurationTimer() {
    // Start counting if not persistent (null) and not zero
    if (config.displayDuration != null &&
        config.displayDuration != Duration.zero) {
      _durationController.forward();
    }
  }

  // Pause on scroll start
  void _handleScrollStart() {
    if (config.displayDuration != null) {
      _durationController.stop();
    }
  }

  // Resume on scroll end
  void _handleScrollEnd() {
    if (config.displayDuration != null && !_isExiting && mounted) {
      _durationController.forward();
    }
  }

  /// Updates the snackbar's content and appearance.
  void updateConfig(HyperConfig newConfig) {
    setState(() {
      config = newConfig;

      // If update comes during Exit, cancel and redisplay
      if (_isExiting) {
        _isExiting = false;
        _animationController.stop();
        _animationController.duration = config.enterAnimationDuration;
        _animationController.forward();
      }
    });

    // Reset Duration timer and restart
    _durationController.stop();
    _durationController.value = 0.0;
    if (config.displayDuration != null) {
      _durationController.duration = config.displayDuration;
      _startDurationTimer();
    }
  }

  /// Starts the exit animation for the snackbar.
  void dismiss() {
    if (!mounted || _isExiting) return;

    _durationController.stop(); // Stop timer

    setState(() {
      _isExiting = true;
    });

    _animationController.stop();
    _animationController.duration = config.exitAnimationDuration;
    _animationController.reset();

    _animationController.forward().then((_) {
      if (mounted && _isExiting) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = HyperSnackBarContent(
      config: config,
      onDismiss: dismiss,
      onScrollStart: _handleScrollStart,
      onScrollEnd: _handleScrollEnd,
      durationAnimation: _durationController, // Pass Controller
    );

    if (config.enableSwipe) {
      child = Dismissible(
        key: ValueKey(config.id ?? DateTime.now().toString()),
        direction: DismissDirection.horizontal,
        onUpdate: (details) {
          // Stop timer during swipe
          if (details.progress > 0) {
            _durationController.stop();
          }
        },
        onDismissed: (_) {
          widget.onDismiss();
        },
        child: child,
      );
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return _isExiting
            ? _applyExitAnimation(child!)
            : _applyEnterAnimation(child!);
      },
      child: child,
    );
  }

  // ---------------------------------------------------------------------------
  // Enter/Exit animations
  // ---------------------------------------------------------------------------
  Widget _applyEnterAnimation(Widget child) {
    switch (config.enterAnimationType) {
      case HyperSnackAnimationType.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.6, end: 1.0).animate(_animation),
          child: FadeTransition(
            opacity: _animation,
            child: child,
          ),
        );
      case HyperSnackAnimationType.left:
        return SlideTransition(
          position:
              Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero)
                  .animate(_animation),
          child: child,
        );
      case HyperSnackAnimationType.right:
        return SlideTransition(
          position:
              Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .animate(_animation),
          child: child,
        );
      case HyperSnackAnimationType.top:
        return SizeTransition(
          sizeFactor: _animation,
          axisAlignment: -1.0,
          child: FadeTransition(opacity: _animation, child: child),
        );
      case HyperSnackAnimationType.bottom:
        return SizeTransition(
          sizeFactor: _animation,
          axisAlignment: 1.0,
          child: FadeTransition(opacity: _animation, child: child),
        );
      case HyperSnackAnimationType.fade:
        return FadeTransition(opacity: _animation, child: child);
    }
  }

  Widget _applyExitAnimation(Widget child) {
    final exitAnim =
        CurvedAnimation(parent: _animationController, curve: config.exitCurve);
    switch (config.exitAnimationType) {
      case HyperSnackAnimationType.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 0.6).animate(exitAnim),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.0).animate(exitAnim),
            child: child,
          ),
        );
      case HyperSnackAnimationType.left:
        return SlideTransition(
          position:
              Tween<Offset>(begin: Offset.zero, end: const Offset(-1.0, 0.0))
                  .animate(exitAnim),
          child: FadeTransition(
              opacity: Tween<double>(begin: 1.0, end: 0.0).animate(exitAnim),
              child: child),
        );
      case HyperSnackAnimationType.right:
        return SlideTransition(
          position:
              Tween<Offset>(begin: Offset.zero, end: const Offset(1.0, 0.0))
                  .animate(exitAnim),
          child: FadeTransition(
              opacity: Tween<double>(begin: 1.0, end: 0.0).animate(exitAnim),
              child: child),
        );
      case HyperSnackAnimationType.top:
      case HyperSnackAnimationType.bottom:
        return SizeTransition(
          sizeFactor: Tween<double>(begin: 1.0, end: 0.0).animate(exitAnim),
          axisAlignment:
              (config.exitAnimationType == HyperSnackAnimationType.top)
                  ? -1.0
                  : 1.0,
          child: FadeTransition(
              opacity: Tween<double>(begin: 1.0, end: 0.0).animate(exitAnim),
              child: child),
        );
      case HyperSnackAnimationType.fade:
        return FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.0).animate(exitAnim),
            child: child);
    }
  }
}

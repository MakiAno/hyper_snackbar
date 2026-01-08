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
  /// The current configuration of the snackbar.
  late HyperConfig config;
  late AnimationController _controller;
  late Animation<double>
      _animation; // Curve for entry animation is already applied
  Timer? _timer;
  Timer? _scrollPauseTimer; // Timer for handling scroll pause/resume

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

    _animation = CurvedAnimation(parent: _controller, curve: config.enterCurve);

    _startEntryAnimation();
  }

  void _startEntryAnimation() {
    _controller.forward();
    _resetDismissTimer(); // Use helper method
  }

  // Helper method to set or reset the dismiss timer
  void _resetDismissTimer() {
    _timer?.cancel();
    _scrollPauseTimer?.cancel(); // Cancel any pending scroll resume timers

    // Treat Duration.zero as persistent (null)
    if (config.displayDuration != null &&
        config.displayDuration != Duration.zero) {
      _timer = Timer(config.displayDuration!, () {
        dismiss();
      });
    }
  }

  // Pauses the dismiss timer when scrolling starts
  void _handleScrollStart() {
    _timer?.cancel();
    _scrollPauseTimer?.cancel(); // Ensure no pending resume
  }

  // Resumes the dismiss timer when scrolling ends
  void _handleScrollEnd() {
    // Add a small delay before resuming the timer,
    // in case of quick flick scrolls that immediately trigger scrollEnd
    _scrollPauseTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted) {
        _resetDismissTimer();
      }
    });
  }

  /// Updates the snackbar's content and appearance.
  ///
  /// If the snackbar is in the middle of an exit animation, this method
  /// will cancel the exit and start a new entry animation with the updated
  /// configuration.
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

    _resetDismissTimer(); // Use the helper method
  }

  /// Starts the exit animation for the snackbar.
  ///
  /// Once the animation is complete, the `onDismiss` callback is called.
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
    _scrollPauseTimer?.cancel(); // Cancel scroll pause timer
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = HyperSnackBarContent(
      config: config,
      onDismiss: dismiss,
      onScrollStart: _handleScrollStart,
      onScrollEnd: _handleScrollEnd,
    );

    if (config.enableSwipe) {
      child = Dismissible(
        key: ValueKey(config.id ?? DateTime.now().toString()),
        direction: DismissDirection.horizontal,
        onUpdate: (details) {
          if (details.progress > 0) {
            _timer?.cancel();
            _scrollPauseTimer?.cancel();
          }
        },
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

      case HyperSnackAnimationType.left:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(_animation),
          child: child,
        );

      case HyperSnackAnimationType.right:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(_animation),
          child: child,
        );

      case HyperSnackAnimationType.top:
        return SizeTransition(
          sizeFactor: _animation,
          axisAlignment: -1.0, // Based on the top edge
          child: FadeTransition(opacity: _animation, child: child),
        );

      case HyperSnackAnimationType.bottom:
        return SizeTransition(
          sizeFactor: _animation,
          axisAlignment: 1.0, // Based on the bottom edge
          child: FadeTransition(opacity: _animation, child: child),
        );

      case HyperSnackAnimationType.fade:
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

      case HyperSnackAnimationType.left:
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

      case HyperSnackAnimationType.right:
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

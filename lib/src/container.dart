// ---------------------------------------------------------------------------
// 3. HyperSnackBarContainer (個別の通知とアニメーションを制御)
// ---------------------------------------------------------------------------

import 'dart:async';
import 'package:flutter/material.dart';
import 'config.dart';
import 'widget.dart';

class HyperSnackBarContainer extends StatefulWidget {
  final HyperConfig config;
  final VoidCallback onDismiss;

  const HyperSnackBarContainer({
    required super.key,
    required this.config,
    required this.onDismiss,
  });

  @override
  State<HyperSnackBarContainer> createState() => HyperSnackBarContainerState();
}

class HyperSnackBarContainerState extends State<HyperSnackBarContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _curvedAnimation;
  late Animation<Offset> _slideAnim;
  late Animation<double> _sizeAnim;
  late Animation<double> _fadeAnim;

  bool _isExiting = false;
  late HyperConfig _currentConfig;

  @override
  void initState() {
    super.initState();
    _currentConfig = widget.config;

    _controller = AnimationController(
      vsync: this,
      duration: _currentConfig.enterAnimationDuration,
    );
    _initializeAnimations();
  }

  // ID指定で中身だけ書き換えるメソッド
  void updateConfig(HyperConfig newConfig) {
    if (mounted) {
      setState(() {
        _currentConfig = newConfig;
      });
    }
  }

  void _initializeAnimations() {
    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.config.enterCurve,
      reverseCurve: widget.config.exitCurve,
    );

    Offset beginOffset;
    switch (widget.config.enterAnimationType) {
      case HyperSnackAnimationType.fromTop:
        beginOffset = const Offset(0, -1);
        break;
      case HyperSnackAnimationType.fromBottom:
        beginOffset = const Offset(0, 1);
        break;
      case HyperSnackAnimationType.fromLeft:
        beginOffset = const Offset(-1, 0);
        break;
      case HyperSnackAnimationType.fromRight:
        beginOffset = const Offset(1, 0);
        break;
      case HyperSnackAnimationType.fadeOnly:
        beginOffset = Offset.zero;
        break;
    }

    _slideAnim = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(_curvedAnimation);

    _sizeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_curvedAnimation);

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
        reverseCurve: Curves.linear,
      ),
    );
  }

  void startEnterAnimation() {
    _controller.forward();
  }

  Future<void> startExitAnimation() async {
    if (!mounted) return;
    setState(() {
      _isExiting = true;
    });
    // Exit用のDurationに書き換え
    _controller.duration = _currentConfig.exitAnimationDuration;
    return _controller.reverse(from: 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Offset exitEndOffset;
    switch (_currentConfig.exitAnimationType) {
      case HyperSnackExitAnimationType.toLeft:
        exitEndOffset = const Offset(-1.0, 0.0);
        break;
      case HyperSnackExitAnimationType.toRight:
        exitEndOffset = const Offset(1.0, 0.0);
        break;
      default:
        exitEndOffset = Offset.zero;
        break;
    }

    final Animation<Offset> currentSlideAnim;

    if (_isExiting) {
      currentSlideAnim = Tween<Offset>(
        begin: exitEndOffset,
        end: Offset.zero,
      ).animate(_curvedAnimation);
    } else {
      currentSlideAnim = _slideAnim;
    }

    final Animation<double> currentSizeAnim;
    if (_isExiting &&
        (_currentConfig.exitAnimationType ==
                HyperSnackExitAnimationType.toLeft ||
            _currentConfig.exitAnimationType ==
                HyperSnackExitAnimationType.toRight)) {
      currentSizeAnim = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
      );
    } else {
      currentSizeAnim = _sizeAnim;
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizeTransition(
            sizeFactor: currentSizeAnim,
            child: SlideTransition(
              position: currentSlideAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: child,
                ),
              ),
            ),
          );
        },
        child: HyperSnackBarWidget(
          config: _currentConfig, // 更新された設定を使用
          onDismiss: widget.onDismiss,
        ),
      ),
    );
  }
}

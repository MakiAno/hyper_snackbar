// ---------------------------------------------------------------------------
// 3. HyperSnackBarContainer (個別の通知とアニメーションを制御)
// ---------------------------------------------------------------------------

import 'dart:async';
import 'package:flutter/material.dart';
import 'config.dart';
import 'widget.dart';

class HyperSnackBarContainer extends StatefulWidget {
  // ★変更: updateConfigで書き換えるため final を外すケースもあるが、
  // ここでは StatefulWidget なので widget.config は不変。
  // 新しい config を受け取るために State 側で変数を管理する。
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

  // ★追加: 現在表示中のConfig (更新に対応するため)
  late HyperConfig _currentConfig;

  @override
  void initState() {
    super.initState();
    _currentConfig = widget.config; // 初期化

    _controller = AnimationController(
      vsync: this,
      duration: _currentConfig.enterAnimationDuration,
    );
    _initializeAnimations();
  }

  // ★追加: ID指定で中身だけ書き換えるメソッド
  void updateConfig(HyperConfig newConfig) {
    setState(() {
      _currentConfig = newConfig;
    });
    // 必要に応じてタイマーのリセットなどをここで行うことも可能
  }

  void _initializeAnimations() {
    // アニメーション設定は _currentConfig ではなく widget.config (初期値) を基準にするか、
    // 更新時にアニメーション再構築するかは設計次第ですが、
    // ここでは「中身の書き換え」を主目的とするため、初期アニメーション設定を維持します。

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
    // ★修正: _currentConfig を参照
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
    // ★修正: _currentConfig を参照
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
          config: _currentConfig, // ★修正: Stateで保持しているConfigを渡す
          onDismiss: widget.onDismiss,
        ),
      ),
    );
  }
}

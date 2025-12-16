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
  late Animation<double> _animation; // 入場用カーブ適用済み
  Timer? _timer;

  // 退出アニメーション中かどうか
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    config = widget.config;
    _controller = AnimationController(
      vsync: this,
      duration: config.enterAnimationDuration,
    );

    // 入場用のカーブを適用
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

      // 退出中に更新が来たら復活させる処理
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
      // 完了時にまだ退出モードなら削除実行
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
  // 入場アニメーション (Enter)
  // ---------------------------------------------------------------------------
  Widget _applyEnterAnimation(Widget child) {
    // _animation には既に config.enterCurve が適用されています

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
          axisAlignment: -1.0, // 上端基準
          child: FadeTransition(opacity: _animation, child: child),
        );

      case HyperSnackAnimationType.fromBottom:
        return SizeTransition(
          sizeFactor: _animation,
          axisAlignment: 1.0, // 下端基準
          child: FadeTransition(opacity: _animation, child: child),
        );

      case HyperSnackAnimationType.fade:
      default:
        return FadeTransition(opacity: _animation, child: child);
    }
  }

  // ---------------------------------------------------------------------------
  // 退出アニメーション (Exit)
  // ---------------------------------------------------------------------------
  Widget _applyExitAnimation(Widget child) {
    // 退出時は 0.0 -> 1.0 へ進むコントローラーを使うが、
    // アニメーションの意味的には "Current -> Gone" なので、
    // Tween等で調整する。

    final exitAnim =
        CurvedAnimation(parent: _controller, curve: config.exitCurve);

    switch (config.exitAnimationType) {
      case HyperSnackAnimationType.scale:
        // 1.0 -> 0.0 へ縮小
        return ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 0.0).animate(exitAnim),
          child: child,
        );

      case HyperSnackAnimationType.toLeft:
        // 左へ消える
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
        // 右へ消える
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

      // 入場用のタイプが指定された場合のフォールバック（逆再生的な挙動）
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

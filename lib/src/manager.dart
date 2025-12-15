// ---------------------------------------------------------------------------
// 2. HyperManager (手動制御対応)
// ---------------------------------------------------------------------------

import 'dart:async';
import 'package:flutter/material.dart';

import 'config.dart';
import 'container.dart';

/// A manager class for displaying and controlling HyperSnackbars.
///
/// Use [HyperSnackbar.show] to display a snackbar from anywhere in your app.
/// This class is implemented as a singleton.
// Configはcontextを持たない純粋なデータクラスであることを想定
// import 'hyper_config.dart';
// import 'hyper_snackbar_container.dart';

class HyperSnackbar {
  // 1. シングルトン化 (どこから HyperSnackbar() と呼んでも同じインスタンス)
  static final HyperSnackbar _instance = HyperSnackbar._internal();
  factory HyperSnackbar() => _instance;
  HyperSnackbar._internal();

  // 2. GlobalKey (Contextなしで動かすための鍵)
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // 内部状態
  OverlayEntry? _overlayEntry;
  final List<Widget> _topEntries = [];
  final List<Widget> _bottomEntries = [];

  /// 表示メソッド
  /// [context] は任意です。
  /// - 渡すと: そのcontext（テーマや位置）を基準に表示します。
  /// - 渡さないと: MaterialAppに設定したnavigatorKeyを使って表示します。
  void show(HyperConfig config, {BuildContext? context}) {
    // ハイブリッドな初期化処理を呼び出し
    _initOverlay(context);

    // 初期化に失敗（Key未設定かつContextなし）したらガード
    if (_overlayEntry == null) {
      debugPrint(
          '⚠️ HyperSnackbar Error: Navigator key is not set and no context was provided.');
      return;
    }

    final targetList = (config.position == HyperSnackPosition.top)
        ? _topEntries
        : _bottomEntries;

    // --- IDによる更新チェック (重複防止) ---
    if (config.id != null) {
      final existingIndex = targetList.indexWhere((w) {
        if (w is HyperSnackBarContainer) {
          return w.config.id == config.id;
        }
        return false;
      });

      if (existingIndex != -1) {
        final container = targetList[existingIndex] as HyperSnackBarContainer;
        final key = container.key as GlobalKey<HyperSnackBarContainerState>;

        // キー経由で安全に更新
        if (key.currentState != null && key.currentState!.mounted) {
          key.currentState!.updateConfig(config);
          return; // 新規追加せずに終了
        }
      }
    }

    // --- 表示数制限 ---
    while (targetList.length >= config.maxVisibleCount) {
      // 内部メソッドの実装は省略していますが、ここで古いものを消す
      _forceRemoveOldest(config.position, newestOnTop: config.newestOnTop);
    }

    // --- コンテナの作成 ---
    final GlobalKey<HyperSnackBarContainerState> containerKey = GlobalKey();

    final newContainer = HyperSnackBarContainer(
      key: containerKey,
      config: config,
      onDismiss: () => removeNotification(config),
    );

    // --- リストへの追加 ---
    if (config.newestOnTop) {
      targetList.insert(0, newContainer);
    } else {
      targetList.add(newContainer);
    }

    // --- 再描画通知 ---
    // _overlayEntryは _initOverlay で確実に作られているか、メソッド冒頭で弾いているため ! でOK
    if (_overlayEntry!.mounted) {
      _overlayEntry!.markNeedsBuild();
    }

    // --- アニメーション開始 ---
    WidgetsBinding.instance.addPostFrameCallback((_) {
      containerKey.currentState?.startEnterAnimation();
    });

    // --- 自動消去タイマー ---
    if (config.displayDuration != null) {
      Future.delayed(config.displayDuration!, () {
        removeNotification(config);
      });
    }
  }

  /// Overlayの初期化 (ハイブリッド対応版)
  void _initOverlay(BuildContext? targetContext) {
    if (_overlayEntry != null && _overlayEntry!.mounted) return;

    OverlayState? overlayState;
    BuildContext? effectiveContext;

    // A. ユーザーがcontextを渡していれば優先使用
    if (targetContext != null) {
      overlayState = Overlay.maybeOf(targetContext);
      effectiveContext = targetContext;
    }

    // B. なければGlobalKeyを使用
    if (overlayState == null) {
      overlayState = navigatorKey.currentState?.overlay;
      effectiveContext = navigatorKey.currentContext;
    }

    if (overlayState == null) return;

    // 言語方向の取得
    final textDirection = (effectiveContext != null)
        ? Directionality.maybeOf(effectiveContext) ?? TextDirection.ltr
        : TextDirection.ltr;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Directionality(
          textDirection: textDirection,
          child: Stack(
            children: [
              // Top Area
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Material(
                    type: MaterialType.transparency,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _topEntries,
                    ),
                  ),
                ),
              ),
              // Bottom Area
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  top: false,
                  child: Material(
                    type: MaterialType.transparency,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _bottomEntries,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    overlayState.insert(_overlayEntry!);
  }

  // ※ 以下のメソッドは元のコードにある前提です
  // void removeNotification(HyperConfig config) { ... }
  // void _forceRemoveOldest(...) { ... }

  /// Clears all currently displayed snackbars.
  ///
  /// If [animated] is true, they will animate out.
  void clearAll({bool animated = true}) {
    final allWidgets = [..._topEntries, ..._bottomEntries];
    if (allWidgets.isEmpty) return;

    if (animated) {
      for (var widget in allWidgets) {
        if (widget is HyperSnackBarContainer) {
          removeNotification(widget.config);
        }
      }
    } else {
      _topEntries.clear();
      _bottomEntries.clear();
      if (_overlayEntry != null && _overlayEntry!.mounted) {
        _overlayEntry!.remove();
      }
      _overlayEntry = null;
    }
  }

  /// Removes a specific notification based on its [config].
  void removeNotification(HyperConfig config,
      {bool immediate = false, bool swiped = false}) {
    final targetList = (config.position == HyperSnackPosition.top)
        ? _topEntries
        : _bottomEntries;

    final index = targetList.indexWhere((widget) {
      final container = widget as HyperSnackBarContainer;
      if (container.config == config) return true;
      if (config.id != null && container.config.id == config.id) return true;
      return false;
    });

    if (index != -1) {
      final containerToRemove = targetList[index] as HyperSnackBarContainer;
      final containerKey =
          containerToRemove.key as GlobalKey<HyperSnackBarContainerState>;

      if (immediate || swiped) {
        _finalizeRemoval(targetList, containerToRemove);
        return;
      }

      if (containerKey.currentState != null &&
          containerKey.currentState!.mounted) {
        containerKey.currentState?.startExitAnimation().then((_) {
          _finalizeRemoval(targetList, containerToRemove);
        });
      } else {
        _finalizeRemoval(targetList, containerToRemove);
      }
    }
  }

  void _finalizeRemoval(List<Widget> targetList, Widget containerToRemove) {
    if (targetList.contains(containerToRemove)) {
      targetList.remove(containerToRemove);
    }
    // 全て消えたらOverlayEntryも削除
    if (_topEntries.isEmpty && _bottomEntries.isEmpty) {
      if (_overlayEntry != null && _overlayEntry!.mounted) {
        _overlayEntry!.remove();
      }
      _overlayEntry = null;
    } else {
      if (_overlayEntry != null && _overlayEntry!.mounted) {
        _overlayEntry!.markNeedsBuild();
      }
    }
  }

  void _forceRemoveOldest(HyperSnackPosition position,
      {bool newestOnTop = true}) {
    final targetList =
        (position == HyperSnackPosition.top) ? _topEntries : _bottomEntries;

    if (targetList.isNotEmpty) {
      final oldestContainer = newestOnTop
          ? targetList.last as HyperSnackBarContainer
          : targetList.first as HyperSnackBarContainer;

      // immediate: true で即時削除
      removeNotification(oldestContainer.config, immediate: true);
    }
  }
}

/// Convenience extensions for common snackbar types.
extension HyperManagerPresets on HyperSnackbar {
  /// Shows a success snackbar (green background).
  void showSuccess({
    required String title,
    String? message,
    Duration? duration = const Duration(seconds: 4),
  }) {
    show(HyperConfig(
      title: title,
      message: message,
      backgroundColor: Colors.green.shade600,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      displayDuration: duration,
    ));
  }

  /// Shows an error snackbar (red background).
  void showError({
    required String title,
    String? message,
    Duration? duration = const Duration(seconds: 4),
  }) {
    show(HyperConfig(
      title: title,
      message: message,
      backgroundColor: Colors.red.shade600,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      displayDuration: duration,
    ));
  }

  /// Shows a warning snackbar (amber background).
  void showWarning({
    required String title,
    String? message,
    Duration? duration = const Duration(seconds: 4),
  }) {
    show(HyperConfig(
      title: title,
      message: message,
      backgroundColor: Colors.amber.shade700,
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      displayDuration: duration,
    ));
  }

  /// Shows an info snackbar (blue background).
  void showInfo({
    required String title,
    String? message,
    Duration? duration = const Duration(seconds: 4),
  }) {
    show(HyperConfig(
      title: title,
      message: message,
      backgroundColor: Colors.blue.shade600,
      icon: const Icon(Icons.info_outline, color: Colors.white),
      displayDuration: duration,
    ));
  }
}

extension HyperSnackbarExtensions on BuildContext {
  // contextから直接呼び出せるメソッドを追加
  void showHyperSnackbar(HyperConfig config) {
    // 内部で元のクラスのメソッドを呼んでいるだけ！
    HyperSnackbar().show(config, context: this);
  }
}

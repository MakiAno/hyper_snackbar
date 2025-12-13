// ---------------------------------------------------------------------------
// 2. HyperManager (手動制御対応)
// ---------------------------------------------------------------------------

import 'dart:async';
import 'package:flutter/material.dart';

import 'config.dart';
import 'container.dart';

class HyperManager {
  static final HyperManager _instance = HyperManager._internal();
  factory HyperManager() => _instance;
  HyperManager._internal();

  OverlayEntry? _overlayEntry;

  final List<Widget> _topEntries = [];
  final List<Widget> _bottomEntries = [];

  void _initOverlay(BuildContext context) {
    if (_overlayEntry != null && _overlayEntry!.mounted) return;

    final overlayState = Overlay.maybeOf(context);
    if (overlayState == null) {
      debugPrint('⚠️ HyperManager Warning: Overlay not found.');
      return;
    }

    // RTL対応
    final textDirection = Directionality.maybeOf(context) ?? TextDirection.ltr;

    _overlayEntry = OverlayEntry(
      builder: (context) => Directionality(
        textDirection: textDirection,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Builder(
                  builder: (BuildContext context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _topEntries.toList(),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Builder(
                  builder: (BuildContext context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _bottomEntries.toList().reversed.toList(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlayState.insert(_overlayEntry!);
  }

  void show(BuildContext context, HyperConfig config) {
    _initOverlay(context);

    if (_overlayEntry == null) return;

    final targetList = (config.position == HyperSnackPosition.top)
        ? _topEntries
        : _bottomEntries;

    // IDによる更新チェック
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
        if (key.currentState != null && key.currentState!.mounted) {
          key.currentState!.updateConfig(config);
          return; // 新規追加せずに終了
        }
      }
    }

    // 表示数制限（無限ループ対策済み）
    while (targetList.length >= config.maxVisibleCount) {
      _forceRemoveOldest(config.position, newestOnTop: config.newestOnTop);
    }

    final GlobalKey<HyperSnackBarContainerState> containerKey = GlobalKey();

    final newContainer = HyperSnackBarContainer(
      key: containerKey,
      config: config,
      onDismiss: () => removeNotification(config),
    );

    // 追加位置（先頭 or 末尾）
    if (config.newestOnTop) {
      targetList.insert(0, newContainer);
    } else {
      targetList.add(newContainer);
    }

    if (_overlayEntry!.mounted) {
      _overlayEntry!.markNeedsBuild();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      containerKey.currentState?.startEnterAnimation();
    });

    if (config.displayDuration != null) {
      Future.delayed(config.displayDuration!, () {
        removeNotification(config);
      });
    }
  }

  void dismissById(String id) {
    final allWidgets = [..._topEntries, ..._bottomEntries];
    for (var widget in allWidgets) {
      if (widget is HyperSnackBarContainer && widget.config.id == id) {
        removeNotification(widget.config);
        return;
      }
    }
  }

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

// プリセット
extension HyperManagerPresets on HyperManager {
  void showSuccess(
    BuildContext context, {
    required String title,
    String? message,
    Duration? duration = const Duration(seconds: 4),
  }) {
    show(
        context,
        HyperConfig(
          title: title,
          message: message,
          backgroundColor: Colors.green.shade600,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          displayDuration: duration,
        ));
  }

  void showError(
    BuildContext context, {
    required String title,
    String? message,
    Duration? duration = const Duration(seconds: 4),
  }) {
    show(
        context,
        HyperConfig(
          title: title,
          message: message,
          backgroundColor: Colors.red.shade600,
          icon: const Icon(Icons.error_outline, color: Colors.white),
          displayDuration: duration,
        ));
  }

  void showWarning(
    BuildContext context, {
    required String title,
    String? message,
    Duration? duration = const Duration(seconds: 4),
  }) {
    show(
        context,
        HyperConfig(
          title: title,
          message: message,
          backgroundColor: Colors.amber.shade700,
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
          displayDuration: duration,
        ));
  }

  void showInfo(
    BuildContext context, {
    required String title,
    String? message,
    Duration? duration = const Duration(seconds: 4),
  }) {
    show(
        context,
        HyperConfig(
          title: title,
          message: message,
          backgroundColor: Colors.blue.shade600,
          icon: const Icon(Icons.info_outline, color: Colors.white),
          displayDuration: duration,
        ));
  }
}

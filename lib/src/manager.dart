import 'dart:async';
import 'package:flutter/material.dart';
import 'config.dart';
import 'container.dart';

/// Singleton Manager for handling overlays.
class HyperSnackbar {
  static final HyperSnackbar _instance = HyperSnackbar._internal();
  factory HyperSnackbar() => _instance;
  HyperSnackbar._internal();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  OverlayEntry? _overlayEntry;
  final List<Widget> _topEntries = [];
  final List<Widget> _bottomEntries = [];

  final StreamController<List<Widget>> _topStream =
      StreamController<List<Widget>>.broadcast();
  final StreamController<List<Widget>> _bottomStream =
      StreamController<List<Widget>>.broadcast();

  bool _isOverlayMounted = false;

  void show(HyperConfig config, {BuildContext? context}) {
    _mountOverlayIfNeeded(context);

    // ID重複チェック & 更新
    if (config.id != null) {
      if (_tryUpdate(config, _topEntries, _topStream)) return;
      if (_tryUpdate(config, _bottomEntries, _bottomStream)) return;
    }

    // 表示数制限のロジック
    final targetList = (config.position == HyperSnackPosition.top)
        ? _topEntries
        : _bottomEntries;
    while (targetList.length >= config.maxVisibleCount) {
      _forceRemoveOldest(config.position, newestOnTop: config.newestOnTop);
    }

    final uniqueKey = GlobalKey<HyperSnackBarContainerState>();
    final widget = HyperSnackBarContainer(
      key: uniqueKey,
      config: config,
      onDismiss: () => removeNotification(config),
    );

    if (config.position == HyperSnackPosition.top) {
      if (config.newestOnTop) {
        _topEntries.insert(0, widget);
      } else {
        _topEntries.add(widget);
      }
      _topStream.add(_topEntries);
    } else {
      if (config.newestOnTop) {
        _bottomEntries.insert(0, widget);
      } else {
        _bottomEntries.add(widget);
      }
      _bottomStream.add(_bottomEntries);
    }
  }

  void dismissById(String id) {
    void findAndDismiss(List<Widget> targetList) {
      for (final widget in targetList) {
        if (widget is HyperSnackBarContainer && widget.config.id == id) {
          final key = widget.key as GlobalKey<HyperSnackBarContainerState>?;
          if (key != null &&
              key.currentState != null &&
              key.currentState!.mounted) {
            key.currentState!.dismiss();
          } else {
            removeNotification(widget.config);
          }
          return;
        }
      }
    }

    findAndDismiss(_topEntries);
    findAndDismiss(_bottomEntries);
  }

  void clearAll() {
    final allWidgets = [..._topEntries, ..._bottomEntries];
    for (final widget in allWidgets) {
      if (widget is HyperSnackBarContainer) {
        final key = widget.key as GlobalKey<HyperSnackBarContainerState>?;
        if (key != null &&
            key.currentState != null &&
            key.currentState!.mounted) {
          key.currentState!.dismiss();
        } else {
          removeNotification(widget.config);
        }
      }
    }
  }

  // --- Presets ---
  void showSuccess(
      {required String title, String? message, BuildContext? context}) {
    show(
        HyperConfig(
          title: title,
          message: message,
          backgroundColor: Colors.green.shade600,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        ),
        context: context);
  }

  void showError(
      {required String title, String? message, BuildContext? context}) {
    show(
        HyperConfig(
          title: title,
          message: message,
          backgroundColor: Colors.red.shade600,
          icon: const Icon(Icons.error, color: Colors.white),
        ),
        context: context);
  }

  void showWarning(
      {required String title, String? message, BuildContext? context}) {
    show(
        HyperConfig(
          title: title,
          message: message,
          backgroundColor: Colors.orange.shade700,
          icon: const Icon(Icons.warning, color: Colors.white),
        ),
        context: context);
  }

  void showInfo(
      {required String title, String? message, BuildContext? context}) {
    show(
        HyperConfig(
          title: title,
          message: message,
          backgroundColor: Colors.blue.shade600,
          icon: const Icon(Icons.info, color: Colors.white),
        ),
        context: context);
  }

  // --- Internal Logic ---

  bool _tryUpdate(
      HyperConfig newConfig, List<Widget> list, StreamController stream) {
    final index = list.indexWhere(
        (w) => (w is HyperSnackBarContainer) && w.config.id == newConfig.id);
    if (index != -1) {
      final oldWidget = list[index] as HyperSnackBarContainer;
      final key = oldWidget.key as GlobalKey<HyperSnackBarContainerState>;
      key.currentState?.updateConfig(newConfig);

      list[index] = HyperSnackBarContainer(
        key: key,
        config: newConfig,
        onDismiss: oldWidget.onDismiss,
      );
      return true;
    }
    return false;
  }

  void removeNotification(HyperConfig config, {bool immediate = false}) {
    void finalizeRemoval(List<Widget> list, StreamController stream) {
      list.removeWhere((w) {
        if (w is HyperSnackBarContainer) {
          // 完全に一致するか、もしくはIDが一致すれば削除対象とする
          if (w.config == config) return true;
          if (config.id != null && w.config.id == config.id) return true;
        }
        return false;
      });
      stream.add(list);
    }

    if (immediate) {
      if (config.position == HyperSnackPosition.top) {
        finalizeRemoval(_topEntries, _topStream);
      } else {
        finalizeRemoval(_bottomEntries, _bottomStream);
      }
      return;
    }

    if (config.position == HyperSnackPosition.top) {
      finalizeRemoval(_topEntries, _topStream);
    } else {
      finalizeRemoval(_bottomEntries, _bottomStream);
    }
  }

  void _forceRemoveOldest(HyperSnackPosition position,
      {bool newestOnTop = true}) {
    final targetList =
        (position == HyperSnackPosition.top) ? _topEntries : _bottomEntries;
    if (targetList.isEmpty) return;

    final oldestWidget = newestOnTop ? targetList.last : targetList.first;

    if (oldestWidget is HyperSnackBarContainer) {
      removeNotification(oldestWidget.config, immediate: true);
    }
  }

  void _mountOverlayIfNeeded(BuildContext? context) {
    if (_isOverlayMounted) return;
    OverlayState? overlayState;

    if (context != null) {
      overlayState = Overlay.of(context);
    } else {
      if (navigatorKey.currentState == null) {
        throw FlutterError(
            'HyperSnackbar: Context was not provided and navigatorKey is not registered.\n'
            'Please Add `navigatorKey: HyperSnackbar.navigatorKey` to your MaterialApp.');
      }
      overlayState = navigatorKey.currentState!.overlay;
    }

    if (overlayState == null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => _HyperOverlayManager(
        topStream: _topStream.stream,
        bottomStream: _bottomStream.stream,
        // ★ 修正ポイント: 現在のリストを初期データとして渡す
        initialTopData: _topEntries,
        initialBottomData: _bottomEntries,
      ),
    );
    overlayState.insert(_overlayEntry!);
    _isOverlayMounted = true;
  }
}

class _HyperOverlayManager extends StatelessWidget {
  final Stream<List<Widget>> topStream;
  final Stream<List<Widget>> bottomStream;

  // ★ 追加: 初期データを受け取るフィールド
  final List<Widget> initialTopData;
  final List<Widget> initialBottomData;

  const _HyperOverlayManager({
    required this.topStream,
    required this.bottomStream,
    required this.initialTopData,
    required this.initialBottomData,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: StreamBuilder<List<Widget>>(
              stream: topStream,
              // ★ 修正ポイント: 初期データを空ではなく、現在のリストにする
              initialData: initialTopData,
              builder: (context, s) => Column(
                  mainAxisSize: MainAxisSize.min, children: s.data ?? []),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            top: false,
            child: StreamBuilder<List<Widget>>(
              stream: bottomStream,
              // ★ 修正ポイント: 初期データを空ではなく、現在のリストにする
              initialData: initialBottomData,
              builder: (context, s) => Column(
                  mainAxisSize: MainAxisSize.min, children: s.data ?? []),
            ),
          ),
        ),
      ],
    );
  }
}

extension HyperSnackbarExtensions on BuildContext {
  void showHyperSnackbar(HyperConfig config) {
    HyperSnackbar().show(config, context: this);
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'config.dart';
import 'container.dart';

/// A static manager class for displaying and managing HyperSnackbars.
///
/// This class handles the overlay insertion, queuing, and dismissal of snackbars.
/// You can access the methods via static calls.
class HyperSnackbar {
  HyperSnackbar._();

  /// The global navigator key used to find the overlay context.
  ///
  /// Add this key to your [MaterialApp] or [GetMaterialApp]:
  /// ```dart
  /// MaterialApp(
  ///   navigatorKey: HyperSnackbar.navigatorKey,
  ///   ...
  /// )
  /// ```
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static OverlayEntry? _overlayEntry;
  static final List<Widget> _topEntries = [];
  static final List<Widget> _bottomEntries = [];
  static final List<HyperConfig> _queue = [];
  static bool _isQueueProcessing = false;

  static final StreamController<List<Widget>> _topStream =
      StreamController<List<Widget>>.broadcast();
  static final StreamController<List<Widget>> _bottomStream =
      StreamController<List<Widget>>.broadcast();

  static bool _isOverlayMounted = false;

  /// Displays a customizable snackbar.
  ///
  /// Shows a custom snackbar with detailed configuration as named parameters.
  /// For reusing configurations, consider creating a [HyperConfig] object and
  /// using [showFromConfig] instead.
  ///
  /// [title] is the headline of the snackbar.
  /// [message] is the main content text.
  /// [icon] is the widget displayed on the left.
  /// [useAdaptiveLoader] if true, displays a platform-adaptive loading indicator
  /// in place of the icon. This overrides [icon] if provided.
  static void show(
      {required String title,
      String? id,
      String? message,
      Widget? icon,
      HyperSnackAction? action,
      MainAxisAlignment actionAlignment = MainAxisAlignment.end,
      Widget? content,
      VoidCallback? onTap,
      TextStyle? titleStyle,
      TextStyle? messageStyle,
      BoxBorder? border,
      EdgeInsetsGeometry margin = EdgeInsets.zero,
      EdgeInsetsGeometry padding =
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      Color? backgroundColor,
      Color? textColor,
      double borderRadius = 12.0,
      double elevation = 4.0,
      Duration? displayDuration = const Duration(seconds: 4),
      bool showCloseButton = true,
      bool enableSwipe = true,
      bool newestOnTop = true,
      int maxVisibleCount = 3,
      HyperSnackPosition position = HyperSnackPosition.top,
      HyperSnackDisplayMode displayMode = HyperSnackDisplayMode.stack,
      int? maxLines = 5,
      bool scrollable = false,
      double? messageMaxHeight,
      Duration enterAnimationDuration = const Duration(milliseconds: 300),
      Duration exitAnimationDuration = const Duration(milliseconds: 500),
      Curve enterCurve = Curves.easeOutQuart,
      Curve exitCurve = Curves.easeOut,
      HyperSnackAnimationType enterAnimationType = HyperSnackAnimationType.top,
      HyperSnackAnimationType exitAnimationType = HyperSnackAnimationType.left,
      double? progressBarWidth,
      Color? progressBarColor,
      bool useAdaptiveLoader = false,
      BuildContext? context}) {
    final config = HyperConfig(
      title: title,
      id: id,
      message: message,
      icon: icon,
      action: action,
      actionAlignment: actionAlignment,
      content: content,
      onTap: onTap,
      titleStyle: titleStyle,
      messageStyle: messageStyle,
      border: border,
      margin: margin,
      padding: padding,
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderRadius: borderRadius,
      elevation: elevation,
      displayDuration: displayDuration,
      showCloseButton: showCloseButton,
      enableSwipe: enableSwipe,
      newestOnTop: newestOnTop,
      maxVisibleCount: maxVisibleCount,
      position: position,
      displayMode: displayMode,
      maxLines: maxLines,
      scrollable: scrollable,
      messageMaxHeight: messageMaxHeight,
      enterAnimationDuration: enterAnimationDuration,
      exitAnimationDuration: exitAnimationDuration,
      enterCurve: enterCurve,
      exitCurve: exitCurve,
      enterAnimationType: enterAnimationType,
      exitAnimationType: exitAnimationType,
      progressBarWidth: progressBarWidth,
      progressBarColor: progressBarColor,
      useAdaptiveLoader: useAdaptiveLoader,
    );
    showFromConfig(config, context: context);
  }

  /// Shows a snackbar using a pre-configured [HyperConfig] object.
  /// This is useful for reusing the same design across different parts of your app.
  static void showFromConfig(HyperConfig config, {BuildContext? context}) {
    _mountOverlayIfNeeded(context);

    if (config.displayMode == HyperSnackDisplayMode.queue) {
      _queue.add(config);
      if (!_isQueueProcessing) {
        _processQueue();
      }
      return;
    }

    // Check for duplicate ID & update
    if (config.id != null) {
      if (_tryUpdate(config, _topEntries, _topStream)) return;
      if (_tryUpdate(config, _bottomEntries, _bottomStream)) return;
    }

    // Logic for limiting the number of visible snackbars
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

  static void _processQueue() {
    if (_queue.isEmpty) {
      _isQueueProcessing = false;
      return;
    }

    _isQueueProcessing = true;
    final config = _queue.removeAt(0);

    final uniqueKey = GlobalKey<HyperSnackBarContainerState>();
    final widget = HyperSnackBarContainer(
      key: uniqueKey,
      config: config,
      onDismiss: () => removeNotification(
        config,
        onComplete: () {
          _isQueueProcessing = false;
          _processQueue();
        },
      ),
    );

    if (config.position == HyperSnackPosition.top) {
      _topEntries.add(widget);
      _topStream.add(_topEntries);
    } else {
      _bottomEntries.add(widget);
      _bottomStream.add(_bottomEntries);
    }
  }

  /// Dismisses a snackbar by its unique [id].
  static void dismissById(String id) {
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

  /// Removes all currently displayed snackbars.
  ///
  /// By default, it dismisses them with their configured exit animation.
  /// If [animated] is set to `false`, it will remove them immediately without animation.
  static void clearAll({bool animated = true}) {
    _isQueueProcessing = false;
    _queue.clear();

    if (animated) {
      final allEntries = [..._topEntries, ..._bottomEntries];
      for (final widget in allEntries) {
        if (widget is HyperSnackBarContainer) {
          final key = widget.key as GlobalKey<HyperSnackBarContainerState>?;
          if (key != null &&
              key.currentState != null &&
              key.currentState!.mounted) {
            key.currentState!.dismiss();
          } else {
            // If the widget is not mounted, remove it directly.
            removeNotification(widget.config);
          }
        }
      }
    } else {
      _topEntries.clear();
      _bottomEntries.clear();
      _topStream.add([]);
      _bottomStream.add([]);
      if (_overlayEntry != null) {
        try {
          _overlayEntry?.remove();
        } catch (_) {}
        _overlayEntry = null;
        _isOverlayMounted = false;
      }
    }
  }

  /// Checks if any snackbar is currently visible on the screen.
  ///
  /// Returns `true` if there is at least one snackbar being shown,
  /// otherwise returns `false`.
  static bool get isSnackbarOpen =>
      _topEntries.isNotEmpty || _bottomEntries.isNotEmpty;

  /// Checks if a specific snackbar is currently visible on the screen by its ID.
  ///
  /// Returns `true` if the snackbar with the given ID is found and visible,
  /// otherwise returns `false`.
  static bool isSnackbarOpenById(String id) {
    final allEntries = [..._topEntries, ..._bottomEntries];
    return allEntries.any(
        (widget) => widget is HyperSnackBarContainer && widget.config.id == id);
  }

// --- Presets ---

  /// Displays a success snackbar (Green background, check icon).
  static void showSuccess({
    required String title,
    String? message,
    BuildContext? context,
    EdgeInsetsGeometry margin = const EdgeInsets.all(8.0), // Default margin
    HyperSnackPosition position = HyperSnackPosition.top,
    Duration? displayDuration = const Duration(seconds: 4),
    double? progressBarWidth,
  }) {
    show(
      title: title,
      message: message,
      backgroundColor: Colors.green.shade600,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      context: context,
      margin: margin,
      position: position,
      displayDuration: displayDuration,
      progressBarWidth: progressBarWidth,
    );
  }

  /// Displays an error snackbar (Red background, error icon).
  static void showError({
    required String title,
    String? message,
    BuildContext? context,
    EdgeInsetsGeometry margin = const EdgeInsets.all(8.0),
    HyperSnackPosition position = HyperSnackPosition.top,
    Duration? displayDuration = const Duration(seconds: 4),
    double? progressBarWidth,
  }) {
    show(
      title: title,
      message: message,
      backgroundColor: Colors.red.shade600,
      icon: const Icon(Icons.error, color: Colors.white),
      context: context,
      margin: margin,
      position: position,
      displayDuration: displayDuration,
      progressBarWidth: progressBarWidth,
    );
  }

  /// Displays a warning snackbar (Orange background, warning icon).
  static void showWarning({
    required String title,
    String? message,
    BuildContext? context,
    EdgeInsetsGeometry margin = const EdgeInsets.all(8.0),
    HyperSnackPosition position = HyperSnackPosition.top,
    Duration? displayDuration = const Duration(seconds: 4),
    double? progressBarWidth,
  }) {
    show(
      title: title,
      message: message,
      backgroundColor: Colors.orange.shade700,
      icon: const Icon(Icons.warning, color: Colors.white),
      context: context,
      margin: margin,
      position: position,
      displayDuration: displayDuration,
      progressBarWidth: progressBarWidth,
    );
  }

  /// Displays an info snackbar (Blue background, info icon).
  static void showInfo({
    required String title,
    String? message,
    BuildContext? context,
    EdgeInsetsGeometry margin = const EdgeInsets.all(8.0),
    HyperSnackPosition position = HyperSnackPosition.top,
    Duration? displayDuration = const Duration(seconds: 4),
    double? progressBarWidth,
  }) {
    show(
      title: title,
      message: message,
      backgroundColor: Colors.blue.shade600,
      icon: const Icon(Icons.info, color: Colors.white),
      context: context,
      margin: margin,
      position: position,
      displayDuration: displayDuration,
      progressBarWidth: progressBarWidth,
    );
  }

  // --- Internal Logic ---

  /// Updates the state of an existing snackbar without removing/re-adding it.
  /// This ensures smooth transitions (e.g., loading -> success) without exit animations.
  static bool _tryUpdate(
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

  static void removeNotification(
    HyperConfig config, {
    bool immediate = false,
    VoidCallback? onComplete,
  }) {
    void finalizeRemoval(List<Widget> list, StreamController stream) {
      list.removeWhere((w) {
        if (w is HyperSnackBarContainer) {
          if (w.config == config) return true;
          if (config.id != null && w.config.id == config.id) return true;
        }
        return false;
      });
      stream.add(list);

      if (onComplete != null && _isQueueProcessing) {
        onComplete();
      }
    }

    if (config.position == HyperSnackPosition.top) {
      finalizeRemoval(_topEntries, _topStream);
    } else {
      finalizeRemoval(_bottomEntries, _bottomStream);
    }
  }

  static void _forceRemoveOldest(HyperSnackPosition position,
      {bool newestOnTop = true}) {
    final targetList =
        (position == HyperSnackPosition.top) ? _topEntries : _bottomEntries;
    if (targetList.isEmpty) return;

    final oldestWidget = newestOnTop ? targetList.last : targetList.first;

    if (oldestWidget is HyperSnackBarContainer) {
      removeNotification(oldestWidget.config, immediate: true);
    }
  }

  static void _mountOverlayIfNeeded(BuildContext? context) {
    if (_isOverlayMounted) return;
    OverlayState? overlayState;

    // rootOverlay: true にすることで、ネストしたNavigatorの中にいても
    // 可能な限り最上位（ドロワーやダイアログの上）を探しに行きます
    if (context != null) {
      overlayState = Overlay.maybeOf(context, rootOverlay: true);
    }

    // 2. context で見つからなかった、または context が null の場合
    // navigatorKey から直接取得する（これが最も確実なフォールバック）
    overlayState ??= navigatorKey.currentState?.overlay;

    // 3. それでも見つからない場合はエラーログを出して終了
    if (overlayState == null) {
      debugPrint(
          "HyperSnackbar: No Overlay found. Check your navigatorKey setup.");
      return;
    }

    final newEntry = OverlayEntry(
      builder: (context) => _HyperOverlayManager(
        topStream: _topStream.stream,
        bottomStream: _bottomStream.stream,
        initialTopData: _topEntries,
        initialBottomData: _bottomEntries,
      ),
    );

    _overlayEntry = newEntry;

    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      // Avoid inserting the overlay during the build phase to prevent
      // "setState() or markNeedsBuild() called during build" errors.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (overlayState?.mounted == true) {
          overlayState!.insert(newEntry);
        }
      });
    } else {
      overlayState.insert(_overlayEntry!);
    }
    _isOverlayMounted = true;
  }

  /// Resets the manager to its initial state.
  ///
  /// This method is intended for use in tests to ensure a clean state between
  /// test cases. It clears all snackbars, queues, and internal flags.
  static void resetForTest() {
    if (_overlayEntry != null) {
      try {
        _overlayEntry?.remove();
      } catch (_) {}
      _overlayEntry = null;
    }

    _topEntries.clear();
    _bottomEntries.clear();
    _queue.clear();

    _isOverlayMounted = false;
    _isQueueProcessing = false;

    _topStream.add([]);
    _bottomStream.add([]);
  }
}

class _HyperOverlayManager extends StatelessWidget {
  final Stream<List<Widget>> topStream;
  final Stream<List<Widget>> bottomStream;

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

/// Extension methods for [BuildContext] to easily show snackbars.
extension HyperSnackbarExtensions on BuildContext {
  void showHyperSnackbar({
    required String title,
    String? id,
    String? message,
    Widget? icon,
    HyperSnackAction? action,
    MainAxisAlignment actionAlignment = MainAxisAlignment.end,
    Widget? content,
    VoidCallback? onTap,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    BoxBorder? border,
    EdgeInsetsGeometry margin = EdgeInsets.zero,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    Color? backgroundColor,
    Color? textColor,
    double borderRadius = 12.0,
    double elevation = 4.0,
    Duration? displayDuration = const Duration(seconds: 4),
    bool showCloseButton = true,
    bool enableSwipe = true,
    bool newestOnTop = true,
    int maxVisibleCount = 3,
    HyperSnackPosition position = HyperSnackPosition.top,
    HyperSnackDisplayMode displayMode = HyperSnackDisplayMode.stack,
    int? maxLines = 5,
    bool scrollable = false,
    double? messageMaxHeight,
    Duration enterAnimationDuration = const Duration(milliseconds: 300),
    Duration exitAnimationDuration = const Duration(milliseconds: 500),
    Curve enterCurve = Curves.easeOutQuart,
    Curve exitCurve = Curves.easeOut,
    HyperSnackAnimationType enterAnimationType = HyperSnackAnimationType.top,
    HyperSnackAnimationType exitAnimationType = HyperSnackAnimationType.left,
    // ▼ Added missing parameters to match HyperSnackbar.show
    double? progressBarWidth,
    Color? progressBarColor,
    bool useAdaptiveLoader = false,
  }) {
    HyperSnackbar.show(
      title: title,
      id: id,
      message: message,
      icon: icon,
      action: action,
      actionAlignment: actionAlignment,
      content: content,
      onTap: onTap,
      titleStyle: titleStyle,
      messageStyle: messageStyle,
      border: border,
      margin: margin,
      padding: padding,
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderRadius: borderRadius,
      elevation: elevation,
      displayDuration: displayDuration,
      showCloseButton: showCloseButton,
      enableSwipe: enableSwipe,
      newestOnTop: newestOnTop,
      maxVisibleCount: maxVisibleCount,
      position: position,
      displayMode: displayMode,
      maxLines: maxLines,
      scrollable: scrollable,
      messageMaxHeight: messageMaxHeight,
      enterAnimationDuration: enterAnimationDuration,
      exitAnimationDuration: exitAnimationDuration,
      enterCurve: enterCurve,
      exitCurve: exitCurve,
      enterAnimationType: enterAnimationType,
      exitAnimationType: exitAnimationType,
      // ▼ Pass them to the show method
      progressBarWidth: progressBarWidth,
      progressBarColor: progressBarColor,
      useAdaptiveLoader: useAdaptiveLoader,
      context: this,
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'config.dart';
import 'container.dart';

/// A static manager class for displaying and managing HyperSnackbars.
class HyperSnackbar {
  HyperSnackbar._();

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
  static OverlayState? _currentOverlayState;

  // ===========================================================================
  // Factory Method for Presets
  // ===========================================================================

  /// Creates a configuration preset.
  ///
  /// Includes aliases for GetX compatibility and unified shortcuts:
  /// - [animationDuration]: Sets both enter and exit animation durations.
  /// - [animationType]: Sets both enter and exit animation types.
  /// - [colorText]: Alias for [textColor].
  /// - [duration]: Alias for [displayDuration].
  /// - [snackPosition]: Alias for [position].
  static HyperConfig preset({
    String? id,
    String? title,
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

    // Changed to nullable to support fallback logic
    Duration? enterAnimationDuration,
    Duration? exitAnimationDuration,
    Curve enterCurve = Curves.easeOutQuart,
    Curve exitCurve = Curves.easeOut,
    HyperSnackAnimationType? enterAnimationType,
    HyperSnackAnimationType? exitAnimationType,
    double? progressBarWidth,
    Color? progressBarColor,
    bool useAdaptiveLoader = false,
    bool useLocalOverlay = false,
    double? maxWidth,
    AlignmentGeometry alignment = Alignment.center,

    // --- Unified Shortcuts & Aliases ---
    Duration? animationDuration,
    HyperSnackAnimationType? animationType, // Added
    Color? colorText,
    Duration? duration,
    HyperSnackPosition? snackPosition,
  }) {
    // Resolve Aliases
    final effectiveTextColor = textColor ?? colorText;
    final effectiveDisplayDuration = displayDuration ?? duration;
    final effectivePosition =
        position == HyperSnackPosition.top && snackPosition != null
            ? snackPosition
            : position;

    // Resolve Animation Duration (Specific > Unified > Default)
    final effectiveEnterDuration = enterAnimationDuration ??
        animationDuration ??
        const Duration(milliseconds: 300);
    final effectiveExitDuration = exitAnimationDuration ??
        animationDuration ??
        const Duration(milliseconds: 500);

    // Resolve Animation Type (Specific > Unified > Default)
    final effectiveEnterType =
        enterAnimationType ?? animationType ?? HyperSnackAnimationType.top;
    final effectiveExitType =
        exitAnimationType ?? animationType ?? HyperSnackAnimationType.left;

    return HyperConfig(
      id: id,
      title: title,
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
      textColor: effectiveTextColor,
      borderRadius: borderRadius,
      elevation: elevation,
      displayDuration: effectiveDisplayDuration,
      showCloseButton: showCloseButton,
      enableSwipe: enableSwipe,
      newestOnTop: newestOnTop,
      maxVisibleCount: maxVisibleCount,
      position: effectivePosition,
      displayMode: displayMode,
      maxLines: maxLines,
      scrollable: scrollable,
      messageMaxHeight: messageMaxHeight,
      enterAnimationDuration: effectiveEnterDuration,
      exitAnimationDuration: effectiveExitDuration,
      enterCurve: enterCurve,
      exitCurve: exitCurve,
      enterAnimationType: effectiveEnterType,
      exitAnimationType: effectiveExitType,
      progressBarWidth: progressBarWidth,
      progressBarColor: progressBarColor,
      useAdaptiveLoader: useAdaptiveLoader,
      useLocalOverlay: useLocalOverlay,
      maxWidth: maxWidth,
      alignment: alignment,
    );
  }

  // ===========================================================================
  // Main Show Methods
  // ===========================================================================

  static void show({
    String? title,
    HyperConfig? preset,
    String? id,
    String? message,
    Widget? icon,
    HyperSnackAction? action,
    MainAxisAlignment? actionAlignment,
    Widget? content,
    VoidCallback? onTap,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    BoxBorder? border,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    Color? textColor,
    double? borderRadius,
    double? elevation,
    Duration? displayDuration,
    bool? showCloseButton,
    bool? enableSwipe,
    bool? newestOnTop,
    int? maxVisibleCount,
    HyperSnackPosition? position,
    HyperSnackDisplayMode? displayMode,
    int? maxLines,
    bool? scrollable,
    double? messageMaxHeight,

    // Changed to nullable to allow fallback to preset/animationType
    Duration? enterAnimationDuration,
    Duration? exitAnimationDuration,
    Curve? enterCurve,
    Curve? exitCurve,
    HyperSnackAnimationType? enterAnimationType,
    HyperSnackAnimationType? exitAnimationType,
    double? progressBarWidth,
    Color? progressBarColor,
    bool? useAdaptiveLoader,
    bool? useLocalOverlay,
    double? maxWidth,
    AlignmentGeometry? alignment,
    BuildContext? context,

    // --- Unified Shortcuts & Aliases ---
    Duration? animationDuration,
    HyperSnackAnimationType? animationType, // Added
    Color? colorText,
    Duration? duration,
    HyperSnackPosition? snackPosition,
  }) {
    assert(
      (title != null && title.isNotEmpty) ||
          (message != null && message.isNotEmpty) ||
          content != null,
      'HyperSnackbar requires at least a title, a message, or a custom content widget.',
    );

    final baseConfig = preset ?? const HyperConfig();

    // Resolve Aliases/Shortcuts for overriding
    final effectiveTextColor = textColor ?? colorText;
    final effectiveDisplayDuration = displayDuration ?? duration;
    final effectivePosition = position ?? snackPosition;

    // Resolve Animation Durations
    // Arg > Unified > null (keep preset)
    final effectiveEnterAnimDuration =
        enterAnimationDuration ?? animationDuration;
    final effectiveExitAnimDuration =
        exitAnimationDuration ?? animationDuration;

    // Resolve Animation Types
    // Arg > Unified > null (keep preset)
    final effectiveEnterAnimType = enterAnimationType ?? animationType;
    final effectiveExitAnimType = exitAnimationType ?? animationType;

    final config = baseConfig.copyWith(
      title: title,
      message: message ?? baseConfig.message,
      maxLines: maxLines ?? baseConfig.maxLines,
      messageMaxHeight: messageMaxHeight ?? baseConfig.messageMaxHeight,
      id: id,
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
      textColor: effectiveTextColor,
      borderRadius: borderRadius,
      elevation: elevation,
      displayDuration: effectiveDisplayDuration,
      showCloseButton: showCloseButton,
      enableSwipe: enableSwipe,
      newestOnTop: newestOnTop,
      maxVisibleCount: maxVisibleCount,
      position: effectivePosition,
      displayMode: displayMode,
      scrollable: scrollable,
      enterAnimationDuration: effectiveEnterAnimDuration,
      exitAnimationDuration: effectiveExitAnimDuration,
      enterCurve: enterCurve,
      exitCurve: exitCurve,
      enterAnimationType: effectiveEnterAnimType,
      exitAnimationType: effectiveExitAnimType,
      progressBarWidth: progressBarWidth,
      progressBarColor: progressBarColor,
      useAdaptiveLoader: useAdaptiveLoader,
      useLocalOverlay: useLocalOverlay,
      maxWidth: maxWidth ?? baseConfig.maxWidth,
      alignment: alignment ?? baseConfig.alignment,
    );

    showFromConfig(config, context: context);
  }

  /// Shows a snackbar using a pre-configured [HyperConfig] object.
  static void showFromConfig(HyperConfig config, {BuildContext? context}) {
    assert(
      (config.title != null && config.title!.isNotEmpty) ||
          (config.message != null && config.message!.isNotEmpty) ||
          config.content != null,
      'HyperSnackbar requires at least a title, a message, or a custom content widget.',
    );

    _mountOverlayIfNeeded(context, config.useLocalOverlay);

    if (config.displayMode == HyperSnackDisplayMode.queue) {
      _queue.add(config);
      if (!_isQueueProcessing) {
        _processQueue();
      }
      return;
    }

    if (config.id != null) {
      if (_tryUpdate(config, _topEntries, _topStream)) return;
      if (_tryUpdate(config, _bottomEntries, _bottomStream)) return;
    }

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

  static bool get isSnackbarOpen =>
      _topEntries.isNotEmpty || _bottomEntries.isNotEmpty;

  static bool isSnackbarOpenById(String id) {
    final allEntries = [..._topEntries, ..._bottomEntries];
    return allEntries.any(
        (widget) => widget is HyperSnackBarContainer && widget.config.id == id);
  }

  // ===========================================================================
  // Convenience Methods
  // ===========================================================================

  static void showSuccess({
    String? title,
    String? message,
    BuildContext? context,
    EdgeInsetsGeometry? margin,
    HyperSnackPosition? position,
    Duration? displayDuration,
    double? progressBarWidth,
  }) {
    final successPreset = preset(
      backgroundColor: Colors.green.shade600,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      margin: const EdgeInsets.all(8.0),
    );

    show(
      title: title,
      message: message,
      preset: successPreset,
      context: context,
      margin: margin,
      position: position,
      displayDuration: displayDuration,
      progressBarWidth: progressBarWidth,
    );
  }

  static void showError({
    String? title,
    String? message,
    BuildContext? context,
    EdgeInsetsGeometry? margin,
    HyperSnackPosition? position,
    Duration? displayDuration,
    double? progressBarWidth,
  }) {
    final errorPreset = preset(
      backgroundColor: Colors.red.shade600,
      icon: const Icon(Icons.error, color: Colors.white),
      margin: const EdgeInsets.all(8.0),
    );

    show(
      title: title,
      message: message,
      preset: errorPreset,
      context: context,
      margin: margin,
      position: position,
      displayDuration: displayDuration,
      progressBarWidth: progressBarWidth,
    );
  }

  static void showWarning({
    String? title,
    String? message,
    BuildContext? context,
    EdgeInsetsGeometry? margin,
    HyperSnackPosition? position,
    Duration? displayDuration,
    double? progressBarWidth,
  }) {
    final warningPreset = preset(
      backgroundColor: Colors.orange.shade700,
      icon: const Icon(Icons.warning, color: Colors.white),
      margin: const EdgeInsets.all(8.0),
    );

    show(
      title: title,
      message: message,
      preset: warningPreset,
      context: context,
      margin: margin,
      position: position,
      displayDuration: displayDuration,
      progressBarWidth: progressBarWidth,
    );
  }

  static void showInfo({
    String? title,
    String? message,
    BuildContext? context,
    EdgeInsetsGeometry? margin,
    HyperSnackPosition? position,
    Duration? displayDuration,
    double? progressBarWidth,
  }) {
    final infoPreset = preset(
      backgroundColor: Colors.blue.shade600,
      icon: const Icon(Icons.info, color: Colors.white),
      margin: const EdgeInsets.all(8.0),
    );

    show(
      title: title,
      message: message,
      preset: infoPreset,
      context: context,
      margin: margin,
      position: position,
      displayDuration: displayDuration,
      progressBarWidth: progressBarWidth,
    );
  }

  // ===========================================================================
  // Internal Logic
  // ===========================================================================

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

  static void _mountOverlayIfNeeded(
      BuildContext? context, bool useLocalOverlay) {
    // 1. Identify the target OverlayState.
    OverlayState? targetOverlay;
    if (context != null) {
      targetOverlay = Overlay.maybeOf(context, rootOverlay: !useLocalOverlay);
    }
    targetOverlay ??= navigatorKey.currentState?.overlay;

    if (targetOverlay == null) {
      debugPrint("HyperSnackbar: No Overlay found.");
      return;
    }

    // 2. If already mounted and the target overlay is the same, reuse it.
    if (_isOverlayMounted && _currentOverlayState == targetOverlay) {
      return;
    }

    // 3. If the target overlay has changed (e.g., Global -> Local), remove the old one.
    if (_isOverlayMounted) {
      try {
        _overlayEntry?.remove();
      } catch (_) {}
      _overlayEntry = null;
      _isOverlayMounted = false;
      _currentOverlayState = null;
    }

    // 4. Create a new OverlayEntry.
    final newEntry = OverlayEntry(
      builder: (context) => _HyperOverlayManager(
        topStream: _topStream.stream,
        bottomStream: _bottomStream.stream,
        initialTopData: _topEntries,
        initialBottomData: _bottomEntries,
      ),
    );

    _overlayEntry = newEntry;
    _currentOverlayState =
        targetOverlay; // Update the current overlay reference.

    // 5. Insert the entry (safely handling build phase errors).
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (targetOverlay?.mounted == true) {
          targetOverlay!.insert(newEntry);
        }
      });
    } else {
      targetOverlay.insert(_overlayEntry!);
    }
    _isOverlayMounted = true;
  }

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

/// Extension methods for [BuildContext].
extension HyperSnackbarExtensions on BuildContext {
  void showHyperSnackbar({
    String? title,
    HyperConfig? preset,
    String? id,
    String? message,
    Widget? icon,
    HyperSnackAction? action,
    MainAxisAlignment? actionAlignment,
    Widget? content,
    VoidCallback? onTap,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    BoxBorder? border,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    Color? textColor,
    double? borderRadius,
    double? elevation,
    Duration? displayDuration,
    bool? showCloseButton,
    bool? enableSwipe,
    bool? newestOnTop,
    int? maxVisibleCount,
    HyperSnackPosition? position,
    HyperSnackDisplayMode? displayMode,
    int? maxLines,
    bool? scrollable,
    double? messageMaxHeight,
    Duration? enterAnimationDuration,
    Duration? exitAnimationDuration,
    Curve? enterCurve,
    Curve? exitCurve,
    HyperSnackAnimationType? enterAnimationType,
    HyperSnackAnimationType? exitAnimationType,
    double? progressBarWidth,
    Color? progressBarColor,
    bool? useAdaptiveLoader,
    bool? useLocalOverlay,
    double? maxWidth,
    AlignmentGeometry? alignment,

    // --- Unified Shortcuts & Aliases ---
    Duration? animationDuration,
    HyperSnackAnimationType? animationType, // Added
    Color? colorText,
    Duration? duration,
    HyperSnackPosition? snackPosition,
  }) {
    assert(
      (title != null && title.isNotEmpty) ||
          (message != null && message.isNotEmpty) ||
          content != null,
      'HyperSnackbar requires at least a title, a message, or a custom content widget.',
    );

    HyperSnackbar.show(
      title: title,
      preset: preset,
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
      useLocalOverlay: useLocalOverlay,
      maxWidth: maxWidth,
      alignment: alignment,

      // Pass Aliases/Shortcuts
      animationDuration: animationDuration,
      animationType: animationType,
      colorText: colorText,
      duration: duration,
      snackPosition: snackPosition,

      context: this,
    );
  }
}

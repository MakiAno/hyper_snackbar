import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'config.dart';
import 'container.dart';

/// A class to manage the blur and color of the overlay (background)
class HyperOverlayState {
  final double blur;
  final Color color;

  const HyperOverlayState(this.blur, this.color);
}

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
  static final StreamController<HyperOverlayState> _overlayStateStream =
      StreamController<HyperOverlayState>.broadcast();

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
    double barBlur = 0.0,
    double overlayBlur = 0.0,

    // --- Unified Shortcuts & Aliases ---
    Duration? animationDuration,
    HyperSnackAnimationType? animationType, // Added
    Color? colorText,
    Duration? duration,
    HyperSnackPosition? snackPosition,
    Widget? mainButton,
    bool? isDismissible,
    Curve? forwardAnimationCurve,
    Curve? reverseAnimationCurve,
    Widget? titleText,
    Widget? messageText,
    List<BoxShadow>? boxShadows,
    bool? shouldIconPulse,
  }) {
    // Resolve Aliases
    final effectiveTextColor = textColor ?? colorText;
    final effectiveDisplayDuration = duration ?? displayDuration;

    // Convert SnackPosition to HyperSnackPosition
    HyperSnackPosition? mappedSnackPosition;
    if (snackPosition != null) {
      mappedSnackPosition = snackPosition == HyperSnackPosition.top
          ? HyperSnackPosition.top
          : HyperSnackPosition.bottom;
    }
    final effectivePosition = mappedSnackPosition ?? position;

    final effectiveContent = content ?? mainButton;
    final effectiveEnableSwipe = isDismissible ?? enableSwipe;
    final effectiveEnterCurve = forwardAnimationCurve ?? enterCurve;
    final effectiveExitCurve = reverseAnimationCurve ?? exitCurve;

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

    // Handle Title/Message Widget aliases via Content if Text is overridden
    Widget? finalContent = effectiveContent;
    if (titleText != null || messageText != null) {
      finalContent = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (titleText != null) titleText,
            if (titleText != null && messageText != null)
              const SizedBox(height: 4),
            if (messageText != null) messageText,
            if (effectiveContent != null) ...[
              const SizedBox(height: 8),
              effectiveContent
            ]
          ]);
    }

    return HyperConfig(
      id: id,
      title: title,
      message: message,
      icon: icon,
      shouldIconPulse: shouldIconPulse ?? false,
      action: action,
      actionAlignment: actionAlignment,
      content: finalContent,
      onTap: onTap,
      titleStyle: titleStyle,
      messageStyle: messageStyle,
      border: border,
      boxShadows: boxShadows,
      margin: margin,
      padding: padding,
      backgroundColor: backgroundColor,
      textColor: effectiveTextColor,
      borderRadius: borderRadius,
      elevation: elevation,
      displayDuration: effectiveDisplayDuration,
      showCloseButton: showCloseButton,
      enableSwipe: effectiveEnableSwipe,
      newestOnTop: newestOnTop,
      maxVisibleCount: maxVisibleCount,
      position: effectivePosition,
      displayMode: displayMode,
      maxLines: maxLines,
      scrollable: scrollable,
      messageMaxHeight: messageMaxHeight,
      enterAnimationDuration: effectiveEnterDuration,
      exitAnimationDuration: effectiveExitDuration,
      enterCurve: effectiveEnterCurve,
      exitCurve: effectiveExitCurve,
      enterAnimationType: effectiveEnterType,
      exitAnimationType: effectiveExitType,
      progressBarWidth: progressBarWidth,
      progressBarColor: progressBarColor,
      useAdaptiveLoader: useAdaptiveLoader,
      useLocalOverlay: useLocalOverlay,
      maxWidth: maxWidth,
      alignment: alignment,
      barBlur: barBlur,
      overlayBlur: overlayBlur,
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
    double? barBlur,
    double? overlayBlur,
    BuildContext? context,

    // --- Unified Shortcuts & Aliases ---
    Duration? animationDuration,
    HyperSnackAnimationType? animationType, // Added
    Color? colorText,
    Duration? duration,
    HyperSnackPosition? snackPosition,
    Widget? mainButton,
    bool? isDismissible,
    Curve? forwardAnimationCurve,
    Curve? reverseAnimationCurve,
    Widget? titleText,
    Widget? messageText,
    List<BoxShadow>? boxShadows,
    bool? shouldIconPulse,

    // --- Maintain compatibility with GetX ---
    SnackbarStatusCallback? snackbarStatus,
    DismissDirection? dismissDirection,
    Color? leftBarIndicatorColor,
    Gradient? backgroundGradient,
    bool? showProgressIndicator,
    AnimationController? progressIndicatorController,
    Color? progressIndicatorBackgroundColor,
    Animation<Color>? progressIndicatorValueColor,
    Color? overlayColor,
    Widget? userInputForm,
    HyperSnackStyle? snackStyle,

    // For GetX aliases
    Color? borderColor,
    double? borderWidth,
  }) {
    assert(
      (title != null && title.isNotEmpty) ||
          (message != null && message.isNotEmpty) ||
          content != null ||
          mainButton != null ||
          titleText != null ||
          messageText != null,
      'HyperSnackbar requires at least a title, a message, or a custom content widget.',
    );

    final baseConfig = preset ?? const HyperConfig();

    // Resolve Aliases/Shortcuts for overriding
    final effectiveTextColor = textColor ?? colorText;
    final effectiveDisplayDuration = duration ?? displayDuration;

    // Convert SnackPosition to HyperSnackPosition
    HyperSnackPosition? mappedSnackPosition;
    if (snackPosition != null) {
      mappedSnackPosition = snackPosition == HyperSnackPosition.top
          ? HyperSnackPosition.top
          : HyperSnackPosition.bottom;
    }
    final effectivePosition = mappedSnackPosition ?? position;

    final effectiveContent = content ?? mainButton;
    final effectiveEnableSwipe = isDismissible ?? enableSwipe;
    final effectiveEnterCurve = forwardAnimationCurve ?? enterCurve;
    final effectiveExitCurve = reverseAnimationCurve ?? exitCurve;

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

    // Handle Title/Message Widget aliases via Content if Text is overridden, though the current Widget strictly takes strings for title/message.
    // To cleanly map titleText/messageText without breaking the Widget, we can map them to custom content if provided.
    // However, if the user provides `messageText` or `titleText` specifically, GetX displays them instead of strings.
    // Since `HyperConfig` title/message are strictly strings, we will map them into a `Column` via `content` if not null.
    Widget? finalContent = effectiveContent;
    if (titleText != null || messageText != null) {
      finalContent = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (titleText != null) titleText,
            if (titleText != null && messageText != null)
              const SizedBox(height: 4),
            if (messageText != null) messageText,
            if (effectiveContent != null) ...[
              const SizedBox(height: 8),
              effectiveContent
            ]
          ]);
    }

    // Compatibility handling for borders
    BoxBorder? effectiveBorder = border;
    if (effectiveBorder == null && borderColor != null) {
      effectiveBorder = Border.all(
        color: borderColor,
        width: borderWidth ?? 1.0,
      );
    }

    // Compatibility handling for snackStyle
    HyperSnackStyle effectiveSnackStyle = snackStyle ?? baseConfig.snackStyle;
    if (snackStyle != null) {
      effectiveSnackStyle = snackStyle == HyperSnackStyle.grounded
          ? HyperSnackStyle.grounded
          : HyperSnackStyle.floating;
    }

    // Grounded margin handling (it is common to set margin to zero for Grounded style)
    EdgeInsetsGeometry effectiveMargin = margin ?? baseConfig.margin;
    if (effectiveSnackStyle == HyperSnackStyle.grounded) {
      effectiveMargin = EdgeInsets.zero;
    }

    final config = baseConfig.copyWith(
      title: title,
      message: message ?? baseConfig.message,
      maxLines: maxLines ?? baseConfig.maxLines,
      messageMaxHeight: messageMaxHeight ?? baseConfig.messageMaxHeight,
      id: id,
      icon: icon,
      shouldIconPulse: shouldIconPulse ?? baseConfig.shouldIconPulse,
      action: action,
      actionAlignment: actionAlignment,
      content: finalContent,
      onTap: onTap,
      titleStyle: titleStyle,
      messageStyle: messageStyle,
      border: effectiveBorder,
      boxShadows: boxShadows ?? baseConfig.boxShadows,
      margin: effectiveMargin,
      padding: padding,
      backgroundColor: backgroundColor,
      textColor: effectiveTextColor,
      borderRadius: borderRadius,
      elevation: elevation,
      displayDuration: effectiveDisplayDuration,
      showCloseButton: showCloseButton,
      enableSwipe: effectiveEnableSwipe,
      newestOnTop: newestOnTop,
      maxVisibleCount: maxVisibleCount,
      position: effectivePosition,
      displayMode: displayMode,
      scrollable: scrollable,
      enterAnimationDuration: effectiveEnterAnimDuration,
      exitAnimationDuration: effectiveExitAnimDuration,
      enterCurve: effectiveEnterCurve,
      exitCurve: effectiveExitCurve,
      enterAnimationType: effectiveEnterAnimType,
      exitAnimationType: effectiveExitAnimType,
      progressBarWidth: progressBarWidth ?? baseConfig.progressBarWidth,
      showProgressIndicator:
          showProgressIndicator ?? baseConfig.showProgressIndicator,
      progressBarColor: progressBarColor,
      useAdaptiveLoader: useAdaptiveLoader,
      useLocalOverlay: useLocalOverlay,
      maxWidth: maxWidth ?? baseConfig.maxWidth,
      alignment: alignment ?? baseConfig.alignment,
      barBlur: barBlur ?? baseConfig.barBlur,
      overlayBlur: overlayBlur ?? baseConfig.overlayBlur,
      snackStyle: effectiveSnackStyle,
      snackbarStatus: snackbarStatus ?? baseConfig.snackbarStatus,
      dismissDirection: dismissDirection ?? baseConfig.dismissDirection,
      leftBarIndicatorColor:
          leftBarIndicatorColor ?? baseConfig.leftBarIndicatorColor,
      backgroundGradient: backgroundGradient ?? baseConfig.backgroundGradient,
      progressIndicatorController:
          progressIndicatorController ?? baseConfig.progressIndicatorController,
      progressIndicatorBackgroundColor: progressIndicatorBackgroundColor ??
          baseConfig.progressIndicatorBackgroundColor,
      progressIndicatorValueColor:
          progressIndicatorValueColor ?? baseConfig.progressIndicatorValueColor,
      overlayColor: overlayColor ?? baseConfig.overlayColor,
      userInputForm: userInputForm ?? baseConfig.userInputForm,
    );

    showFromConfig(config, context: context);
  }

  /// Shows a snackbar using a pre-configured [HyperConfig] object.
  static void _updateOverlayState() {
    double maxBlur = 0.0;
    Color overlayColor = Colors.transparent;

    for (final widget in _topEntries.followedBy(_bottomEntries)) {
      if (widget is HyperSnackBarContainer) {
        maxBlur = math.max(maxBlur, widget.config.overlayBlur);
        if (widget.config.overlayColor != null) {
          overlayColor = widget.config.overlayColor!;
        }
      }
    }
    _overlayStateStream.add(HyperOverlayState(maxBlur, overlayColor));
  }

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
      if (_tryUpdate(config, _topEntries, _topStream)) {
        _updateOverlayState();
        return;
      }
      if (_tryUpdate(config, _bottomEntries, _bottomStream)) {
        _updateOverlayState();
        return;
      }
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
    _updateOverlayState();
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
    _updateOverlayState();
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
      _dismissAllFromList(_topEntries);
      _dismissAllFromList(_bottomEntries);
    } else {
      _topEntries.clear();
      _bottomEntries.clear();
      _topStream.add([]);
      _bottomStream.add([]);
      _updateOverlayState();
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
    return _topEntries.followedBy(_bottomEntries).any(
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
    _updateOverlayState();
  }

  static void _dismissAllFromList(List<Widget> list) {
    for (int i = list.length - 1; i >= 0; i--) {
      final widget = list[i];
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
        overlayStateStream: _overlayStateStream.stream,
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
    _overlayStateStream.add(const HyperOverlayState(0.0, Colors.transparent));
  }
}

class _HyperOverlayManager extends StatelessWidget {
  final Stream<List<Widget>> topStream;
  final Stream<List<Widget>> bottomStream;
  final Stream<HyperOverlayState> overlayStateStream;

  final List<Widget> initialTopData;
  final List<Widget> initialBottomData;

  const _HyperOverlayManager({
    required this.topStream,
    required this.bottomStream,
    required this.overlayStateStream,
    required this.initialTopData,
    required this.initialBottomData,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background blur & color effect
        Positioned.fill(
          child: StreamBuilder<HyperOverlayState>(
            stream: overlayStateStream,
            initialData: const HyperOverlayState(0.0, Colors.transparent),
            builder: (context, snapshot) {
              final state = snapshot.data ??
                  const HyperOverlayState(0.0, Colors.transparent);
              final blurValue = state.blur;
              final colorValue = state.color;

              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: blurValue),
                duration: const Duration(milliseconds: 300),
                builder: (context, blur, child) {
                  return TweenAnimationBuilder<Color?>(
                    tween:
                        ColorTween(begin: Colors.transparent, end: colorValue),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, color, child) {
                      if (blur == 0.0 &&
                          (color == null || color == Colors.transparent)) {
                        return const SizedBox.shrink();
                      }
                      return BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                        child: Container(color: color),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
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
    double? barBlur,
    double? overlayBlur,

    // --- Unified Shortcuts & Aliases ---
    Duration? animationDuration,
    HyperSnackAnimationType? animationType, // Added
    Color? colorText,
    Duration? duration,
    HyperSnackPosition? snackPosition,
    Widget? mainButton,
    bool? isDismissible,
    Curve? forwardAnimationCurve,
    Curve? reverseAnimationCurve,
    Widget? titleText,
    Widget? messageText,
    List<BoxShadow>? boxShadows,
    bool? shouldIconPulse,
  }) {
    assert(
      (title != null && title.isNotEmpty) ||
          (message != null && message.isNotEmpty) ||
          content != null ||
          mainButton != null ||
          titleText != null ||
          messageText != null,
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
      barBlur: barBlur,
      overlayBlur: overlayBlur,

      // Pass Aliases/Shortcuts
      animationDuration: animationDuration,
      animationType: animationType,
      colorText: colorText,
      duration: duration,
      snackPosition: snackPosition,
      mainButton: mainButton,
      isDismissible: isDismissible,
      forwardAnimationCurve: forwardAnimationCurve,
      reverseAnimationCurve: reverseAnimationCurve,
      titleText: titleText,
      messageText: messageText,
      boxShadows: boxShadows,
      shouldIconPulse: shouldIconPulse,

      context: this,
    );
  }
}

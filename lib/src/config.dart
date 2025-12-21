import 'package:flutter/material.dart';

/// Defines the vertical position where the snackbar will appear.
enum HyperSnackPosition { top, bottom }

/// Defines the display mode of the snackbar.
enum HyperSnackDisplayMode {
  /// Stacks snackbars on top of each other.
  stack,

  /// Queues snackbars and displays them one after another.
  queue,
}

/// Defines the entrance and exit animation styles.
enum HyperSnackAnimationType {
  top,
  bottom,
  left,
  right,
  fade,
  scale,
}

/// Represents an action button displayed within the snackbar.
class HyperSnackAction {
  /// The text label for the button.
  final String label;

  /// The callback function executed when the button is pressed.
  final VoidCallback onPressed;
  final Color? textColor;
  final Color? backgroundColor;

  const HyperSnackAction({
    required this.label,
    required this.onPressed,
    this.textColor,
    this.backgroundColor,
  });
}

/// Configuration class for customizing the appearance and behavior of [HyperSnackbar].
///
/// You can configure titles, messages, colors, animations, and duration.
class HyperConfig {
  /// A unique identifier for the snackbar.
  ///
  /// If provided, updating a snackbar with the same ID will update the existing one
  /// instead of creating a new one.
  final String? id;

  /// The main title text of the snackbar.
  final String title;

  /// The detailed message body text.
  final String? message;
  final Widget? icon;
  final HyperSnackAction? action;

  /// Interaction & Style.
  final VoidCallback? onTap;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final BoxBorder? border;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final double elevation;

  /// Behavior.
  final Duration? displayDuration;
  final bool showCloseButton;
  final bool enableSwipe;
  final bool newestOnTop;
  final int maxVisibleCount;
  final HyperSnackPosition position;
  final HyperSnackDisplayMode displayMode;

  /// Animation.
  final Duration enterAnimationDuration;
  final Duration exitAnimationDuration;
  final Curve enterCurve;
  final Curve exitCurve;
  final HyperSnackAnimationType enterAnimationType;
  final HyperSnackAnimationType exitAnimationType;

  const HyperConfig({
    required this.title,
    this.id,
    this.message,
    this.icon,
    this.action,
    this.onTap,
    this.titleStyle,
    this.messageStyle,
    this.border,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 12.0,
    this.elevation = 4.0,
    this.displayDuration = const Duration(seconds: 4),
    this.showCloseButton = true,
    this.enableSwipe = true,
    this.newestOnTop = true,
    this.maxVisibleCount = 3,
    this.position = HyperSnackPosition.top,
    this.displayMode = HyperSnackDisplayMode.stack,
    this.enterAnimationDuration = const Duration(milliseconds: 300),
    this.exitAnimationDuration = const Duration(milliseconds: 500),
    this.enterCurve = Curves.easeOutQuart,
    this.exitCurve = Curves.easeOut,
    this.enterAnimationType = HyperSnackAnimationType.top,
    this.exitAnimationType = HyperSnackAnimationType.left,
  });

  HyperConfig copyWith({
    String? id,
    String? title,
    String? message,
    Widget? icon,
    HyperSnackAction? action,
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
    Duration? enterAnimationDuration,
    Duration? exitAnimationDuration,
    Curve? enterCurve,
    Curve? exitCurve,
    HyperSnackAnimationType? enterAnimationType,
    HyperSnackAnimationType? exitAnimationType,
  }) {
    return HyperConfig(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      icon: icon ?? this.icon,
      action: action ?? this.action,
      onTap: onTap ?? this.onTap,
      titleStyle: titleStyle ?? this.titleStyle,
      messageStyle: messageStyle ?? this.messageStyle,
      border: border ?? this.border,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      displayDuration: displayDuration ?? this.displayDuration,
      showCloseButton: showCloseButton ?? this.showCloseButton,
      enableSwipe: enableSwipe ?? this.enableSwipe,
      newestOnTop: newestOnTop ?? this.newestOnTop,
      maxVisibleCount: maxVisibleCount ?? this.maxVisibleCount,
      position: position ?? this.position,
      displayMode: displayMode ?? this.displayMode,
      enterAnimationDuration:
          enterAnimationDuration ?? this.enterAnimationDuration,
      exitAnimationDuration:
          exitAnimationDuration ?? this.exitAnimationDuration,
      enterCurve: enterCurve ?? this.enterCurve,
      exitCurve: exitCurve ?? this.exitCurve,
      enterAnimationType: enterAnimationType ?? this.enterAnimationType,
      exitAnimationType: exitAnimationType ?? this.exitAnimationType,
    );
  }
}

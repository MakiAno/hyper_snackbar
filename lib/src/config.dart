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

  /// The color of the action button's text.
  final Color? textColor;

  /// The background color of the action button.
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

  /// An optional icon to display on the left side of the snackbar.
  final Widget? icon;

  /// An optional action button to display on the right side of the snackbar.
  final HyperSnackAction? action;

  /// Interaction & Style. ------------------------------

  /// A callback function to be executed when the snackbar is tapped.
  final VoidCallback? onTap;

  /// The text style for the title.
  final TextStyle? titleStyle;

  /// The text style for the message.
  final TextStyle? messageStyle;

  /// The border of the snackbar.
  final BoxBorder? border;

  /// The margin around the snackbar.
  final EdgeInsetsGeometry margin;

  /// The padding within the snackbar.
  final EdgeInsetsGeometry padding;

  /// The background color of the snackbar.
  final Color? backgroundColor;

  /// The color for the title and message text.
  final Color? textColor;

  /// The border radius of the snackbar's corners.
  final double borderRadius;

  /// The elevation of the snackbar (shadow).
  final double elevation;

  /// Behavior.---------------------------------------

  /// The duration for which the snackbar is displayed.
  ///
  /// If `null`, the snackbar will be persistent until manually dismissed.
  final Duration? displayDuration;

  /// Whether to show a close button on the right side of the snackbar.
  final bool showCloseButton;

  /// Whether the snackbar can be dismissed by swiping.
  final bool enableSwipe;

  /// Determines the stacking order of new snackbars.
  ///
  /// If `true`, the newest snackbar appears on top. If `false`, it's appended to the bottom.
  final bool newestOnTop;

  /// The maximum number of snackbars that can be visible at the same time in stack mode.
  final int maxVisibleCount;

  /// The position of the snackbar on the screen.
  final HyperSnackPosition position;

  /// The display mode of the snackbar (stack or queue).
  final HyperSnackDisplayMode displayMode;

  /// Animation. ---------------------------------------

  /// The duration of the entry animation.
  final Duration enterAnimationDuration;

  /// The duration of the exit animation.
  final Duration exitAnimationDuration;

  /// The curve for the entry animation.
  final Curve enterCurve;

  /// The curve for the exit animation.
  final Curve exitCurve;

  /// The type of animation for entry.
  final HyperSnackAnimationType enterAnimationType;

  /// The type of animation for exit.
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

  /// Creates a copy of this [HyperConfig] but with the given fields replaced with the new values.
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

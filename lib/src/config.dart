import 'package:flutter/material.dart';

/// Defines the vertical position where the snackbar will appear.
enum HyperSnackPosition { top, bottom }

/// Defines the entrance and exit animation styles.
enum HyperSnackAnimationType {
  fromTop,
  fromBottom,
  fromLeft,
  fromRight,
  toLeft, // 退出用
  toRight, // 退出用
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
  final int maxVisibleCount; // ★ 追加
  final HyperSnackPosition position;

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
    this.maxVisibleCount = 3, // ★ 追加 (デフォルト3)
    this.position = HyperSnackPosition.top,
    this.enterAnimationDuration = const Duration(milliseconds: 300),
    this.exitAnimationDuration = const Duration(milliseconds: 500),
    this.enterCurve = Curves.easeOutQuart,
    this.exitCurve = Curves.easeOut,
    this.enterAnimationType = HyperSnackAnimationType.fromTop,
    this.exitAnimationType = HyperSnackAnimationType.toLeft,
  });

  HyperConfig copyWith({
    String? title,
    String? message,
    Widget? icon,
    HyperSnackAction? action,
    Color? backgroundColor,
    Color? textColor,
    Duration? displayDuration,
    int? maxVisibleCount, // ★ 追加
  }) {
    return HyperConfig(
      title: title ?? this.title,
      message: message ?? this.message,
      icon: icon ?? this.icon,
      action: action ?? this.action,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      displayDuration: displayDuration ?? this.displayDuration,
      maxVisibleCount: maxVisibleCount ?? this.maxVisibleCount, // ★ 追加
      // 以下維持
      id: id,
      onTap: onTap,
      titleStyle: titleStyle,
      messageStyle: messageStyle,
      border: border,
      margin: margin,
      padding: padding,
      borderRadius: borderRadius,
      elevation: elevation,
      showCloseButton: showCloseButton,
      enableSwipe: enableSwipe,
      newestOnTop: newestOnTop,
      position: position,
      enterAnimationDuration: enterAnimationDuration,
      exitAnimationDuration: exitAnimationDuration,
      enterCurve: enterCurve,
      exitCurve: exitCurve,
      enterAnimationType: enterAnimationType,
      exitAnimationType: exitAnimationType,
    );
  }
}

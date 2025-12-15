import 'package:flutter/material.dart';

/// Defines the position where the snackbar will appear.
enum HyperSnackPosition { top, bottom }

/// Defines the animation type for the snackbar entry.
enum HyperSnackAnimationType {
  fromTop,
  fromBottom,
  fromLeft,
  fromRight,
  fadeOnly,
}

/// Defines the animation type for the snackbar exit.
enum HyperSnackExitAnimationType { toLeft, toRight, toTop, toBottom, fadeOut }

/// Defines the action button configuration within the snackbar.
class HyperSnackAction {
  /// The text label for the action button.
  final String label;

  /// The callback to be executed when the action button is pressed.
  final VoidCallback onPressed;

  /// The text color of the action button.
  final Color? textColor;

  /// The text color of the action button when disabled.
  final Color? disabledTextColor;

  /// Creates a [HyperSnackAction].
  HyperSnackAction({
    required this.label,
    required this.onPressed,
    this.textColor,
    this.disabledTextColor,
  });
}

/// Configuration class for customizing the HyperSnackbar.
///
/// This class holds all the design and behavior properties.
class HyperConfig {
  // --- コンテキスト ---
  // --- 識別子 ---

  /// An optional ID to identify the snackbar.
  /// Used for updating or removing specific snackbars.
  final String? id;

  // --- コンテンツ ---

  /// The title text of the snackbar.
  final String title;

  /// The optional message text.
  final String? message;

  /// The optional icon widget.
  final Widget? icon;

  /// The optional action button.
  final HyperSnackAction? action;

  // --- インタラクション & スタイル ---

  /// Callback when the snackbar itself is tapped.
  final VoidCallback? onTap;

  /// Custom text style for the title.
  final TextStyle? titleStyle;

  /// Custom text style for the message.
  final TextStyle? messageStyle;

  /// Border decoration for the snackbar.
  final BoxBorder? border;

  /// Outer margin of the snackbar.
  final EdgeInsetsGeometry margin;

  /// Inner padding of the snackbar content.
  final EdgeInsetsGeometry padding;

  // --- 基本デザイン ---

  /// The background color of the snackbar.
  final Color backgroundColor;

  /// The default text color for title and message.
  final Color textColor;

  /// The border radius of the snackbar.
  final double borderRadius;

  /// The elevation (shadow) of the snackbar.
  final double elevation;

  // --- 動作設定 ---

  /// How long the snackbar should be displayed.
  /// If null, it will be persistent until manually dismissed.
  final Duration? displayDuration;

  /// Whether to show the close (X) button.
  final bool showCloseButton;

  /// Whether to allow dismissing the snackbar by swiping.
  final bool enableSwipe;

  /// The maximum number of snackbars visible at once.
  final int maxVisibleCount;

  /// If true, new snackbars are added to the top of the stack.
  /// If false, they are added to the bottom.
  final bool newestOnTop;

  // --- 位置 ---

  /// The position on the screen (top or bottom).
  final HyperSnackPosition position;

  // --- アニメーション設定 ---

  /// Duration of the entry animation.
  final Duration enterAnimationDuration;

  /// Duration of the exit animation.
  final Duration exitAnimationDuration;

  /// Curve for the entry animation.
  final Curve enterCurve;

  /// Curve for the exit animation.
  final Curve exitCurve;

  /// The type of entry animation.
  final HyperSnackAnimationType enterAnimationType;

  /// The type of exit animation.
  final HyperSnackExitAnimationType exitAnimationType;

  /// Creates a [HyperConfig] with the specified properties.
  HyperConfig({
    required this.title,
    this.id,
    this.message,
    this.icon,
    this.action,

    // New Properties
    this.onTap,
    this.titleStyle,
    this.messageStyle,
    this.border,
    this.margin = const EdgeInsets.all(0),
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.backgroundColor = const Color(0xFF323232),
    this.textColor = Colors.white,
    this.borderRadius = 12.0,
    this.elevation = 4.0,
    this.displayDuration = const Duration(seconds: 4),
    this.showCloseButton = true,
    this.enableSwipe = true,
    this.maxVisibleCount = 3,
    this.newestOnTop = true,
    this.position = HyperSnackPosition.top,
    this.enterAnimationDuration = const Duration(milliseconds: 300),
    this.exitAnimationDuration = const Duration(milliseconds: 500),
    this.enterCurve = Curves.easeOutQuart,
    this.exitCurve = Curves.easeOut,
    this.enterAnimationType = HyperSnackAnimationType.fromTop,
    this.exitAnimationType = HyperSnackExitAnimationType.toLeft,
  });
}

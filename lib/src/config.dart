import 'package:flutter/material.dart';

enum HyperSnackPosition { top, bottom }

enum HyperSnackAnimationType {
  fromTop,
  fromBottom,
  fromLeft,
  fromRight,
  fadeOnly
}

enum HyperSnackExitAnimationType { toLeft, toRight, toTop, toBottom, fadeOut }

// ★追加1: アクションボタンの定義クラス
class HyperSnackAction {
  final String label;
  final VoidCallback onPressed;
  final Color? textColor;
  final Color? disabledTextColor;

  HyperSnackAction({
    required this.label,
    required this.onPressed,
    this.textColor,
    this.disabledTextColor,
  });
}

class HyperConfig {
  // ★追加2: ID (これを使って更新や削除を行う)
  final String? id;

  final String title;
  final String? message;
  final Widget? icon;

  // ★追加3: アクションボタン
  final HyperSnackAction? action;

  final Color backgroundColor;
  final Color textColor;
  final Duration? displayDuration; // Nullable (永続表示対応)

  final Duration enterAnimationDuration;
  final Duration exitAnimationDuration;
  final Curve enterCurve;
  final Curve exitCurve;

  final bool showCloseButton;
  final bool enableSwipe;
  final HyperSnackPosition position;
  final HyperSnackAnimationType enterAnimationType;
  final HyperSnackExitAnimationType exitAnimationType;

  final double borderRadius;
  final double elevation;
  final int maxVisibleCount;
  final bool newestOnTop;

  HyperConfig({
    required this.title,
    this.id, // 追加
    this.message,
    this.icon,
    this.action, // 追加
    this.backgroundColor = const Color(0xFF323232),
    this.textColor = Colors.white,
    this.displayDuration = const Duration(seconds: 4),
    this.enterAnimationDuration = const Duration(milliseconds: 300),
    this.exitAnimationDuration = const Duration(milliseconds: 500),
    this.enterCurve = Curves.easeOutQuart,
    this.exitCurve = Curves.easeOut,
    this.showCloseButton = true,
    this.enableSwipe = true,
    this.position = HyperSnackPosition.top,
    this.enterAnimationType = HyperSnackAnimationType.fromTop,
    this.exitAnimationType = HyperSnackExitAnimationType.toLeft,
    this.borderRadius = 12.0,
    this.elevation = 4.0,
    this.maxVisibleCount = 3,
    this.newestOnTop = true,
  });
}

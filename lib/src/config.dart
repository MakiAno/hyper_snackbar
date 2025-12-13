import 'package:flutter/material.dart';

enum HyperSnackPosition { top, bottom }

enum HyperSnackAnimationType {
  fromTop,
  fromBottom,
  fromLeft,
  fromRight,
  fadeOnly,
}

enum HyperSnackExitAnimationType { toLeft, toRight, toTop, toBottom, fadeOut }

/// アクションボタンの定義
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
  // --- 識別子 ---
  final String? id; // 更新・個別削除用

  // --- コンテンツ ---
  final String title;
  final String? message;
  final Widget? icon;
  final HyperSnackAction? action;

  // --- インタラクション & スタイル (New!) ---
  final VoidCallback? onTap; // バー全体のタップアクション
  final TextStyle? titleStyle; // タイトルのスタイル
  final TextStyle? messageStyle; // メッセージのスタイル
  final BoxBorder? border; // 枠線
  final EdgeInsetsGeometry margin; // 外側の余白
  final EdgeInsetsGeometry padding; // 内側の余白

  // --- 基本デザイン ---
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final double elevation;

  // --- 動作設定 ---
  final Duration? displayDuration; // nullなら永続表示
  final bool showCloseButton;
  final bool enableSwipe;
  final int maxVisibleCount;
  final bool newestOnTop; // true: 先頭に追加(押し下げ), false: 末尾に追加(ぶら下げ)

  // --- 位置 ---
  final HyperSnackPosition position;

  // --- アニメーション設定 ---
  final Duration enterAnimationDuration;
  final Duration exitAnimationDuration;
  final Curve enterCurve;
  final Curve exitCurve;
  final HyperSnackAnimationType enterAnimationType;
  final HyperSnackExitAnimationType exitAnimationType;

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

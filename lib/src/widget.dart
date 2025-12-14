// ---------------------------------------------------------------------------
// 4. UIウィジェット (HyperSnackBarWidget)
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'config.dart';
import 'manager.dart';

/// A widget that displays the content of the snackbar.
class HyperSnackBarWidget extends StatelessWidget {
  final HyperConfig config;
  final VoidCallback onDismiss;

  const HyperSnackBarWidget({
    super.key,
    required this.config,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    // コンテンツ部分 (Row)
    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (config.icon != null) ...[
          config.icon!,
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                config.title,
                style: config.titleStyle ??
                    TextStyle(
                      fontWeight: FontWeight.bold,
                      color: config.textColor,
                      fontSize: 16,
                    ),
              ),
              if (config.message != null)
                Text(
                  config.message!,
                  style: config.messageStyle ??
                      TextStyle(
                        color: config.textColor.withAlpha(200),
                      ),
                ),
            ],
          ),
        ),

        // アクションボタン
        if (config.action != null) ...[
          const SizedBox(width: 8),
          TextButton(
            onPressed: config.action!.onPressed,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              config.action!.label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: config.action!.textColor ?? Colors.blueAccent,
              ),
            ),
          ),
        ],

        // 閉じるボタン
        if (config.showCloseButton)
          IconButton(
            icon: Icon(Icons.close, color: config.textColor, size: 20),
            onPressed: onDismiss,
          ),
      ],
    );

    // 装飾とインクウェル (タップ波紋)
    Widget containerBody = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(config.borderRadius),
        border: config.border, // 枠線
      ),
      // Materialを挟むことでInkWellの波紋が見えるようにする
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: config.onTap, // タップアクション
          borderRadius: BorderRadius.circular(config.borderRadius),
          child: Padding(
            padding: config.padding, // 内側のパディング
            child: content,
          ),
        ),
      ),
    );

    // 外枠 (マージンと影)
    Widget wrapper = Padding(
      padding: config.margin, // 外側のマージン
      child: Material(
        elevation: config.elevation,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(config.borderRadius),
        child: containerBody,
      ),
    );

    if (config.enableSwipe) {
      return Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.horizontal,
        onDismissed: (_) {
          HyperManager().removeNotification(config, swiped: true);
        },
        child: wrapper,
      );
    }
    return wrapper;
  }
}

// ---------------------------------------------------------------------------
// 4. UIウィジェット (HyperSnackBarWidget)
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'config.dart';
import 'manager.dart';

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
    Widget content = Material(
      color: config.backgroundColor,
      elevation: config.elevation,
      borderRadius: BorderRadius.circular(config.borderRadius),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: config.textColor,
                      fontSize: 16,
                    ),
                  ),
                  if (config.message != null)
                    Text(
                      config.message!,
                      style: TextStyle(
                        color: config.textColor.withAlpha(200),
                      ),
                    ),
                ],
              ),
            ),

            // ★追加: アクションボタンの表示
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

            if (config.showCloseButton)
              IconButton(
                icon: Icon(Icons.close, color: config.textColor, size: 20),
                onPressed: onDismiss,
              ),
          ],
        ),
      ),
    );

    if (config.enableSwipe) {
      return Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.horizontal,
        onDismissed: (_) {
          HyperManager().removeNotification(config);
        },
        child: content,
      );
    }
    return content;
  }
}

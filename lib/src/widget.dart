import 'package:flutter/material.dart';
import 'config.dart';

/// Pure UI Widget for the Snackbar content.
class HyperSnackBarContent extends StatelessWidget {
  final HyperConfig config;
  final VoidCallback onDismiss;

  const HyperSnackBarContent({
    super.key,
    required this.config,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = config.backgroundColor ?? Colors.grey[800];
    final txtColor = config.textColor ?? Colors.white;

    // 枠線（Shape）があるかどうか
    final hasBorder = config.border != null;

    return Container(
      margin: config.margin,
      child: Material(
        elevation: config.elevation,
        color: bgColor,

        // ★ 修正ポイント: shape がある場合、borderRadius は null にしなければならない
        borderRadius:
            hasBorder ? null : BorderRadius.circular(config.borderRadius),

        shape: hasBorder
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(config.borderRadius),
                side: BorderSide(
                  color: config.border!.top.color,
                  width: config.border!.top.width,
                ),
              )
            : null,

        child: InkWell(
          onTap: config.onTap,
          borderRadius: BorderRadius.circular(config.borderRadius),
          child: Padding(
            padding: config.padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (config.icon != null) ...[
                  config.icon!,
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.title,
                        style: config.titleStyle ??
                            TextStyle(
                              color: txtColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                      ),
                      if (config.message != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          config.message!,
                          style: config.messageStyle ??
                              TextStyle(
                                // Flutter 3.27+ withValues対応
                                color: txtColor.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (config.action != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: config.action!.onPressed,
                    style: TextButton.styleFrom(
                      foregroundColor:
                          config.action!.textColor ?? theme.colorScheme.primary,
                      backgroundColor: config.action!.backgroundColor,
                    ),
                    child: Text(config.action!.label),
                  ),
                ],
                if (config.showCloseButton) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.close,
                        size: 20, color: txtColor.withValues(alpha: 0.6)),
                    onPressed: onDismiss,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

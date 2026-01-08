import 'package:flutter/material.dart';
import 'config.dart';

/// Pure UI Widget for the Snackbar content.
class HyperSnackBarContent extends StatefulWidget {
  /// The configuration for the snackbar's appearance and content.
  final HyperConfig config;

  /// A callback function that is called when the snackbar is dismissed.
  final VoidCallback onDismiss;

  /// A callback function that is called when message scrolling starts.
  final VoidCallback? onScrollStart;

  /// A callback function that is called when message scrolling ends.
  final VoidCallback? onScrollEnd;

  const HyperSnackBarContent({
    super.key,
    required this.config,
    required this.onDismiss,
    this.onScrollStart,
    this.onScrollEnd,
  });

  @override
  State<HyperSnackBarContent> createState() => _HyperSnackBarContentState();
}

class _HyperSnackBarContentState extends State<HyperSnackBarContent> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final theme = Theme.of(context);
    final bgColor = config.backgroundColor ?? Colors.grey[800];
    final txtColor = config.textColor ?? Colors.white;
    final screenHeight = MediaQuery.of(context).size.height;

    // Border (Shape) check
    final hasBorder = config.border != null;

    // Get padding from config
    // We split the padding into individual sides to apply them to specific sections (Header, Body, Footer).
    // This allows the scrollbar to appear at the absolute right edge of the card, outside the content padding.
    final EdgeInsetsGeometry basePadding = config.padding;
    final double leftPad = basePadding is EdgeInsets ? basePadding.left : 16.0;
    final double rightPad =
        basePadding is EdgeInsets ? basePadding.right : 16.0;
    final double topPad = basePadding is EdgeInsets ? basePadding.top : 12.0;
    final double bottomPad =
        basePadding is EdgeInsets ? basePadding.bottom : 12.0;

    // Check for the presence of each section
    final bool hasMessage = config.message != null;
    final bool hasFooter = config.content != null || config.action != null;

    return Container(
      margin: config.margin,
      child: Material(
        elevation: config.elevation,
        color: bgColor,
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
          child: ConstrainedBox(
            // Safety measure: Limit the total height to 80% of the screen
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ---------------------------------------------------
                // 1. Header (Icon + Title + Close Button)
                // ---------------------------------------------------
                Padding(
                  padding: EdgeInsets.only(
                    left: leftPad,
                    right: rightPad,
                    top: topPad,
                    // If there is no message and no footer, this is the last element, so add bottom padding
                    bottom: (!hasMessage && !hasFooter) ? bottomPad : 0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (config.icon != null) ...[
                        config.icon!,
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          config.title,
                          style: config.titleStyle ??
                              TextStyle(
                                color: txtColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (config.showCloseButton) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: widget.onDismiss,
                          child: Icon(Icons.close,
                              size: 20, color: txtColor.withValues(alpha: 0.6)),
                        ),
                      ],
                    ],
                  ),
                ),

                // ---------------------------------------------------
                // 2. Body (Message)
                // ---------------------------------------------------
                if (hasMessage) ...[
                  const SizedBox(height: 4),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxHeight: config.scrollable
                            ? (config.messageMaxHeight ?? double.infinity)
                            : double.infinity,
                      ),
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification is ScrollStartNotification) {
                            widget.onScrollStart?.call();
                          } else if (notification is ScrollEndNotification) {
                            widget.onScrollEnd?.call();
                          }
                          return false;
                        },
                        child: Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          // Place Padding inside to keep the Scrollbar on the right edge (outside of Padding)
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics:
                                (config.scrollable || config.maxLines == null)
                                    ? const BouncingScrollPhysics()
                                    : const NeverScrollableScrollPhysics(),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: leftPad,
                                right: rightPad,
                                // If there is no footer, this is the last element, so add bottom padding
                                bottom: (!hasFooter) ? bottomPad : 4.0,
                              ),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  config.message!,
                                  style: config.messageStyle ??
                                      TextStyle(
                                        color: txtColor.withValues(alpha: 0.9),
                                        fontSize: 14,
                                      ),
                                  // If scrollable=true, display all lines (view by scrolling)
                                  maxLines: (config.scrollable ||
                                          config.maxLines == null)
                                      ? null
                                      : config.maxLines,
                                  overflow: (config.scrollable ||
                                          config.maxLines == null)
                                      ? TextOverflow.visible
                                      : TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                // ---------------------------------------------------
                // 3. Footer (Action / Content)
                // ---------------------------------------------------
                if (hasFooter) ...[
                  // If there is no message, make the gap with the title a little wider
                  SizedBox(height: hasMessage ? 0 : 8),

                  Padding(
                    padding: EdgeInsets.only(
                      left: leftPad,
                      right: rightPad,
                      bottom: bottomPad,
                      top: 0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (config.content != null)
                          config.content!
                        else if (config.action != null)
                          Row(
                            mainAxisAlignment: config.actionAlignment,
                            children: [
                              TextButton(
                                onPressed: () {
                                  config.action!.onPressed();
                                  if (config.action!.autoDismiss) {
                                    widget.onDismiss();
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: config.action!.textColor ??
                                      theme.colorScheme.primary,
                                  backgroundColor:
                                      config.action!.backgroundColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  config.action!.label,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
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

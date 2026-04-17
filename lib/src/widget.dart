import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

  /// Timer animation received from parent
  final Animation<double>? durationAnimation;

  const HyperSnackBarContent({
    super.key,
    required this.config,
    required this.onDismiss,
    this.onScrollStart,
    this.onScrollEnd,
    this.durationAnimation,
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
    final bgColor = config.backgroundColor ?? Colors.grey[800];
    final txtColor = config.textColor ?? Colors.white;
    final screenHeight = MediaQuery.of(context).size.height;

    // Get padding from config
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

    final bool hasNotifier = config.progressNotifier != null;
    final bool showProgressBar = config.progressBarWidth != null &&
        (widget.durationAnimation != null || hasNotifier);
    final bool isWipeEffect = showProgressBar && config.progressBarWidth == 0.0;

    // Determine effective animation and line effect flags safely
    final Animation<double>? effectiveProgressAnimation =
        config.progressIndicatorController ?? widget.durationAnimation;
    final bool isLineEffect = (config.showProgressIndicator ||
            (config.progressBarWidth != null &&
                config.progressBarWidth! > 0.0)) &&
        !isWipeEffect;

    // Use a safe width fallback (LinearProgressIndicator crashes on minHeight <= 0)
    final double safeProgressBarWidth =
        (config.progressBarWidth != null && config.progressBarWidth! > 0.0)
            ? config.progressBarWidth!
            : 4.0;

    // Progress bar color (default is faint white)
    final progressColor = config.progressBarColor ?? Colors.white.withAlpha(51);

    // --- Message Logic for Ellipsis (Stabilization Fix) ---
    // If not scrollable and maxLines is set, we treat it as "Summary Mode".
    final bool isEllipsisMode = !config.scrollable && config.maxLines != null;

    String displayMessage = config.message ?? '';

    if (hasMessage && isEllipsisMode) {
      // 1. Remove trailing spaces (prevents ellipsis from being pushed out)
      displayMessage = displayMessage.trimRight();
      // 2. Replace newlines with spaces (treat as single paragraph)
      //    This prevents hard line breaks from confusing the maxLines counter.
      displayMessage = displayMessage.replaceAll('\n', ' ');
    }

    Widget? iconWidget;

    if (config.useAdaptiveLoader) {
      // --- Loader ---

      Color loaderColor = txtColor;

      if (config.icon is Icon) {
        final icon = config.icon as Icon;
        if (icon.color != null) {
          loaderColor = icon.color!;
        }
      }

      final isCupertino = Theme.of(context).platform == TargetPlatform.iOS ||
          Theme.of(context).platform == TargetPlatform.macOS;

      // --- Loader ---
      iconWidget = SizedBox(
        width: 20,
        height: 20,
        child: isCupertino
            ? CupertinoActivityIndicator(
                color:
                    loaderColor, // This ensures that the color changes even on iOS
                radius: 10, // Match the diameter to 20px
              )
            : CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
              ),
      );
    } else {
      // --- Icon ---
      iconWidget = config.icon;
      if (iconWidget != null &&
          config.shouldIconPulse &&
          widget.durationAnimation != null) {
        iconWidget = AnimatedBuilder(
          animation: widget.durationAnimation!,
          builder: (context, child) {
            final double scale =
                1.0 + (widget.durationAnimation!.value * 10 % 1.0) * 0.2;
            return Transform.scale(scale: scale, child: child);
          },
          child: iconWidget,
        );
      }
    }

    BorderRadius effectiveBorderRadius =
        BorderRadius.circular(config.borderRadius);
    if (config.snackStyle == HyperSnackStyle.grounded) {
      effectiveBorderRadius = BorderRadius.zero;
    }

    final bool hasTitle = config.title != null && config.title!.isNotEmpty;
    final bool hasHeader =
        hasTitle || iconWidget != null || config.showCloseButton;

    final double pbHeight =
        isLineEffect ? (config.progressBarWidth ?? 4.0) : 0.0;

    Widget materialContent = Container(
      decoration: BoxDecoration(
        color: config.backgroundGradient == null ? bgColor : null,
        gradient: config.backgroundGradient,
        borderRadius: effectiveBorderRadius,
        border: config.border,
        boxShadow: config.boxShadows ??
            (config.elevation > 0
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: config.elevation,
                      offset: Offset(0, config.elevation / 2),
                    ),
                  ]
                : null),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ClipRRect(
          borderRadius: effectiveBorderRadius,
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // ===============================================
              // 1. Background Wipe (Wipe Effect) - Width == 0
              // ===============================================
              if (isWipeEffect)
                Positioned.fill(
                  child: Builder(
                    builder: (context) {
                      final wipeColor =
                          config.progressBarColor ?? Colors.white.withAlpha(77);
                      if (hasNotifier) {
                        return ValueListenableBuilder<double>(
                          valueListenable: config.progressNotifier!,
                          builder: (context, value, child) {
                            return TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                  begin: 0.0, end: value.clamp(0.0, 1.0)),
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                              builder: (context, animValue, child) {
                                return FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: animValue.clamp(0.0, 1.0),
                                  heightFactor: 1.0,
                                  child: Container(color: wipeColor),
                                );
                              },
                            );
                          },
                        );
                      } else {
                        return AnimatedBuilder(
                          animation: widget.durationAnimation!,
                          builder: (context, child) {
                            final double fillValue =
                                widget.durationAnimation!.value;
                            return FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: fillValue.clamp(0.0, 1.0),
                              heightFactor: 1.0,
                              child: Container(color: wipeColor),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),

              // ===============================================
              // 1.5. Accent color bar on the left edge
              // ===============================================
              if (config.leftBarIndicatorColor != null)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 5.0, // Thickness matching GetX default
                    color: config.leftBarIndicatorColor,
                  ),
                ),

              // ===============================================
              // 2. Main Content (InkWell)
              // ===============================================
              InkWell(
                onTap: config.onTap,
                borderRadius: BorderRadius.circular(config.borderRadius),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: screenHeight * 0.8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- Header ---
                      if (hasHeader)
                        Padding(
                          padding: EdgeInsets.only(
                            left: leftPad +
                                (config.leftBarIndicatorColor != null
                                    ? 5.0
                                    : 0.0), // Margin for the bar
                            right: rightPad,
                            top: topPad,
                            bottom: (!hasMessage &&
                                    !hasFooter &&
                                    config.userInputForm == null)
                                ? bottomPad
                                : 0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (iconWidget != null) ...[
                                iconWidget,
                                const SizedBox(width: 12)
                              ],
                              if (hasTitle)
                                Expanded(
                                  child: Text(
                                    config.title!,
                                    style: config.titleStyle ??
                                        TextStyle(
                                            color: txtColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              else
                                const Spacer(),
                              if (config.showCloseButton) ...[
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: widget.onDismiss,
                                  child: Icon(
                                    Icons.close,
                                    size: 20,
                                    color: txtColor.withAlpha(153),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                      // --- Body ---
                      if (hasMessage) ...[
                        if (hasHeader) const SizedBox(height: 4),
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
                                } else if (notification
                                    is ScrollEndNotification) {
                                  widget.onScrollEnd?.call();
                                }
                                return false;
                              },
                              child: Scrollbar(
                                controller: _scrollController,
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                  controller: _scrollController,
                                  physics: (config.scrollable ||
                                          config.maxLines == null)
                                      ? const BouncingScrollPhysics()
                                      : const NeverScrollableScrollPhysics(),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: leftPad +
                                          (config.leftBarIndicatorColor != null
                                              ? 5.0
                                              : 0.0),
                                      right: rightPad,
                                      top: (!hasHeader) ? topPad : 0,
                                      bottom: (!hasFooter &&
                                              config.userInputForm == null)
                                          ? (bottomPad + pbHeight)
                                          : 4.0,
                                    ),
                                    child: Align(
                                      alignment: (!hasHeader && !hasFooter)
                                          ? Alignment.centerLeft
                                          : Alignment.topLeft,
                                      child: Text(
                                        displayMessage, // Use stabilized message
                                        style: config.messageStyle ??
                                            TextStyle(
                                              color: txtColor.withAlpha(230),
                                              fontSize: 14,
                                            ),
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

                      // --- UserInputForm (Added feature) ---
                      if (config.userInputForm != null) ...[
                        if (hasHeader || hasMessage) const SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.only(
                            left: leftPad +
                                (config.leftBarIndicatorColor != null
                                    ? 5.0
                                    : 0.0),
                            right: rightPad,
                            bottom: hasFooter ? 8.0 : bottomPad,
                          ),
                          child: config.userInputForm!,
                        ),
                      ],

                      // ---------------------------------------------------
                      // Footer (Action / Content)
                      // ---------------------------------------------------
                      if (hasFooter) ...[
                        SizedBox(
                            height: (hasMessage || config.userInputForm != null)
                                ? 0
                                : 8),
                        Padding(
                          padding: EdgeInsets.only(
                            left: leftPad +
                                (config.leftBarIndicatorColor != null
                                    ? 5.0
                                    : 0.0),
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
                                        foregroundColor:
                                            config.action!.textColor ??
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                        backgroundColor:
                                            config.action!.backgroundColor,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        config.action!.label,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
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

              // ===============================================
              // 3. Thin Bar (Line Effect) - Width > 0
              // ===============================================
              if (isLineEffect &&
                  (effectiveProgressAnimation != null || hasNotifier))
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Builder(
                    builder: (context) {
                      final bgColor = config.progressIndicatorBackgroundColor ??
                          Colors.transparent;
                      final valueColor = config.progressIndicatorValueColor ??
                          AlwaysStoppedAnimation<Color>(progressColor);

                      if (hasNotifier) {
                        return ValueListenableBuilder<double>(
                          valueListenable: config.progressNotifier!,
                          builder: (context, value, child) {
                            return TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                  begin: 0.0, end: value.clamp(0.0, 1.0)),
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                              builder: (context, animValue, child) {
                                return LinearProgressIndicator(
                                  value: animValue.clamp(0.0, 1.0),
                                  backgroundColor: bgColor,
                                  valueColor: valueColor,
                                  minHeight: safeProgressBarWidth,
                                  borderRadius: BorderRadius.zero,
                                );
                              },
                            );
                          },
                        );
                      } else {
                        return AnimatedBuilder(
                          animation: effectiveProgressAnimation!,
                          builder: (context, child) {
                            return LinearProgressIndicator(
                              value: effectiveProgressAnimation.value
                                  .clamp(0.0, 1.0),
                              backgroundColor: bgColor,
                              valueColor: valueColor,
                              minHeight: safeProgressBarWidth,
                              borderRadius: BorderRadius.zero,
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (config.barBlur > 0.0) {
      materialContent = ClipRRect(
        borderRadius: BorderRadius.circular(config.borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: config.barBlur,
            sigmaY: config.barBlur,
          ),
          child: materialContent,
        ),
      );
    }

    return Align(
      alignment: config.alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          // Apply maxWidth if specified, otherwise it's infinite (existing behavior)
          maxWidth: config.maxWidth ?? double.infinity,
        ),
        child: Container(margin: config.margin, child: materialContent),
      ),
    );
  }
}

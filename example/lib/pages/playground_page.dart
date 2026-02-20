import 'dart:math';
import 'dart:ui'; // For ImageFilter

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyper_snackbar/hyper_snackbar.dart';

enum _IconMode { none, static, loader }

class PlaygroundPage extends StatefulWidget {
  const PlaygroundPage({super.key});

  @override
  State<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<PlaygroundPage> {
  // --- State Variables ---
  String _title = 'Hello Hyper!';
  String _message = 'This is a fully customizable snackbar.';

  // Style
  Color _selectedColor = const Color(0xFF323232);
  bool _useBorder = false;
  Color _borderColor = Colors.white;
  double _borderRadius = 12.0;
  double _elevation = 4.0;
  final double _contentPadding = 16.0;

  // Icon & Action
  _IconMode _iconMode = _IconMode.static;
  bool _showAction = false;
  MainAxisAlignment _actionAlignment = MainAxisAlignment.end;

  // Text Options
  int? _maxLines; // null = Unlimited
  bool _allowScroll = false;

  // Animation
  HyperSnackAnimationType _enterType = HyperSnackAnimationType.scale;
  HyperSnackAnimationType _exitType = HyperSnackAnimationType.fade;
  bool _useElasticCurve = true;

  // Progress Bar
  double _progressBarValue = 0.0;

  // Behavior & Layout
  HyperSnackPosition _position = HyperSnackPosition.top;
  bool _useMargin = true;
  double _durationSeconds = 2.5;
  bool _dismissible = true;

  // Stack/Queue & Order
  HyperSnackDisplayMode _displayMode = HyperSnackDisplayMode.stack;
  bool _newestOnTop = true;
  double _maxVisibleCount = 3.0; // New: Variable maxVisibleCount

  // Key for the inner Scaffold (Phone Screen)
  final GlobalKey _innerScaffoldKey = GlobalKey();

  // --- Presets ---
  void _applyPreset(String type) {
    setState(() {
      switch (type) {
        case 'Success':
          _title = 'Success!';
          _message = 'Data has been saved successfully.';
          _selectedColor = Colors.green.shade700;
          _enterType = HyperSnackAnimationType.left;
          _exitType = HyperSnackAnimationType.right;
          _progressBarValue = -1;
          _showAction = false;
          _useBorder = false;
          _borderRadius = 12.0;
          _iconMode = _IconMode.static;
          _maxLines = null;
          _allowScroll = false;
          _displayMode = HyperSnackDisplayMode.stack;
          _newestOnTop = true;
          _maxVisibleCount = 3.0;
          break;
        case 'Log View':
          _title = 'Log Entry';
          _message = 'Operation completed at ${DateTime.now().second}s.';
          _selectedColor = const Color(0xFF212121);
          _enterType = HyperSnackAnimationType.top;
          _exitType = HyperSnackAnimationType.fade;
          _progressBarValue = 0.0;
          _useElasticCurve = false;
          _showAction = false;
          _useBorder = true;
          _borderColor = Colors.grey.shade800;
          _borderRadius = 4.0;
          _iconMode = _IconMode.static;
          _position = HyperSnackPosition.top;
          _displayMode = HyperSnackDisplayMode.stack;
          _newestOnTop = false; // Log style
          _maxLines = 1;
          _allowScroll = false;
          _maxVisibleCount = 5.0; // Show more logs
          break;
        case 'Long Text':
          _title = 'Long Text Test';
          _message = ('Long message ' * 100).trim();
          _selectedColor = const Color(0xFF212121);
          _enterType = HyperSnackAnimationType.scale;
          _progressBarValue = 4.0;
          _showAction = true;
          _iconMode = _IconMode.static;
          _maxLines = 3;
          _allowScroll = true;
          _actionAlignment = MainAxisAlignment.end;
          _displayMode = HyperSnackDisplayMode.stack;
          _newestOnTop = true;
          _maxVisibleCount = 3.0;
          break;
        case 'Loading':
          _title = 'Processing...';
          _message = 'Please wait while we connect to the server.';
          _selectedColor = Colors.indigo.shade700;
          _enterType = HyperSnackAnimationType.fade;
          _exitType = HyperSnackAnimationType.fade;
          _progressBarValue = -1; // No progress bar (infinite feel)
          _showAction = false;
          _useBorder = false;
          _borderRadius = 12.0;
          _iconMode = _IconMode.loader; // Loader Mode
          _maxLines = null;
          _allowScroll = false;
          _displayMode = HyperSnackDisplayMode.stack;
          _newestOnTop = true;
          _durationSeconds = 4.0; // Slightly longer
          break;
      }
    });
  }

  void _randomize() {
    final random = Random();
    setState(() {
      _selectedColor = [
        const Color(0xFF323232),
        Colors.green.shade700,
        Colors.red.shade700,
        const Color(0xFF2196F3),
        const Color(0xFF6C63FF),
      ][random.nextInt(5)];

      _enterType = HyperSnackAnimationType
          .values[random.nextInt(HyperSnackAnimationType.values.length)];
      _exitType = HyperSnackAnimationType
          .values[random.nextInt(HyperSnackAnimationType.values.length)];
      _position = random.nextBool()
          ? HyperSnackPosition.top
          : HyperSnackPosition.bottom;
      _borderRadius = random.nextInt(30).toDouble();
      _useElasticCurve = random.nextBool();
      _progressBarValue = [-1.0, 0.0, 4.0][random.nextInt(3)];
      _useBorder = random.nextBool();
      if (_useBorder) {
        _borderColor = [
          Colors.white,
          Colors.cyanAccent,
          Colors.amber,
        ][random.nextInt(3)];
      }
      _showAction = random.nextBool();
      if (_showAction) {
        _actionAlignment = [
          MainAxisAlignment.start,
          MainAxisAlignment.center,
          MainAxisAlignment.end,
        ][random.nextInt(3)];
      }
      _displayMode = random.nextBool()
          ? HyperSnackDisplayMode.stack
          : HyperSnackDisplayMode.queue;
      _newestOnTop = random.nextBool();
      _maxVisibleCount = (random.nextInt(5) + 1).toDouble();
    });
    _showSnackbar();
  }

  void _showSnackbar() {
    if (_title == 'Log Entry') {
      setState(() {
        _message =
            'Operation completed at ${DateTime.now().minute}:${DateTime.now().second}.${DateTime.now().millisecond}';
      });
    }

    double? width;
    if (_progressBarValue >= 0) {
      width = _progressBarValue;
    }

    final isLightBg = _selectedColor.computeLuminance() > 0.5;
    final contentColor = isLightBg ? Colors.black87 : Colors.white;

    Color? progressColor;
    if (width == 0) {
      progressColor =
          isLightBg ? Colors.black.withAlpha(25) : Colors.white.withAlpha(38);
    } else if (width != null && width > 0) {
      progressColor = Colors.redAccent;
    }

    int? activeMaxLines = _maxLines;
    double? activeMaxHeight;

    if (_allowScroll) {
      activeMaxLines = null;
      if (_maxLines != null) {
        activeMaxHeight = _maxLines! * 20.0;
      } else {
        activeMaxHeight = 200.0;
      }
    }

    EdgeInsets effectiveMargin =
        _useMargin ? const EdgeInsets.all(12) : EdgeInsets.zero;

    final targetContext = _innerScaffoldKey.currentContext;

    if (targetContext != null) {
      HyperSnackbar.show(
        context: targetContext,
        title: _title,
        message: _message,
        backgroundColor: _selectedColor,
        textColor: contentColor,
        icon: _iconMode == _IconMode.none
            ? null
            : Icon(
                _getIconForColor(_selectedColor),
                color: contentColor,
              ),
        useAdaptiveLoader: _iconMode == _IconMode.loader,
        borderRadius: _borderRadius,
        elevation: _elevation,
        border: _useBorder ? Border.all(color: _borderColor, width: 2) : null,
        padding: EdgeInsets.all(_contentPadding),
        position: _position,
        margin: effectiveMargin,
        enableSwipe: _dismissible,
        displayMode: _displayMode,
        newestOnTop: _newestOnTop,
        maxVisibleCount: _maxVisibleCount.toInt(),
        maxLines: activeMaxLines,
        scrollable: _allowScroll,
        messageMaxHeight: activeMaxHeight,
        enterAnimationType: _enterType,
        exitAnimationType: _exitType,
        enterCurve: _useElasticCurve ? Curves.elasticOut : Curves.easeOutQuart,
        enterAnimationDuration: _useElasticCurve
            ? const Duration(milliseconds: 800)
            : const Duration(milliseconds: 400),
        progressBarWidth: width,
        progressBarColor: progressColor,
        displayDuration: Duration(
          milliseconds: (_durationSeconds * 1000).toInt(),
        ),
        action: _showAction
            ? HyperSnackAction(
                label: 'UNDO',
                textColor:
                    isLightBg ? Colors.blue.shade700 : Colors.amberAccent,
                onPressed: () {
                  _showUndoFeedback();
                },
              )
            : null,
        actionAlignment: _actionAlignment,
        useLocalOverlay: true,
      );
    }
  }

  void _showUndoFeedback() {
    final targetContext = _innerScaffoldKey.currentContext;
    if (targetContext != null) {
      EdgeInsets margin =
          _useMargin ? const EdgeInsets.all(12) : EdgeInsets.zero;

      HyperSnackbar.show(
        context: targetContext,
        title: 'Action Triggered',
        message: 'The undo action was successfully processed.',
        backgroundColor: Colors.grey.shade900,
        icon: const Icon(Icons.refresh, color: Colors.white),
        position: _position,
        margin: margin,
        displayDuration: const Duration(seconds: 2),
        useLocalOverlay: true,
      );
    }
  }

  IconData _getIconForColor(Color color) {
    if (color == Colors.green.shade700) return Icons.check_circle;
    if (color == Colors.red.shade700) return Icons.error;
    if (color == Colors.orange.shade800) return Icons.warning;
    if (color == const Color(0xFF2196F3)) return Icons.download;
    if (color == const Color(0xFF212121)) return Icons.design_services;
    return Icons.rocket_launch;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'HyperSnackbar Playground',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withAlpha(128)),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Surprise Me',
            onPressed: _randomize,
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy Code',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _generateCode()));
              HyperSnackbar.showInfo(
                title: 'Code Copied!',
                margin: const EdgeInsets.all(8),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
          ),
        ),
        child: SafeArea(
          child: isDesktop
              ? Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: _buildGlassContainer(
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: _buildControls(),
                              ),
                            ),
                            Divider(
                              height: 1,
                              color: Colors.white.withAlpha(61),
                            ),
                            _buildShowButtonArea(),
                          ],
                        ),
                      ),
                    ),
                    Expanded(flex: 6, child: _buildPhonePreview()),
                  ],
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: _buildGlassContainer(
                                child: _buildControls(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(height: 650, child: _buildPhonePreview()),
                          ],
                        ),
                      ),
                    ),
                    _buildShowButtonArea(glass: true),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(102),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withAlpha(25)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildControls() {
    const textStyle = TextStyle(color: Colors.white);

    return Theme(
      data: ThemeData.dark().copyWith(
        sliderTheme: SliderThemeData(
          activeTrackColor: Colors.cyanAccent,
          thumbColor: Colors.cyan,
          overlayColor: Colors.cyan.withAlpha(51),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? Colors.cyan
                : Colors.grey,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? Colors.cyan.withAlpha(128)
                : null,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('1. Layout & Behavior'),
            Row(
              children: [
                _label('Pos: '),
                const SizedBox(width: 8),
                DropdownButton<HyperSnackPosition>(
                  value: _position,
                  dropdownColor: Colors.grey.shade900,
                  style: textStyle,
                  isDense: true,
                  underline: Container(height: 1, color: Colors.white54),
                  items: const [
                    DropdownMenuItem(
                      value: HyperSnackPosition.top,
                      child: Text('TOP'),
                    ),
                    DropdownMenuItem(
                      value: HyperSnackPosition.bottom,
                      child: Text('BOTTOM'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _position = v!),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _label('Mode: '),
                const SizedBox(width: 8),
                SegmentedButton<HyperSnackDisplayMode>(
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.selected)
                          ? Colors.cyan.withAlpha(77)
                          : Colors.transparent,
                    ),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                  segments: const [
                    ButtonSegment(
                      value: HyperSnackDisplayMode.stack,
                      label: Text('Stack'),
                    ),
                    ButtonSegment(
                      value: HyperSnackDisplayMode.queue,
                      label: Text('Queue'),
                    ),
                  ],
                  selected: {_displayMode},
                  onSelectionChanged: (newSet) =>
                      setState(() => _displayMode = newSet.first),
                ),

                // Max Visible Count Slider (Only for Stack)
                if (_displayMode == HyperSnackDisplayMode.stack) ...[
                  const SizedBox(width: 16),
                  _label('Max: ${_maxVisibleCount.toInt()}'),
                  Expanded(
                    child: Slider(
                      value: _maxVisibleCount,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      onChanged: (v) => setState(() => _maxVisibleCount = v),
                    ),
                  ),
                ],
              ],
            ),
            if (_displayMode == HyperSnackDisplayMode.stack) ...[
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Newest on Top', style: textStyle),
                subtitle: Text(
                  _newestOnTop
                      ? 'New entries push old ones down'
                      : 'New entries append to bottom (Log view)',
                  style: const TextStyle(fontSize: 10, color: Colors.white70),
                ),
                dense: true,
                value: _newestOnTop,
                onChanged: (v) => setState(() => _newestOnTop = v),
              ),
            ],
            Row(
              children: [
                _label('Margin: '),
                Switch(
                  value: _useMargin,
                  onChanged: (v) => setState(() => _useMargin = v),
                ),
                const SizedBox(width: 16),
                _label('Dismissible: '),
                Switch(
                  value: _dismissible,
                  onChanged: (v) => setState(() => _dismissible = v),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _sectionHeader('2. Presets'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _presetButton('Success', Colors.greenAccent),
                _presetButton('Wipe', Colors.lightBlueAccent),
                _presetButton('Log View', Colors.grey),
                _presetButton('Long Text', Colors.white),
                _presetButton('Loading', Colors.indigo),
              ],
            ),
            const SizedBox(height: 24),
            _sectionHeader('3. Real-time Style Preview'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(13),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(_contentPadding),
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      borderRadius: BorderRadius.circular(_borderRadius),
                      border: _useBorder
                          ? Border.all(color: _borderColor, width: 2)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(77),
                          blurRadius: _elevation,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_iconMode == _IconMode.static) ...[
                          Icon(
                            _getIconForColor(_selectedColor),
                            color: _selectedColor.computeLuminance() > 0.5
                                ? Colors.black87
                                : Colors.white,
                          ),
                          const SizedBox(width: 12),
                        ],
                        Flexible(
                          child: Text(
                            'Style Preview',
                            style: TextStyle(
                              color: _selectedColor.computeLuminance() > 0.5
                                  ? Colors.black87
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _sectionHeader('4. Content'),
            TextField(
              style: textStyle,
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyanAccent),
                ),
                isDense: true,
              ),
              controller: TextEditingController(text: _title),
              onChanged: (v) => _title = v,
            ),
            const SizedBox(height: 12),
            TextField(
              style: textStyle,
              decoration: const InputDecoration(
                labelText: 'Message',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyanAccent),
                ),
                isDense: true,
              ),
              controller: TextEditingController(text: _message),
              maxLines: 3,
              minLines: 1,
              onChanged: (v) => _message = v,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Max Lines: ', style: textStyle.copyWith(fontSize: 13)),
                Expanded(
                  child: Slider(
                    value: _maxLines?.toDouble() ?? 6.0,
                    min: 1,
                    max: 6,
                    divisions: 5,
                    label: _maxLines == null ? 'All' : _maxLines.toString(),
                    onChanged: (v) {
                      setState(() {
                        _maxLines = v >= 6 ? null : v.toInt();
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    _maxLines == null ? 'All' : '${_maxLines!}',
                    style: textStyle.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Scrollable Content', style: textStyle),
              subtitle: _allowScroll
                  ? const Text(
                      'Use "Max Lines" slider to set visible height.',
                      style: TextStyle(fontSize: 10, color: Colors.white70),
                    )
                  : null,
              dense: true,
              value: _allowScroll,
              onChanged: (v) => setState(() => _allowScroll = v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(height: 12),
                _label('Icon Type:'),
                const SizedBox(height: 8),
                Expanded(
                  child: SegmentedButton<_IconMode>(
                    showSelectedIcon: false,
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.selected)
                              ? Colors.cyan.withAlpha(77)
                              : Colors.transparent),
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                    ),
                    segments: const [
                      ButtonSegment(
                        value: _IconMode.none,
                        label: Text('None'),
                        icon: Icon(Icons.close, size: 16),
                      ),
                      ButtonSegment(
                        value: _IconMode.static,
                        label: Text('Static'),
                        icon: Icon(Icons.image, size: 16),
                      ),
                      ButtonSegment(
                        value: _IconMode.loader,
                        label: Text('Loader'),
                        icon: Icon(Icons.refresh, size: 16),
                      ),
                    ],
                    selected: {_iconMode},
                    onSelectionChanged: (newSet) =>
                        setState(() => _iconMode = newSet.first),
                  ),
                ),
                const SizedBox(width: 16),
                _compactSwitch('Action', _showAction, (v) => _showAction = v),
              ],
            ),
            if (_showAction) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    'Action Pos: ',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  const SizedBox(width: 8),
                  SegmentedButton<MainAxisAlignment>(
                    showSelectedIcon: false,
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: WidgetStateProperty.all(EdgeInsets.zero),
                      backgroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? Colors.cyan.withAlpha(77)
                            : Colors.transparent,
                      ),
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                    ),
                    segments: const [
                      ButtonSegment(
                        value: MainAxisAlignment.start,
                        icon: Icon(Icons.align_horizontal_left),
                      ),
                      ButtonSegment(
                        value: MainAxisAlignment.center,
                        icon: Icon(Icons.align_horizontal_center),
                      ),
                      ButtonSegment(
                        value: MainAxisAlignment.end,
                        icon: Icon(Icons.align_horizontal_right),
                      ),
                    ],
                    selected: {_actionAlignment},
                    onSelectionChanged: (newSet) {
                      setState(() => _actionAlignment = newSet.first);
                    },
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            _sectionHeader('5. Appearance'),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _colorOption(const Color(0xFF323232)),
                  _colorOption(Colors.white),
                  _colorOption(const Color(0xFF212121)),
                  _colorOption(Colors.green.shade700),
                  _colorOption(Colors.red.shade700),
                  _colorOption(const Color(0xFF2196F3)),
                  _colorOption(const Color(0xFF6C63FF)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _label('Border: '),
                _compactSwitch('', _useBorder, (v) => _useBorder = v),
                if (_useBorder) ...[
                  const SizedBox(width: 12),
                  _borderColorOption(Colors.white),
                  _borderColorOption(Colors.cyanAccent),
                  _borderColorOption(Colors.redAccent),
                  _borderColorOption(Colors.black),
                ],
              ],
            ),
            const SizedBox(height: 8),
            _sliderRow(
              'Radius',
              _borderRadius,
              0,
              32,
              (v) => setState(() => _borderRadius = v),
            ),
            _sliderRow(
              'Shadow',
              _elevation,
              0,
              20,
              (v) => setState(() => _elevation = v),
            ),
            const SizedBox(height: 24),
            _sectionHeader('6. Animation'),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<HyperSnackAnimationType>(
                    key: ValueKey('enter_$_enterType'),
                    dropdownColor: Colors.grey.shade900,
                    style: textStyle,
                    decoration: const InputDecoration(
                      labelText: 'Enter',
                      labelStyle: TextStyle(color: Colors.white70),
                      isDense: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                    ),
                    initialValue: _enterType,
                    items: HyperSnackAnimationType.values
                        .map(
                          (e) =>
                              DropdownMenuItem(value: e, child: Text(e.name)),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _enterType = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<HyperSnackAnimationType>(
                    key: ValueKey('exit_$_exitType'),
                    dropdownColor: Colors.grey.shade900,
                    style: textStyle,
                    decoration: const InputDecoration(
                      labelText: 'Exit',
                      labelStyle: TextStyle(color: Colors.white70),
                      isDense: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                    ),
                    initialValue: _exitType,
                    items: HyperSnackAnimationType.values
                        .map(
                          (e) =>
                              DropdownMenuItem(value: e, child: Text(e.name)),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _exitType = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Elastic Curve (Bouncy)', style: textStyle),
              dense: true,
              value: _useElasticCurve,
              onChanged: (v) => setState(() => _useElasticCurve = v),
            ),
            _sliderRow(
              'Duration (s)',
              _durationSeconds,
              1,
              10,
              (v) => setState(() => _durationSeconds = v),
            ),
            const SizedBox(height: 24),
            _sectionHeader('7. Progress Bar'),
            SegmentedButton<double>(
              segments: const [
                ButtonSegment(value: -1, label: Text('None')),
                ButtonSegment(value: 0.0, label: Text('Wipe')),
                ButtonSegment(value: 4.0, label: Text('Line')),
              ],
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? Colors.cyan.withAlpha(77)
                      : Colors.transparent,
                ),
                foregroundColor: WidgetStateProperty.all(Colors.white),
              ),
              selected: {
                _progressBarValue == 0.0
                    ? 0.0
                    : (_progressBarValue > 0 ? 4.0 : -1),
              },
              onSelectionChanged: (Set<double> newSelection) {
                setState(() {
                  _progressBarValue = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildShowButtonArea({bool glass = false}) {
    final button = SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF48A9FE)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withAlpha(102),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _showSnackbar,
          icon: const Icon(Icons.bolt, color: Colors.white),
          label: const Text(
            'SHOW SNACKBAR',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        ),
      ),
    );

    if (glass) {
      return Container(padding: const EdgeInsets.all(24), child: button);
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: button,
    );
  }

  Widget _buildPhonePreview() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Device Frame (Notch Removed)
          Container(
            width: 380,
            height: 750,
            decoration: BoxDecoration(
              color: Colors.black, // Device body
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(102),
                  blurRadius: 30,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12), // Bezel width
            child: Stack(
              children: [
                // Screen Content
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Navigator(
                    onGenerateRoute: (settings) {
                      return MaterialPageRoute(
                        builder: (context) => Scaffold(
                          key: _innerScaffoldKey, // Key for context
                          extendBodyBehindAppBar: true,
                          appBar: AppBar(
                            title: const Text(
                              'Hyper Demo',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            centerTitle: true,
                          ),
                          body: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFF2A2D3E), Color(0xFF1F1F2E)],
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Mock Content
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.touch_app,
                                        size: 64,
                                        color: Colors.white.withAlpha(25),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Preview Screen',
                                        style: TextStyle(
                                          color: Colors.white.withAlpha(51),
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Code Overlay
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: ClipRRect(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 10,
                                        sigmaY: 10,
                                      ),
                                      child: Container(
                                        height: 220,
                                        padding: const EdgeInsets.all(16),
                                        color: Colors.black.withAlpha(153),
                                        child: SingleChildScrollView(
                                          child: SelectableText(
                                            _generateCode(),
                                            style: const TextStyle(
                                              fontFamily: 'Courier',
                                              color: Color(0xFF00FFC6),
                                              fontSize: 10,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Interactive Device Preview',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.cyanAccent,
        ),
      ),
    );
  }

  Widget _sliderRow(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text('$label: ', style: const TextStyle(color: Colors.white)),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            label: value.toInt().toString(),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 30,
          child: Text(
            '${value.toInt()}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _compactSwitch(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: value,
            onChanged: (v) => setState(() => onChanged(v)),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Widget _presetButton(String label, Color color) {
    return ActionChip(
      label: Text(label),
      backgroundColor: color.withAlpha(25),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
      side: BorderSide.none,
      onPressed: () => _applyPreset(label),
    );
  }

  Widget _colorOption(Color color) {
    final isSelected = _selectedColor == color;
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withAlpha(102),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: color.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
                size: 16,
              )
            : null,
      ),
    );
  }

  Widget _borderColorOption(Color color) {
    final isSelected = _borderColor == color;
    return GestureDetector(
      onTap: () => setState(() => _borderColor = color),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 4),
        ),
        child: isSelected
            ? const Center(
                child: Icon(Icons.circle, size: 8, color: Colors.white),
              )
            : null,
      ),
    );
  }

  String _generateCode() {
    final sb = StringBuffer();
    final isLightBg = _selectedColor.computeLuminance() > 0.5;

    sb.writeln('HyperSnackbar.show(');
    sb.writeln("  title: '$_title',");

    // TRUNCATE MESSAGE IN CODE VIEW
    if (_message.isNotEmpty) {
      if (_message.length > 80) {
        sb.writeln("  message: '${_message.substring(0, 80)}...',");
      } else {
        sb.writeln("  message: '$_message',");
      }
    }

    sb.writeln(
      '  backgroundColor: Color(0x${_selectedColor.toARGB32().toRadixString(16).toUpperCase()}),',
    );

    if (_useBorder) {
      sb.writeln(
        '  border: Border.all(color: Color(0x${_borderColor.toARGB32().toRadixString(16).toUpperCase()}), width: 2),',
      );
    }
    if (_borderRadius != 12.0) sb.writeln('  borderRadius: $_borderRadius,');
    if (_elevation != 4.0) sb.writeln('  elevation: $_elevation,');
    if (_contentPadding != 16.0) {
      sb.writeln('  padding: EdgeInsets.all($_contentPadding),');
    }

    if (_iconMode == _IconMode.none) {
      sb.writeln('  icon: null,');
    } else if (_iconMode == _IconMode.static) {
      if (isLightBg) {
        sb.writeln('  textColor: Colors.black87,');
        sb.writeln(
            '  icon: Icon(Icons.${_getIconName()}, color: Colors.black87),');
      } else {
        sb.writeln(
            '  icon: Icon(Icons.${_getIconName()}, color: Colors.white),');
      }
    } else if (_iconMode == _IconMode.loader) {
      sb.writeln('  useAdaptiveLoader: true,');
    }

    if (_position == HyperSnackPosition.bottom) {
      sb.writeln('  position: HyperSnackPosition.bottom,');
    }

    if (!_useMargin) {
      sb.writeln('  margin: EdgeInsets.zero,');
    }

    if (!_dismissible) sb.writeln('  dismissible: false,');

    if (_displayMode == HyperSnackDisplayMode.queue) {
      sb.writeln('  displayMode: HyperSnackDisplayMode.queue,');
    } else {
      // Only show if Stack
      if (_maxVisibleCount != 3.0) {
        sb.writeln('  maxVisibleCount: ${_maxVisibleCount.toInt()},');
      }
    }

    if (!_newestOnTop) {
      sb.writeln('  newestOnTop: false, // Log style');
    }

    if (_durationSeconds != 2.5) {
      sb.writeln(
        '  displayDuration: Duration(milliseconds: ${(_durationSeconds * 1000).toInt()}),',
      );
    }

    if (_allowScroll) {
      sb.writeln('  scrollable: true,');
      if (_maxLines != null) {
        sb.writeln('  messageMaxHeight: ${_maxLines! * 20.0},');
      } else {
        sb.writeln('  messageMaxHeight: 200.0,');
      }
    } else {
      if (_maxLines != null) {
        sb.writeln('  maxLines: $_maxLines,');
      }
    }

    sb.writeln(
      '  enterAnimationType: HyperSnackAnimationType.${_enterType.name},',
    );
    if (_exitType != HyperSnackAnimationType.fade) {
      sb.writeln(
        '  exitAnimationType: HyperSnackAnimationType.${_exitType.name},',
      );
    }

    if (_useElasticCurve) {
      sb.writeln('  enterCurve: Curves.elasticOut,');
      sb.writeln(
        '  enterAnimationDuration: const Duration(milliseconds: 800),',
      );
    }

    if (_progressBarValue == 0.0) {
      sb.writeln('  progressBarWidth: 0.0, // Wipe');
    } else if (_progressBarValue > 0) {
      sb.writeln('  progressBarWidth: 4.0,');
    }

    if (_showAction) {
      sb.writeln('  action: HyperSnackAction(');
      sb.writeln("    label: 'UNDO',");
      sb.writeln('    onPressed: () {},');
      sb.writeln('  ),');
      if (_actionAlignment != MainAxisAlignment.end) {
        if (_actionAlignment == MainAxisAlignment.center) {
          sb.writeln('  actionAlignment: MainAxisAlignment.center,');
        } else if (_actionAlignment == MainAxisAlignment.start) {
          sb.writeln('  actionAlignment: MainAxisAlignment.start,');
        }
      }
    }

    sb.writeln(');');
    return sb.toString();
  }

  String _getIconName() {
    if (_selectedColor == Colors.green.shade700) return 'check_circle';
    if (_selectedColor == Colors.red.shade700) return 'error';
    if (_selectedColor == Colors.orange.shade800) return 'warning';
    if (_selectedColor == const Color(0xFF2196F3)) return 'download';
    if (_selectedColor == const Color(0xFF212121)) return 'design_services';
    return 'rocket_launch';
  }
}

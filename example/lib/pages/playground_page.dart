import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyper_snackbar/hyper_snackbar.dart';

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
  bool _showIcon = true;
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
  HyperSnackPosition _position = HyperSnackPosition.top; // Default TOP
  bool _useMargin = true;
  double _durationSeconds = 2.5;
  bool _dismissible = true;

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
          _showIcon = true;
          _maxLines = null;
          _allowScroll = false;
          break;
        case 'Wipe':
          _title = 'Downloading...';
          _message = 'Please wait while we fetch your data.';
          _selectedColor = const Color(0xFF2196F3);
          _enterType = HyperSnackAnimationType.top;
          _exitType = HyperSnackAnimationType.top;
          _progressBarValue = 0.0;
          _useElasticCurve = false;
          _showAction = false;
          _useBorder = false;
          _showIcon = true;
          _maxLines = null;
          _allowScroll = false;
          break;
        case 'Long Text':
          _title = 'Long Text Test';
          // Reverted to the repetitive pattern as requested.
          // Using trim() to minimize trailing space issues where possible.
          _message = ('Long message ' * 100).trim();

          _selectedColor = const Color(0xFF212121);
          _enterType = HyperSnackAnimationType.scale;
          _progressBarValue = 4.0;
          _showAction = true;
          _showIcon = true;
          _maxLines = 3;
          _allowScroll = true;
          _actionAlignment = MainAxisAlignment.end;
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
    });
    _showSnackbar();
  }

  void _showSnackbar() {
    double? width;
    if (_progressBarValue >= 0) {
      width = _progressBarValue;
    }

    final isLightBg = _selectedColor.computeLuminance() > 0.5;
    final contentColor = isLightBg ? Colors.black87 : Colors.white;

    Color? progressColor;
    if (width == 0) {
      progressColor = isLightBg
          ? Colors.black.withValues(alpha: 0.1)
          : Colors.white.withValues(alpha: 0.15);
    } else if (width != null && width > 0) {
      progressColor = Colors.redAccent;
    }

    // --- Logic for Scrollable vs MaxLines ---
    int? activeMaxLines = _maxLines;
    double? activeMaxHeight;

    if (_allowScroll) {
      // If scrolling is ON, disable maxLines text truncation.
      activeMaxLines = null;

      // Use slider value to calculate a height constraint.
      // Adjusted multiplier from 28.0 to 20.0 to fix the "one extra line" issue.
      if (_maxLines != null) {
        activeMaxHeight = _maxLines! * 20.0;
      } else {
        activeMaxHeight = 200.0;
      }
    }

    final targetContext = _innerScaffoldKey.currentContext;

    if (targetContext != null) {
      HyperSnackbar.show(
        context: targetContext,
        title: _title,
        message: _message,
        backgroundColor: _selectedColor,
        textColor: contentColor,
        // Icon
        icon: _showIcon
            ? Icon(_getIconForColor(_selectedColor), color: contentColor)
            : null,
        // Style
        borderRadius: _borderRadius,
        elevation: _elevation,
        border: _useBorder ? Border.all(color: _borderColor, width: 2) : null,
        padding: EdgeInsets.all(_contentPadding),

        // Layout
        position: _position,
        margin: _useMargin ? const EdgeInsets.all(12) : EdgeInsets.zero,
        enableSwipe: _dismissible,

        // --- Text Options ---
        maxLines: activeMaxLines,
        scrollable: _allowScroll,
        messageMaxHeight: activeMaxHeight,

        // Animation
        enterAnimationType: _enterType,
        exitAnimationType: _exitType,
        enterCurve: _useElasticCurve ? Curves.elasticOut : Curves.easeOutQuart,
        enterAnimationDuration: _useElasticCurve
            ? const Duration(milliseconds: 800)
            : const Duration(milliseconds: 400),
        // Progress
        progressBarWidth: width,
        progressBarColor: progressColor,
        displayDuration: Duration(
          milliseconds: (_durationSeconds * 1000).toInt(),
        ),

        // Action
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
      );
    }
  }

  void _showUndoFeedback() {
    final targetContext = _innerScaffoldKey.currentContext;
    if (targetContext != null) {
      HyperSnackbar.show(
        context: targetContext,
        title: 'Action Triggered',
        message: 'The undo action was successfully processed.',
        backgroundColor: Colors.grey.shade900,
        icon: const Icon(Icons.refresh, color: Colors.white),
        position: _position,
        displayDuration: const Duration(seconds: 2),
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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Playground'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        scrolledUnderElevation: 0,
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
      body: isDesktop
          ? Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(child: _buildControls()),
                        ),
                        const Divider(height: 1),
                        _buildShowButtonArea(),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(flex: 6, child: _buildPhonePreview()),
              ],
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildControls(),
                        const SizedBox(height: 20),
                        SizedBox(height: 600, child: _buildPhonePreview()),
                      ],
                    ),
                  ),
                ),
                _buildShowButtonArea(),
              ],
            ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. Position & Presets ---
          Row(
            children: [
              const Text(
                'Pos: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButton<HyperSnackPosition>(
                value: _position,
                isDense: true,
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
              const Spacer(),
              const Text('Dismissible: '),
              Switch(
                value: _dismissible,
                onChanged: (v) => setState(() => _dismissible = v),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _sectionHeader('Presets'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _presetButton('Success', Colors.green),
              _presetButton('Wipe', Colors.blue),
              _presetButton('Long Text', Colors.black87),
            ],
          ),

          const SizedBox(height: 24),
          // --- 2. Live Style Preview ---
          _sectionHeader('Real-time Style Preview'),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                // The Mock Snackbar (Visual Only)
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
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: _elevation,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_showIcon) ...[
                        Icon(
                          _getIconForColor(_selectedColor),
                          color: _selectedColor.computeLuminance() > 0.5
                              ? Colors.black87
                              : Colors.white,
                        ),
                        const SizedBox(width: 12),
                      ],
                      Text(
                        'Style Preview',
                        style: TextStyle(
                          color: _selectedColor.computeLuminance() > 0.5
                              ? Colors.black87
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This preview updates shape & color only.',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          // --- 3. Content ---
          _sectionHeader('Content'),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            controller: TextEditingController(text: _title),
            onChanged: (v) => _title = v,
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Message',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            controller: TextEditingController(text: _message),
            maxLines: 3,
            minLines: 1,
            onChanged: (v) => _message = v,
          ),
          const SizedBox(height: 12),
          // Text Options
          Row(
            children: [
              const Text('Max Lines: ', style: TextStyle(fontSize: 13)),
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Scrollable Content'),
            subtitle: _allowScroll
                ? const Text(
                    'Use "Max Lines" slider to set visible height.',
                    style: TextStyle(fontSize: 10),
                  )
                : null,
            dense: true,
            value: _allowScroll,
            onChanged: (v) => setState(() => _allowScroll = v),
          ),

          const SizedBox(height: 12),
          // Toggles
          Row(
            children: [
              _compactSwitch('Icon', _showIcon, (v) => _showIcon = v),
              const SizedBox(width: 24),
              _compactSwitch('Action', _showAction, (v) => _showAction = v),
            ],
          ),
          // Action Alignment (Only if Action is shown)
          if (_showAction) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Action Pos: ', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                SegmentedButton<MainAxisAlignment>(
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: WidgetStateProperty.all(EdgeInsets.zero),
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
          // --- 4. Appearance ---
          _sectionHeader('Appearance'),
          // Colors
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

          // Border
          Row(
            children: [
              const Text(
                'Border: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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

          Row(
            children: [
              const Text('Margin: '),
              Switch(
                value: _useMargin,
                onChanged: (v) => setState(() => _useMargin = v),
              ),
            ],
          ),

          const SizedBox(height: 24),
          // --- 5. Animation ---
          _sectionHeader('Animation'),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<HyperSnackAnimationType>(
                  key: ValueKey('enter_$_enterType'),
                  decoration: const InputDecoration(
                    labelText: 'Enter',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _enterType,
                  items: HyperSnackAnimationType.values
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _enterType = v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<HyperSnackAnimationType>(
                  key: ValueKey('exit_$_exitType'),
                  decoration: const InputDecoration(
                    labelText: 'Exit',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _exitType,
                  items: HyperSnackAnimationType.values
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.name)),
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
            title: const Text('Elastic Curve (Bouncy)'),
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
          // --- 6. Progress Bar ---
          _sectionHeader('Progress Bar'),
          SegmentedButton<double>(
            segments: const [
              ButtonSegment(value: -1, label: Text('None')),
              ButtonSegment(value: 0.0, label: Text('Wipe')),
              ButtonSegment(value: 4.0, label: Text('Line')),
            ],
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
    );
  }

  Widget _buildShowButtonArea() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _showSnackbar,
          icon: const Icon(Icons.bolt),
          label: const Text(
            'SHOW SNACKBAR',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            elevation: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildPhonePreview() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Phone Frame
          Container(
            width: 380,
            height: 700,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.grey.shade800, width: 8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Navigator(
              onGenerateRoute: (settings) {
                return MaterialPageRoute(
                  builder: (context) => Scaffold(
                    key: _innerScaffoldKey, // Key for context
                    backgroundColor: Colors.grey[50], // Preview BG
                    appBar: AppBar(
                      title: const Text(
                        'My App',
                        style: TextStyle(fontSize: 16),
                      ),
                      backgroundColor: Colors.white,
                      elevation: 0,
                      centerTitle: true,
                    ),
                    body: Stack(
                      children: [
                        // App Content
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.touch_app,
                                size: 64,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Preview Area',
                                style: TextStyle(
                                  color: Colors.grey[400],
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
                          child: Container(
                            height: 200,
                            padding: const EdgeInsets.all(16),
                            color: const Color(0xFF1E1E2E),
                            child: SingleChildScrollView(
                              child: SelectableText(
                                _generateCode(),
                                style: const TextStyle(
                                  fontFamily: 'Courier',
                                  color: Color(0xFFA6ACCD),
                                  fontSize: 11,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Interactive Device Preview',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
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
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
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
        SizedBox(width: 80, child: Text('$label: ')),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            label: value.toInt().toString(),
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 30, child: Text('${value.toInt()}')),
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
        if (label.isNotEmpty) Text(label, style: const TextStyle(fontSize: 14)),
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
      backgroundColor: color.withValues(alpha: 0.1),
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
                    color: color.withValues(alpha: 0.4),
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
                child: Icon(Icons.circle, size: 8, color: Colors.black),
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

    // TRUNCATE MESSAGE IN CODE VIEW TO PREVENT UI FRAGMENTATION
    if (_message.isNotEmpty) {
      if (_message.length > 80) {
        sb.writeln("  message: '${_message.substring(0, 80)}... (truncated)',");
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

    if (_showIcon) {
      if (isLightBg) {
        sb.writeln('  textColor: Colors.black87,');
        sb.writeln(
          '  icon: Icon(Icons.${_getIconName()}, color: Colors.black87),',
        );
      } else {
        sb.writeln(
          '  icon: Icon(Icons.${_getIconName()}, color: Colors.white),',
        );
      }
    } else {
      sb.writeln('  icon: null,');
    }

    if (_position == HyperSnackPosition.bottom) {
      sb.writeln('  position: HyperSnackPosition.bottom,');
    }
    if (!_useMargin) sb.writeln('  margin: EdgeInsets.zero,');
    if (!_dismissible) sb.writeln('  dismissible: false,');
    if (_durationSeconds != 2.5) {
      sb.writeln(
        '  displayDuration: Duration(milliseconds: ${(_durationSeconds * 1000).toInt()}),',
      );
    }

    // Text Options & Scroll logic
    if (_allowScroll) {
      sb.writeln('  scrollable: true,');
      if (_maxLines != null) {
        sb.writeln('  // Constraining height instead of lines for scrolling:');
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

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

  Color _selectedColor = const Color(0xFF323232);
  bool _useBorder = false;
  Color _borderColor = Colors.white;
  double _borderRadius = 12.0;
  double _elevation = 4.0;

  HyperSnackAnimationType _enterType = HyperSnackAnimationType.scale;
  final HyperSnackAnimationType _exitType = HyperSnackAnimationType.fade;
  bool _useElasticCurve = true;

  double _progressBarValue = 0.0;

  HyperSnackPosition _position = HyperSnackPosition.top;
  bool _useMargin = true;
  final double _durationSeconds = 4.0;
  bool _showAction = false;

  // Key for the inner Scaffold.
  // Using this to get the context ensures that it is displayed securely within the smartphone frame (inside the Navigator).
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
          _progressBarValue = -1; // None
          _showAction = false;
          _useBorder = false;
          _borderRadius = 12.0;
          break;
        case 'Wipe':
          _title = 'Downloading...';
          _message = 'Please wait while we fetch your data.';
          _selectedColor = const Color(0xFF2196F3);
          _enterType = HyperSnackAnimationType.top;
          _progressBarValue = 0.0; // Wipe
          _useElasticCurve = false;
          _showAction = false;
          _useBorder = false;
          break;
        case 'Outlined':
          _title = 'Outlined Style';
          _message = 'Modern look with borders.';
          _selectedColor = const Color(0xFF212121);
          _enterType = HyperSnackAnimationType.scale;
          _progressBarValue = 4.0; // Line
          _useElasticCurve = true;
          _position = HyperSnackPosition.bottom;
          _showAction = true;
          _useBorder = true;
          _borderColor = Colors.cyanAccent;
          _borderRadius = 20.0;
          break;
      }
    });
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

    // ★ Context Fix:
    // Use the context of the Scaffold inside the phone frame.
    final targetContext = _innerScaffoldKey.currentContext;

    if (targetContext != null) {
      HyperSnackbar.show(
        context:
            targetContext, // <--- This will display it inside the phone frame
        title: _title,
        message: _message,
        backgroundColor: _selectedColor,
        textColor: contentColor,
        icon: Icon(
          _getIconForColor(_selectedColor),
          color: contentColor,
        ),

        borderRadius: _borderRadius,
        elevation: _elevation,
        border: _useBorder ? Border.all(color: _borderColor, width: 2) : null,

        position: _position,
        margin: _useMargin ? const EdgeInsets.all(12) : EdgeInsets.zero,

        enterAnimationType: _enterType,
        exitAnimationType: _exitType,
        enterCurve: _useElasticCurve ? Curves.elasticOut : Curves.easeOutQuart,
        enterAnimationDuration: _useElasticCurve
            ? const Duration(milliseconds: 800)
            : const Duration(milliseconds: 400),

        progressBarWidth: width,
        progressBarColor: progressColor,

        displayDuration:
            Duration(milliseconds: (_durationSeconds * 1000).toInt()),

        action: _showAction
            ? HyperSnackAction(
                label: 'UNDO',
                textColor:
                    isLightBg ? Colors.blue.shade700 : Colors.amberAccent,
                onPressed: () {},
              )
            : null,
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
            icon: const Icon(Icons.copy),
            tooltip: 'Copy Code',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _generateCode()));
              HyperSnackbar.showInfo(
                  title: 'Code Copied!', margin: const EdgeInsets.all(8));
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
                              child: SingleChildScrollView(
                                  child: _buildControls())),
                          const Divider(height: 1),
                          _buildShowButtonArea(),
                        ],
                      ),
                    )),
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 6,
                  child: _buildPhonePreview(),
                ),
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
                        SizedBox(
                          height: 600,
                          child: _buildPhonePreview(),
                        ),
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
          _sectionHeader('1. Presets'),
          Wrap(
            spacing: 8,
            children: [
              _presetButton('Success', Colors.green),
              _presetButton('Wipe', Colors.blue),
              _presetButton('Outlined', Colors.black87),
            ],
          ),
          const SizedBox(height: 24),
          _sectionHeader('2. Content'),
          TextField(
            decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                isDense: true),
            controller: TextEditingController(text: _title),
            onChanged: (v) => _title = v,
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
                isDense: true),
            controller: TextEditingController(text: _message),
            onChanged: (v) => _message = v,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Show Action Button'),
            dense: true,
            value: _showAction,
            onChanged: (v) => setState(() => _showAction = v),
          ),
          const SizedBox(height: 24),
          _sectionHeader('3. Colors & Style'),
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
              const Text('Radius: '),
              Expanded(
                child: Slider(
                  value: _borderRadius,
                  min: 0,
                  max: 32,
                  label: _borderRadius.toInt().toString(),
                  onChanged: (v) => setState(() => _borderRadius = v),
                ),
              ),
              Text('${_borderRadius.toInt()}'),
            ],
          ),
          Row(
            children: [
              const Text('Shadow: '),
              Expanded(
                child: Slider(
                  value: _elevation,
                  min: 0,
                  max: 20,
                  label: _elevation.toInt().toString(),
                  onChanged: (v) => setState(() => _elevation = v),
                ),
              ),
              Text('${_elevation.toInt()}'),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Border'),
            dense: true,
            value: _useBorder,
            onChanged: (v) => setState(() => _useBorder = v),
          ),
          if (_useBorder)
            Row(
              children: [
                const Text('Border Color: '),
                const SizedBox(width: 8),
                _borderColorOption(Colors.white),
                _borderColorOption(Colors.cyanAccent),
                _borderColorOption(Colors.redAccent),
                _borderColorOption(Colors.black),
              ],
            ),
          const SizedBox(height: 24),
          _sectionHeader('4. Animation'),
          DropdownButtonFormField<HyperSnackAnimationType>(
            key: ValueKey(_enterType),
            decoration: const InputDecoration(
                labelText: 'Enter Animation',
                isDense: true,
                border: OutlineInputBorder()),
            initialValue: _enterType,
            items: HyperSnackAnimationType.values
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.name.toUpperCase()),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _enterType = v!),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Elastic Curve'),
            dense: true,
            value: _useElasticCurve,
            onChanged: (v) => setState(() => _useElasticCurve = v),
          ),
          const SizedBox(height: 24),
          _sectionHeader('5. Progress Bar'),
          SegmentedButton<double>(
            segments: const [
              ButtonSegment(value: -1, label: Text('None')),
              ButtonSegment(value: 0.0, label: Text('Wipe')),
              ButtonSegment(value: 4.0, label: Text('Line')),
            ],
            selected: {
              _progressBarValue == 0.0
                  ? 0.0
                  : (_progressBarValue > 0 ? 4.0 : -1)
            },
            onSelectionChanged: (Set<double> newSelection) {
              setState(() {
                _progressBarValue = newSelection.first;
              });
            },
          ),
          const SizedBox(height: 24),
          _sectionHeader('6. Layout'),
          Row(
            children: [
              const Text('Pos: '),
              DropdownButton<HyperSnackPosition>(
                  value: _position,
                  items: const [
                    DropdownMenuItem(
                        value: HyperSnackPosition.top, child: Text('TOP')),
                    DropdownMenuItem(
                        value: HyperSnackPosition.bottom,
                        child: Text('BOTTOM')),
                  ],
                  onChanged: (v) => setState(() => _position = v!)),
              const Spacer(),
              const Text('Margin: '),
              Switch(
                  value: _useMargin,
                  onChanged: (v) => setState(() => _useMargin = v)),
            ],
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
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _showSnackbar,
          icon: const Icon(Icons.bolt),
          label: const Text('SHOW SNACKBAR',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                    color: Colors.black.withAlpha(20),
                    blurRadius: 20,
                    offset: const Offset(0, 10)),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            // Returned to Stack layout.
            // This allows MaterialApp to occupy the entire screen, and the Overlay will securely fit within this frame.
            // The code area at the bottom is placed at the very front of the Stack, but the snackbar (Overlay) is displayed on top of it.
            child: Navigator(
              onGenerateRoute: (settings) {
                return MaterialPageRoute(
                  builder: (context) => Scaffold(
                    key: _innerScaffoldKey, // Key for context
                    backgroundColor: Colors.grey[50], // Preview BG
                    appBar: AppBar(
                      title:
                          const Text('My App', style: TextStyle(fontSize: 16)),
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
                              Icon(Icons.touch_app,
                                  size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(
                                'Preview Area',
                                style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        // Code Overlay at bottom of phone
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
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text('Interactive Device Preview',
              style:
                  TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Helpers ...
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87)),
    );
  }

  Widget _presetButton(String label, Color color) {
    return ActionChip(
      label: Text(label),
      backgroundColor: color.withAlpha(10),
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
                      color: color.withAlpha(40),
                      blurRadius: 6,
                      spreadRadius: 2)
                ]
              : null,
        ),
        child: isSelected
            ? Icon(Icons.check,
                color: color.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
                size: 16)
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
                child: Icon(Icons.circle, size: 8, color: Colors.black))
            : null,
      ),
    );
  }

  String _generateCode() {
    final sb = StringBuffer();
    final isLightBg = _selectedColor.computeLuminance() > 0.5;

    sb.writeln('HyperSnackbar.show(');
    sb.writeln("  title: '$_title',");
    if (_message.isNotEmpty) sb.writeln("  message: '$_message',");

    sb.writeln(
        '  backgroundColor: Color(0x${_selectedColor.toARGB32().toRadixString(16).toUpperCase()}),');

    if (_useBorder) {
      sb.writeln(
          '  border: Border.all(color: Color(0x${_borderColor.toARGB32().toRadixString(16).toUpperCase()}), width: 2),');
    }
    if (_borderRadius != 12.0) sb.writeln('  borderRadius: $_borderRadius,');
    if (_elevation != 4.0) sb.writeln('  elevation: $_elevation,');

    if (isLightBg) {
      sb.writeln('  textColor: Colors.black87,');
      sb.writeln(
          '  icon: Icon(Icons.${_getIconName()}, color: Colors.black87),');
    } else {
      sb.writeln('  icon: Icon(Icons.${_getIconName()}, color: Colors.white),');
    }

    if (_position == HyperSnackPosition.bottom) {
      sb.writeln('  position: HyperSnackPosition.bottom,');
    }
    if (!_useMargin) sb.writeln('  margin: EdgeInsets.zero,');

    sb.writeln(
        '  enterAnimationType: HyperSnackAnimationType.${_enterType.name},');
    if (_useElasticCurve) {
      sb.writeln('  enterCurve: Curves.elasticOut,');
      sb.writeln(
          '  enterAnimationDuration: const Duration(milliseconds: 800),');
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

import 'package:flutter/material.dart';
import 'package:hyper_snackbar/hyper_snackbar.dart';

class PresetDemoPage extends StatefulWidget {
  const PresetDemoPage({super.key});

  @override
  State<PresetDemoPage> createState() => _PresetDemoPageState();
}

class _PresetDemoPageState extends State<PresetDemoPage> {
  // ===========================================================================
  // 1. Define Presets
  //    It is convenient to define configurations reused throughout the app as static final.
  // ===========================================================================

  /// Base design (Strong rounded corners, bold title)
  static final _basePreset = HyperSnackbar.preset(
    borderRadius: 24.0,
    titleStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w900,
      color: Colors.white,
    ),
    messageStyle: const TextStyle(color: Colors.white70),
    margin: const EdgeInsets.all(16),
    enterAnimationDuration: const Duration(milliseconds: 400),
    exitAnimationDuration: const Duration(milliseconds: 400),
  );

  /// "Brand Color (Purple)" Preset inheriting from _basePreset
  /// Define only the differences using HyperConfig.copyWith
  late final _brandPreset = _basePreset.copyWith(
    backgroundColor: Colors.deepPurple.shade700,
    icon: const Icon(Icons.star, color: Colors.amber),
    progressBarColor: Colors.amber,
    progressBarWidth: 4.0,
  );

  /// "Dark Mode" Preset inheriting from _basePreset
  late final _darkPreset = _basePreset.copyWith(
    backgroundColor: const Color(0xFF1E1E1E),
    textColor: Colors.white,
    border: Border.all(color: Colors.grey.shade800),
    icon: const Icon(Icons.nightlight_round, color: Colors.blueAccent),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preset & Override Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionHeader(text: "1. Basic Usage (No Preset)"),
              ElevatedButton(
                onPressed: () {
                  HyperSnackbar.show(
                    title: 'Hello World',
                    message: 'This is displayed with default settings.',
                  );
                },
                child: const Text('Default Show'),
              ),
              const SizedBox(height: 20),
              const _SectionHeader(text: "2. Using Presets"),

              // Using Brand Preset
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade50,
                  foregroundColor: Colors.deepPurple,
                ),
                onPressed: () {
                  HyperSnackbar.show(
                    title: 'Brand Style',
                    message:
                        'Using defined _brandPreset.\nRounded corners and icons are applied.',
                    preset: _brandPreset, // <--- Specify preset here
                  );
                },
                child: const Text('Show with Brand Preset'),
              ),

              const SizedBox(height: 10),

              // Using Dark Preset
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black87,
                ),
                onPressed: () {
                  HyperSnackbar.show(
                    title: 'Dark Mode',
                    message:
                        'This is _darkPreset inheriting from base settings.',
                    preset: _darkPreset,
                  );
                },
                child: const Text('Show with Dark Preset'),
              ),

              const SizedBox(height: 20),
              const _SectionHeader(text: "3. Override Priority (Arg > Preset)"),

              // Preset Override Test
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red.shade900,
                ),
                onPressed: () {
                  HyperSnackbar.show(
                    title: 'Override Test',
                    message:
                        'Using Brand Preset, but Red color specified in arguments takes precedence.',
                    preset: _brandPreset, // Base is Brand (Purple)
                    backgroundColor:
                        Colors.red.shade800, // <--- Override with Red
                    icon: const Icon(
                      Icons.priority_high,
                      color: Colors.white,
                    ), // Override Icon
                  );
                },
                child: const Text('Preset + Override (Red)'),
              ),

              const SizedBox(height: 20),
              const _SectionHeader(text: "4. Convenience Methods (Regression)"),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => HyperSnackbar.showSuccess(
                        title: 'Success',
                        message: 'Data saved successfully.',
                      ),
                      child: const Text('Success'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => HyperSnackbar.showError(
                        title: 'Error',
                        message: 'Connection failed.',
                      ),
                      child: const Text('Error'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const _SectionHeader(text: "5. Queue & Position Test"),
              ElevatedButton(
                onPressed: () {
                  // Check queueing and position by rapid firing
                  HyperSnackbar.show(
                    title: 'Bottom Queue 1',
                    preset: _brandPreset.copyWith(
                      position: HyperSnackPosition.bottom,
                    ),
                  );
                  HyperSnackbar.show(
                    title: 'Bottom Queue 2',
                    preset: _darkPreset.copyWith(
                      position: HyperSnackPosition.bottom,
                    ),
                  );
                },
                child: const Text('Queue Test (Bottom)'),
              ),

              const SizedBox(height: 40),
              OutlinedButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text('Clear All'),
                onPressed: () => HyperSnackbar.clearAll(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

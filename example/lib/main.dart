import 'package:flutter/material.dart';
import 'package:hyper_snackbar/hyper_snackbar.dart';

import 'pages/playground_page.dart';
import 'pages/scenario_page.dart';
import 'pages/preset_demo_page.dart'; // Import added

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hyper Snackbar Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // Important: Register the key to show snackbars without BuildContext
      navigatorKey: HyperSnackbar.navigatorKey,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hyper Snackbar Example'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. Minimal Usage (For Pub.dev) ---
            const _SectionHeader('Minimal Usage'),
            const SizedBox(height: 8),

            // The most basic usage
            _ActionButton(
              label: 'Hello World',
              onPressed: () {
                HyperSnackbar.show(
                  title: 'Hello World',
                  message: 'This is the simplest usage.',
                );
              },
            ),
            const SizedBox(height: 12),

            // Introduction of presets
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Success Preset',
                    color: const Color.fromRGBO(76, 175, 80, 1),
                    onPressed: () => HyperSnackbar.showSuccess(
                      title: 'Success!',
                      message: 'Operation completed successfully.',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    label: 'Error Preset',
                    color: Colors.red,
                    onPressed: () => HyperSnackbar.showError(
                      title: 'Error',
                      // message: 'Something went wrong.',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // --- 2. Advanced Demos ---
            const _SectionHeader('Interactive Demos'),
            const SizedBox(height: 12),

            // Playground Button
            _MenuCard(
              title: '🚀 Playground',
              subtitle: 'Customize styling, animations, and generate code.',
              color: Colors.deepPurple,
              icon: Icons.tune,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PlaygroundPage()),
                );
              },
            ),

            const SizedBox(height: 16),

            // Scenarios Button
            _MenuCard(
              title: '🧪 Scenarios',
              subtitle: 'Test stack/queue behaviors and edge cases.',
              color: Colors.blueGrey,
              icon: Icons.playlist_add_check,
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const ScenarioPage()));
              },
            ),

            const SizedBox(height: 16),

            // Preset & Override Demo Button (New)
            _MenuCard(
              title: '🎨 Presets & Overrides',
              subtitle: 'Learn how to use config presets and inheritance.',
              color: Colors.teal,
              icon: Icons.style,
              onTap: () {
                Navigator.of(
                  context,
                ).push(
                    MaterialPageRoute(builder: (_) => const PresetDemoPage()));
              },
            ),

            const SizedBox(height: 16),

            // GetX & Blur Compatibility Demo Button
            _MenuCard(
              title: '⚡ GetX Compatibility & Blurs',
              subtitle: 'Explore GetX aliases and frosted glass blur effects.',
              color: Colors.orange,
              icon: Icons.blur_on,
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(
                    builder: (_) => const GetxLikeDemoPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class GetxLikeDemoPage extends StatelessWidget {
  const GetxLikeDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GetX Compatibility & Blurs'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: Stack(
        children: [
          // A busy background to make blur effects clearly visible
          Positioned.fill(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
              ),
              itemBuilder: (context, index) {
                return Container(
                  color: index % 2 == 0 ? Colors.grey[300] : Colors.grey[200],
                  margin: const EdgeInsets.all(2),
                  child: Center(
                    child: Text(
                      '$index',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 10,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ActionButton(
                    label: '1. Full Compatibility Case',
                    color: Colors.blueAccent,
                    onPressed: () {
                      HyperSnackbar.show(
                        title: "GetX Style Notification",
                        message:
                            "Uses title, message, TOP position, duration, and isDismissible: false",
                        snackPosition: SnackPosition.TOP,
                        duration: const Duration(seconds: 4),
                        isDismissible: false,
                        colorText: Colors.white,
                        backgroundColor: Colors.blueAccent,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _ActionButton(
                    label: '2. Stylish Blur (barBlur)',
                    color: Colors.purple,
                    onPressed: () {
                      HyperSnackbar.show(
                        title: "Frosted Glass Effect",
                        message:
                            "barBlur: 20.0 with highly transparent background.",
                        snackPosition: SnackPosition.TOP,
                        barBlur: 20.0,
                        backgroundColor: Colors.purple.withAlpha(50),
                        colorText: Colors.purple.shade900,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        duration: const Duration(seconds: 4),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _ActionButton(
                    label: '3. Full Screen Blur + Position',
                    color: Colors.redAccent,
                    onPressed: () {
                      HyperSnackbar.show(
                        title: "Focus Mode",
                        message:
                            "overlayBlur covers the background. Positioned BOTTOM.",
                        snackPosition: SnackPosition.BOTTOM,
                        overlayBlur: 10.0,
                        margin: const EdgeInsets.only(
                            bottom: 40, left: 16, right: 16),
                        duration: const Duration(seconds: 4),
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _ActionButton(
                    label: '4. Quick Notification',
                    color: Colors.green,
                    onPressed: () {
                      HyperSnackbar.show(
                        message: "Quick toast-like alert.",
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(milliseconds: 1500),
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        showCloseButton: false,
                        margin: const EdgeInsets.all(16),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _ActionButton(
                    label: '5. Full Action & Icon (GetX)',
                    color: Colors.deepOrange,
                    onPressed: () {
                      HyperSnackbar.show(
                        title: "Action Required",
                        message:
                            "This snackbar uses icon, mainButton, and onTap in a GetX-like rich notification!",
                        snackPosition: SnackPosition.TOP,
                        duration: const Duration(seconds: 6),
                        backgroundColor: Colors.deepOrange,
                        colorText: Colors.white,
                        icon: const Icon(Icons.warning_amber_rounded,
                            color: Colors.white),
                        shouldIconPulse: true,
                        mainButton: TextButton(
                          onPressed: () => HyperSnackbar.clearAll(),
                          child: const Text(
                            'DISMISS',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        margin: const EdgeInsets.all(24),
                        borderRadius: 24,
                        boxShadows: [
                          BoxShadow(
                            color: Colors.deepOrange.withAlpha(150),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                        onTap: () {
                          debugPrint('Snackbar Tapped!');
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Helper Widgets ---

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const _ActionButton({
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color?.withAlpha(30),
        foregroundColor: color ?? Theme.of(context).colorScheme.primary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 6)),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

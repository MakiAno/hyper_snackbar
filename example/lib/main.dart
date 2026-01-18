import 'package:flutter/material.dart';
import 'package:hyper_snackbar/hyper_snackbar.dart';

import 'pages/playground_page.dart';
import 'pages/scenario_page.dart';

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
            // --- 1. Minimal Usage (For Pub.dev: Area to understand usage without looking at the code) ---
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
                    color: Colors.green,
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
                      message: 'Something went wrong.',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // --- 2. Advanced Demos (Guide to Playground & Scenarios) ---
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
          ],
        ),
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
        backgroundColor: color?.withAlpha(30), // Light tint
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

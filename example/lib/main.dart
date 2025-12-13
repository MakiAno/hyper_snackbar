import 'package:flutter/material.dart';
import 'dart:async';

// Import your package
import 'package:hyper_snackbar/hyper_snackbar.dart';

// For development (relative path), use this:
// import 'src/manager.dart';
// import 'src/config.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Hyper Snack List Demo',
    home: HyperDemoPage(),
  ));
}

class HyperDemoPage extends StatefulWidget {
  const HyperDemoPage({super.key});

  @override
  State<HyperDemoPage> createState() => _HyperDemoPageState();
}

class _HyperDemoPageState extends State<HyperDemoPage> {
  int _logCount = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hyper Snack List Demo'),
        backgroundColor: const Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader('1. Basic Presets'),
            _buildButton(
              'Success',
              Colors.green,
              () => HyperManager()
                  .showSuccess(context, title: 'Operation Successful'),
            ),
            _buildButton(
              'Error',
              Colors.red,
              () => HyperManager().showError(
                context,
                title: 'Connection Failed',
                message: 'Please check your internet connection.',
              ),
            ),
            _buildButton(
              'Warning + Tap Action',
              Colors.amber,
              () {
                // Using .show() directly for tap interactions
                HyperManager().show(
                  context,
                  HyperConfig(
                    title: 'Low Storage',
                    message: 'Tap here to manage storage.',
                    backgroundColor: Colors.amber.shade700,
                    icon: const Icon(Icons.warning_amber_rounded,
                        color: Colors.white),
                    // Tap to navigate
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const DetailPage(title: 'Low Storage'),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            _buildButton(
              'Info',
              Colors.blue,
              () => HyperManager().showInfo(
                context,
                title: 'New Message',
                message: 'You have received a new notification.',
              ),
            ),
            _buildHeader('2. Advanced Design'),
            _buildButton(
              'Modern Card Style',
              Colors.indigo,
              () => _showModernStyledSnackBar(),
            ),
            _buildHeader('3. With Actions'),
            _buildButton(
              'Delete with "Undo"',
              Colors.orange,
              () => _showUndoSnackBar(),
            ),
            _buildHeader('4. State Update (Using ID)'),
            _buildButton(
              'Process (Loading -> Done)',
              Colors.blueGrey,
              () => _showProcessSnackBar(),
            ),
            _buildHeader('5. Log Style (Bottom Append)'),
            _buildButton(
              'Add Log (Newest on Bottom)',
              Colors.teal,
              () => _showLogStyleSnackBar(),
            ),
            _buildHeader('6. Control & Persistent'),
            _buildButton(
              'Persistent Notification',
              Colors.deepPurple,
              () => _showPersistentSnackBar(),
            ),
            const SizedBox(height: 8),
            _buildButton(
              'Clear All',
              Colors.grey,
              () => HyperManager().clearAll(animated: true),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // Demo Pattern: Advanced Design
  // ----------------------------------------------------------------
  void _showModernStyledSnackBar() {
    HyperManager().show(
      context,
      HyperConfig(
        title: 'Design Update',
        message: 'Custom border, margin, and fonts applied.',
        backgroundColor: const Color(0xFF212121),

        // Custom Border
        border: Border.all(color: Colors.white.withAlpha(2), width: 1.0),

        // Floating Margin
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        // Inner Padding
        padding: const EdgeInsets.all(20),

        // Custom Font Styles
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
        messageStyle: TextStyle(
          color: Colors.white.withAlpha(7),
          fontStyle: FontStyle.italic,
        ),

        icon: const Icon(Icons.brush, color: Colors.lightBlueAccent),
      ),
    );
  }

  // ----------------------------------------------------------------
  // Demo Pattern: Action Button
  // ----------------------------------------------------------------
  void _showUndoSnackBar() {
    HyperManager().show(
      context,
      HyperConfig(
        title: 'Item deleted',
        icon: const Icon(Icons.delete_outline, color: Colors.white),
        action: HyperSnackAction(
          label: 'UNDO',
          textColor: Colors.yellowAccent,
          onPressed: () {
            HyperManager().showSuccess(context, title: 'Item restored!');
          },
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // Demo Pattern: State Update (ID)
  // ----------------------------------------------------------------
  Future<void> _showProcessSnackBar() async {
    const String processId = 'process_123';

    // 1. Start (Loading)
    if (!mounted) return;
    HyperManager().show(
      context,
      HyperConfig(
        id: processId,
        title: 'Uploading...',
        message: 'Sending data (20%)',
        displayDuration: null, // Keep it visible
        backgroundColor: Colors.blue[800]!,
        icon: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // 2. Update Progress (Using same ID)
    HyperManager().show(
      context,
      HyperConfig(
        id: processId,
        title: 'Processing...',
        message: 'Converting on server (80%)',
        displayDuration: null,
        backgroundColor: Colors.orange[800]!,
        icon: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // 3. Finish (Update & Set duration to auto-dismiss)
    HyperManager().show(
      context,
      HyperConfig(
        id: processId,
        title: 'Completed!',
        message: 'All tasks finished successfully.',
        displayDuration: const Duration(seconds: 3),
        backgroundColor: Colors.green[700]!,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      ),
    );
  }

  // ----------------------------------------------------------------
  // Demo Pattern: Log Style
  // ----------------------------------------------------------------
  void _showLogStyleSnackBar() {
    HyperManager().show(
      context,
      HyperConfig(
        title: 'System Log #$_logCount',
        message: 'Newest item is appended to the bottom.',

        position: HyperSnackPosition.top,
        newestOnTop: false, // Append to bottom
        enterAnimationType: HyperSnackAnimationType.fromTop,

        // Console-like appearance
        backgroundColor: Colors.black87,
        borderRadius: 4.0,
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        icon: const Icon(Icons.terminal, size: 16, color: Colors.greenAccent),
        titleStyle: const TextStyle(
            fontFamily: 'Courier',
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold),

        maxVisibleCount: 5,
      ),
    );
    _logCount++;
  }

  // ----------------------------------------------------------------
  // Demo Pattern: Persistent
  // ----------------------------------------------------------------
  void _showPersistentSnackBar() {
    HyperManager().show(
      context,
      HyperConfig(
        title: 'Maintenance Alert',
        message: 'This notification will not disappear automatically.',
        displayDuration: null, // Persistent
        backgroundColor: const Color(0xFFC62828),
        icon: const Icon(Icons.notifications_active, color: Colors.white),
        position: HyperSnackPosition.bottom,
        margin: const EdgeInsets.all(12),
        borderRadius: 16,
      ),
    );
  }

  // ----------------------------------------------------------------
  // UI Helpers
  // ----------------------------------------------------------------
  Widget _buildButton(String label, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------
// Detail Page (Navigation Target)
// ----------------------------------------------------------------
class DetailPage extends StatelessWidget {
  final String title;
  const DetailPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Page'),
        backgroundColor: const Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              'Detail for:\n$title',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

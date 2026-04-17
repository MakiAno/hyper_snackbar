import 'package:flutter/material.dart';
import 'package:hyper_snackbar/hyper_snackbar.dart';

class ScenarioPage extends StatefulWidget {
  const ScenarioPage({super.key});

  @override
  State<ScenarioPage> createState() => _ScenarioPageState();
}

class _ScenarioPageState extends State<ScenarioPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scenarios')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildScenarioItem(
            '1. File Deleted (Undo)',
            'Bottom position, Line Progress Bar, Action Button.',
            Icons.delete_sweep,
            Colors.brown,
            _showUndoScenario,
          ),
          _buildScenarioItem(
            '2. New Message',
            'Top position, Slide Down, Tap to open.',
            Icons.chat,
            Colors.indigo,
            _showMessageScenario,
          ),
          _buildScenarioItem(
            '3. Persistent Error',
            'Elastic Scale animation, Sticky (no duration), Retry button.',
            Icons.wifi_off,
            Colors.redAccent,
            _showErrorScenario,
          ),
          _buildScenarioItem(
            '4. Uploading Process',
            'Wipe Effect for progress, updates state by ID.',
            Icons.cloud_upload,
            Colors.blue,
            _showUploadScenario,
          ),
          _buildScenarioItem(
            '5. Async Task Progress',
            'Syncs progress bar with real-world async tasks.',
            Icons.downloading,
            Colors.teal,
            _showAsyncProgressScenario,
          ),
        ],
      ),
    );
  }

  // --- Scenarios ---

  void _showUndoScenario() {
    HyperSnackbar.show(
      title: 'Item deleted',
      message: 'The item has been moved to trash.',
      backgroundColor: const Color(0xFF323232),
      icon: const Icon(Icons.delete_outline, color: Colors.white),
      position: HyperSnackPosition.bottom,
      progressBarWidth: 2.0, // Line Effect
      displayDuration: const Duration(seconds: 4),
      action: HyperSnackAction(
        label: 'UNDO',
        textColor: Colors.amberAccent,
        onPressed: () {
          HyperSnackbar.showSuccess(
            title: 'Restored!',
            position: HyperSnackPosition.bottom,
          );
        },
      ),
    );
  }

  void _showMessageScenario() {
    HyperSnackbar.show(
      title: 'Sarah Jenkins',
      message: 'Hey, are we still meeting for lunch?',
      backgroundColor: Colors.indigo.shade600,
      icon: const Icon(Icons.account_circle, color: Colors.white),
      position: HyperSnackPosition.top,
      enterAnimationType: HyperSnackAnimationType.top, // Slide down
      progressBarWidth: -1, // No bar
      onTap: () {
        // Navigate to chat screen
        HyperSnackbar.showInfo(title: 'Navigating to Chat...');
      },
    );
  }

  void _showErrorScenario() {
    HyperSnackbar.show(
      title: 'No Internet Connection',
      message: 'Please check your connection and try again.',
      backgroundColor: Colors.redAccent.shade700,
      icon: const Icon(Icons.signal_wifi_off, color: Colors.white),
      // Elastic pop animation
      enterAnimationType: HyperSnackAnimationType.scale,
      enterCurve: Curves.elasticOut,
      enterAnimationDuration: const Duration(milliseconds: 800),
      // Persistent
      displayDuration: Duration.zero,
      action: HyperSnackAction(
        label: 'RETRY',
        backgroundColor: Colors.white,
        textColor: Colors.redAccent.shade700,
        onPressed: () {
          HyperSnackbar.showSuccess(title: 'Connected!');
        },
      ),
    );
  }

  void _showUploadScenario() async {
    const id = 'upload_process';

    // 1. Start
    HyperSnackbar.show(
      id: id,
      title: 'Uploading...',
      message: 'Please wait while uploading your files.',
      backgroundColor: Colors.blue.shade600,
      icon: const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      ),
      progressBarWidth: 0.0, // Wipe Effect

      displayDuration: const Duration(seconds: 2),
    );

    // Simulate delay
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    HyperSnackbar.show(
      id: id,
      title: 'Upload Complete',
      message: 'All files have been uploaded successfully.',
      backgroundColor: Colors.green.shade600,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      progressBarWidth: -1,
      displayDuration: const Duration(seconds: 3),
    );
  }

  void _showAsyncProgressScenario() async {
    final controller = HyperSnackbar.showProgress(
      title: 'Downloading...',
      message: 'Fetching remote files...',
      progressBarWidth: 4.0,
      progressBarColor: Colors.greenAccent,
      position: HyperSnackPosition.top,
      margin: const EdgeInsets.all(8.0),
    );

    // Simulate an async task taking 5 steps
    for (int i = 1; i <= 5; i++) {
      if (!mounted) {
        controller.dismiss();
        return;
      }

      // Update the progress first
      controller.updateProgress(i * 0.2);

      // Simulate some async work taking 1 second per step
      await Future.delayed(const Duration(seconds: 1));
    }

    // Replace with a success snackbar that auto-dismisses
    // (The controller will automatically wait 350ms to let the animation complete!)
    // Add await since this is now an async method.
    await controller.success(
      title: 'Download Complete',
      message: 'Files downloaded successfully.',
    );
  }

  // --- UI Helper ---

  Widget _buildScenarioItem(
    String title,
    String desc,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
        trailing: const Icon(Icons.play_arrow_rounded),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}

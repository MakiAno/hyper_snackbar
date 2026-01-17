import 'package:flutter/material.dart';
import 'package:hyper_snackbar/hyper_snackbar.dart';

class BasicPage extends StatelessWidget {
  const BasicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Usage')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBtn('Success', Colors.green, () {
                HyperSnackbar.showSuccess(
                  title: 'Operation Successful',
                  message: 'Your changes have been saved.',
                );
              }),
              _buildBtn('Error', Colors.red, () {
                HyperSnackbar.showError(
                  title: 'Connection Failed',
                  message: 'Please check your internet connection.',
                );
              }),
              _buildBtn('Warning', Colors.orange, () {
                HyperSnackbar.showWarning(
                  title: 'Storage Full',
                  message: 'You are running out of storage space.',
                );
              }),
              _buildBtn('Info', Colors.blue, () {
                HyperSnackbar.showInfo(
                  title: 'New Update',
                  message: 'Version 1.2.0 is now available.',
                );
              }),
              const Divider(height: 40),
              _buildBtn('Custom (Dark Mode)', Colors.black87, () {
                HyperSnackbar.show(
                  title: 'Dark Mode',
                  message: 'Custom colors and icon.',
                  backgroundColor: const Color(0xFF333333),
                  icon:
                      const Icon(Icons.nightlight_round, color: Colors.yellow),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBtn(String label, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}

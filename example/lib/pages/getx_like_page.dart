import 'package:flutter/material.dart';
import 'package:hyper_snackbar/hyper_snackbar.dart';

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
                      style: TextStyle(color: Colors.grey[500], fontSize: 10),
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
                          bottom: 40,
                          left: 16,
                          right: 16,
                        ),
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
                        icon: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                        ),
                        shouldIconPulse: true,
                        mainButton: TextButton(
                          onPressed: () => HyperSnackbar.clearAll(),
                          child: const Text(
                            'DISMISS',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        margin: const EdgeInsets.all(24),
                        borderRadius: 24,
                        boxShadows: [
                          BoxShadow(
                            color: Colors.deepOrange.withAlpha(150),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
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

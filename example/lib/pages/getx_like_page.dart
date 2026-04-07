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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('--- Demos A ---',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 16),
                  _ActionButton(
                    label: '1. Full Compatibility Case',
                    color: Colors.blueAccent,
                    onPressed: () {
                      HyperSnackbar.show(
                        title: "GetX Style Notification",
                        message:
                            "Uses title, message, TOP position, duration, and isDismissible: false",
                        snackPosition: HyperSnackPosition.top,
                        duration: const Duration(seconds: 4),
                        isDismissible: false,
                        colorText: Colors.white,
                        backgroundColor: Colors.blueAccent,
                        showProgressIndicator: true,
                        progressBarWidth: 2.0,
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
                        snackPosition: HyperSnackPosition.top,
                        barBlur: 20.0,
                        backgroundColor: Colors.purple.withAlpha(50),
                        colorText: Colors.purple.shade900,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        duration: const Duration(seconds: 4),
                        showProgressIndicator: true,
                        progressBarWidth: 2.0,
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
                        snackPosition: HyperSnackPosition.bottom,
                        overlayBlur: 10.0,
                        margin: const EdgeInsets.only(
                            bottom: 40, left: 16, right: 16),
                        duration: const Duration(seconds: 4),
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                        showProgressIndicator: true,
                        progressBarWidth: 2.0,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _ActionButton(
                    label: '4. Quick Notification (Slim)',
                    color: Colors.green,
                    onPressed: () {
                      HyperSnackbar.show(
                        message: "Quick toast-like alert.",
                        snackPosition: HyperSnackPosition.bottom,
                        duration: const Duration(milliseconds: 1500),
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        showCloseButton: false,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        showProgressIndicator: true,
                        progressBarWidth: 2.0,
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
                        snackPosition: HyperSnackPosition.top,
                        duration: const Duration(seconds: 6),
                        backgroundColor: Colors.deepOrange,
                        colorText: Colors.white,
                        icon: const Icon(Icons.warning_amber_rounded,
                            color: Colors.white),
                        shouldIconPulse: true,
                        showProgressIndicator: true,
                        progressBarWidth: 2.0,
                        mainButton: TextButton(
                          onPressed: () => HyperSnackbar.clearAll(),
                          child: const Text('DISMISS',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
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
                  const SizedBox(height: 32),
                  const Text('--- New Features Demos ---',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 16),
                  _ActionButton(
                    label: '6. Gradient & Left Bar Indicator',
                    color: Colors.purpleAccent,
                    onPressed: () {
                      HyperSnackbar.show(
                        title: "Neon Cyberpunk",
                        message:
                            "Multiple vivid colors combined in a linear gradient for a striking look.",
                        backgroundGradient: const LinearGradient(
                          colors: [
                            Colors.purple,
                            Colors.pinkAccent,
                            Colors.orangeAccent,
                            Colors.yellowAccent,
                          ],
                          stops: [0.0, 0.4, 0.7, 1.0],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        leftBarIndicatorColor: Colors.blueAccent,
                        borderColor: Colors.white.withAlpha(100),
                        borderWidth: 2.0,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                        duration: const Duration(seconds: 4),
                        showProgressIndicator: true,
                        progressBarWidth: 2.0,
                        progressIndicatorValueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _ActionButton(
                    label: '7. Grounded Style (Slim)',
                    color: Colors.teal,
                    onPressed: () {
                      HyperSnackbar.show(
                        // Keep only the message and tighten padding to make it a thin bar at the screen edge
                        message:
                            "System connected. Grounded style with slim padding.",
                        snackPosition: HyperSnackPosition.bottom,
                        snackStyle: HyperSnackStyle.grounded,
                        backgroundColor: Colors.teal.shade800,
                        colorText: Colors.white,
                        borderRadius: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        duration: const Duration(seconds: 3),
                        showProgressIndicator: true,
                        progressBarWidth: 2.0,
                        snackbarStatus: (status) {
                          debugPrint('🟢 Snackbar Status: $status');
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _ActionButton(
                    label: '8. User Input Form',
                    color: Colors.blueGrey,
                    onPressed: () {
                      // 1. Prepare a controller to retrieve input values
                      final TextEditingController replyController =
                          TextEditingController();

                      HyperSnackbar.show(
                        title: "Quick Reply",
                        message:
                            "Enter your response directly in the snackbar.",
                        backgroundColor: Colors.blueGrey.shade800,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 10),
                        margin: const EdgeInsets.all(16),
                        showProgressIndicator: true,
                        progressBarWidth: 2.0,
                        userInputForm: Form(
                          child: TextFormField(
                            controller:
                                replyController, // 2. Set the controller
                            style: const TextStyle(color: Colors.black87),
                            autofocus: true, // Show the keyboard immediately
                            textInputAction: TextInputAction
                                .send, // Set the keyboard action button to "Send"
                            decoration: InputDecoration(
                              hintText: 'Type your reply...',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.send,
                                    color: Colors.blueGrey),
                                onPressed: () {
                                  // Action when the send button is pressed
                                  final text = replyController.text;
                                  HyperSnackbar.clearAll(
                                      animated:
                                          false); // Dismiss the current snackbar
                                  HyperSnackbar.showSuccess(
                                      title: 'Sent!', message: text);
                                },
                              ),
                            ),
                            onFieldSubmitted: (text) {
                              // Action when the "Send" (Done) button on the keyboard is pressed
                              HyperSnackbar.clearAll(animated: false);
                              HyperSnackbar.showSuccess(
                                  title: 'Sent!', message: text);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _ActionButton(
                    label: '9. Overlay Color & Progress Bar',
                    color: Colors.pink,
                    onPressed: () {
                      HyperSnackbar.show(
                        title: "Task in Progress",
                        message:
                            "Notice the dark overlay dimming the background and the custom colored progress indicator below.",
                        overlayColor: Colors.black.withAlpha(150),
                        showProgressIndicator: true,
                        progressBarWidth: 6.0,
                        progressIndicatorBackgroundColor: Colors.white24,
                        progressIndicatorValueColor:
                            const AlwaysStoppedAnimation<Color>(
                                Colors.pinkAccent),
                        backgroundColor: Colors.pink.shade900,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                        duration: const Duration(seconds: 4),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _ActionButton(
                    label: '10. Horizontal Swipe (Slim)',
                    color: Colors.brown,
                    onPressed: () {
                      HyperSnackbar.show(
                        message:
                            "Swipe LEFT or RIGHT to dismiss this thin notification.",
                        snackPosition: HyperSnackPosition.top,
                        dismissDirection: DismissDirection.horizontal,
                        backgroundColor: Colors.brown,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        duration: const Duration(seconds: 5),
                        showProgressIndicator: true,
                        progressBarWidth: 2.0,
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

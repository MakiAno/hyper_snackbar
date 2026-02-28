import 'package:flutter/material.dart';
import 'package:hyper_snackbar/hyper_snackbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HyperSnackbar GetX Like Demo',
      navigatorKey: HyperSnackbar.navigatorKey, // Crucial for overlay support
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GetxLikeDemoPage(),
    );
  }
}

class GetxLikeDemoPage extends StatelessWidget {
  const GetxLikeDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GetX Like Snackbar Demo'),
      ),
      body: Stack(
        children: [
          // A busy background to make blur effects visible
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Demonstration of GetX style aliases
                    HyperSnackbar.show(
                      title: "GetX Style Snackbar",
                      message: "It works just like Get.snackbar!",
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 3),
                      colorText: Colors.white,
                      backgroundColor: Colors.blueAccent,
                    );
                  },
                  child: const Text('Show GetX Style Snackbar'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Demonstration of barBlur
                    HyperSnackbar.show(
                      title: "Bar Blur Effect",
                      message: "The background of this snackbar is blurred.",
                      snackPosition: SnackPosition.TOP,
                      barBlur: 20.0, // Amount of blur
                      backgroundColor: Colors.black.withAlpha(100), // Must be transparent to see blur
                      duration: const Duration(seconds: 4),
                    );
                  },
                  child: const Text('Show barBlur Example'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Demonstration of overlayBlur
                    HyperSnackbar.show(
                      title: "Overlay Blur Effect",
                      message: "The entire screen behind is blurred.",
                      snackPosition: SnackPosition.TOP,
                      overlayBlur: 5.0, // Blurs the whole background
                      duration: const Duration(seconds: 4),
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                    );
                  },
                  child: const Text('Show overlayBlur Example'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

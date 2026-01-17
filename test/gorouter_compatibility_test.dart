// test/gorouter_compatibility_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_snackbar/hyper_snackbar.dart';

void main() {
  testWidgets('GoRouter transition does not crash HyperSnackbar',
      (WidgetTester tester) async {
    // 1. Launch the app (using the router defined in this file)
    await tester.pumpWidget(_createTestApp());

    // Wait for the initial display to complete
    await tester.pumpAndSettle();

    // 2. Tap the button
    // This should ensure the button is found.
    await tester.tap(find.text('Show Snackbar'));

    // 3. Wait for snackbar display processing
    // Since inserting into the Overlay requires frame progression, pump thoroughly.
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300)); // アニメーション

    // 4. Verification
    expect(find.text('Hello GoRouter'), findsOneWidget);
  });
}

// --- GoRouter app definition for testing ---
Widget _createTestApp() {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                // Display snackbar here
                HyperSnackbar.show(
                  context: context,
                  title: 'Hello GoRouter',
                  message: 'This is a test.',
                );
              },
              child: const Text('Show Snackbar'), // ★ Looking for this text
            ),
          ),
        ),
      ),
    ],
  );

  return MaterialApp.router(
    routerConfig: router,
  );
}

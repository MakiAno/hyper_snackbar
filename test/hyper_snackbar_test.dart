import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyper_snackbar/hyper_snackbar.dart';

void main() {
  group('HyperSnackbar', () {
    // A helper function to create a MaterialApp with a scaffold for tests.
    Widget createTestApp(Widget child) {
      return MaterialApp(
        navigatorKey: HyperSnackbar.navigatorKey,
        home: Scaffold(body: child),
      );
    }

    testWidgets('isSnackbarOpen reflects the visibility of a snackbar',
        (WidgetTester tester) async {
      // Build an app where the snackbar can be displayed.
      await tester.pumpWidget(createTestApp(Container()));

      // Initially, no snackbar should be open.
      expect(HyperSnackbar().isSnackbarOpen, isFalse);

      // Show a snackbar.
      HyperSnackbar().show(const HyperConfig(title: 'Test'));

      // Pump the tree to process the frame where the snackbar is shown.
      await tester.pump(); // Start animation
      await tester.pump(const Duration(seconds: 1)); // Animation finished

      // Now a snackbar should be open.
      expect(HyperSnackbar().isSnackbarOpen, isTrue);

      // Find the snackbar to ensure it's on screen.
      expect(find.text('Test'), findsOneWidget);

      // Clear all snackbars.
      HyperSnackbar().clearAll();

      // Pump the tree to process the dismiss animation.
      await tester.pump(); // Start animation
      await tester.pump(const Duration(seconds: 1)); // Animation finished

      // Now no snackbar should be open.
      expect(HyperSnackbar().isSnackbarOpen, isFalse);

      // Ensure the snackbar is gone.
      expect(find.text('Test'), findsNothing);
    });
  });
}
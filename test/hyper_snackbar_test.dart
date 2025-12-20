import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyper_snackbar/hyper_snackbar.dart';

void main() {
  group('HyperSnackbar', () {
    // Ensure that all snackbars are cleared after each test to maintain a clean state.
    tearDown(() {
      HyperSnackbar.clearAll();
    });

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
      expect(HyperSnackbar.isSnackbarOpen, isFalse);

      // Show a snackbar.
      HyperSnackbar.show(title: 'Test', displayDuration: null);

      // Let the snackbar animation finish.
      await tester.pumpAndSettle();

      // Now a snackbar should be open.
      expect(HyperSnackbar.isSnackbarOpen, isTrue);

      // Find the snackbar to ensure it's on screen.
      expect(find.text('Test'), findsOneWidget);

      // Clear all snackbars.
      HyperSnackbar.clearAll();

      // Let the dismiss animation finish.
      await tester.pumpAndSettle();

      // Now no snackbar should be open.
      expect(HyperSnackbar.isSnackbarOpen, isFalse);

      // Ensure the snackbar is gone.
      expect(find.text('Test'), findsNothing);
    });

    testWidgets('Queue mode displays snackbars sequentially',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(Container()));

      // Show two snackbars in queue mode.
      HyperSnackbar.show(
        title: 'Snackbar 1',
        displayMode: HyperSnackDisplayMode.queue,
        displayDuration: const Duration(seconds: 1),
      );
      HyperSnackbar.show(
        title: 'Snackbar 2',
        displayMode: HyperSnackDisplayMode.queue,
        displayDuration: const Duration(seconds: 1),
      );

      // At first, only the first snackbar should be visible.
      await tester.pump(); // Start enter animation
      await tester.pump(const Duration(milliseconds: 500)); // Finish enter animation
      expect(find.text('Snackbar 1'), findsOneWidget);
      expect(find.text('Snackbar 2'), findsNothing);

      // Wait for the first snackbar to disappear.
      await tester.pump(const Duration(seconds: 1)); // displayDuration
      await tester.pump(); // Start exit animation
      await tester.pump(const Duration(milliseconds: 500)); // Finish exit animation
      await tester.pump(); // Frame for microtask to run

      // Now the second snackbar should appear.
      await tester.pump(); // Start enter animation for second snackbar
      await tester.pump(const Duration(milliseconds: 500)); // Finish enter animation
      expect(find.text('Snackbar 1'), findsNothing);
      expect(find.text('Snackbar 2'), findsOneWidget);
    });

    testWidgets('clearAll clears the queue', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(Container()));

      // Queue up multiple snackbars.
      HyperSnackbar.show(
        title: 'Snackbar 1',
        displayMode: HyperSnackDisplayMode.queue,
        displayDuration: const Duration(seconds: 1),
      );
      HyperSnackbar.show(
        title: 'Snackbar 2',
        displayMode: HyperSnackDisplayMode.queue,
        displayDuration: const Duration(seconds: 1),
      );

      // The first snackbar is visible.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Snackbar 1'), findsOneWidget);

      // Clear all.
      HyperSnackbar.clearAll();

      // Pump through dismiss animation.
      await tester.pump(); // Start dismiss animation
      await tester.pump(const Duration(seconds: 1)); // Finish dismiss animation
      await tester.pump(); // Final frame

      // No snackbar should be visible.
      expect(find.text('Snackbar 1'), findsNothing);
      expect(find.text('Snackbar 2'), findsNothing);
    });
  });
}
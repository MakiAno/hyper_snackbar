import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyper_snackbar/hyper_snackbar.dart';

void main() {
  group('HyperSnackbar', () {
    setUp(() {
      HyperSnackbar.resetForTest();
    });

    tearDown(() {
      HyperSnackbar.clearAll();
    });

    Widget createTestApp(Widget child) {
      return MaterialApp(
        navigatorKey: HyperSnackbar.navigatorKey,
        home: Scaffold(body: child),
      );
    }

    testWidgets('isSnackbarOpen reflects the visibility of a snackbar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(Container()));
      expect(HyperSnackbar.isSnackbarOpen, isFalse);

      HyperSnackbar.show(title: 'Test', id: 'test_id', displayDuration: null);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(HyperSnackbar.isSnackbarOpen, isTrue);
      expect(find.text('Test'), findsOneWidget);

      HyperSnackbar.clearAll();
      await tester.pumpAndSettle();

      expect(HyperSnackbar.isSnackbarOpen, isFalse);
      expect(find.text('Test'), findsNothing);
    });

    testWidgets('Queue mode displays snackbars sequentially',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(Container()));

      const display = Duration(milliseconds: 500);
      const anim = Duration(milliseconds: 50);

      HyperSnackbar.show(
        title: 'Snackbar 1',
        displayMode: HyperSnackDisplayMode.queue,
        displayDuration: display,
        enterAnimationDuration: anim,
        exitAnimationDuration: anim,
      );
      await tester.pump();

      HyperSnackbar.show(
        title: 'Snackbar 2',
        displayMode: HyperSnackDisplayMode.queue,
        displayDuration: display,
        enterAnimationDuration: anim,
        exitAnimationDuration: anim,
      );
      await tester.pump();

      // Snackbar 1 appears
      await tester.pump(anim + const Duration(milliseconds: 10));
      expect(find.text('Snackbar 1'), findsOneWidget);

      // Wait for Snackbar 1 to dismiss
      await tester.pump(display + anim + const Duration(milliseconds: 50));
      await tester.pump(); // Gap for queue processing

      // Snackbar 2 appears
      await tester.pump(anim + const Duration(milliseconds: 10));
      expect(find.text('Snackbar 1'), findsNothing);
      expect(find.text('Snackbar 2'), findsOneWidget);
    });

    testWidgets('clearAll clears the queue and screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(Container()));

      for (var i = 1; i <= 3; i++) {
        HyperSnackbar.show(
          title: 'Snackbar $i',
          displayMode: HyperSnackDisplayMode.queue,
          displayDuration: const Duration(milliseconds: 500),
        );
        await tester.pump();
      }

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Snackbar 1'), findsOneWidget);

      HyperSnackbar.clearAll();
      await tester.pumpAndSettle();

      expect(find.text('Snackbar 1'), findsNothing);
      expect(find.text('Snackbar 2'), findsNothing);
      expect(find.text('Snackbar 3'), findsNothing);
      expect(HyperSnackbar.isSnackbarOpen, isFalse);
    });

    testWidgets('Queue mode handles multiple items correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(Container()));

      const display = Duration(milliseconds: 500);
      const anim = Duration(milliseconds: 50);

      HyperSnackbar.show(
        title: 'A',
        displayMode: HyperSnackDisplayMode.queue,
        displayDuration: display,
        enterAnimationDuration: anim,
        exitAnimationDuration: anim,
      );
      await tester.pump();
      await tester.pump(anim + const Duration(milliseconds: 10));
      expect(find.text('A'), findsOneWidget);

      HyperSnackbar.show(
        title: 'B',
        displayMode: HyperSnackDisplayMode.queue,
        displayDuration: display,
        enterAnimationDuration: anim,
        exitAnimationDuration: anim,
      );
      await tester.pump();
      await tester.pump(anim + const Duration(milliseconds: 10));

      expect(find.text('B'), findsNothing);

      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      expect(find.text('A'), findsNothing);
      expect(find.text('B'), findsOneWidget);

      HyperSnackbar.clearAll();
      await tester.pumpAndSettle();

      expect(find.text('B'), findsNothing);
      expect(HyperSnackbar.isSnackbarOpen, isFalse);
    });
  });
}

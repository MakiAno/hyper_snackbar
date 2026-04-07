import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyper_snackbar/hyper_snackbar.dart';

Widget createTestApp(Widget home) {
  return MaterialApp(
    navigatorKey: HyperSnackbar.navigatorKey,
    home: Scaffold(body: home),
  );
}

void main() {
  group('Coverage Booster - Filling the Red Lines', () {
    setUp(() {
      HyperSnackbar.resetForTest();
    });

    // 1. Coverage for convenience methods (showSuccess, showError, etc.)
    testWidgets('Convenience methods coverage', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(Container()));

      HyperSnackbar.showSuccess(title: 'Success');
      await tester.pump();
      expect(find.text('Success'), findsOneWidget);

      HyperSnackbar.showError(title: 'Error');
      await tester.pump();
      expect(find.text('Error'), findsOneWidget);

      HyperSnackbar.showWarning(title: 'Warning');
      await tester.pump();
      expect(find.text('Warning'), findsOneWidget);

      HyperSnackbar.showInfo(title: 'Info');
      await tester.pump();
      expect(find.text('Info'), findsOneWidget);

      await tester.pumpAndSettle();
    });

    // 2. Coverage for all animation types
    testWidgets('All animation types coverage', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(Container()));

      for (var type in HyperSnackAnimationType.values) {
        HyperSnackbar.show(
          title: 'Anim ${type.name}',
          enterAnimationType: type,
          exitAnimationType: type,
          displayDuration: const Duration(milliseconds: 500),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Passes through each animation branch here
        expect(find.text('Anim ${type.name}'), findsOneWidget);

        await tester.pumpAndSettle();
      }
    });

    // 3. Update by ID (_tryUpdate) and Dismiss by ID (dismissById)
    testWidgets('Update and Dismiss by ID coverage',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(Container()));

      const String testId = 'unique_id';

      // Initial display
      HyperSnackbar.show(title: 'Original', id: testId);
      await tester.pump();

      // Update with the same ID (passes through _tryUpdate)
      HyperSnackbar.show(title: 'Updated Title', id: testId);
      await tester.pump();
      expect(find.text('Updated Title'), findsOneWidget);
      expect(find.text('Original'), findsNothing);

      // Dismiss by ID (passes through dismissById / isSnackbarOpenById)
      expect(HyperSnackbar.isSnackbarOpenById(testId), isTrue);
      HyperSnackbar.dismissById(testId);
      await tester.pumpAndSettle();
      expect(HyperSnackbar.isSnackbarOpenById(testId), isFalse);
    });

    // 4. Coverage for using Widgets for title/message
    testWidgets('Widget title and message coverage',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(Container()));

      HyperSnackbar.show(
        titleText: const Text('Widget Title'),
        messageText: const Text('Widget Message'),
      );
      await tester.pump();

      expect(find.text('Widget Title'), findsOneWidget);
      expect(find.text('Widget Message'), findsOneWidget);

      await tester.pumpAndSettle();
    });

    // 5. Timer pause and resume by scrolling
    testWidgets('Scroll pause and resume timer coverage',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        ListView.builder(
          itemCount: 100,
          itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
        ),
      ));

      HyperSnackbar.show(
        title: 'Scroll Test',
        displayDuration: const Duration(seconds: 2),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Scroll start (_handleScrollStart)
      await tester.drag(find.text('Item 0'), const Offset(0, -300),
          warnIfMissed: false);
      await tester.pump();

      // Scroll end (_handleScrollEnd)
      // Wait for the 1-second delay timer
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpAndSettle();
    });

    // 6. Non-animated (immediate removal) path for clearAll
    testWidgets('clearAll immediate coverage', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(Container()));
      HyperSnackbar.show(title: 'Immediate');
      await tester.pump();

      HyperSnackbar.clearAll(animated: false);
      await tester.pump();

      expect(find.text('Immediate'), findsNothing);
    });
  });
}

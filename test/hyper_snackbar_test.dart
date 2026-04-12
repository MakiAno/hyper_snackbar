import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyper_snackbar/hyper_snackbar.dart';

void main() {
  // Include all tests within this group
  group('HyperSnackbar', () {
    // Reset before each test starts
    setUp(() {
      HyperSnackbar.resetForTest();
    });

    // Always clean up after each test ends
    tearDown(() {
      HyperSnackbar.clearAll();
    });

    Widget createTestApp(Widget child) {
      return MaterialApp(
        navigatorKey: HyperSnackbar.navigatorKey,
        home: Scaffold(body: child),
      );
    }

    testWidgets('isSnackbarOpen reflects the visibility of a snackbar', (
      WidgetTester tester,
    ) async {
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

    testWidgets('Queue mode displays snackbars sequentially', (
      WidgetTester tester,
    ) async {
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

      await tester.pump(anim + const Duration(milliseconds: 10));
      expect(find.text('Snackbar 1'), findsOneWidget);

      await tester.pump(display + anim + const Duration(milliseconds: 50));
      await tester.pump();

      await tester.pump(anim + const Duration(milliseconds: 10));
      expect(find.text('Snackbar 1'), findsNothing);
      expect(find.text('Snackbar 2'), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('clearAll clears the queue and screen', (
      WidgetTester tester,
    ) async {
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

    testWidgets('Queue mode handles multiple items correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp(Container()));

      const display = Duration(milliseconds: 500);
      const anim = Duration(milliseconds: 50);

      // 1. Show A
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

      // 2. Show B (Queued)
      HyperSnackbar.show(
        title: 'B',
        displayMode: HyperSnackDisplayMode.queue,
        displayDuration: display,
        enterAnimationDuration: anim,
        exitAnimationDuration: anim,
      );
      await tester.pump();
      await tester.pump(anim + const Duration(milliseconds: 10));

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsNothing);

      await tester.pump(display);

      await tester.pump(anim);

      await tester.pump();

      await tester.pump(anim);

      expect(find.text('A'), findsNothing);
      expect(find.text('B'), findsOneWidget);

      HyperSnackbar.clearAll();
      await tester.pumpAndSettle();

      expect(find.text('B'), findsNothing);
      expect(HyperSnackbar.isSnackbarOpen, isFalse);
    });

    // --- New tests added below ---

    testWidgets('Test whether swiping can dismiss the SnackBar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  HyperSnackbar.show(
                    title: 'Swipe to dismiss', // Title
                    enableSwipe: true,
                    context: context,
                  );
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Look for 'Swipe to dismiss' instead of 'Test'
      expect(find.text('Swipe to dismiss'), findsOneWidget);

      // Swipe target should also use the correct title
      await tester.drag(find.text('Swipe to dismiss'), const Offset(500, 0));

      // Wait for the animation to complete after swiping
      await tester.pumpAndSettle();

      expect(find.text('Swipe to dismiss'), findsNothing);
    });

    testWidgets('maxVisibleCount limit test: UI overlap fixed version', (
      WidgetTester tester,
    ) async {
      // Thanks to setUp, resetForTest() runs automatically here.

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                int count = 0;
                // [Fix] Wrap the button in Center to place it in the middle of the screen.
                // This prevents overlap with the snackbar appearing from the top.
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      count++;
                      HyperSnackbar.show(
                        context: context,
                        title: 'No.$count',
                        message: 'Message',
                        maxVisibleCount: 2,
                        displayDuration: const Duration(seconds: 20),
                        enterAnimationDuration: const Duration(
                          milliseconds: 500,
                        ),
                      );
                    },
                    child: const Text('PUSH ME'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // 1st
      await tester.tap(find.text('PUSH ME'));
      await tester.pump(const Duration(milliseconds: 600));

      // 2nd
      // The button is no longer hidden, so it should be clickable!
      await tester.tap(find.text('PUSH ME'));
      await tester.pump(const Duration(milliseconds: 600));

      // 3rd
      await tester.tap(find.text('PUSH ME'));
      await tester.pump(const Duration(milliseconds: 1000));

      // Verification
      expect(find.text('No.1'), findsNothing, reason: 'No.1 should be gone.');
      expect(find.text('No.2'), findsOneWidget, reason: 'No.2 should remain.');
      expect(find.text('No.3'), findsOneWidget, reason: 'No.3 should remain.');

      // Finally, wait for everything to disappear to avoid affecting the next test.
      await tester.pumpAndSettle();
    });

    // -------------------------------------------------------------------------
    // Situation 1: Template creation (Can it be instantiated without a title?)
    // -------------------------------------------------------------------------
    test(
      'Should instantiate HyperConfig without a title (Template Pattern)',
      () {
        // Previously caused an error because it was required
        const errorTemplate = HyperConfig(
          backgroundColor: Colors.red,
          borderRadius: 8.0,
          icon: Icon(Icons.error),
        );

        expect(errorTemplate.title, isNull);
        expect(errorTemplate.backgroundColor, Colors.red);
      },
    );

    // ------------------------------------------------------ -------------------
    // Situation 2: Injecting and displaying the title using a template
    // -------------------------------------------------------------------------
    testWidgets('Should display injected title when using template', (
      WidgetTester tester,
    ) async {
      // App setup
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: HyperSnackbar.navigatorKey,
          home: const Scaffold(body: Center(child: Text('Home'))),
        ),
      );

      // 1. Define the template
      const successTemplate = HyperConfig(
        backgroundColor: Colors.green,
        icon: Icon(Icons.check),
      );

      // 2. Inject and display title
      HyperSnackbar.showFromConfig(
        successTemplate.copyWith(
          title: 'Upload Complete',
          message: 'File has been saved.',
        ),
      );

      // Animation progress
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 3. Verification
      expect(
        find.text('Upload Complete'),
        findsOneWidget,
      ); // Title is displayed
      expect(
        find.text('File has been saved.'),
        findsOneWidget,
      ); // Message is also OK
      expect(find.byIcon(Icons.check), findsOneWidget); // Template icon is OK

      await tester.pumpAndSettle();
    });

    // ---------------------------------------------------------- ---------------
    // Scenario 3: Safety Check when title is completely null
    // ---------------------------------------------------------- ---------------
    testWidgets('Should not crash when title is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: HyperSnackbar.navigatorKey,
          home: const Scaffold(body: SizedBox()),
        ),
      );

      // 1. No title configuration
      const noTitleConfig = HyperConfig(message: 'Message Only Notification');

      // 2. Display as-is (to verify Text(config.title ?? '') in widget.dart works)
      HyperSnackbar.showFromConfig(noTitleConfig);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 3. Verification (success if message displays without crashing)
      expect(find.text('Message Only Notification'), findsOneWidget);

      // The title should be empty, but visual verification is sufficient as long as no errors occur

      await tester.pumpAndSettle();
    });

    testWidgets(
      'displayDuration controls how long the snackbar stays visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(Container()));

        HyperSnackbar.show(
          title: 'Duration Test',
          displayDuration: const Duration(seconds: 2),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100)); // animation in

        expect(find.text('Duration Test'), findsOneWidget);

        await tester.pump(const Duration(seconds: 1)); // wait 1s

        expect(find.text('Duration Test'), findsOneWidget); // still there

        await tester.pump(const Duration(seconds: 1)); // wait another 1s
        await tester.pump(
          const Duration(milliseconds: 600),
        ); // wait for exit animation

        expect(find.text('Duration Test'), findsNothing); // should be gone
      },
    );

    testWidgets('Colors are applied correctly to background and text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp(Container()));

      const bgColor = Colors.purple;
      const txtColor = Colors.yellow;

      HyperSnackbar.show(
        title: 'Color Test',
        message: 'Message test',
        backgroundColor: bgColor,
        textColor: txtColor,
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // In the implementation, color is now handled by Container decoration
      final containerFinder = find
          .ancestor(
            of: find.byType(Material).last,
            matching: find.byType(Container),
          )
          .first;
      final containerWidget = tester.widget<Container>(containerFinder);
      expect((containerWidget.decoration as BoxDecoration).color, bgColor);

      final titleTextFinder = find.text('Color Test');
      final titleWidget = tester.widget<Text>(titleTextFinder);
      expect(titleWidget.style?.color, txtColor);

      final messageTextFinder = find.text('Message test');
      final messageWidget = tester.widget<Text>(messageTextFinder);
      expect(messageWidget.style?.color, txtColor.withAlpha(230));

      await tester.pumpAndSettle();
    });

    testWidgets('Action button triggers callback and auto-dismisses', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp(Container()));

      bool actionTriggered = false;

      HyperSnackbar.show(
        title: 'Action Test',
        action: HyperSnackAction(
          label: 'UNDO',
          onPressed: () {
            actionTriggered = true;
          },
          autoDismiss: true,
        ),
        displayDuration: const Duration(seconds: 10), // keep it open
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final buttonFinder = find.text('UNDO');
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pump();

      expect(actionTriggered, isTrue);

      await tester.pump(
        const Duration(milliseconds: 600),
      ); // wait for exit animation
      expect(find.text('Action Test'), findsNothing); // it should be dismissed
    });

    testWidgets('Action button triggers callback without auto-dismissing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp(Container()));

      bool actionTriggered = false;

      HyperSnackbar.show(
        title: 'Action Test 2',
        action: HyperSnackAction(
          label: 'RETRY',
          onPressed: () {
            actionTriggered = true;
          },
          autoDismiss: false,
        ),
        displayDuration: const Duration(seconds: 10), // keep it open
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final buttonFinder = find.text('RETRY');
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pump();

      expect(actionTriggered, isTrue);

      await tester.pump(
        const Duration(milliseconds: 600),
      ); // wait for exit animation
      expect(
        find.text('Action Test 2'),
        findsOneWidget,
      ); // it should NOT be dismissed

      await tester.pumpAndSettle();
    });

    testWidgets('Very long text in non-scrollable mode applies ellipsis', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp(Container()));

      final longText = 'A' * 1000;

      HyperSnackbar.show(
        title: 'Long Text Test',
        message: longText,
        maxLines: 2,
        scrollable: false,
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final textFinder = find.textContaining('A' * 10);
      expect(textFinder, findsOneWidget);
      final textWidget = tester.widget<Text>(textFinder.last);

      expect(textWidget.maxLines, 2);
      expect(textWidget.overflow, TextOverflow.ellipsis);

      await tester.pumpAndSettle();
    });

    testWidgets('Very long text in scrollable mode allows scrolling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp(Container()));

      final longText = 'A\n' * 100;

      HyperSnackbar.show(
        title: 'Scrollable Text Test',
        message: longText,
        scrollable: true,
        messageMaxHeight: 100,
        displayDuration: null,
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final scrollableFinder = find.byType(SingleChildScrollView);
      expect(scrollableFinder, findsOneWidget);

      final textFinder = find.textContaining('A');
      expect(textFinder, findsOneWidget);
      final textWidget = tester.widget<Text>(textFinder.last);

      expect(textWidget.maxLines, isNull);
      expect(textWidget.overflow, TextOverflow.visible);

      // Try scrolling
      await tester.drag(scrollableFinder, const Offset(0, -500));
      await tester.pump();

      await tester.pumpAndSettle();
    });

    testWidgets('Progress bar renders correctly based on progressBarWidth', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp(Container()));

      // 1. Line Effect
      HyperSnackbar.show(title: 'Line Progress', progressBarWidth: 4.0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      HyperSnackbar.clearAll();
      await tester.pumpAndSettle();

      // 2. Wipe Effect
      HyperSnackbar.show(title: 'Wipe Progress', progressBarWidth: 0.0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Wipe effect uses a FractionallySizedBox in AnimatedBuilder
      expect(find.byType(FractionallySizedBox), findsOneWidget);

      HyperSnackbar.clearAll();
      await tester.pumpAndSettle();
    });

    testWidgets(
      'useAdaptiveLoader shows platform-specific loader instead of icon',
      (WidgetTester tester) async {
        // Test for non-Cupertino platform (Android by default in test)
        await tester.pumpWidget(createTestApp(Container()));

        HyperSnackbar.show(
          title: 'Loader Test',
          icon: const Icon(Icons.star), // should be ignored
          useAdaptiveLoader: true,
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byIcon(Icons.star), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();
      },
    );

    testWidgets('Convenience methods and animations coverage', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp(Container()));

      // 1. Test various convenience methods
      HyperSnackbar.showSuccess(title: 'Success');
      HyperSnackbar.showError(title: 'Error');
      HyperSnackbar.showWarning(title: 'Warning');
      HyperSnackbar.showInfo(title: 'Info');

      // 2. Test updating and dismissing by ID
      HyperSnackbar.show(title: 'Initial', id: 'update_test');
      await tester.pump();
      HyperSnackbar.show(
        title: 'Updated',
        id: 'update_test',
      ); // Passes through _tryUpdate
      await tester.pump();
      HyperSnackbar.dismissById('update_test'); // Passes through dismissById

      // 3. Cover all animation types
      for (var type in HyperSnackAnimationType.values) {
        HyperSnackbar.show(
          title: 'Anim Test',
          enterAnimationType: type,
          exitAnimationType: type,
        );
        await tester.pump();
        HyperSnackbar.clearAll();
        await tester.pumpAndSettle();
      }
    });
  }); // End of group
}

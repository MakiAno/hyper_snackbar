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

      await tester.pump(anim + const Duration(milliseconds: 10));
      expect(find.text('Snackbar 1'), findsOneWidget);

      await tester.pump(display + anim + const Duration(milliseconds: 50));
      await tester.pump();

      await tester.pump(anim + const Duration(milliseconds: 10));
      expect(find.text('Snackbar 1'), findsNothing);
      expect(find.text('Snackbar 2'), findsOneWidget);

      await tester.pumpAndSettle();
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

    // ▼ New tests added below

    testWidgets('Test whether swiping can dismiss the SnackBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
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
      ));

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

    testWidgets('maxVisibleCount limit test: UI overlap fixed version',
        (WidgetTester tester) async {
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
                        enterAnimationDuration:
                            const Duration(milliseconds: 500),
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
    test('Should instantiate HyperConfig without a title (Template Pattern)',
        () {
      // Previously caused an error because it was required
      const errorTemplate = HyperConfig(
        backgroundColor: Colors.red,
        borderRadius: 8.0,
        icon: Icon(Icons.error),
      );

      expect(errorTemplate.title, isNull);
      expect(errorTemplate.backgroundColor, Colors.red);
    });

    // ------------------------------------------------------ -------------------
    // Situation 2: Injecting and displaying the title using a template
    // -------------------------------------------------------------------------
    testWidgets('Should display injected title when using template',
        (WidgetTester tester) async {
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
      await tester.pumpAndSettle();

      // 3. Verification
      expect(
          find.text('Upload Complete'), findsOneWidget); // Title is displayed
      expect(find.text('File has been saved.'),
          findsOneWidget); // Message is also OK
      expect(find.byIcon(Icons.check), findsOneWidget); // Template icon is OK

      await tester.pumpAndSettle();
    });

    // ---------------------------------------------------------- ---------------
    // Scenario 3: Safety Check when title is completely null
    // ---------------------------------------------------------- ---------------
    testWidgets('Should not crash when title is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: HyperSnackbar.navigatorKey,
          home: const Scaffold(body: SizedBox()),
        ),
      );

      // 1. No title configuration
      const noTitleConfig = HyperConfig(
        message: 'Message Only Notification',
      );

      // 2. Display as-is (to verify Text(config.title ?? '') in widget.dart works)
      HyperSnackbar.showFromConfig(noTitleConfig);

      await tester.pump();
      await tester.pumpAndSettle();

      // 3. Verification (success if message displays without crashing)
      expect(find.text('Message Only Notification'), findsOneWidget);

      // The title should be empty, but visual verification is sufficient as long as no errors occur

      await tester.pumpAndSettle();
    });
  }); // End of group
}

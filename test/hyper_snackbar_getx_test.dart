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
  group('GetX Compatibility and Advanced Features', () {
    setUp(() {
      HyperSnackbar.resetForTest();
    });

    tearDown(() {
      HyperSnackbar.clearAll(animated: false);
    });

    // 1. Test for dynamic swipe direction (DismissDirection)
    testWidgets('Dynamic dismissDirection defaults based on SnackPosition',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(Container()));

      HyperSnackbar.show(
        title: 'Top',
        position: HyperSnackPosition.top,
        enableSwipe: true,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      var dismissible =
          tester.widget<Dismissible>(find.byType(Dismissible).last);
      expect(dismissible.direction, DismissDirection.up);
      HyperSnackbar.clearAll(animated: false);
      await tester.pumpAndSettle();

      HyperSnackbar.show(
        title: 'Bottom',
        position: HyperSnackPosition.bottom,
        enableSwipe: true,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      dismissible = tester.widget<Dismissible>(find.byType(Dismissible).last);
      expect(dismissible.direction, DismissDirection.down);
      HyperSnackbar.clearAll(animated: false);
      await tester.pumpAndSettle();

      HyperSnackbar.show(
        title: 'Override',
        dismissDirection: DismissDirection.horizontal,
        enableSwipe: true,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      dismissible = tester.widget<Dismissible>(find.byType(Dismissible).last);
      expect(dismissible.direction, DismissDirection.horizontal);
    });

    // 2. Test for lifecycle callbacks (snackbarStatus)
    testWidgets('snackbarStatus callbacks fire in correct order',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(Container()));

      final List<HyperSnackbarStatus> statuses = [];

      HyperSnackbar.show(
        title: 'Status Test',
        displayDuration: const Duration(
            seconds: 1), // Set to 1 second to stabilize the timer
        snackbarStatus: (status) {
          if (statuses.isEmpty || statuses.last != status) {
            statuses.add(status);
          }
        },
      );

      // Start opening (opening)
      await tester.pump();
      expect(statuses.last, HyperSnackbarStatus.opening);

      // Finished opening (open) - after entry animation completion
      await tester.pump(const Duration(milliseconds: 350));
      expect(statuses.last, HyperSnackbarStatus.open);

      // Wait for display time to pass, start closing (closing)
      await tester.pump(const Duration(milliseconds: 700));
      expect(statuses.last, HyperSnackbarStatus.closing);

      // Finished closing (closed) - after exit animation completion
      await tester.pump(const Duration(milliseconds: 550));
      expect(statuses.last, HyperSnackbarStatus.closed);

      expect(statuses, [
        HyperSnackbarStatus.opening,
        HyperSnackbarStatus.open,
        HyperSnackbarStatus.closing,
        HyperSnackbarStatus.closed,
      ]);
    });

    // 3. Test for Grounded style (pinned to the screen edge)
    testWidgets('Grounded style removes border radius',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(Container()));

      HyperSnackbar.show(
        title: 'Grounded',
        snackStyle: HyperSnackStyle.grounded,
        borderRadius: 15.0,
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final containerFinder = find.byWidgetPredicate((widget) {
        return widget is Container && widget.decoration is BoxDecoration;
      });

      final container = tester.widget<Container>(containerFinder.first);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.borderRadius, BorderRadius.zero);
    });

    // 4. Rendering test for new UI extension elements (gradient, left bar, form)
    testWidgets(
        'UI elements: LeftBar, Gradient, UserInputForm render correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(Container()));

      const gradient = LinearGradient(colors: [Colors.red, Colors.blue]);
      final formKey = GlobalKey<FormState>();

      HyperSnackbar.show(
        title: 'Rich UI',
        leftBarIndicatorColor: Colors.amber,
        backgroundGradient: gradient,
        userInputForm: Form(key: formKey, child: const TextField()),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final leftBarFinder = find.byWidgetPredicate((widget) {
        return widget is Container && widget.color == Colors.amber;
      });
      expect(leftBarFinder, findsWidgets);

      expect(find.byKey(formKey), findsOneWidget);

      final materialContentFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final dec = widget.decoration as BoxDecoration;
          return dec.gradient == gradient;
        }
        return false;
      });
      expect(materialContentFinder, findsOneWidget);
    });

    // 5. Robust test for Progress Bar and BackdropFilter
    testWidgets('Progress Bar and BackdropFilter render correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(Container()));

      HyperSnackbar.show(
        title: 'Progress Test',
        barBlur:
            5.0, // Avoid unstable overlayBlur in test environments and use immediately rendered barBlur
        progressBarWidth: 2.0, // Cause the progress bar to be rendered
        displayDuration: const Duration(seconds: 2),
      );

      // Mounting and animation progress
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Ensure BackdropFilter created by barBlur is present
      expect(find.byType(BackdropFilter), findsWidgets);

      // Check if progress bar (LinearProgressIndicator) exists
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}

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
  setUp(() {
    HyperSnackbar.resetForTest();
  });


  testWidgets('shouldIconPulse wraps icon with Transform.scale', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(Container()));

    HyperSnackbar.show(
      title: 'Pulse Test',
      icon: const Icon(Icons.star, key: Key('pulse_icon')),
      shouldIconPulse: true,
      displayDuration: const Duration(seconds: 1),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150)); // halfway through entry to catch animation running

    final iconFinder = find.byKey(const Key('pulse_icon'));
    expect(iconFinder, findsOneWidget);

    // Check if the icon has a Transform ancestor (which indicates pulsing)
    final transformFinder = find.ancestor(of: iconFinder, matching: find.byType(Transform));
    expect(transformFinder, findsWidgets);

    await tester.pumpAndSettle(const Duration(seconds: 2)); // wait for exit animation
  });

  testWidgets('boxShadows property applies custom shadow correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(Container()));

    const customShadow = [
      BoxShadow(
        color: Colors.red,
        blurRadius: 10,
        offset: Offset(0, 5),
      )
    ];

    HyperSnackbar.show(
      title: 'Shadow Test',
      boxShadows: customShadow,
      displayDuration: const Duration(seconds: 1),
    );

    await tester.pump();
    await tester.pumpAndSettle(const Duration(milliseconds: 300)); // wait for animation

    // In the implementation, color is now handled by Container decoration
    final containerFinder = find.byType(Container).last; // find the outer container of material
    expect(containerFinder, findsWidgets);

    final containerWidget = tester.widget<Container>(containerFinder);

    if (containerWidget.decoration is BoxDecoration) {
      final decoration = containerWidget.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, 1);
      expect(decoration.boxShadow!.first.color, Colors.red);
      expect(decoration.boxShadow!.first.blurRadius, 10);
    }

    await tester.pump(const Duration(seconds: 1)); // wait for display
    await tester.pumpAndSettle(const Duration(milliseconds: 500)); // exit animation
  });

  testWidgets('titleText and messageText GetX aliases render correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(Container()));

    HyperSnackbar.show(
      title: 'Dummy', // Needs a fallback title to pass assert
      titleText: const Text('Custom Title Alias', key: Key('custom_title')),
      messageText: const Text('Custom Message Alias', key: Key('custom_message')),
      displayDuration: const Duration(seconds: 1),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const Key('custom_title')), findsOneWidget);
    expect(find.byKey(const Key('custom_message')), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets('Context extension passes GetX aliases correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              context.showHyperSnackbar(
                title: 'Dummy Ext',
                titleText: const Text('Ext Title', key: Key('ext_title')),
                mainButton: const Text('Ext Button', key: Key('ext_button')),
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 1),
              );
            },
            child: const Text('Show'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Show'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const Key('ext_title')), findsOneWidget);
    expect(find.byKey(const Key('ext_button')), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 500));
  });
}

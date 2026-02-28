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

  testWidgets('barBlur creates a BackdropFilter', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(Container()));

    HyperSnackbar.show(
      title: 'Blur Test',
      message: 'Testing bar blur',
      barBlur: 5.0,
      displayDuration: const Duration(seconds: 1),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300)); // enter animation

    expect(find.text('Blur Test'), findsOneWidget);

    final backdropFilterFinder = find.byType(BackdropFilter);
    expect(backdropFilterFinder, findsWidgets);

    await tester.pump(const Duration(seconds: 1)); // wait for display
    await tester.pump(const Duration(milliseconds: 500)); // exit animation
  });

  testWidgets('GetX aliases map correctly', (WidgetTester tester) async {
    final config = HyperSnackbar.preset(
      mainButton: const Text('MainButton'),
      isDismissible: false,
      forwardAnimationCurve: Curves.bounceIn,
      reverseAnimationCurve: Curves.bounceOut,
      duration: const Duration(seconds: 10),
      snackPosition: HyperSnackPosition.bottom,
      colorText: Colors.red,
    );

    expect(config.content, isA<Text>());
    expect(config.enableSwipe, isFalse);
    expect(config.enterCurve, Curves.bounceIn);
    expect(config.exitCurve, Curves.bounceOut);
    expect(config.displayDuration, const Duration(seconds: 10));
    expect(config.position, HyperSnackPosition.bottom);
    expect(config.textColor, Colors.red);
  });
}

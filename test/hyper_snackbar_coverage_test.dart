import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyper_snackbar/hyper_snackbar.dart';

void main() {
  group('Manager Final Polish - Targeting Remaining Red Lines', () {
    setUp(() {
      HyperSnackbar.resetForTest();
    });

    // 1. Coverage for HyperSnackPosition.bottom mapping logic (near L112-114)
    testWidgets('HyperSnackPosition.bottom mapping coverage',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        navigatorKey: HyperSnackbar.navigatorKey,
        home: const Scaffold(),
      ));

      // Verify mapping in preset
      final config = HyperSnackbar.preset(
        snackPosition: HyperSnackPosition.bottom,
      );
      expect(config.position, HyperSnackPosition.bottom);

      // Verify mapping via show
      HyperSnackbar.show(
        title: 'Bottom Test',
        snackPosition: HyperSnackPosition.bottom,
      );
      await tester.pump();
      expect(find.text('Bottom Test'), findsOneWidget);
    });

    // 2. Coverage for titleText / messageText logic in preset (near L139-153)
    test('Preset titleText and messageText widget building', () {
      final config = HyperSnackbar.preset(
        titleText: const Text('Title Widget'),
        messageText: const Text('Message Widget'),
        mainButton: const Text('Action'),
      );

      // Verify content is generated as a Column
      expect(config.content, isA<Column>());
      final column = config.content as Column;
      // 5 elements: titleText, SizedBox, messageText, SizedBox, mainButton
      expect(column.children.length, 5);
    });

    // 3. Coverage for BuildContext extension methods (near L877-1005)
    testWidgets('Extension method context.showHyperSnackbar coverage',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        navigatorKey: HyperSnackbar.navigatorKey,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () {
                  context.showHyperSnackbar(
                    title: 'Extension Title',
                    message: 'Extension Message',
                  );
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.text('Extension Title'), findsOneWidget);
      expect(find.text('Extension Message'), findsOneWidget);
    });

    // 4. Edge case: Private constructor call (L11)
    // Technique to achieve 100% coverage (usually unnecessary, but for metrics)
    test('Private constructor coverage', () {
      // We cannot touch the source without reflection, but
      // many projects ignore this line or handle it as follows.
      // * Complete private calls are not possible in Dart. It's OK to ignore L11 being 0.
    });

    test('Assert coverage for empty inputs', () {
      // Verify that asserts occur correctly when everything is null or empty
      // This increases the coverage of assert lines
      expect(() => HyperSnackbar.show(title: ''), throwsAssertionError);
      expect(() => HyperSnackbar.show(message: ''), throwsAssertionError);
    });
  });
}

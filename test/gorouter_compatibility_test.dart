// test/gorouter_compatibility_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_snackbar/hyper_snackbar.dart';

void main() {
  testWidgets('GoRouter transition does not crash HyperSnackbar',
      (WidgetTester tester) async {
    // 1. テスト用のGoRouter設定
    final router = GoRouter(
      navigatorKey: HyperSnackbar.navigatorKey, // ここがテストの肝
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                context.go('/second');
                // 画面遷移直後にスナックバーを表示（ビルド中の呼び出しをシミュレート）
                HyperSnackbar.show(title: 'Test', message: 'Message');
              },
              child: const Text('Go'),
            ),
          ),
        ),
        GoRoute(
          path: '/second',
          builder: (context, state) =>
              const Scaffold(body: Text('Second Page')),
        ),
      ],
    );

    // 2. Sart App
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
    ));

    // 3. Tap the button and transition
    await tester.tap(find.text('Go'));

    // 4. Rebuid screen
    await tester.pumpAndSettle();

    // 5. No error and Transition complete
    expect(find.text('Second Page'), findsOneWidget);

    // Check snackbars
    expect(find.text('Test'), findsOneWidget);
    expect(find.text('Message'), findsOneWidget);
  });
}

// test/gorouter_compatibility_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_snackbar/hyper_snackbar.dart';

void main() {
  testWidgets('GoRouter transition does not crash HyperSnackbar',
      (WidgetTester tester) async {
    // 1. アプリを起動 (このファイル内で定義したルーターを使用)
    await tester.pumpWidget(_createTestApp());

    // 初期表示の完了を待つ
    await tester.pumpAndSettle();

    // 2. ボタンをタップ
    // これで確実にボタンが見つかるはずです
    await tester.tap(find.text('Show Snackbar'));

    // 3. スナックバーの表示処理を待機
    // Overlayへの挿入にはフレーム経過が必要なため、念入りにpumpします
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300)); // アニメーション

    // 4. 検証
    expect(find.text('Hello GoRouter'), findsOneWidget);
  });
}

// --- テスト用のGoRouterアプリ定義 ---
Widget _createTestApp() {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                // ここでスナックバーを表示
                HyperSnackbar.show(
                  context: context,
                  title: 'Hello GoRouter',
                  message: 'This is a test.',
                );
              },
              child: const Text('Show Snackbar'), // ★この文字を探しています
            ),
          ),
        ),
      ),
    ],
  );

  return MaterialApp.router(
    routerConfig: router,
  );
}

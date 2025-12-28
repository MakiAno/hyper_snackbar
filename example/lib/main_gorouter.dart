import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_snackbar/hyper_snackbar.dart';

void main() {
  runApp(const MyApp());
}

// 1. GoRouterの設定
final GoRouter _router = GoRouter(
  // ★重要: HyperSnackbarのnavigatorKeyをGoRouterに渡す
  navigatorKey: HyperSnackbar.navigatorKey,
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/second',
      builder: (BuildContext context, GoRouterState state) {
        HyperSnackbar.show(
          title: 'Navigation Check',
          message: 'Called during screen transition build',
          backgroundColor: Colors.green,
        );

        return const SecondScreen();
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'HyperSnackbar GoRouter Test',
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Press the button to test the operation.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // ★テストポイント1:
                // 画面遷移命令の直後に、Contextなしでスナックバーを表示
                context.go('/second');

                // contextを渡さずに呼び出し
                HyperSnackbar.show(
                  title: 'Success',
                  message: 'Displayed successfully without context!',
                );
              },
              child: const Text('Go to Second Page'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Screen'),
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Transition complete'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_snackbar/hyper_snackbar.dart';

void main() {
  runApp(const MyApp());
}

// 1. GoRouter Configuration
final GoRouter _router = GoRouter(
  // ★ Important: Pass HyperSnackbar's navigatorKey to GoRouter
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
                // ★Test Point 1:
                // Display snackbar immediately after screen transition command, without Context
                context.go('/second');

                // Call without passing context
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

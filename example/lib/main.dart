import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hyper_snackbar/hyper_snackbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ★ Contextなしで表示するためにNavigatorKeyを登録
      navigatorKey: HyperSnackbar.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Hyper Snack Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HyperDemoPage(),
    );
  }
}

class HyperDemoPage extends StatefulWidget {
  const HyperDemoPage({super.key});

  @override
  State<HyperDemoPage> createState() => _HyperDemoPageState();
}

class _HyperDemoPageState extends State<HyperDemoPage> {
  int _logCount = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hyper Snack List Demo'),
        backgroundColor: const Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // -------------------------------------------------------
            // 1. Basic Presets
            // -------------------------------------------------------
            _buildHeader('1. Basic Presets'),
            _buildButton(
              'Success',
              Colors.green,
              () => HyperSnackbar().showSuccess(title: 'Operation Successful'),
            ),
            _buildButton(
              'Error',
              Colors.red,
              () => HyperSnackbar().showError(
                title: 'Connection Failed',
                message: 'Please check your internet connection.',
              ),
            ),
            _buildButton(
              'Warning + Tap Action',
              Colors.amber,
              () {
                // contextを渡すことで、タップ時の画面遷移などがスムーズに行えます
                HyperSnackbar().show(
                  HyperConfig(
                    title: 'Low Storage',
                    message: 'Tap here to manage storage.',
                    backgroundColor: Colors.amber.shade700,
                    icon: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const DetailPage(title: 'Storage Settings'),
                        ),
                      );
                    },
                  ),
                  context: context,
                );
              },
            ),
            _buildButton(
              'Info',
              Colors.blue,
              () => HyperSnackbar().showInfo(
                title: 'New Message',
                message: 'You have received a new notification.',
              ),
            ),

            // -------------------------------------------------------
            // 2. Advanced Design
            // -------------------------------------------------------
            _buildHeader('2. Advanced Design'),
            _buildButton(
              'Modern Card Style',
              Colors.indigo,
              () => _showModernStyledSnackBar(),
            ),

            // -------------------------------------------------------
            // 3. With Actions
            // -------------------------------------------------------
            _buildHeader('3. With Actions'),
            _buildButton(
              'Delete with "Undo"',
              Colors.deepOrange,
              () => _showUndoSnackBar(),
            ),

            // -------------------------------------------------------
            // 4. State Update (Using ID)
            // -------------------------------------------------------
            _buildHeader('4. State Update (Using ID)'),
            _buildButton(
              'Process (Loading -> Done)',
              Colors.blueGrey,
              () => _showProcessSnackBar(),
            ),

            // -------------------------------------------------------
            // 5. Log Style (Bottom Append)
            // -------------------------------------------------------
            _buildHeader('5. Log Style (Console)'),
            _buildButton(
              'Add Log (Max Visible: 5)',
              Colors.teal,
              () => _showLogStyleSnackBar(),
            ),

            // -------------------------------------------------------
            // 6. Control & Management
            // -------------------------------------------------------
            _buildHeader('6. Control & Management'),

            // 新機能: 固定IDで表示 (Persistent)
            _buildButton(
              'Show Static ID ("static_1")',
              Colors.purple,
              () => HyperSnackbar().show(
                HyperConfig(
                  id: 'static_1',
                  title: 'Persistent Notification',
                  message: 'This will stay until you dismiss it by ID.',
                  displayDuration: null, // 自動で消えない
                  backgroundColor: Colors.purple.shade700,
                  icon: const Icon(Icons.fingerprint, color: Colors.white),
                  showCloseButton: false, // ユーザーに閉じさせない
                ),
              ),
            ),

            // 新機能: 指定IDのみ閉じる
            _buildButton(
              'Dismiss by ID ("static_1")',
              Colors.purple.shade300,
              () => HyperSnackbar().dismissById('static_1'),
            ),

            const SizedBox(height: 16),

            // 新機能: 全て閉じる
            _buildButton(
              'Clear All',
              Colors.grey,
              () => HyperSnackbar().clearAll(),
            ),

            const SizedBox(height: 16),

            // -------------------------------------------------------
            // 7. Animation Playground
            // -------------------------------------------------------
            _buildHeader('7. Animation Playground'),

            // 1. Slide Horizontal (左から出て、右へ消える)
            _buildButton(
              'Left In -> Right Out',
              Colors.brown,
              () => HyperSnackbar().show(
                HyperConfig(
                  title: 'Horizontal Slide',
                  message: 'Enter: fromLeft, Exit: toRight',
                  backgroundColor: Colors.brown.shade700,
                  icon: const Icon(Icons.swap_horiz, color: Colors.white),

                  // ★ アニメーション設定
                  enterAnimationType: HyperSnackAnimationType.fromLeft,
                  exitAnimationType: HyperSnackAnimationType.toRight,
                ),
              ),
            ),

            // 2. Scale / Elastic (ポヨンと出てくる)
            _buildButton(
              'Scale (Elastic) -> Fade',
              Colors.pink,
              () => HyperSnackbar().show(
                HyperConfig(
                  title: 'Pop Notification',
                  message: 'Enter: Scale (Elastic), Exit: Fade',
                  backgroundColor: Colors.pink.shade600,
                  icon: const Icon(Icons.star, color: Colors.white),

                  // ★ アニメーション設定
                  enterAnimationType: HyperSnackAnimationType.scale,
                  exitAnimationType: HyperSnackAnimationType.fade,
                  enterCurve: Curves.elasticOut, // 弾むような動き
                  enterAnimationDuration: const Duration(milliseconds: 800),
                ),
              ),
            ),

            // 3. From Bottom (下から出てくる)
            _buildButton(
              'From Bottom -> Slide Left',
              Colors.blueGrey,
              () => HyperSnackbar().show(
                HyperConfig(
                  title: 'Bottom Sheet Style',
                  message: 'Position: Bottom, Enter: fromBottom',
                  backgroundColor: Colors.blueGrey.shade800,
                  icon: const Icon(Icons.vertical_align_bottom,
                      color: Colors.white),

                  // ★ 位置とアニメーション設定
                  position: HyperSnackPosition.bottom, // 下に表示
                  enterAnimationType: HyperSnackAnimationType.fromBottom,
                  exitAnimationType: HyperSnackAnimationType.toLeft,
                ),
              ),
            ),

            // 4. Fade Only (ふわっと出る)
            _buildButton(
              'Fade In -> Fade Out',
              Colors.black54,
              () => HyperSnackbar().show(
                HyperConfig(
                  title: 'Subtle Message',
                  message: 'Enter: Fade, Exit: Fade',
                  backgroundColor: Colors.black,
                  icon: const Icon(Icons.blur_on, color: Colors.white),

                  // ★ アニメーション設定
                  enterAnimationType: HyperSnackAnimationType.fade,
                  exitAnimationType: HyperSnackAnimationType.fade,
                  enterAnimationDuration: Duration(milliseconds: 600),
                  enterCurve: Curves.easeIn,
                  exitCurve: Curves.easeIn,
                ),
              ),
            ),

            const SizedBox(height: 60), // 最下部の余白

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // Demo Pattern: Advanced Design
  // ----------------------------------------------------------------
  void _showModernStyledSnackBar() {
    HyperSnackbar().show(
      HyperConfig(
        title: 'Design Update',
        message: 'Custom border, margin, and fonts applied.',
        backgroundColor: const Color(0xFF212121),

        // Custom Border
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.0),

        // Floating Margin
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        // Inner Padding
        padding: const EdgeInsets.all(20),

        // Custom Font Styles
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
        messageStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
          fontStyle: FontStyle.italic,
        ),

        icon: const Icon(Icons.brush, color: Colors.lightBlueAccent),
      ),
      context: context,
    );
  }

  // ----------------------------------------------------------------
  // Demo Pattern: Action Button
  // ----------------------------------------------------------------
  void _showUndoSnackBar() {
    context.showHyperSnackbar(
      HyperConfig(
        title: 'Item deleted',
        icon: const Icon(Icons.delete_outline, color: Colors.white),
        action: HyperSnackAction(
          label: 'UNDO',
          textColor: Colors.yellowAccent,
          onPressed: () {
            HyperSnackbar().showSuccess(title: 'Item restored!');
          },
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // Demo Pattern: State Update (ID)
  // ----------------------------------------------------------------
  Future<void> _showProcessSnackBar() async {
    const String processId = 'process_123';

    // 1. Start (Loading)
    if (!mounted) return;
    HyperSnackbar().show(
      HyperConfig(
        id: processId,
        title: 'Uploading...',
        message: 'Sending data (20%)',
        displayDuration: null, // Sticky
        backgroundColor: Colors.blue[800]!,
        icon: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      ),
      context: context,
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // 2. Update Progress (Using same ID)
    HyperSnackbar().show(
      HyperConfig(
        id: processId,
        title: 'Processing...',
        message: 'Converting on server (80%)',
        displayDuration: null,
        backgroundColor: Colors.orange[800]!,
        icon: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      ),
      context: context,
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // 3. Finish (Update & Auto-dismiss)
    HyperSnackbar().show(
      HyperConfig(
        id: processId,
        title: 'Completed!',
        message: 'All tasks finished successfully.',
        displayDuration: const Duration(seconds: 3), // 3秒後に消える
        backgroundColor: Colors.green[700]!,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      ),
      context: context,
    );
  }

  // ----------------------------------------------------------------
  // Demo Pattern: Log Style
  // ----------------------------------------------------------------
  void _showLogStyleSnackBar() {
    HyperSnackbar().show(
      HyperConfig(
        title: 'System Log #$_logCount',
        message: 'Newest item is appended to the bottom.',

        position: HyperSnackPosition.top,
        newestOnTop: false, // 下に追加していく
        enterAnimationType: HyperSnackAnimationType.fromTop,

        // コンソール風のデザイン
        backgroundColor: Colors.black87,
        borderRadius: 4.0,
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        icon: const Icon(Icons.terminal, size: 16, color: Colors.greenAccent),
        titleStyle: const TextStyle(
          fontFamily: 'Courier',
          color: Colors.greenAccent,
          fontWeight: FontWeight.bold,
        ),

        // ★ 最大表示数を5に制限（6個目が出ると1個目が消える）
        maxVisibleCount: 5,
      ),
      context: context,
    );
    _logCount++;
  }

  // ----------------------------------------------------------------
  // UI Helpers
  // ----------------------------------------------------------------
  Widget _buildButton(String label, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 5,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------
// Detail Page (Navigation Target)
// ----------------------------------------------------------------
class DetailPage extends StatelessWidget {
  final String title;
  const DetailPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Page'),
        backgroundColor: const Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              'Detail for:\n$title',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

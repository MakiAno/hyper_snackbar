[![pub package](https://img.shields.io/pub/v/hyper_snackbar.svg)](https://pub.dev/packages/hyper_snackbar)
[![likes](https://img.shields.io/pub/likes/hyper_snackbar)](https://pub.dev/packages/hyper_snackbar/score)
[![GitHub issues](https://img.shields.io/github/issues/MakiAno/hyper_snackbar?style=flat-square)](https://github.com/MakiAno/hyper_snackbar/issues)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

# HyperSnackbar 🚀

A highly customizable, animated, and powerful snackbar package for Flutter.
Designed to be "Hyper" flexible — supports Stack/Queue modes, custom animations (Scale, Slide, Fade), progress bars, and highly interactive actions.

Now with **Presets** and **GetX-style** aliases for easier migration!

[![Live Demo](https://img.shields.io/badge/demo-online-green.svg?style=flat-square&logo=flutter)](https://makiano.github.io/hyper_snackbar/)
<br>
<h2 align="center">
  <a href="https://makiano.github.io/hyper_snackbar/">👉 Try the Interactive Playground!</a>
</h2>

<p align="center">
  <img src="https://raw.githubusercontent.com/MakiAno/hyper_snackbar/main/screenshots/demo1.gif" width="32%" />
  <img src="https://raw.githubusercontent.com/MakiAno/hyper_snackbar/main/screenshots/demo2.gif" width="32%" />
  <img src="https://raw.githubusercontent.com/MakiAno/hyper_snackbar/main/screenshots/demo3.gif" width="32%" />
</p>

## ✨ Features

* **Flexible Positioning**: Top or Bottom.
* **Display Modes**: Stack (overlay) or Queue (sequential).
* **Rich Animations**: Slide, Fade, and Scale (Elastic Zoom).
* **Presets System**: Define reusable styles and inherit/override them easily.
* **Progress Bar**: Line or Wipe effects.
* **Interactive**: Tap callbacks, Action buttons, and Dismissible swipes.
* **GetX Migration Aids**: Supports parameters like `duration`, `snackPosition`, and `colorText`.
* **No Context Required**: Uses `NavigatorKey` for easy calling from anywhere.
* **Highly Optimized**: Zero-overhead list operations and lazy evaluations ensure smooth 60/120fps animations without unnecessary memory allocations.

## 🚀 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  hyper_snackbar: ^0.11.0
```

## 🛠 Setup

Register the `navigatorKey` in your `MaterialApp` to show snackbars without a `BuildContext`.

```dart
import 'package:hyper_snackbar/hyper_snackbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Important: Register the key here to show snackbars without BuildContext
      navigatorKey: HyperSnackbar.navigatorKey, 
      home: const HomePage(),
    );
  }
}
```

## 📖 Usage

### Basic Usage
The simplest way to show a message.

```dart
HyperSnackbar.show(
  title: 'Hello World',
  message: 'This is the simplest usage.',
);
```

### Built-in Presets
Quickly show styled messages for common scenarios.

```dart
// Success
HyperSnackbar.showSuccess(
  title: 'Success!',
  message: 'Operation completed successfully.',
);

// Error
HyperSnackbar.showError(
  title: 'Error',
  message: 'Something went wrong.',
);

// Warning & Info
HyperSnackbar.showWarning(title: 'Low Storage');
HyperSnackbar.showInfo(title: 'New Message');
```

---

### 🎨 Creating Custom Presets

Stop repeating yourself! Define reusable styles using `HyperSnackbar.preset` and reuse them across your app.

```dart
// 1. Define a base preset (e.g., in your constants file)
static final myBrandPreset = HyperSnackbar.preset(
  backgroundColor: Colors.deepPurple,
  icon: Icon(Icons.star, color: Colors.amber),
  borderRadius: 16,
  animationType: HyperSnackAnimationType.scale, // Sets both enter & exit
);

// 2. Use it anywhere
HyperSnackbar.show(
  title: 'Welcome!',
  preset: myBrandPreset,
);

// 3. Override specific properties on the fly
HyperSnackbar.show(
  title: 'Welcome!',
  preset: myBrandPreset,
  backgroundColor: Colors.red, // Overrides the purple color
);
```

You can even inherit and extend presets using `copyWith`:

```dart
final darkPreset = myBrandPreset.copyWith(
  backgroundColor: Colors.black,
  textColor: Colors.white,
);
```

---

### 🖥️ Web & Desktop Layout

The default full-width design is perfect for mobile, but it can stretch too far on large screens. You can now easily constrain the width and align the snackbar for Web and Desktop layouts.

```dart
HyperSnackbar.show(
  message: 'This is a compact notification.',
  maxWidth: 400.0, // Prevents stretching on large screens
  alignment: Alignment.centerRight, // Aligns to the right side of the window
  showCloseButton: false, // Optional: create a clean, message-only toast
);
```

By keeping the type as `AlignmentGeometry`, it fully supports `center`, `centerLeft`, `centerRight`, and even RTL (Right-to-Left) layouts using `AlignmentDirectional`.

---

### ⚡ GetX Migration Guide

Coming from GetX? `HyperSnackbar` now supports familiar parameter aliases to assist with seamless migration. You can copy-paste most of your existing `Get.snackbar` code!

| GetX Parameter | HyperSnackbar Equivalent / Alias |
|---|---|
| `duration` | Supported directly (alias for `displayDuration`) |
| `snackPosition` | Supported directly (`HyperSnackPosition.top` / `.bottom`) |
| `snackStyle` | Supported directly (`HyperSnackStyle.grounded` / `.floating`) |
| `colorText` | Supported directly (alias for `textColor`) |
| `isDismissible` | Supported directly (alias for `enableSwipe`) |
| `dismissDirection` | Supported directly (Overrides dynamic directional swipe) |
| `snackbarStatus` | Supported directly (Lifecycle callbacks) |
| `userInputForm` | Supported directly (Embed a `Form` or `TextField`) |
| `icon`, `mainButton`, `onTap`, `shouldIconPulse`, `boxShadows` | Supported directly |

```dart
// You can use GetX-style parameters directly:
HyperSnackbar.show(
  title: 'Action Required',
  message: 'It works just like you expect.',
  snackPosition: HyperSnackPosition.top,
  snackStyle: HyperSnackStyle.grounded, // Attaches directly to the screen edge
  icon: const Icon(Icons.warning, color: Colors.white),
  shouldIconPulse: true,
  isDismissible: false,
  mainButton: TextButton(
    onPressed: () => print('Action!'),
    child: const Text('UNDO'),
  ),
  snackbarStatus: (status) => print('Status: $status'),
);
```

---

### Advanced Features

#### Progress Bar Effects
#### Async Progress Control (New!)
You can seamlessly synchronize the progress bar with real asynchronous operations. `showProgress` returns a controller that manages the UI without blocking your code.

```dart
// 1. Show the progress bar and get the controller
final controller = HyperSnackbar.showProgress(
  title: 'Downloading...',
  message: 'Fetching files...',
  progressBarWidth: 0.0, // Wipe effect
  transitionDelay: const Duration(milliseconds: 300), // Delay before transitioning to success
);

// 2. Perform your async work
for (int i = 1; i <= 5; i++) {
  await Future.delayed(const Duration(seconds: 1));
  controller.updateProgress(i * 0.2); // Updates from 0.0 to 1.0
}

// 3. Automatically transition to a success state!
// The controller will wait for the 100% animation to finish before swapping.
await controller.success(
  title: 'Download Complete',
  message: 'Files downloaded successfully.',
);
```

Visualize the remaining duration.

```dart
HyperSnackbar.show(
  title: 'Loading...',
  progressBarWidth: 4.0, // Line effect
  // progressBarWidth: 0.0, // Wipe effect (background fill)
  displayDuration: const Duration(seconds: 5),
);
```

#### Frosted Glass & Background Blur
Add beautiful blur effects to your snackbars or the entire screen.

```dart
// Frosted Glass Effect (blur the snackbar itself)
HyperSnackbar.show(
  title: 'Frosted Glass',
  barBlur: 20.0,
  backgroundColor: Colors.black.withAlpha(100), // Must be semi-transparent
);

// Focus Mode (blur the entire background screen)
HyperSnackbar.show(
  title: 'Focus Mode',
  overlayBlur: 5.0,
  snackPosition: HyperSnackPosition.bottom,
);
```

#### Rich UI & User Input Forms
Create highly engaging notifications with gradients, side indicators, and inline text inputs.

```dart
// Neon Gradient with Left Bar
HyperSnackbar.show(
  title: 'Neon Cyberpunk',
  message: 'Multiple vivid colors combined in a linear gradient.',
  backgroundGradient: const LinearGradient(
    colors: [Colors.purple, Colors.pinkAccent, Colors.orangeAccent],
  ),
  leftBarIndicatorColor: Colors.blueAccent, 
  colorText: Colors.white,
);

// User Input Form (Quick Reply)
final TextEditingController replyController = TextEditingController();
HyperSnackbar.show(
  title: 'Quick Reply',
  message: 'Enter your response directly in the snackbar.',
  userInputForm: Form(
    child: TextFormField(
      controller: replyController,
      autofocus: true,
      textInputAction: TextInputAction.send,
      onFieldSubmitted: (text) {
        HyperSnackbar.clearAll(animated: false);
        HyperSnackbar.showSuccess(title: 'Sent!', message: text);
      },
    ),
  ),
);
```

#### Action Button & Custom Content
Add interactive buttons or fully custom widgets.

```dart
HyperSnackbar.show(
  title: 'Item Deleted',
  action: HyperSnackAction(
    label: 'UNDO',
    onPressed: () => undoAction(),
  ),
);

// Or use a custom widget
HyperSnackbar.show(
  title: 'Cart Updated',
  content: Row(
    children: [
      TextButton(onPressed: () {}, child: Text('View Cart')),
      TextButton(onPressed: () {}, child: Text('Checkout')),
    ],
  ),
);
```

#### Overlay Control (Embedded Mode)
By default, snackbars render on the root overlay (covering modals). Set `useLocalOverlay: true` to render inside the nearest active Navigator (e.g., inside a tab or bottom sheet).

```dart
HyperSnackbar.show(
  title: 'Embedded Message',
  useLocalOverlay: true, 
  backgroundColor: Colors.indigo,
);
```

## 📚 API Reference

### HyperSnackbar Methods

All methods are static and can be called from anywhere.

| Method | Description |
|---|---|
| `show(...)` | Displays a fully customizable snackbar. |
| `preset(...)` | Creates a reusable configuration object. |
| `showProgress(...)` | **(New)** Displays an async progress bar and returns a `HyperSnackbarProgressController`. |
| `showSuccess(...)` | Preset: Green background, Check icon. |
| `showError(...)` | Preset: Red background, Error icon. |
| `showWarning(...)` | Preset: Orange background, Warning icon. |
| `showInfo(...)` | Preset: Blue background, Info icon. |
| `dismissById(id)` | Dismisses a specific snackbar by its ID. |
| `clearAll({animated})` | Dismisses all currently visible snackbars. |
| `isSnackbarOpen` | Returns `true` if any snackbar is visible. |
| `isSnackbarOpenById(id)` | Returns `true` if the specific snackbar is visible. |

## ⚙️ Configuration Parameters

`HyperSnackbar` is highly customizable. You can configure it using the `HyperConfig` object, `HyperSnackbar.preset`, or directly via parameters in `HyperSnackbar.show`.

### 🎨 General & Appearance
| Parameter | Type | Default | Description |
|---|---|---|---|
| `preset` | `HyperConfig?` | `null` | Base configuration to apply/override. |
| `title` | `String?` | `null` | The title of the snackbar. |
| `message` | `String?` | `null` | The main message body. |
| `icon` | `Widget?` | `null` | Custom icon widget displayed on the left. |
| `useAdaptiveLoader` | `bool` | `false` | If `true`, displays a platform-adaptive loading indicator instead of the icon. |
| `backgroundColor` | `Color?` | `null` | Background color (defaults to dark grey). |
| `textColor` | `Color?` | `null` | Color for title and message text (alias: `colorText`). |
| `borderRadius` | `double` | `12.0` | Corner radius of the snackbar. |
| `elevation` | `double` | `4.0` | Shadow elevation. |
| `border` | `BoxBorder?` | `null` | Custom border for the snackbar container. |
| `margin` | `EdgeInsetsGeometry` | `zero` | Margin around the snackbar. |
| `padding` | `EdgeInsetsGeometry` | `16, 12` | Internal padding. |
| `useLocalOverlay`| `bool` | `false` | If false, renders on the root overlay. If true, renders on the nearest overlay. |
| `maxWidth` | `double?` | `null` | Maximum width of the snackbar. Ideal for Web/Desktop. |
| `alignment` | `AlignmentGeometry` | `.center` | Alignment of the snackbar when `maxWidth` is constrained. |
| `backgroundGradient` | `Gradient?` | `null` | Custom gradient for the background (e.g., `LinearGradient`). |
| `leftBarIndicatorColor` | `Color?` | `null` | Adds a colored accent bar to the left edge of the snackbar. |
| `snackStyle` | `HyperSnackStyle`| `.floating` | Use `.grounded` to remove margins and corner radii on the attached edge. |

### 👆 Actions & Interaction
| Parameter | Type | Default | Description |
|---|---|---|---|
| `action` | `HyperSnackAction?` | `null` | Action button configuration (label, callback, colors). |
| `actionAlignment` | `MainAxisAlignment` | `.end` | Alignment of the action button (e.g., `.start`, `.center`). |
| `content` | `Widget?` | `null` | Custom widget to replace the action button area. |
| `onTap` | `VoidCallback?` | `null` | Callback when the snackbar itself is tapped. |
| `showCloseButton` | `bool` | `true` | Whether to show the "X" close button. |
| `enableSwipe` | `bool` | `true` | Allow dismissing the snackbar by swiping horizontally. |
| `userInputForm` | `Form?` | `null` | Embed a `TextField` or `Form` directly inside the snackbar. |
| `dismissDirection`| `DismissDirection?`| `null` | Overrides default swipe direction (e.g., `horizontal`). |
| `snackbarStatus` | `Function(Status)?`| `null` | Lifecycle callback (`opening`, `open`, `closing`, `closed`). |

### ⏱️ Behavior & Positioning
| Parameter | Type | Default | Description |
|---|---|---|---|
| `id` | `String?` | `null` | Unique ID. Updating a snackbar with the same ID modifies the existing one. |
| `displayDuration` | `Duration?` | `4s` | How long the snackbar stays visible (alias: `duration`). `null` means persistent. |
| `position` | `HyperSnackPosition` | `.top` | Vertical position (alias: `snackPosition`). |
| `displayMode` | `HyperSnackDisplayMode` | `.stack` | `.stack` (overlays on top) or `.queue` (shows one by one). |
| `newestOnTop` | `bool` | `true` | (Stack mode) If `true`, new snackbars appear on top of the stack. |
| `maxVisibleCount` | `int` | `3` | Maximum number of snackbars visible at once (Stack mode). |

### 📝 Text Handling
| Parameter | Type | Default | Description |
|---|---|---|---|
| `titleStyle` | `TextStyle?` | `null` | Custom style for the title text. |
| `messageStyle` | `TextStyle?` | `null` | Custom style for the message text. |
| `maxLines` | `int?` | `5` | Maximum lines for the message text. |
| `scrollable` | `bool` | `false` | If `true`, the message becomes scrollable within constraints. |
| `messageMaxHeight` | `double?` | `null` | Max height for the scrollable message area. |

### ✨ Animation
| Parameter | Type | Default | Description |
|---|---|---|---|
| `animationType` | `HyperSnackAnimationType?`| `null` | Sets both enter and exit animation types simultaneously. |
| `enterAnimationType` | `HyperSnackAnimationType` | `.top` | Animation style for entry (`scale`, `fade`, `left`, etc.). |
| `exitAnimationType` | `HyperSnackAnimationType` | `.left` | Animation style for exit. |
| `animationDuration` | `Duration?` | `null` | Sets both enter and exit durations simultaneously. |
| `enterAnimationDuration`| `Duration` | `300ms` | Duration of entry animation. |
| `exitAnimationDuration` | `Duration` | `500ms` | Duration of exit animation. |
| `enterCurve` | `Curve` | `easeOutQuart`| Animation curve for entry. |
| `exitCurve` | `Curve` | `easeOut` | Animation curve for exit. |

### 📊 Progress Bar
| Parameter | Type | Default | Description |
|---|---|---|---|
| `progressBarWidth` | `double?` | `null` | Height of the progress bar. `0.0` creates a background "wipe" effect. `null` disables it. |
| `progressBarColor` | `Color?` | `null` | Color of the progress bar. Defaults to a semi-transparent contrast color. |
| `showProgressIndicator` | `bool` | `false` | Explicitly enable or disable the progress indicator. |
| `progressIndicatorBackgroundColor` | `Color?` | `null` | Custom background track color for the progress bar. |
| `progressIndicatorValueColor` | `Animation<Color>?` | `null` | Custom active value color (e.g., `AlwaysStoppedAnimation(Colors.red)`). |

## 📄 License

MIT License
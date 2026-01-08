[![pub package](https://img.shields.io/pub/v/hyper_snackbar.svg)](https://pub.dev/packages/hyper_snackbar)
[![likes](https://img.shields.io/pub/likes/hyper_snackbar)](https://pub.dev/packages/hyper_snackbar/score)
[![GitHub issues](https://img.shields.io/github/issues/MakiAno/hyper_snackbar?style=flat-square)](https://github.com/MakiAno/hyper_snackbar/issues)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

# Hyper Snackbar 🚀

A highly customizable, animated, and stackable snackbar manager for Flutter.
Designed for modern apps that need more than just a simple toast.

<p align="center">
  <img src="https://raw.githubusercontent.com/MakiAno/hyper_snackbar/main/screenshots/demo1.gif" width="32%" />
  <img src="https://raw.githubusercontent.com/MakiAno/hyper_snackbar/main/screenshots/demo2.gif" width="32%" />
  <img src="https://raw.githubusercontent.com/MakiAno/hyper_snackbar/main/screenshots/demo3.gif" width="32%" />
</p>

## ✨ Features

* **Stackable**: Display multiple notifications simultaneously without overlap.
* **Highly Customizable**: Custom borders, margins, fonts, shadows, and animations.
* **Flexible Action Placement**: Align action buttons to the **Right**, **Center**, or **Left**.
* **Custom Content Support**: Embed any widget (e.g., multiple buttons, sliders) instead of a standard action.
* **Smart Updates**: Update the content of an existing snackbar by ID without animation glitches.
* **Overflow Safety**: Automatically handles ultra-long text with internal scrolling, preventing UI overflow errors.
* **Persistent Mode**: Set duration to `Duration.zero` (or `null`) to keep the snackbar visible until dismissed.
* **Log Style**: Option to append new notifications to the **bottom** of the list (console log style).
* **Presets**: Ready-to-use methods for Success, Error, Warning, and Info.
* **Polished UI**: Supports bold action text, custom colors, and top-aligned close buttons for a modern look.

## 📦 Installation

Add this to your package's `pubspec.yaml` file:
```dart
    dependencies:
      hyper_snackbar: ^0.3.0
```
## 🚀 Setup (Important)

To use `HyperSnackbar` from anywhere in your code (e.g., ViewModels, BLoCs), you must register the `navigatorKey` in your `MaterialApp`.
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
          title: 'My App',
          // ▼ Register the key here to show snackbars without BuildContext
          navigatorKey: HyperSnackbar.navigatorKey, 
          home: const HomePage(),
        );
      }
    }
```
## 💡 Usage

### Basic Usage
The API is static, so you can call it directly without creating an instance.
```dart
    HyperSnackbar.show(
      title: 'Success!',
      message: 'Data has been saved successfully.',
      backgroundColor: Colors.green,
    );
```
### Action Alignment (Right / Center / Left) 🆕
You can now control the position of the action button.
```dart
    // Center Alignment
    HyperSnackbar.show(
      title: 'Update Available',
      action: HyperSnackAction(
        label: 'INSTALL',
        onPressed: () => installUpdate(),
      ),
      actionAlignment: MainAxisAlignment.center, // <--- Center the button
    );
```
### Custom Content (Arbitrary Widget) 🆕
Need more than one button? Use `content` to pass any widget.
```dart
    HyperSnackbar.show(
      title: 'Delete this item?',
      message: 'This action cannot be undone.',
      // Embed your own widget
      content: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => HyperSnackbar.dismissById('delete_confirm'),
            child: Text('CANCEL', style: TextStyle(color: Colors.white)),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => deleteItem(),
            child: Text('DELETE'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
      id: 'delete_confirm',
    );
```
### Presets
Simple one-liners for common scenarios.
```dart
    // Success
    HyperSnackbar.showSuccess(title: 'Saved successfully');

    // Error
    HyperSnackbar.showError(
      title: 'Connection Failed', 
      message: 'Please check your internet connection.'
    );

    // Warning
    HyperSnackbar.showWarning(title: 'Low Storage');

    // Info
    HyperSnackbar.showInfo(title: 'New Message Received');
```
### Update by ID (Loading -> Done) ⚡
Update the state of a snackbar by providing a unique `id`.
```dart
    const String processId = 'upload_process';

    // 1. Show Loading state
    HyperSnackbar.show(
      id: processId,
      title: 'Uploading...',
      displayDuration: null, // Keep it visible
      icon: CircularProgressIndicator(color: Colors.white),
    );

    // ... do some work ...

    // 2. Update to "Done" state (using the same ID)
    HyperSnackbar.show(
      id: processId, // Replaces the content
      title: 'Upload Complete!',
      backgroundColor: Colors.green,
      icon: Icon(Icons.check_circle, color: Colors.white),
      displayDuration: Duration(seconds: 3), // Auto-dismiss
    );
```
### Advanced Usage

#### Persistent Notification
Set `displayDuration` to `Duration.zero` (or `null`) to make the snackbar stay until manually dismissed.
```dart
    HyperSnackbar.show(
      title: 'Persistent Message',
      message: 'I will stay here until you close me.',
      displayDuration: Duration.zero, // <--- Persistent
    );
```
#### Handling Long Text (Overflow Safety)
Even with `maxLines: null`, the snackbar will safely handle extremely long text by enabling internal scrolling, ensuring it never exceeds the screen height.
```dart
    HyperSnackbar.show(
      title: 'System Log',
      message: 'Very long error log...\nLine 1\nLine 2\n...',
      maxLines: null, // Unlimited lines (scrollable if needed)
      backgroundColor: Colors.grey[900],
    );
```
### Using with GoRouter

If you are using `go_router`, simply assign `HyperSnackbar.navigatorKey` to the `navigatorKey` property.
```dart
    final _router = GoRouter(
      navigatorKey: HyperSnackbar.navigatorKey, // Add this line
      routes: [ ... ],
    );
```
## ⚙️ Configuration (`HyperConfig`)

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| **Content** | | | |
| `title` | `String` | Required | The main title text. |
| `message` | `String?` | `null` | The subtitle text. |
| `icon` | `Widget?` | `null` | Icon widget displayed on the left. |
| `action` | `HyperSnackAction?` | `null` | Action button definition. |
| `actionAlignment` | `MainAxisAlignment` | `.end` | Alignment of the action (Left/Center/Right). |
| `content` | `Widget?` | `null` | Custom widget to replace the action button. |
| `maxLines` | `int?` | `5` | Max lines for message. `null` for unlimited. |
| **Style** | | | |
| `backgroundColor` | `Color` | `Grey[800]` | Background color. |
| `textColor` | `Color` | `White` | Text color. |
| `borderRadius` | `double` | `12.0` | Corner radius. |
| `border` | `BoxBorder?` | `null` | Border around the snackbar. |
| `margin` | `EdgeInsets` | `zero` | Outer margin. |
| `padding` | `EdgeInsets` | `16, 12` | Inner padding. |
| `elevation` | `double` | `4.0` | Shadow elevation. |
| **Behavior** | | | |
| `id` | `String?` | `null` | Unique ID for updating content. |
| `onTap` | `VoidCallback?` | `null` | Callback when tapped. |
| `displayDuration` | `Duration?` | `4s` | `Duration.zero` or `null` makes it persistent. |
| `enableSwipe` | `bool` | `true` | Allow swipe to dismiss. |
| `showCloseButton`| `bool` | `true` | Show 'X' button on the right. |
| `newestOnTop` | `bool` | `true` | `false` appends new items to the bottom. |
| **Animation** | | | |
| `enterAnimationType`| `Enum` | `.top` | Entry animation type. |
| `exitAnimationType` | `Enum` | `.left` | Exit animation type. |
| `enterAnimationDuration`| `Duration` | `300ms` | Entry duration. |
| `exitAnimationDuration` | `Duration` | `500ms` | Exit duration. |

## ❤️ Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

MIT License
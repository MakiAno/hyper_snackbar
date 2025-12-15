import csv

# README.md content (Raw Text)
readme_content = r"""# Hyper Snackbar 🚀
![Demo GIF](https://raw.githubusercontent.com/MakiAno/hyper_snackbar/main/screenshots/demo.gif)

A highly customizable, animated, and stackable snackbar manager for Flutter.
Designed for modern apps that need more than just a simple toast.

[![pub package](https://img.shields.io/pub/v/hyper_snackbar.svg)](https://pub.dev/packages/hyper_snackbar)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## ✨ Features

* **Stackable**: Display multiple notifications simultaneously without overlap.
* **Highly Customizable**: Custom borders, margins, fonts, shadows, and tap actions.
* **Smart Updates**: **Update the content** (text, icon, color) of an existing snackbar by ID without animation glitches.
* **Interactive**: Support for action buttons (e.g., "Undo") and tap gestures on the bar itself.
* **Flexible Positioning**: Show at the **Top** or **Bottom** of the screen.
* **Log Style**: Option to append new notifications to the **bottom** of the list (console log style).
* **Presets**: Ready-to-use methods for Success, Error, Warning, and Info.

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  hyper_snackbar: ^0.1.0
```

## 🚀 Setup (Important)
To use HyperSnackbar without a BuildContext, you must register the navigatorKey in your MaterialApp.

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
      // ▼ Register the key here
      navigatorKey: HyperSnackbar.navigatorKey, 
      home: const HomePage(),
    );
  }
}
```

## 💡 Usage
### Basic Usage (No Context required)
You can now show a snackbar from anywhere (e.g., BLoC, ViewModels, or async callbacks) without passing a BuildContext.

```dart
final config = HyperConfig(
  title: 'Success!',
  message: 'Data has been saved successfully.',
  backgroundColor: Colors.green,
);

// Just call show!
HyperSnackbar().show(config);
```

### Advanced Usage (With Context)
If you want to inherit the local theme or Directionality of a specific screen, you can optionally pass the context.
```dart
// The snackbar will use the theme from this context
HyperSnackbar().show(config, context: context);
```

### Using Extension (Optional)
You can also use the convenient extension method inside your widgets.
```dart
context.showHyperSnackbar(config);
```

### 1. Basic Presets
Simple one-liners for common scenarios.

```dart
import 'package:hyper_snackbar/hyper_snackbar.dart';

// Success
HyperSnackbar().showSuccess(title: 'Saved successfully');

// Error
HyperSnackbar().showError(
  title: 'Connection Failed', 
  message: 'Please check your internet connection.'
);

// Warning
HyperSnackbar().showWarning(title: 'Low Storage');

// Info
HyperSnackbar().showInfo(title: 'New Message Received');
```

### 2. Advanced Customization
You can customize almost everything using `HyperConfig`.

```dart
HyperSnackbar().show(
  HyperConfig(
    title: 'Modern Notification',
    message: 'With custom border, font, and tap action.',
    backgroundColor: Color(0xFF212121),
    
    // Custom Design
    border: Border.all(color: Colors.white24, width: 1),
    borderRadius: 8,
    margin: EdgeInsets.all(16),
    titleStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    
    // Tap Interaction
    onTap: () {
      print('Notification tapped!');
      Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage()));
    },
    
    // Action Button
    action: HyperSnackAction(
      label: 'UNDO',
      textColor: Colors.amber,
      onPressed: () => print('Undo pressed'),
    ),
  ),
);
```
### 3. Update by ID (Loading -> Done) ⚡
This is the **killer feature**. You can update the state of a snackbar while keeping it on screen.

```dart
const String processId = 'upload_process';

// 1. Show Loading
HyperSnackbar().show(
  HyperConfig(
    id: processId, // Unique ID
    title: 'Uploading...',
    displayDuration: null, // Keep it visible
    icon: CircularProgressIndicator(color: Colors.white),
  ),
);

// ... do some work ...

// 2. Update to "Done" (Using the same ID)
HyperSnackbar().show(
  HyperConfig(
    id: processId, // Same ID replaces the content
    title: 'Upload Complete!',
    backgroundColor: Colors.green,
    icon: Icon(Icons.check_circle, color: Colors.white),
    displayDuration: Duration(seconds: 3), // Auto-dismiss after 3s
  ),
);
```

### 4. Log Style (Stacking Direction)
By default, new items appear at the top. You can append them to the **bottom** like a chat or log.

```dart
HyperSnackbar().show(
  HyperConfig(
    title: 'System Log',
    message: 'Newest item is at the bottom.',
    position: HyperSnackPosition.top,
    newestOnTop: false, // <--- Append to bottom
    enterAnimationType: HyperSnackAnimationType.fromTop,
  ),
);
```

## ⚙️ Configuration (`HyperConfig`)

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| **Content** | | | |
| `title` | `String` | Required | The main title text. |
| `message` | `String?` | `null` | The subtitle text. |
| `icon` | `Widget?` | `null` | Icon widget displayed on the left. |
| `action` | `HyperSnackAction?` | `null` | Action button definition (label & callback). |
| **Style** | | | |
| `backgroundColor` | `Color` | `Grey[800]` | Background color of the snackbar. |
| `textColor` | `Color` | `White` | Color for title and message. |
| `borderRadius` | `double` | `12.0` | Corner radius. |
| `border` | `BoxBorder?` | `null` | Border around the snackbar. |
| `margin` | `EdgeInsets` | `zero` | Outer margin (e.g., for floating effect). |
| `padding` | `EdgeInsets` | `16, 12` | Inner padding. |
| `elevation` | `double` | `4.0` | Shadow elevation. |
| `titleStyle` | `TextStyle?` | `null` | Custom style for the title. |
| `messageStyle` | `TextStyle?` | `null` | Custom style for the message. |
| **Behavior** | | | |
| `id` | `String?` | `null` | Unique ID for updating content dynamically. |
| `onTap` | `VoidCallback?` | `null` | Callback when the entire bar is tapped. |
| `displayDuration` | `Duration?` | `4s` | Set `null` for persistent (sticky) notification. |
| `enableSwipe` | `bool` | `true` | Allow users to swipe to dismiss. |
| `showCloseButton`| `bool` | `true` | Show 'X' button on the right. |
| `newestOnTop` | `bool` | `true` | `false` appends new items to the bottom. |
| **Animation** | | | |
| `enterAnimationType`| `Enum` | `.fromTop` | Slide direction or Fade for entry. |
| `exitAnimationType` | `Enum` | `.toLeft` | Slide direction or Fade for exit. |
| `enterAnimationDuration`| `Duration` | `300ms` | Duration of entry animation. |
| `exitAnimationDuration` | `Duration` | `500ms` | Duration of exit animation. |
| `enterCurve` | `Curve` | `easeOutQuart`| Animation curve for entry. |
| `exitCurve` | `Curve` | `easeOut` | Animation curve for exit. |

## ❤️ Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

MIT License
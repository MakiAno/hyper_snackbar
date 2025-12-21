## 0.2.1

### ✨ Features

### 🧹 Refactoring
* Consolidated `HyperSnackAnimationType` enum to use unified types (e.g., `top` instead of `fromTop` or `toTop`) for both entry and exit animations. This simplifies animation configuration.

*   **Enhanced HyperConfig.copyWith**: The `HyperConfig.copyWith` method now supports all properties, significantly improving reusability and flexibility when updating snackbar configurations.

### 📝 Documentation

*   **Internationalization**: All Japanese comments across the codebase (`pubspec.yaml`, `lib/src/*`, `example/lib/main.dart`) have been translated to English.
*   **GitHub Feedback Link**: The `README.md` has been updated to include a GitHub Issues badge, making it easier for users to provide feedback and contribute.

## 0.2.0

### ⚠️ BREAKING CHANGES

*   **Static API by Default**: The `HyperSnackbar` class is now fully static. This makes the API more intuitive and similar to popular packages like `GetX`. You no longer need to instantiate it.

    **Before:**
    ```dart
    HyperSnackbar().show(config);
    ```

    **After:**
    ```dart
    HyperSnackbar.show(...); // With named parameters
    // Old usage style (with HyperConfig object) is now available via `HyperSnackbar.showFromConfig(config);`
    ```

*   **Simplified `show` Method**: The primary `show` method no longer takes a `HyperConfig` object. Instead, it now accepts named parameters directly, significantly improving ease of use for one-off snackbars.

    **Before:**
    ```dart
    HyperSnackbar().show(HyperConfig(
      title: 'Success',
      message: 'Your file was saved.'
    ));
    ```

    **After:**
    ```dart
    HyperSnackbar.show(
      title: 'Success',
      message: 'Your file was saved.'
    );
    // Old usage style (with HyperConfig object) is now available via `HyperSnackbar.showFromConfig(config);`
    ```

### ✨ Features

*   **Intuitive API**: The new static API (`HyperSnackbar.show(...)`) is cleaner, requires less boilerplate, and is easier to discover.
    ```dart
    // The simplest way to show a snackbar:
    HyperSnackbar.show(title: 'Hello World!');
    ```
*   **Configuration Reusability**: Added the `HyperSnackbar.showFromConfig(config)` method. This allows you to create a reusable `HyperConfig` object for styles that you use frequently, offering the best of both worlds.

    ```dart
    // Define a reusable style
    final myErrorStyle = HyperConfig(
      backgroundColor: Colors.red,
      // ... other properties
    );

    // Reuse it anywhere
    HyperSnackbar.showFromConfig(
      myErrorStyle.copyWith(title: 'Error 1')
    );
    HyperSnackbar.showFromConfig(
      myErrorStyle.copyWith(title: 'Error 2')
    );
    ```

*   **Updated BuildContext Extension**: The `context.showHyperSnackbar()` extension has also been updated to use named parameters for a consistent and convenient API.

## 0.1.3
* Improved documentation comments.

## 0.1.2

### ✨ Features
*   **Manual Dismissal:** Added `dismissById(String id)` to close specific snackbars programmatically.
*   **Clear All:** Added `clearAll()` to close all visible snackbars at once.

## 0.1.1

* Fix README formatting.

## 0.1.0

### ⚠️ Breaking Changes
*   **Renamed Main Class:** `HyperManager` has been renamed to `HyperSnackbar` to be more intuitive.

### ✨ Features
*   **Context-less Usage:** Added support for showing snackbars without a `BuildContext`.
    *   *Note:* To use this feature, you must assign `HyperSnackbar.navigatorKey` to the `navigatorKey` property of your `MaterialApp`.
*   **Hybrid Support:** The `show` method now accepts an optional `context`. If provided, it uses the local context (ideal for inheriting themes); otherwise, it falls back to the global navigator key.
*   **Extension Method:** Added `context.showHyperSnackbar(config)` for easier usage within widgets.

## 0.0.4

* Documents update.

## 0.0.3

* Initial complete release.

## 0.0.2

* Update README.md.
* Add Demo.gif

## 0.0.1

* Initial release.

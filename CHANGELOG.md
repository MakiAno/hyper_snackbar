## [0.2.5] - 2026-01-06

### New Features
* **Scrollable Message Text**: Introduced `scrollable` and `messageMaxHeight` properties to `show()` and `HyperConfig`, allowing for scrollable message content within a specified maximum height. When scrolling, the auto-dismiss timer is paused.
* **Display Mode (Stack vs. Queue)**: Added `displayMode` property to `show()` and `HyperConfig`.
    * `HyperSnackDisplayMode.stack` (default): Shows multiple notifications simultaneously, stacked on top of each other.
    * `HyperSnackDisplayMode.queue`: Displays notifications one by one, similar to standard Snackbars.

### Bug Fixes
* **Swipe Gesture Ghosting**: Resolved an issue where a ghost animation could appear when dismissing a snackbar via swipe gesture. The auto-dismiss timer is now properly cancelled when a swipe begins.

### Docs
* Updated `README.md` to include an explanation of the new `displayMode` feature.

## [0.2.4]

### UI/UX Improvements
* **Action Button Placement:** Moved the action button below the message text to improve readability and layout stability on narrower screens.
* **Close Button:** Aligned the close button to the top-right corner (`CrossAxisAlignment.start`) for better aesthetics with multi-line messages.
* **Typography:** Added `TextOverflow.ellipsis` to the title (max 1 line) to prevent layout breakage. Action button text is now bold for better visibility.

### New Features
* **Message Lines Control:** Added `maxLines` parameter to `show()` and `HyperConfig`.
    * Defaults to `5` lines to prevent the snackbar from taking up too much screen space.
    * Pass `null` to display the full message without truncation.
* **Auto Dismiss Action:** Added `autoDismiss` property to `HyperSnackAction` (defaults to `true`). The snackbar will now automatically close when an action is tapped, unless specified otherwise.

## [0.2.3]

* **Fixed:** Resolved a `setState() called during build` runtime error that could occur when triggering a snackbar during a navigation transition (e.g., using `go_router` without a `BuildContext`).
* **Improvement:** Added `SchedulerBinding` phase checks to ensure the overlay is inserted safely after the current frame build is completed.
* **Tests:** Added compatibility tests and examples for `go_router`.

## [0.2.2]

### Added
- Added `isSnackbarOpenById(String id)` to check if a snackbar with a specific ID is currently visible.
- Added an `animated` parameter to the `clearAll()` method to allow choosing whether to dismiss snackbars with an animation. Defaults to `true`.
- Added an example of using `HyperConfig` to the sample app.

### Changed
- The default behavior of `clearAll()` has been changed from immediate removal to animated dismissal.

### Fixed
- Stabilized tests related to animations by using `pumpAndSettle` to ensure animations are complete before making assertions.

### Chore
- Removed unnecessary dependencies.
- Updated `SECURITY.md` to reflect the currently supported version.

## 0.2.1

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


## [0.2.4]

### UI/UX Improvements
* **Action Button Placement:** Moved the action button below the message text to improve readability and layout stability on narrower screens.
* **Close Button:** Aligned the close button to the top-right corner (`CrossAxisAlignment.start`) for better aesthetics with multi-line messages.
* **Typography:** Added `TextOverflow.ellipsis` to the title (max 1 line) to prevent layout breakage. Action button text is now bold for better visibility.

### New Features
* **Message Lines Control:** Added `maxLines` parameter to `show()` and `HyperConfig`.
    * Defaults to `5` lines to prevent the snackbar from taking up too much screen space.
    * Pass `null` to display the full message without truncation.
* **Auto Dismiss Action:** Added `autoDismiss` property to `HyperSnackAction` (defaults to `true`). The snackbar will now automatically close when an action is tapped, unless specified otherwise.

## [0.2.3]

* **Fixed:** Resolved a `setState() called during build` runtime error that could occur when triggering a snackbar during a navigation transition (e.g., using `go_router` without a `BuildContext`).
* **Improvement:** Added `SchedulerBinding` phase checks to ensure the overlay is inserted safely after the current frame build is completed.
* **Tests:** Added compatibility tests and examples for `go_router`.

## [0.2.2]

### Added
- Added `isSnackbarOpenById(String id)` to check if a snackbar with a specific ID is currently visible.
- Added an `animated` parameter to the `clearAll()` method to allow choosing whether to dismiss snackbars with an animation. Defaults to `true`.
- Added an example of using `HyperConfig` to the sample app.

### Changed
- The default behavior of `clearAll()` has been changed from immediate removal to animated dismissal.

### Fixed
- Stabilized tests related to animations by using `pumpAndSettle` to ensure animations are complete before making assertions.

### Chore
- Removed unnecessary dependencies.
- Updated `SECURITY.md` to reflect the currently supported version.

## 0.2.1

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

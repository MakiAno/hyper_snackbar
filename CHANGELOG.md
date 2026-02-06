## 0.4.4 - 2026-02-06

* Fix: Corrected installation instructions and example code in README.md.
* Documentation: Updated usage examples for better clarity.

## [0.4.3]

### Fixed
- **Overlay Retrieval Crash:** Fixed an issue where calling `HyperSnackbar.show` without a proper context (or from background processes) caused a `No Overlay widget found` crash. Added a robust fallback mechanism using `navigatorKey`.
- **Corner Rendering Artifacts:** Fixed an issue where black halos/borders appeared on rounded corners when the snackbar was displayed over dark backgrounds (like Drawers). Improved rendering by separating Material shape handling from content clipping using `ClipRRect`.

### Improved
- **Overlay Lookup:** Enhanced `Overlay` lookup to support `rootOverlay: true`, ensuring the snackbar appears above modals and drawers when a context is provided.
- 
## 0.4.2

* **CHORE**: Translated remaining comments in the example app to English for better accessibility.
* **DOCS**: Minor updates to the example code for consistency.

## 0.4.1

* **FIX**: Improved UX for scrollable messages. The auto-dismiss timer now pauses for 1 second after the user stops scrolling, preventing the snackbar from disappearing immediately.
* **FIX**: Resolved an issue where the text ellipsis (`...`) would not appear correctly if the truncated text ended with a space or newline.
* **REFACTOR**: Replaced deprecated color methods (e.g., `withOpacity`) with `withAlpha` to ensure future Flutter compatibility.
* **EXAMPLE**: Significant design and feature updates to the Playground app.
    * New "Dark Glassmorphism" UI design.
    * Added "Surprise Me" button for random style generation.
    * Improved real-time code generation preview.

## 0.4.0

* **FEAT**: Added Progress Bar support.
    * Introduced `progressBarWidth`: Supports `0.0` for a "Wipe" effect (fills the background), positive values for a standard line (e.g., `4.0`), and negative values to hide it.
    * Introduced `progressBarColor`: Allows customization of the progress indicator's color.
* **FEAT**: Increased freedom of styling presets.
    * Enhanced `HyperConfig` and `show()` parameters to support finer control over `border`, `borderRadius`, `elevation`, and shadows. This enables diverse preset styles like "Outlined", "Flat", or "High Contrast".
* **FEAT**: Added an interactive **Playground** to the example app.
    * Includes a real-time mobile preview, style toggles, and code generation.
* **DOCS**: Updated README to showcase the new progress bar styles and playground features.

## 0.3.2

* **IMPROVEMENT**: Made `title` in `HyperConfig` optional (`String?`). This facilitates the creation of reusable configuration templates (e.g., defining a common error style without a dummy title).
* **DOCS**: Updated the configuration table in `README.md` to include previously missing parameters: `maxVisibleCount`, `displayMode`, `scrollable`, and `messageMaxHeight`.
* **DOCS**: Added a "Style Templates" section to `README.md` to demonstrate how to reuse configuration objects effectively.
* **REFACTOR**: Improved null-safety handling for the title in `HyperSnackBarContent` and removed unused variables.

## 0.3.1

* **FIX**: Ensures the scrollbar always appears at the right edge of the card, even for short messages on wide screens.
* **DOCS**: Updated README images to use absolute URLs for better compatibility with pub.dev.

## 0.3.0

* **FEAT**: Added `actionAlignment` parameter to control the horizontal alignment of the action button (Right, Center, Left).
* **FEAT**: Added `content` parameter to support arbitrary Widgets as footer content (replacing the standard action button).
* **FEAT**: Implemented "Overflow Safety" mechanism. Extremely long messages now automatically become scrollable within a constrained height (max 80% of screen) to prevent UI overflow errors.
* **FEAT**: `Duration.zero` in `displayDuration` is now treated as a persistent snackbar (equivalent to `null`).
* **FIX**: Resolved `ScrollController` related crashes by refactoring `HyperSnackBarContent` to a StatefulWidget.
* **FIX**: Fixed layout issues where the close button would scroll off-screen. The header and footer are now fixed, with only the message body being scrollable.
* **FIX**: Improved scrollbar positioning to appear at the absolute right edge of the card.
* **DOCS**: Updated README with examples for new features.

## [0.2.5]

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

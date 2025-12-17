<!-- ## 0.1.4     -->
<!-- Next version -->
* Updated README

## 0.1.3
* Improved documentation comments.

## 0.1.2 - 2025-12-16

### ✨ Features
* **Manual Dismissal:** Added `dismissById(String id)` to close specific snackbars programmatically.
* **Clear All:** Added `clearAll()` to close all visible snackbars at once.

## 0.1.1

* Fix README formatting.

## 0.1.0

### ⚠️ Breaking Changes
* **Renamed Main Class:** `HyperManager` has been renamed to `HyperSnackbar` to be more intuitive.

### ✨ Features
* **Context-less Usage:** Added support for showing snackbars without a `BuildContext`.
    * *Note:* To use this feature, you must assign `HyperSnackbar.navigatorKey` to the `navigatorKey` property of your `MaterialApp`.
* **Hybrid Support:** The `show` method now accepts an optional `context`. If provided, it uses the local context (ideal for inheriting themes); otherwise, it falls back to the global navigator key.
* **Extension Method:** Added `context.showHyperSnackbar(config)` for easier usage within widgets.

## 0.0.4

* Documents update.

## 0.0.3

* Initial complete release.

## 0.0.2

* Update README.md.
* Add Demo.gif

## 0.0.1

* Initial release.
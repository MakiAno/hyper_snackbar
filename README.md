<!--
# Hyper Snackbar

A highly customizable, animated, and stackable snackbar package for Flutter.
Supports features like "Undo" actions, state updates (using ID), log-style stacking, and persistent messages.

## Features

* **Presets**: Easy success, error, warning, and info messages.
* **Highly Customizable**: Custom borders, margins, fonts, and tap actions.
* **Stackable**: Control entry direction and stacking order (top or bottom).
* **Interactive**: Support for action buttons (e.g., Undo) and tap gestures.
* **Smart Updates**: Update content of existing snackbars by ID without animation glitches.

## Getting started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  hyper_snack_list: ^0.0.1

## Usage

import 'package:hyper_snack_list/hyper_snack_list.dart';

// Show a simple success message
HyperManager().showSuccess(context, title: 'Saved successfully');

// Show a custom warning with action
HyperManager().show(
  context,
  HyperConfig(
    title: 'Item deleted',
    action: HyperSnackAction(
      label: 'Undo',
      onPressed: () => print('Undo clicked'),
    ),
  ),
);

## Additional information

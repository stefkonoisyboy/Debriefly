---
inclusion: auto
---

# Project Structure

## Root Layout

```
/
├── api/              # Backend API (currently empty, reserved for future use)
├── app/              # Flutter application
└── .kiro/            # Kiro AI assistant configuration
```

## Flutter App Structure (`app/`)

### Core Directories

- `lib/` - Main Dart source code
  - `main.dart` - Application entry point
- `test/` - Unit and widget tests
  - `widget_test.dart` - Widget test examples

### Platform-Specific Directories

- `android/` - Android native configuration and build files
- `ios/` - iOS native configuration and Xcode project
- `macos/` - macOS native configuration and Xcode project
- `windows/` - Windows native configuration and CMake files
- `linux/` - Linux native configuration and CMake files
- `web/` - Web-specific assets and configuration

### Build & Configuration

- `.dart_tool/` - Dart tooling cache (generated, not committed)
- `build/` - Build output directory (generated, not committed)
- `pubspec.yaml` - Package dependencies and metadata
- `pubspec.lock` - Locked dependency versions
- `analysis_options.yaml` - Dart analyzer configuration

## Code Organization Conventions

### Widget Structure

- Use `StatelessWidget` for widgets without mutable state
- Use `StatefulWidget` for widgets with mutable state
- Private state classes follow naming pattern: `_WidgetNameState`
- Widget constructors should use `const` when possible with `super.key`

### File Naming

- Use snake_case for Dart file names (e.g., `my_widget.dart`)
- Test files mirror source file names with `_test.dart` suffix

### State Management

- Currently using built-in `setState()` for state management
- State changes should always be wrapped in `setState()` calls

## Assets & Resources

- Assets are configured in `pubspec.yaml` under the `flutter:` section
- Material Design icons are enabled via `uses-material-design: true`
- Cupertino icons available via `cupertino_icons` package

## Testing

- Widget tests go in `test/` directory
- Test files should mirror the structure of `lib/`
- Use `flutter_test` package for testing utilities

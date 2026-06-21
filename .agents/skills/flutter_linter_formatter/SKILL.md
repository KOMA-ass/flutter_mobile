---
name: flutter-linter-formatter
description: Format and analyze the Flutter app and Dart Frog backend.
---

# Flutter Linter And Formatter

Use this skill when Dart code must be formatted or lint problems must be fixed.

## Workflow

1. Find every directory that contains `pubspec.yaml`.
2. Run `dart format . --set-exit-if-changed` in `flutt` and `backend`.
3. Run `flutter analyze` and `flutter test` in `flutt`.
4. Run `dart analyze` and `dart test` in `backend`.
5. Fix errors and report any checks that could not be run.

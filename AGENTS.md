# Repository Guidelines

## Architecture

Single-file app: all logic, state, models, and widgets live in `lib/main.dart`. No code splitting until the file warrants extraction.

Dual-platform UI: renders Material on Android, Cupertino on iOS. Platform branch is `defaultTargetPlatform` (checked once per widget build). When adding UI, provide both Material and Cupertino variants following the existing pattern (e.g., `_TopBar` vs `_IosStatusHeader`).

Puzzles are hardcoded `const` data — same solution (`_solution`), different givens per difficulty. No generator or network calls.

Version appears in two places and must stay in sync: `pubspec.yaml` field `version` and `lib/main.dart` const `appVersion`.

## Commands

- `flutter test` — runs all widget tests
- `flutter analyze` — static analysis (lints from `package:flutter_lints/flutter.yaml`)
- `flutter run` — launch on device/emulator
- `flutter build apk` — release APK

Run `flutter analyze` then `flutter test` before considering a change complete.

## Testing Conventions

Tests live in `test/widget_test.dart`. Helpers:

- `pumpSudoku(tester, platform:)` — pumps the app at 390×844 (iPhone-sized). Pass `platform: TargetPlatform.iOS` to test Cupertino path; teardown resets the override automatically.
- `startEasyGame(tester)` — opens new-game sheet, selects easy, taps start.

Cell finders use `ValueKey('cell-$index')` where index is 0–80 (row-major). Note digits render at `fontSize: 9`, which distinguishes them from number-pad text in assertions.

Test behavior at phone-sized constraints; the layout has responsive breakpoints at 360px width.

## Gotchas

- Mistake counter clamps at 3 (`clamp(0, 3)`) — not a bug, intentional cap.
- Undo history is capped at 80 snapshots; oldest entries are silently dropped.
- `design-review/` contains a static iOS prototype image for visual reference.

## Commits

Short, imperative, title-case: `Restore compact Sudoku layout`, `Build Sudoku Android app`.

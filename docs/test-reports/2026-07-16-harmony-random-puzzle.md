# 2026-07-16 HarmonyOS Random Puzzle Fix

## Scope

- Fixed HarmonyOS new-game puzzle selection so each difficulty no longer reuses the exact same board every time.
- Added Sudoku-preserving transformations for rows, columns, and digits while keeping the original three difficulty masks as the base difficulty contract.

## Verification

| Check | Command | Result |
|---|---|---|
| Whitespace | `git diff --check -- harmony/SudokuHarmony/entry/src/main/ets/data/Puzzles.ets` | Passed |
| HarmonyOS build | `DEVECO_CLI_SKIP_VERSION_CHECK=1 devecocli build --product default` | Passed: `BUILD SUCCESSFUL` |
| Flutter analysis | `/Users/noah/development/flutter/bin/flutter analyze` | Passed: `No issues found` |
| Flutter widget tests | `/Users/noah/development/flutter/bin/flutter test` | Passed: 6 tests |

## Simulator

- Not completed on this machine.
- `devecocli device list` failed because `hdc` is reported by macOS as not digitally signed.
- `devecocli emulator list` failed because the DevEco `Emulator` binary is reported by macOS as not digitally signed.

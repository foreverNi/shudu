# HarmonyOS Icon Depth Update

Date: 2026-07-14

## Scope

- Re-generated the HarmonyOS Sudoku app icon with the same 192x192 PNG specification.
- Kept the same Sudoku board content and added subtle dimensional edge treatment.
- Updated both layered icon source locations and the matching start window icon:
  - `harmony/SudokuHarmony/AppScope/resources/base/media/background.png`
  - `harmony/SudokuHarmony/AppScope/resources/base/media/foreground.png`
  - `harmony/SudokuHarmony/entry/src/main/resources/base/media/background.png`
  - `harmony/SudokuHarmony/entry/src/main/resources/base/media/foreground.png`
  - `harmony/SudokuHarmony/entry/src/main/resources/base/media/startIcon.png`

## Validation

| Check | Command | Result |
| --- | --- | --- |
| Image dimensions | `file harmony/SudokuHarmony/AppScope/resources/base/media/background.png harmony/SudokuHarmony/AppScope/resources/base/media/foreground.png harmony/SudokuHarmony/entry/src/main/resources/base/media/background.png harmony/SudokuHarmony/entry/src/main/resources/base/media/foreground.png harmony/SudokuHarmony/entry/src/main/resources/base/media/startIcon.png` | Passed: all PNG files are 192 x 192 RGB. |
| Resource consistency | `shasum -a 256 ...media/background.png ...media/foreground.png ...media/startIcon.png` | Passed: all five replacement icon files share SHA-256 `306a020aeef40ddf482336f6ec97708e28900367467fe9b059de0e208a199d7b`. |
| HarmonyOS build | `devecocli build --product default` | Passed: BUILD SUCCESSFUL. |

## Notes

- The image was generated with the built-in image generation tool from the previous flat Sudoku icon as the edit reference.
- Build output reported an existing `app_name` duplicate declaration warning between AppScope and entry string resources. This warning was not introduced by the icon replacement.

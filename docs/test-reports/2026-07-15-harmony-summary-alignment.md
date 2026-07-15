# 2026-07-15 HarmonyOS Summary Alignment

## Scope

- Moved the game, statistics, and achievements summary cards into a shared parent-level slot in `Index.ets`.
- Removed the statistics and achievements page-local overview cards so those pages only render their scrollable body content.
- Kept the shared summary metric item free of `@BuilderParam` after runtime validation showed that approach could crash on real devices.

## Verification

| Check | Command / Action | Result |
| --- | --- | --- |
| Diff whitespace | `git diff --check -- harmony/SudokuHarmony/entry/src/main/ets/pages/Index.ets harmony/SudokuHarmony/entry/src/main/ets/components/StatsPage.ets harmony/SudokuHarmony/entry/src/main/ets/components/AchievementsPage.ets harmony/SudokuHarmony/entry/src/main/ets/components/SummaryCard.ets` | Passed |
| HarmonyOS build | `DEVECO_CLI_SKIP_VERSION_CHECK=1 devecocli build --product default` | Passed: BUILD SUCCESSFUL |
| Emulator launch | `devecocli run --device 127.0.0.1:5555 --product default --skip-build` | Passed |
| Emulator tab smoke test | `hdc ... uiInput click` on statistics and achievements tab coordinates | Passed: app process remained alive |
| Runtime log check | `devecocli log --device 127.0.0.1:5555 --bundle-name com.noahni.sudokuharmony --from 15s --tail 120` | Passed: no ArkUI runtime exception observed |

## Notes

- Real-device install to `HUAWEI Mate X6 典藏版` succeeded, but launch validation was blocked because the device screen was locked.
- Existing local signing changes in `harmony/SudokuHarmony/build-profile.json5` were intentionally excluded from this change.

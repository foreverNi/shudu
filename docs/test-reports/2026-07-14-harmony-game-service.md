# Harmony Game Service Self-Check Fix

Date: 2026-07-14

## Scope

- Added Game Service metadata and network permission to `harmony/SudokuHarmony/entry/src/main/module.json5`.
- Added the Huawei Game Service login flow in `Index.ets`: `init` -> `unionLogin` -> `verifyLocalPlayer`.
- Added `playerChanged` handling, manual Huawei login retry, local failure gating, and default role reporting for this no-role Sudoku game.
- The Sudoku board and timer remain gated until `verifyLocalPlayer` succeeds.

## Source Basis

- Huawei Game Service Kit guide requires game startup to call `init`, then `unionLogin`, then `verifyLocalPlayer` before allowing the player into the game.
- Huawei API reference states Huawei-account compliance verification can pass `ThirdUserInfo.thirdOpenId` as an empty string and does not require `isRealName`, `isAdult`, or `ageRange`.
- Huawei checklist states missing `unionLogin` or `verifyLocalPlayer` will cause review rejection.

## Verification

- `devecocli build --product default`: passed after configuring the real AppGallery Connect IDs.
- `flutter analyze`: passed, no issues found.
- `flutter test`: passed, 6 tests.
- `devecocli device list`: blocked by local DevEco `hdc` signature error: `invalid signature (code or signature have been modified)`.
- `devecocli emulator list`: blocked by local DevEco `Emulator` signature error: `invalid signature (code or signature have been modified)`.

## Release Notes

- `client_id` and `app_id` are configured as `6917610740515299336`.
- Before submitting to Huawei review, ensure the release signing certificate fingerprint is configured in AppGallery Connect.

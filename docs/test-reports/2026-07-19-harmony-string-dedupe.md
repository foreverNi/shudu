# 2026-07-19 HarmonyOS String Resource Dedupe

## Scope

- Removed the duplicate `app_name` resource from the HarmonyOS entry module string resources.
- Kept the app-level `app_name` resource as the single declaration used by the app label.

## Verification

| Check | Command | Result |
|---|---|---|
| Flutter analysis | `flutter analyze` | Passed: `No issues found` |
| Flutter widget tests | `flutter test` | Passed: 6 tests |
| HarmonyOS build | `devecocli build` | Passed: `BUILD SUCCESSFUL`; duplicate `app_name` warning no longer appeared |

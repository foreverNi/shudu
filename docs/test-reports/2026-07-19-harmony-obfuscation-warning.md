# HarmonyOS Obfuscation Warning Fix Test Report

## Scope

- Enabled release obfuscation for the HarmonyOS entry module.
- Kept persisted statistics JSON keys stable during property obfuscation.

## Root Cause

Release builds referenced `entry/obfuscation-rules.txt`, but `entry/build-profile.json5` set `arkOptions.obfuscation.ruleOptions.enable` to `false`. DevEco therefore warned that obfuscation was not enabled for the current build process.

## Validation

- Command: `devecocli build --product default --build-mode release`
- Result: PASS
- Evidence: build completed successfully and no longer printed the warning:
  `If obfuscation is needed, enable obfuscation settings in this build process`

## Runtime Check

- Command: `devecocli device list`
- Result: PASS when run outside the Codex sandbox
- Device: `Mate X6` (`127.0.0.1:5555`)

Runtime launch was not repeated in this report because the requested fix targets a compile/package warning, and release build validation confirms the warning is resolved.

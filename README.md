# Life

Personal, offline-first Flutter app for tasks, daily wellbeing, training,
nutrition, and personal growth. Android is the primary target; web is useful
for preview and widget work.

## Current status

As of 2026-07-16, the repository is a functional internal alpha with the
planned offline product flows implemented:

- Phase 1 is mostly complete: app shell/navigation, Today, Tasks, equipment,
  local profile/settings, Drift/SQLite, local notifications, and privacy copy.
- Phase 2 is substantially implemented: strength logging, exercises, plans
  and text import, history/prefill, progression, rest timer, WODs, kettlebell,
  Zone 2 manual sessions, walking, mobility, and a Health Connect adapter for
  permission-gated steps and recorded heart-rate samples. Live sessions now
  summarize average heart rate and time in the 120–150 bpm target range;
  wearable-specific background sync remains device/provider dependent.
- Phase 3 has a manual nutrition foundation: meals, saved meals, Quick Log,
  portions, approved targets, weight logging, trend logic, and working photo,
  voice, and barcode capture paths that return to editable manual logging.
  Food recognition and barcode lookup now have replaceable service interfaces;
  the shipped provider is intentionally manual-only and offline.
- Phase 4 is substantially implemented. Growth protocols can now be added, persisted locally,
  paused/resumed, and logged as completed, minimum, or skipped without streak
  pressure. Lightweight Goals can be created and moved between active,
  paused, and completed. Fixed-day/flexible scheduling, optional reminders,
  review dates, and basic automatic contribution counts are now wired.
  Goal contribution links cover habit, training, nutrition, and cardio counts;
  richer custom linking remains optional follow-up work.
- Phase 5 production hardening is substantially implemented: photo/voice/barcode capture,
  versioned JSON export/restore, and password-protected AES-256-GCM export /
  restore are available from Settings. Restore validates the format/version,
  replaces all local tables inside one transaction, and preserves row ids.
  CI and local release compilation are checked in. A credentialed publish build
  and physical-device QA remain external release steps.

Latest verification: code generation completed cleanly, `flutter analyze` is
clean, and the full suite passes (63 tests). Fresh test APKs are available at
`build/app/outputs/flutter-apk/app-debug.apk` (debug, 235 MB) and
`build/app/outputs/flutter-apk/app-release.apk` (local release, 84 MB). Builds
emit only the known Flutter/Kotlin-plugin migration warnings.

The product brief and non-negotiable principles are in [docs/BRIEF.md](docs/BRIEF.md).
Keep manual entry working, avoid guilt mechanics, remain offline-first, and
keep AI optional and replaceable.

## Handoff rules

This folder is the shared source of truth for Claude and Codex. Before coding:

1. Read `AGENTS.md`, this README, and the relevant section of `docs/BRIEF.md`.
2. Check `git status` and preserve unrelated existing changes.
3. Keep feature logic testable in plain Dart files; keep persistence in the
   relevant repository and Drift schema.
4. After changing `database.dart`, regenerate `database.g.dart` before running
   analysis or tests.
5. Update this README's status and next-step notes when a phase materially
   changes. Record known blockers honestly.

## Architecture

- `lib/app/`: GoRouter shell, theme, and shared styling.
- `lib/core/database/`: Drift schema, generated code, and Riverpod provider.
- `lib/core/notifications/`: local task reminders and background-capable rest
  timer notifications.
- `lib/core/health/`: replaceable Health Connect gateway with manual fallback.
- `lib/core/backup/`: versioned JSON export/restore plus password-protected
  AES-256-GCM backup codec.
- `lib/features/<module>/`: Today, Tasks, Training, Nutrition, Growth,
  Equipment, and Settings.
- `test/`: pure-logic, repository, asset, database, and widget tests.
- `.github/workflows/flutter.yml`: shared CI quality gate for code generation,
  analysis, tests, a debug APK build, and downloadable APK artifact.
- [Privacy policy](docs/PRIVACY.md)
- [Release and device QA checklist](docs/RELEASE_CHECKLIST.md)

## UI/UX direction

The shared visual system is inspired by Nominal's current editorial product
language, without copying its brand assets or product copy:

- Ink/paper neutrals with an acid-lime accent replace the earlier terracotta
  palette.
- Headings and navigation use strong sans-serif hierarchy; compact section
  labels use tracking and muted contrast for an editorial rhythm.
- Cards use tighter 14px geometry, hairline borders, and restrained shadows.
- The five-tab shell uses a quiet selected surface, stronger selected weight,
  and larger touch-safe spacing.
- Life-specific principles remain unchanged: no red guilt states, no streak
  pressure, no mandatory AI, and manual entry always works.

UI tokens live in `lib/app/style.dart` and `lib/app/theme.dart`; shell behavior
lives in `lib/app/router.dart`. Claude should extend these tokens rather than
introducing per-screen colors or one-off card styles.

The app opens on Today. Main navigation order is Tasks, Today, Training,
Nutrition, Growth. There is no account, cloud sync, team functionality, or
mandatory AI.

## Build and test

The bundled Flutter SDK is at `C:\flutter`; if `flutter` is not on PATH, use
`C:\flutter\bin\flutter.bat`.

```powershell
C:\flutter\bin\flutter.bat pub get
C:\flutter\bin\dart.bat run build_runner build --delete-conflicting-outputs
C:\flutter\bin\flutter.bat analyze
C:\flutter\bin\flutter.bat test
C:\flutter\bin\flutter.bat build apk --debug
```

For a release APK, provide `LIFE_KEYSTORE_PATH`, `LIFE_KEYSTORE_PASSWORD`,
`LIFE_KEY_ALIAS`, and `LIFE_KEY_PASSWORD` in the build environment, then run
`C:\flutter\bin\flutter.bat build apk --release`. No signing credentials are
stored in the repository. Without those variables, local release builds use
the debug key as an explicit development fallback and are not publishable.

For web preview, use `run-web.bat` or the `life_app` launch configuration on
port 5180. Drift web support depends on the checked-in
`web/sqlite3.wasm` and `web/drift_worker.js` files.

Android debug builds require `JAVA_HOME` to point to the Android Studio JBR and
target Android API 26+ because Health Connect requires that minimum.
Do not treat an old APK under `build/` as validation of current source.

## Testing handoff

1. Install the debug APK for normal internal testing.
2. Follow [docs/RELEASE_CHECKLIST.md](docs/RELEASE_CHECKLIST.md) for device,
   Health Connect, notification, backup, accessibility, and offline checks.
3. Use a credentialed signing environment only when preparing a publishable
   release; the checked-in local release APK uses the documented development
   fallback.

## Useful files

- [Product brief](docs/BRIEF.md)
- [Project instructions](AGENTS.md)
- [Router](lib/app/router.dart)
- [Database schema](lib/core/database/database.dart)
- [Pure task logic](lib/features/tasks/task_logic.dart)
- [Pure training progression](lib/features/training/progression.dart)
- [Nutrition logic](lib/features/nutrition/nutrition_logic.dart)

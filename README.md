# Life

Personal, offline-first Flutter app for tasks, daily wellbeing, training,
nutrition, and personal growth. Android is the primary target; web is useful
for preview and widget work.

## Current status

As of 2026-07-16, the repository is a functional internal alpha:

- Phase 1 is mostly complete: app shell/navigation, Today, Tasks, equipment,
  local profile/settings, Drift/SQLite, local notifications, and privacy copy.
- Phase 2 is substantially implemented: strength logging, exercises, plans
  and text import, history/prefill, progression, rest timer, WODs, kettlebell,
  Zone 2 manual sessions, walking, mobility, and a Health Connect adapter for
  permission-gated steps and recorded heart-rate samples. Wearable-specific
  background sync and richer time-in-zone analytics remain.
- Phase 3 has a manual nutrition foundation: meals, saved meals, Quick Log,
  portions, approved targets, weight logging, and trend logic.
- Phase 4 is underway. Growth protocols can now be added, persisted locally,
  paused/resumed, and logged as completed, minimum, or skipped without streak
  pressure. Lightweight Goals can be created and moved between active,
  paused, and completed. Fixed-day/flexible scheduling, optional reminders,
  review dates, and basic automatic contribution counts are now wired.
  Richer contribution linking is still pending.
- Phase 5 production hardening is not complete: photo/voice/barcode capture,
  export, backup/restore, encryption, CI, release signing, and full production
  QA remain.

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
- `lib/features/<module>/`: Today, Tasks, Training, Nutrition, Growth,
  Equipment, and Settings.
- `test/`: pure-logic, repository, asset, database, and widget tests.

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

For web preview, use `run-web.bat` or the `life_app` launch configuration on
port 5180. Drift web support depends on the checked-in
`web/sqlite3.wasm` and `web/drift_worker.js` files.

Android debug builds require `JAVA_HOME` to point to the Android Studio JBR and
target Android API 26+ because Health Connect requires that minimum.
Do not treat an old APK under `build/` as validation of current source.

## Immediate next steps

1. Expand migration and widget coverage for Growth and Goals, then improve
   contribution links beyond the current kind-based counts.
2. Complete Health Connect background sync and richer training data flows.
3. Continue nutrition capture and production hardening in the order defined
   by `docs/BRIEF.md`.

## Useful files

- [Product brief](docs/BRIEF.md)
- [Project instructions](AGENTS.md)
- [Router](lib/app/router.dart)
- [Database schema](lib/core/database/database.dart)
- [Pure task logic](lib/features/tasks/task_logic.dart)
- [Pure training progression](lib/features/training/progression.dart)
- [Nutrition logic](lib/features/nutrition/nutrition_logic.dart)

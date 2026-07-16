# Life — Personal Development & Life Management App

Personal-use Flutter app (Android-first). Full product brief lives in `docs/BRIEF.md`.

## Core principles (never violate)
- Consistency over rigid plans; manual entry must always work.
- No guilt: no red warnings, overdue counts, streak pressure, scores, or pie charts.
- English by default; only specifically requested elements in Arabic (آية اليوم, عمل الخير اليوم).
- Offline-first, no account, no cloud. Photos are processed temporarily and deleted after analysis.
- AI is optional infrastructure behind replaceable interfaces, never required for core functions.

## Architecture
- Flutter stable (SDK at `C:\flutter`), Riverpod, GoRouter, Drift (SQLite).
- `lib/app/` — router (5-tab shell: Tasks, Today, Training, Nutrition, Growth; opens on **Today**), theme (calm teal-green, Material 3).
- `lib/core/database/` — Drift schema + provider. Codegen: `dart run build_runner build`.
- `lib/core/notifications/` — flutter_local_notifications + timezone (task reminders).
- `lib/features/<module>/` — one folder per module: today, tasks, training, nutrition, growth, equipment, settings.
- Pure logic lives in plain functions for testability (see `features/tasks/task_logic.dart`, `features/today/today_data.dart`).

## Key behaviors already implemented (Phase 1)
- Tasks: quick single-line entry; expandable details (notes, due, reminder, list, subtasks); dated by date, undated by creation, manual drag overrides (fractional `manualPosition`); completed → bottom, crossed out, auto-purged after 3 days, restorable by unchecking.
- Today: آية اليوم from `assets/data/ayah_of_day.json` (30 verses, tafsir adapted from التفسير الميسر — rotation is deterministic per day), عمل الخير suggestions + custom, optional 1–5 check-in (mood/energy/physical), Today's Focus (accept/replace/own/skip/done).
- Equipment: single global library seeded on DB creation; add/edit/remove; availability toggle.
- Training: reorderable tiles persisted in SharedPreferences; sub-modules are Phase 2.
- Settings (gear icon on Today): profile, notification toggle, privacy statements.

## Build & test
- `flutter analyze` must stay clean; `flutter test` (14 tests) must pass.
- Web preview: launch.json config `life_app` (port 5180). Drift on web needs `web/sqlite3.wasm` + `web/drift_worker.js` (version-matched to pubspec.lock).
- Android: requires `JAVA_HOME` = Android Studio JBR. Debug APK: `flutter build apk --debug`.
- Known quirk: on debug web builds the ayah card semantics don't appear in the DOM; it renders fine in widget tests and is not reproducible outside debug-web. Android is the target platform.

## Roadmap
Phase 2: strength logging, exercise library, plans, rest timers, progression engine, WOD engine, Zone 2 + Health Connect. Phase 3: nutrition. Phase 4: growth protocols + goals. Phase 5: hardening/release.

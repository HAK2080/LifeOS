# Life

Personal, offline-first Flutter app for tasks, daily wellbeing, training,
nutrition, and personal growth. Android is the primary target; web is useful
for preview and widget work.

## Current status

As of 2026-07-17, the repository is a functional internal alpha at Build 4 with the
planned offline product flows implemented:

- Phase 1 is mostly complete: app shell/navigation, Today, Tasks, equipment,
  local profile/settings, Drift/SQLite, local notifications, and privacy copy.
- Phase 2 is substantially implemented: strength logging, exercises, plans
  and text import, history/prefill, progression, rest timer, WODs, kettlebell,
  Zone 2 manual sessions, walking, mobility, and a Health Connect adapter for
  permission-gated steps and recorded heart-rate samples. Settings now exposes
  Health Connect availability, permission state, sync pause/resume, access
  request, system access management, disconnect, and last-sync status. Live sessions now
  summarize average heart rate and time in the 120–150 bpm target range;
  wearable-specific background sync remains device/provider dependent.
- Phase 3 now has an offline nutrition feature-parity layer: a first-class food
  library with servings, brands, barcodes, pinning, and search; recipe builder
  and per-serving macro calculation; date-navigable meal diary; saved meals,
  portions, approved targets, weight logging, trend logic, and editable photo,
  voice, and barcode capture paths. Food recognition and barcode lookup remain
  replaceable service interfaces. Barcode scans optionally query Open Food
  Facts, cache successful editable estimates locally, and fall back to manual
  entry whenever the network or product record is unavailable. Photo analysis
  remains manual-only in the shipped build.
- Phase 4 is substantially implemented. Growth protocols can now be added, persisted locally,
  paused/resumed, and logged as completed, minimum, or skipped without streak
  pressure. Lightweight Goals can be created and moved between active,
  paused, and completed. Fixed-day/flexible scheduling, optional reminders,
  review dates, and basic automatic contribution counts are now wired. The
  Wellness library is now seeded from versioned JSON and stores protocols,
  broad browsing categories, sources, habit logs, and reviews separately from
  the UI. It includes a day navigator, recent practice history, copyable source
  URLs, and category filtering inspired by the reviewed Longevity Master flow.
- Tasks now present user-created lists as visible Categories, with tasks nested
  under their category in the all-tasks view. Strength now has an original
  Progressive Overload feature-parity layer: 100+ exercises, searchable
  library, editable full-body/upper-lower/push-pull-legs starter templates,
  RIR-aware rep-range progression, rest timer, history, recent volume review,
  and personal records. It remains an optional method alongside manual,
  double, and coach progression modes.
- Today keeps Ayah of the Day date-aware and lets the user dismiss it for the
  current day. The unused Quick check-in card has been removed from the Today
  surface; its legacy table remains only for backwards-compatible local data.
- Nutrition includes a searchable local Food library and Recipes screen. This
  is an original Flutter implementation informed by FoodYou's feature model;
  the FoodYou GPL-3.0 source is not embedded in this project.
  Goal contribution links cover habit, training, nutrition, and cardio counts;
  richer custom linking remains optional follow-up work.
- Phase 5 production hardening is substantially implemented: photo/voice/barcode capture,
  versioned JSON export/restore, and password-protected AES-256-GCM export /
  restore are available from Settings. Restore validates the format/version,
  replaces all local tables inside one transaction, and preserves row ids.
  CI and local release compilation are checked in. A credentialed publish build
  and physical-device QA remain external release steps.
- Build 4 adds a responsive shell: phones retain the five-item bottom bar,
  while tablet and desktop widths use a navigation rail and constrained content
  area. Settings includes a privacy-safe diagnostics report and in-app release
  notes; first launch of a new build shows a dismissible What's new sheet.

Latest verification: code generation completed cleanly, `flutter analyze` is
clean, and the full suite passes (73 tests). Build 4 Android and web artifact
verification completed on 2026-07-17: debug APK 189,382,041 bytes (SHA-256
`A758548D6A8BD627FA12F7CC23E85FFC9F81428DCF59A94FA16DFBA0FF009F81`),
local release APK 86,024,606 bytes (SHA-256
`C0BDA9210F1713230920688376CD65DB3C4356A5C971385D847764E38577BB41`),
and release web bundle 4,168,782 bytes. The local preview returned HTTP 200 and
contained the Build 4 marker. The local release APK uses the documented debug
signing fallback; a credentialed publish build and physical-device QA remain
explicit external steps.

The product brief and non-negotiable principles are in [docs/BRIEF.md](docs/BRIEF.md).
The Wellness schema, safety policy, seed shape, and implementation plan are in
[docs/WELLNESS_DESIGN.md](docs/WELLNESS_DESIGN.md).
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
- `lib/app/release_notes.dart`: per-build in-app change summary and first-run gate.
- `lib/features/settings/diagnostics_screen.dart`: local, content-free support report.
- `.github/workflows/flutter.yml`: shared CI quality gate for code generation,
  analysis, tests, a debug APK build, and downloadable APK artifact.
- [Privacy policy](docs/PRIVACY.md)
- [Release and device QA checklist](docs/RELEASE_CHECKLIST.md)
- [Wellness design and safety policy](docs/WELLNESS_DESIGN.md)

## UI/UX direction

The shared visual system is based on the supplied archive
`C:\Users\aeroh\Downloads\inspired by this website https_www.nominal.so_change the UI  ux OF THE appl.zip`,
which contained replacement versions of `lib/app/style.dart`,
`lib/app/theme.dart`, and `lib/app/router.dart`. It follows Nominal's current
editorial product language without copying branded assets or product copy:

- Ink/paper neutrals with a mint signal and deep green contrast replace the
  earlier terracotta palette.
- Light-mode primary actions use ink; dark-mode primary actions use mint, with
  explicit high-contrast foregrounds.
- Headings and navigation use strong sans-serif hierarchy; compact section
  labels use uppercase tracking and muted contrast.
- Cards are flat with 10px geometry and hairline borders; buttons and chips use
  stadium shapes for a precise, product-like control language.
- The five-tab shell uses a quiet selected surface, stronger selected weight,
  and light/dark-aware selected colors. It changes to a NavigationRail at 900
  logical pixels and caps primary content at 1100 pixels on wide screens.
- Life-specific principles remain unchanged: no red guilt states, no streak
  pressure, no mandatory AI, and manual entry always works.

UI tokens live in `lib/app/style.dart` and `lib/app/theme.dart`; shell behavior
lives in `lib/app/router.dart`. Claude should extend these tokens rather than
introducing per-screen colors or one-off card styles.

The app opens on Today. Main navigation order is Tasks, Today, Training,
Nutrition, Growth. There is no account, cloud sync, team functionality, or
mandatory AI.

## External project integration boundary

The referenced projects are capability references, not runtime dependencies.
Their original applications are not copied into this Flutter app because they
use different stacks and have different distribution terms: Progressive
Overload App is React/Node, FoodYou is Kotlin/Compose under GPL-3.0, and
Longevity Master is SwiftUI/iOS under CC BY-NC 4.0. LifeOS ports the useful
offline behaviors into its own Dart/Riverpod/Drift modules with local data and
attribution links. The ported capabilities are visible in the app: Training →
Strength → Progressive overload now reports the live exercise/plan libraries,
and Nutrition shows the local food and recipe libraries directly on its main
screen.

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

For a stable web preview, run `run-web.bat`, then open
`http://127.0.0.1:5180`. It builds the release web bundle and serves it with a
plain local HTTP server, avoiding the Flutter debug browser bridge. Drift web
support depends on the checked-in `web/sqlite3.wasm` and `web/drift_worker.js`
files. Stop the server with `Ctrl+C`.

Android debug builds require `JAVA_HOME` to point to the Android Studio JBR and
target Android API 26+ because Health Connect requires that minimum.

### Build identity

The current installable build is `Version 1.0.0 / Build 4`. `BUILD 4` is shown
in the Today app-bar and the full identity is visible in Settings → App on the
device. Increment the `+N` build number in
`pubspec.yaml` and update `lib/app/build_info.dart` together for every new APK;
the build number is what distinguishes a newly installed APK from an older
one.
Do not treat an old APK under `build/` as validation of current source.

### Build 4 implementation notes for Claude

- Health Connect orchestration is in `lib/core/health/health_service.dart`.
  Android system-settings navigation is bridged through the
  `lifeos/health_connect` channel in `MainActivity.kt`; manual cardio entry is
  still the fallback on unsupported devices and web.
- Barcode networking is isolated behind `BarcodeProductService` in
  `lib/features/nutrition/food_services.dart`. Only a user-scanned barcode is
  sent to Open Food Facts, successful results are cached in SharedPreferences,
  and all returned nutrition fields remain editable before saving.
- New settings routes are `/settings/health-connect`, `/settings/diagnostics`,
  and `/settings/release-notes`. Keep these nested beneath `/settings`.
- Release-note display state is stored under `last_seen_release_build`. Add a
  new release-note list and bump both `pubspec.yaml` and `build_info.dart` for
  the next installable build.

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
- [Strength content and volume heuristics](lib/features/training/strength/strength_content.dart)
- [Nutrition logic](lib/features/nutrition/nutrition_logic.dart)
- [Nutrition repository](lib/features/nutrition/nutrition_repository.dart)

## External project references

- [Progressive Overload App](https://github.com/simmahon/progressive-overload-app)
  is used as a public reference for the feature set and optional RP-style
  method. Life develops its own offline Flutter implementation using the
  LifeOS architecture; the external React/Node source, branding, and assets
  are not embedded.
- [FoodYou](https://github.com/maksimowiczm/FoodYou) is GPL-3.0 licensed and is
  implemented in Kotlin/Compose. Its local food-diary, food-library, and
  recipe feature model informed Life's original Flutter feature-parity layer;
  no FoodYou source code, branding, or assets are copied.
- [Longevity Master](https://github.com/banghuazhao/longevity-master) is a
  CC BY-NC 4.0 SwiftUI/SQLite habit tracker. Its category gallery, flexible
  scheduling, reminder, calendar/history, and local relational-data ideas were
  reviewed; LifeOS keeps its own offline Flutter implementation and does not
  copy its source, content, branding, scoring, streaks, or achievements.

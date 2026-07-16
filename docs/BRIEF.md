# Build Brief: Personal Development & Life Management App

## Product purpose
A personal-use app that helps the user:
- Track, monitor and improve their life
- Build lasting habits
- Manage training, nutrition, health and personal growth
- Capture and complete tasks without complicated organisation
- Start activities easily and maintain consistency over time

Functional first, not AI-first or chat-first. AI only where it materially improves coaching, analysis or data entry.

## Core principles
- Consistency is the primary success metric.
- Flexible use is more important than rigid plans.
- Manual entry must always work.
- Avoid guilt, red warnings, overdue dashboards and excessive charts.
- Do not force the user to organise everything neatly.
- The app should feel positive, calm and useful.
- English is the default language; only specifically requested elements appear in Arabic.
- Personal use only. No team accounts, permissions or collaboration.
- Offline-first.
- Photos are processed temporarily and deleted after analysis.

## Main navigation
Order: Tasks, Today, Training, Nutrition, Growth. The app always opens on Today.

## 1. Today
Start the day positively without pressure. In order:

### آية اليوم
- One Qur'an verse per day, Arabic text, brief Arabic tafsir from trusted Sunni sources, optional source view.

### عمل الخير اليوم
- Prompt: ما العمل الصالح الذي تريد أن تفعله اليوم؟
- Rotating Arabic suggestions: صدقة ولو بسيطة، صلة رحم، مساعدة شخص، قراءة شيء من القرآن، الدعاء لشخص، إدخال السرور على شخص
- User can add their own good deed and mark it complete.

### Daily check-in
Three optional quick inputs: Mood, Energy, Physical condition.

### Today's Focus
- Suggest one useful action; accept, replace, choose manually or skip.
- Keep visible as completed until the next day.

Do not show: task lists, overdue counts, pie charts, scores, red warnings, long recommendations.

## 2. Tasks
Quick capture without forced organisation.
- One combined task screen; single-line quick entry; expand only when needed.
- Expandable fields: notes, reminder, due date, image/file attachment, subtasks, optional list/category.
- Optional lists (Personal, Work, Business, custom); tasks need not belong to a list.
- Ordering: dated by date; undated in creation order; automatic ordering allowed; manual drag-and-drop must override.
- Completion: move to bottom, crossed out for three days, auto-disappear, immediate removal allowed, restorable.
- No projects, milestones, teams, assignees, workflows, or separate overdue page. Subtasks never required.

## 3. Training
Main page title: "What do you feel like doing today?" — customizable, reorderable tiles:
Strength/Hypertrophy, WOD/Conditioning, Kettlebell, Zone 2, Walking, Mobility/Recovery.

### Global equipment library
One global list, added manually or from photos (photos deleted after extraction), editable, used across all training features. Never ask which gym/location. Known equipment: Smith machine/functional trainer, adjustable bench, dumbbells, kettlebells, straight barbell, EZ-curl bar, trap bar, plates, cable attachments, resistance bands, battle ropes, rings, pull-up rig, climbing rope, plyometric boxes, curved treadmill, air rower, SkiErg, stationary/air bike.

### Strength / Hypertrophy
- No auto-built workouts unless coaching enabled.
- Options: Start Empty Workout, Choose Exercises, Continue Training Plan, Create/Edit Training Plan, Exercise History.
- Plans: manual, progress by sequence not calendar, no missed/overdue workouts, edit/skip/abandon anytime; import from text/CSV/spreadsheet/PDF/temporary screenshots. No scraping proprietary libraries.
- Logging per exercise: name, sets, reps, weight, optional rep range, RIR/RPE, notes, pain, rest between sets/exercises. Show previous performance beside each set; prefill previous weight/reps; all editable.
- Rest timer: global/plan/exercise levels, between-set and between-exercise durations, sound, vibration, pause, skip, add time, disable. Must work with screen locked/background.
- Progression modes per plan/exercise: manual, double progression, coach-assisted (more reps/weight, same, lower, reduced sets, deload) using rep completion, rep range, RIR/RPE, recent performance, weight increments, pain, recovery, technique. Recommendations optional, editable, transparent, briefly explained. Principles inspired by RP Strength and JuggernautAI, implemented independently. No forced splits, exercise selection, deloads, or templates.

### WOD / Conditioning
Not a random slot machine. Options: Coach Suggestion, Choose Equipment, Browse Existing WODs, Enter Manually.
- Coach-designed uses: readiness, duration, difficulty, equipment, level, knee limitations, recent training, stimulus, work:rest, movement balance.
- Every generated WOD includes: purpose, difficulty, stimulus, movements, reps/time, scaling, substitutions, expected duration.
- Equipment-led WODs from chosen gear. Library filtered by level/duration/equipment/stimulus/restrictions. Track completed, avoid exact repeats. No scraping restricted databases.

### Kettlebell
Strength, conditioning, complexes, EMOM, AMRAP, technique, custom — respecting equipment, difficulty, duration, restrictions.

### Zone 2
Start Session, Weekly Target, History. Bike/rower/treadmill/SkiErg/walking/custom. Remember last activity+duration. Live HR, target range, total time, time-in-zone, below/above alerts, pause/extend/finish. Data: Amazfit → Zepp → Health Connect → App; manual always available. Optional machine-console photo analysis (distance, time, pace, resistance, incline, cadence, stroke rate) — image deleted after extraction. Track weekly Zone 2 minutes across activities.

### Walking
Steps from Health Connect, manual entry, optional daily target, walking/treadmill/rucking, gentle shortfall display, notifications only when enabled.

### Mobility / Recovery
Free session, body-area selection, custom routines, stretching, mobility, foam rolling, breathing, recovery. Track consistency and time, not performance scores.

## 4. Nutrition
Replace MacroFactor with lower-friction, less obsessive tracking.
- Main: Log Meal, Quick Log, Saved Meals, Today's Intake, Goals, Progress.
- Logging: photo, voice, text, barcode, manual, previous meal.
- Photo workflow: analyse → estimate → user edits/confirms → log → delete photo.
- Saved meals: reuse, pin, hide, rename, edit, portion −20/−10/same/+10/+20%. Frequent meals in Quick Log.
- Estimates show: calories, protein, carbs, fat, confidence, ingredients, portions — all editable, clearly approximate.
- Targets calculated from weight, height, age, activity, goal, weight trend, body-fat goal, logging consistency. User can override. Changes are suggested, never automatic, require approval, prefer ≥2 weeks of data. Never increase targets from wearable calorie estimates.
- Progress: optional weight, waist, body-fat estimate, progress photos (analysed and deleted — store only estimate, date, trend, confidence), review weekly/monthly/custom/disabled.

## 5. Growth
Main question: "What do you want to improve?" Tiles: Sleep, Memory, Focus, Stress, Breathing, Sauna, Cold exposure, Red-light therapy, Reading, Mobility, Mental wellbeing, Custom habit, Custom skill.

Each habit/skill: name, purpose, explanation, practical protocol, frequency, duration, minimum version, reminder, notes, evidence level, safety notes, source/expert, review period.

Scheduling: fixed days, flexible weekly target, both, or none. Completion: completed / minimum version / skipped. No streak pressure.

Habit journey: learn basics → set protocol → schedule reminders → track → review after suggested period → keep/adjust/pause/stop.

Protocol research from respected sources (Huberman, Attia, Galpin, Walker, Patrick, Norton, Clear, Fogg, others). Label: strong/moderate/limited evidence, experimental, personal preference. Include safety warnings.

## Goals (outside main navigation)
Name, optional target, optional deadline, active/paused/completed. Training, nutrition, habits and tasks auto-contribute where the relationship is obvious; no forced manual linking; auto-links removable. No complicated dashboards.

## Shared behaviour
Auto-connect actions to the broader picture (Zone 2 → cardio goal, meal logs → nutrition consistency, weight trend → body-composition, sauna → recovery habit, training → fitness consistency). Never require manual classification.

## Technical direction
Flutter, Android first, clean modular architecture, offline-first, SQLite/Drift, Riverpod, GoRouter, Health Connect, background timers/notifications, local file processing, replaceable interfaces for AI/barcode/food DB/cloud sync, no mandatory account, optional encrypted backup later.

Modules: Today, Tasks, Training, Nutrition, Growth, Goals, Equipment, Health Connect, Notifications, Media analysis, Local database, Settings/privacy.

## AI usage
Optional infrastructure, not the product: meal estimation, equipment recognition, body-composition estimate, WOD generation, protocol summarisation, progression explanations, natural-language task entry. Core functions work without AI.

## Build order
1. **Phase 1 — runnable foundation**: app shell/nav, local profile, Today, Tasks, equipment library, module shells, local DB, notifications, privacy settings, tests.
2. **Phase 2 — training**: strength logging, exercise library, plans, history/prefill, rest timers, progression engine, WOD engine, Zone 2, Health Connect.
3. **Phase 3 — nutrition**: manual logging, saved meals, Quick Log, targets, trend system, barcode, photo/text/voice estimation.
4. **Phase 4 — growth & goals**: habit protocols, reminders, completion states, reviews, lightweight goals, automatic contribution links.
5. **Phase 5 — production hardening**: error handling, accessibility, background behaviour, data export, backup/restore, encryption, CI/CD, Android release build, privacy policy, full test suite.

## Non-goals
No news module, projects, team accounts, social feed, leaderboards, complicated charts, guilt-based reminders, chat-first interface, forced plans, mandatory AI, mandatory cloud account.

## Final product rule
Every feature must help the user start, continue and improve without turning life management into another job.

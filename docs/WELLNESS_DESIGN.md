# Wellness module design

## Scope

The Growth tab becomes an offline-first Wellness library. Protocols are immutable seed content; habits are user-owned copies that can be scheduled, logged, reviewed, adjusted, paused, or stopped.

## Schema

| Table | Purpose |
| --- | --- |
| `wellness_protocols` | Versioned, curated protocol content kept separate from UI and user changes, including `category` and broad `category_group` values for browsing. |
| `wellness_sources` | Source records with title, publisher, URL, and source kind. |
| `wellness_protocol_sources` | Many-to-many link between protocols and sources. |
| `habits` | User-owned protocol or custom habit, including schedule and status. Existing rows remain valid. |
| `habit_logs` | One daily state per habit: `completed`, `minimum`, or `skipped`. |
| `habit_reviews` | Review date, outcome (`keep`, `adjust`, `pause`, `stop`), whether it helped, and notes. |

Seed JSON is versioned by filename (`wellness_protocols_v1.json`) and each record includes its own version. New seed versions add or revise protocols without overwriting user habits.

## UI flow

1. Growth → browse the protocol gallery by broad category: Diet, Exercise, Sleep, Preventive Health, or Mental Health.
2. Open a protocol and review the specific practice category.
3. Read purpose, instructions, minimum/standard versions, evidence, safety notes, and sources.
4. Add as a habit.
5. Customize frequency, duration, minimum version, and reminders.
6. Choose a day and log completed, minimum completed, or skipped without streaks or penalties.
7. Open a practice history to review recent states, then record whether it helped and choose keep, adjust, pause, or stop.

## Safety policy

- Content is educational and written originally; it does not diagnose, treat, or replace professional care.
- Safety notes appear before adding a protocol and remain available from the habit detail view.
- Sauna, cold exposure, caffeine, strength, and Zone 2 protocols include conservative entry points and stop conditions.
- No protocol is required. Minimum versions are intentionally small and skipping has no negative state.
- Suggestions never change nutrition targets, training load, reminders, or health data automatically.
- External services remain optional. The database and core logging work offline.

## Example JSON

```json
{
  "schema_version": 1,
  "protocols": [
    {
      "id": "morning-light",
      "version": 1,
      "category": "Morning light",
      "category_group": "Sleep",
      "title": "Morning light",
      "purpose": "Give the body clock a consistent daytime signal.",
      "instructions": "Spend time outdoors soon after waking; do not stare at the sun.",
      "minimum_version": "Step outside for 5 minutes.",
      "standard_version": "Spend 10–20 minutes outdoors within about an hour of waking.",
      "frequency": "Most days",
      "duration_minutes": 15,
      "best_time": "Morning",
      "evidence_level": "Moderate",
      "safety_notes": "Use ordinary daylight, never direct sun-gazing. Follow local advice for extreme heat or poor air quality.",
      "review_period_days": 28,
      "sources": [{"id": "sleep-foundation-circadian", "title": "Circadian rhythm and light", "publisher": "Sleep Foundation", "url": "https://www.sleepfoundation.org/circadian-rhythm"}]
    }
  ]
}
```

## Implementation plan

1. Add Drift tables and migrate the existing database without deleting user data.
2. Load the versioned seed file and create protocol/source links on database creation and migration.
3. Replace hardcoded Growth protocol cards with database-backed browsing and add review actions.
4. Add the optional RP-style progressive-overload method to Strength using the existing RIR and progression engine.
5. Group Tasks visually under their Categories while retaining manual entry and filtering.
6. Make Ayah of the Day date-aware and dismissible; remove the unused Today check-in card.
7. Expand Nutrition with an original local food diary flow informed by FoodYou’s feature set: saved foods, recipes, daily logs, targets, and optional lookup boundaries.
8. Add tests, update the README and privacy notes, run code generation, analysis, tests, and an APK build.

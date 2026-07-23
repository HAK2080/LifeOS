// Original strength content used by the LifeOS implementation.

class StarterTemplate {
  const StarterTemplate({
    required this.name,
    required this.description,
    required this.workouts,
    this.notes,
  });

  final String name;
  final String description;
  final List<TemplateWorkout> workouts;
  final String? notes;
}

class TemplateWorkout {
  const TemplateWorkout(this.name, this.exercises);

  final String name;
  final List<TemplateExercise> exercises;
}

class TemplateExercise {
  const TemplateExercise(
    this.name, {
    this.sets = 3,
    this.repMin = 6,
    this.repMax = 12,
  });

  final String name;
  final int sets;
  final int repMin;
  final int repMax;
}

const starterTemplates = <StarterTemplate>[
  StarterTemplate(
    name: 'Full body · 3 days',
    description:
        'A flexible rotation of squat, push, pull, hinge, and carry patterns.',
    workouts: [
      TemplateWorkout('Full Body A', [
        TemplateExercise('Back Squat', sets: 3, repMin: 5, repMax: 8),
        TemplateExercise('Dumbbell Bench Press'),
        TemplateExercise('Barbell Row'),
        TemplateExercise('Romanian Deadlift', sets: 2),
      ]),
      TemplateWorkout('Full Body B', [
        TemplateExercise('Trap Bar Deadlift', sets: 3, repMin: 4, repMax: 6),
        TemplateExercise('Overhead Press'),
        TemplateExercise('Pull-Up', sets: 3, repMin: 5, repMax: 10),
        TemplateExercise('Bulgarian Split Squat', sets: 2),
      ]),
      TemplateWorkout('Full Body C', [
        TemplateExercise('Front Squat', sets: 3, repMin: 6, repMax: 10),
        TemplateExercise('Incline Dumbbell Press'),
        TemplateExercise('Seated Cable Row'),
        TemplateExercise('Hip Thrust', sets: 2, repMin: 8, repMax: 12),
      ]),
    ],
  ),
  StarterTemplate(
    name: 'Upper / lower · 4 days',
    description: 'Two upper and two lower sessions with moderate rep ranges.',
    workouts: [
      TemplateWorkout('Upper A', [
        TemplateExercise('Dumbbell Bench Press', sets: 4),
        TemplateExercise('Barbell Row', sets: 4),
        TemplateExercise('Dumbbell Shoulder Press'),
        TemplateExercise('Lat Pulldown'),
      ]),
      TemplateWorkout('Lower A', [
        TemplateExercise('Back Squat', sets: 4, repMin: 5, repMax: 8),
        TemplateExercise('Romanian Deadlift', sets: 3),
        TemplateExercise('Walking Lunge'),
        TemplateExercise('Calf Raise'),
      ]),
      TemplateWorkout('Upper B', [
        TemplateExercise('Incline Dumbbell Press', sets: 4),
        TemplateExercise('Pull-Up', sets: 4, repMin: 5, repMax: 10),
        TemplateExercise('Cable Fly'),
        TemplateExercise('Seated Cable Row'),
      ]),
      TemplateWorkout('Lower B', [
        TemplateExercise('Trap Bar Deadlift', sets: 3, repMin: 4, repMax: 6),
        TemplateExercise('Bulgarian Split Squat', sets: 3),
        TemplateExercise('Hip Thrust'),
        TemplateExercise('Leg Extension (band)'),
      ]),
    ],
  ),
  StarterTemplate(
    name: 'Push / pull / legs',
    description:
        'A three-session sequence that can be repeated according to recovery.',
    workouts: [
      TemplateWorkout('Push', [
        TemplateExercise('Smith Machine Bench Press', sets: 4),
        TemplateExercise('Overhead Press', sets: 3, repMin: 6, repMax: 10),
        TemplateExercise('Lateral Raise', sets: 3, repMin: 10, repMax: 15),
        TemplateExercise('Triceps Pushdown', sets: 3, repMin: 10, repMax: 15),
      ]),
      TemplateWorkout('Pull', [
        TemplateExercise('Pull-Up', sets: 4, repMin: 5, repMax: 10),
        TemplateExercise('Dumbbell Row', sets: 3),
        TemplateExercise('Face Pull', sets: 3, repMin: 10, repMax: 15),
        TemplateExercise('Hammer Curl', sets: 3, repMin: 8, repMax: 12),
      ]),
      TemplateWorkout('Legs', [
        TemplateExercise('Back Squat', sets: 4, repMin: 5, repMax: 8),
        TemplateExercise('Romanian Deadlift', sets: 3),
        TemplateExercise('Walking Lunge', sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Calf Raise', sets: 3, repMin: 10, repMax: 15),
      ]),
    ],
  ),
  StarterTemplate(
    name: 'PHUL · public program',
    description:
        'Brandon Campbell’s free 4-day Power Hypertrophy Upper Lower routine.',
    notes: '''
SOURCE
Boostcamp PHUL and the publicly published PHUL routine by Brandon Campbell.

SCHEDULE
Upper Power → Lower Power → rest → Upper Hypertrophy → Lower Hypertrophy.

PROGRESSION
Start with the minimum set count shown. The original allows an optional fourth set on most 3-set movements and an optional third set on 2-set movements. When every set reaches the top of its rep range with clean form, add a small amount of weight, commonly about 2.5 kg.

EQUIPMENT MAPPING
The canonical routine uses barbell bench press, barbell squat, leg press, machine leg curl, and standard leg extension. This LifeOS copy maps those to your available Smith machine, hack-squat pattern, and band leg movements. The split, order, set ranges, rep ranges, and progression remain the published PHUL structure.

SOURCE URL
https://www.boostcamp.app/coaches/brandon-campbell/phul-4-day-split
''',
    workouts: [
      TemplateWorkout('Upper Power', [
        TemplateExercise('Smith Machine Bench Press',
            sets: 3, repMin: 3, repMax: 5),
        TemplateExercise('Barbell Row', sets: 3, repMin: 3, repMax: 5),
        TemplateExercise('Incline Dumbbell Press',
            sets: 3, repMin: 6, repMax: 10),
        TemplateExercise('Lat Pulldown', sets: 3, repMin: 6, repMax: 10),
        TemplateExercise('Overhead Press', sets: 2, repMin: 5, repMax: 8),
        TemplateExercise('Barbell Curl', sets: 2, repMin: 6, repMax: 10),
        TemplateExercise('Skull Crusher', sets: 2, repMin: 8, repMax: 12),
      ]),
      TemplateWorkout('Lower Power', [
        TemplateExercise('Smith Machine Squat',
            sets: 3, repMin: 3, repMax: 5),
        TemplateExercise('Barbell Deadlift',
            sets: 3, repMin: 3, repMax: 5),
        TemplateExercise('Bulgarian Split Squat',
            sets: 3, repMin: 6, repMax: 10),
        TemplateExercise('Lying Leg Curl (band)',
            sets: 3, repMin: 6, repMax: 10),
        TemplateExercise('Standing Calf Raise',
            sets: 3, repMin: 6, repMax: 10),
      ]),
      TemplateWorkout('Upper Hypertrophy', [
        TemplateExercise('Smith Machine Incline Press',
            sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Seated Cable Row',
            sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Dumbbell Fly',
            sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Dumbbell Row',
            sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Lateral Raise',
            sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Dumbbell Curl',
            sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Triceps Pushdown',
            sets: 3, repMin: 10, repMax: 15),
      ]),
      TemplateWorkout('Lower Hypertrophy', [
        TemplateExercise('Walking Lunge',
            sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Hack Squat',
            sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Leg Extension (band)',
            sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Lying Leg Curl (band)',
            sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Standing Calf Raise',
            sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Seated Calf Raise',
            sets: 3, repMin: 8, repMax: 12),
      ]),
    ],
  ),
  StarterTemplate(
    name: 'Reddit PPL · public program',
    description:
        'Metallicadpa’s free 6-day linear-progression Push/Pull/Legs routine.',
    notes: '''
SOURCE
The canonical Reddit PPL by u/Metallicadpa, published free through r/Fitness and Boostcamp.

ROTATION
Pull A → Push A → Legs A → Pull B → Push B → Legs B, with one rest day placed where recovery requires it.

MAIN-LIFT PROGRESSION
Add 2.5 kg to upper-body compounds and squats after successful sessions. Add 5 kg to deadlifts. The final main-lift set is AMRAP while leaving a technically sound rep in reserve. If a main lift fails, repeat the load. After repeated failure, reduce the training load and rebuild.

ACCESSORY PROGRESSION
Use double progression: remain inside the prescribed rep range, then add a small amount of weight once all sets reach the top cleanly.

EQUIPMENT MAPPING
Barbell bench and squat are mapped to your Smith machine. The remaining structure is the canonical public routine.

SOURCE URL
https://www.boostcamp.app/coaches/r-fitness/reddit-ppl
''',
    workouts: [
      TemplateWorkout('Pull A · Deadlift', [
        TemplateExercise('Barbell Deadlift', sets: 1, repMin: 5, repMax: 5),
        TemplateExercise('Lat Pulldown', sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Chest-Supported Row',
            sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Face Pull', sets: 5, repMin: 15, repMax: 20),
        TemplateExercise('Hammer Curl', sets: 4, repMin: 8, repMax: 12),
        TemplateExercise('Dumbbell Curl', sets: 4, repMin: 8, repMax: 12),
      ]),
      TemplateWorkout('Push A · Bench', [
        TemplateExercise('Smith Machine Bench Press',
            sets: 5, repMin: 5, repMax: 5),
        TemplateExercise('Overhead Press',
            sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Incline Dumbbell Press',
            sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Triceps Pushdown',
            sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Lateral Raise',
            sets: 6, repMin: 15, repMax: 20),
        TemplateExercise('Overhead Triceps Extension',
            sets: 3, repMin: 8, repMax: 12),
      ]),
      TemplateWorkout('Legs A · Squat', [
        TemplateExercise('Smith Machine Squat',
            sets: 3, repMin: 5, repMax: 5),
        TemplateExercise('Romanian Deadlift',
            sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Hack Squat', sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Lying Leg Curl (band)',
            sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Seated Calf Raise',
            sets: 5, repMin: 8, repMax: 12),
      ]),
      TemplateWorkout('Pull B · Row', [
        TemplateExercise('Barbell Row', sets: 5, repMin: 5, repMax: 5),
        TemplateExercise('Lat Pulldown', sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Chest-Supported Row',
            sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Face Pull', sets: 5, repMin: 15, repMax: 20),
        TemplateExercise('Hammer Curl', sets: 4, repMin: 8, repMax: 12),
        TemplateExercise('Dumbbell Curl', sets: 4, repMin: 8, repMax: 12),
      ]),
      TemplateWorkout('Push B · Overhead press', [
        TemplateExercise('Overhead Press',
            sets: 5, repMin: 5, repMax: 5),
        TemplateExercise('Smith Machine Bench Press',
            sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Incline Dumbbell Press',
            sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Triceps Pushdown',
            sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Lateral Raise',
            sets: 6, repMin: 15, repMax: 20),
        TemplateExercise('Overhead Triceps Extension',
            sets: 3, repMin: 8, repMax: 12),
      ]),
      TemplateWorkout('Legs B · Squat', [
        TemplateExercise('Smith Machine Squat',
            sets: 3, repMin: 5, repMax: 5),
        TemplateExercise('Romanian Deadlift',
            sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Hack Squat', sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Lying Leg Curl (band)',
            sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Seated Calf Raise',
            sets: 5, repMin: 8, repMax: 12),
      ]),
    ],
  ),
  StarterTemplate(
    name: 'GZCLP · public program',
    description:
        'Cody Lefever’s free four-workout novice linear-progression program.',
    notes: '''
SOURCE
GZCLP by Cody Lefever, published free on Swole at Every Height.

ORDER
Run A1 → B1 → A2 → B2 in sequence. A common three-day schedule simply continues the rotation across weeks.

T1
Five sets of 3, final set AMRAP: 3×5+. Add weight each time the lift returns. After missing the 15-rep base volume, use 2×6+. After missing 12 total reps, use 1×10+. After missing 10 singles, rest 2–3 days, test a new 5RM, and restart 3×5+ at 85% of that 5RM.

T2
3×10. After failing 30 total reps, move to 3×8; after failing 24, move to 3×6. After failing 18, restart 3×10 slightly heavier than the prior cycle, no more than about 9 kg heavier.

T3
3×15 with the final set AMRAP. Add weight when the final set reaches 25 reps.

LOAD INCREASES
Cody recommends no more than roughly 2.5–4.5 kg per successful workout for novice and early-intermediate lifters.

EQUIPMENT MAPPING
Barbell bench and squat are mapped to your Smith machine. Tier structure and progression are unchanged.

SOURCE URL
https://swoleateveryheight.blogspot.com/2016/02/gzcl-applications-adaptations.html
''',
    workouts: [
      TemplateWorkout('A1', [
        TemplateExercise('Smith Machine Squat',
            sets: 5, repMin: 3, repMax: 3),
        TemplateExercise('Smith Machine Bench Press',
            sets: 3, repMin: 10, repMax: 10),
        TemplateExercise('Lat Pulldown',
            sets: 3, repMin: 15, repMax: 25),
      ]),
      TemplateWorkout('B1', [
        TemplateExercise('Overhead Press',
            sets: 5, repMin: 3, repMax: 3),
        TemplateExercise('Barbell Deadlift',
            sets: 3, repMin: 10, repMax: 10),
        TemplateExercise('Dumbbell Row',
            sets: 3, repMin: 15, repMax: 25),
      ]),
      TemplateWorkout('A2', [
        TemplateExercise('Smith Machine Bench Press',
            sets: 5, repMin: 3, repMax: 3),
        TemplateExercise('Smith Machine Squat',
            sets: 3, repMin: 10, repMax: 10),
        TemplateExercise('Lat Pulldown',
            sets: 3, repMin: 15, repMax: 25),
      ]),
      TemplateWorkout('B2', [
        TemplateExercise('Barbell Deadlift',
            sets: 5, repMin: 3, repMax: 3),
        TemplateExercise('Overhead Press',
            sets: 3, repMin: 10, repMax: 10),
        TemplateExercise('Dumbbell Row',
            sets: 3, repMin: 15, repMax: 25),
      ]),
    ],
  ),
  StarterTemplate(
    name: 'nSuns 4-day · public program',
    description:
        'The free 4-day nSuns linear-progression template with exact set waves.',
    notes: '''
SOURCE
The public nSuns 4-day linear-progression program, digitized by Boostcamp in partnership with its creator.

TRAINING MAX
Begin around 90% of a true or estimated 1RM. The percentage sequence below is applied to the current training max.

DAY 1
Bench: 1×8@65%, 2×6@75%, 3×4@85%, 1×5@80%, 1×7@70%, 1×8+@65%.
OHP: 1×6@50%, 1×5@60%, 1×3@70%, then 1×5, 1×7, 1×4, 1×6, 1×8 all at 70%.

DAY 2
Squat: 2×5@75%, 2×3@85%, 1×1+@95%, 1×3@90%, 1×3@80%, 1×5@70%, 1×5+@65%.
Sumo deadlift: 1×5@50%, 1×5@60%, 1×3@70%, then 1×5, 1×7, 1×4, 1×6, 1×8 all at 70% of conventional-deadlift max.

DAY 3
Bench: 2×5@75%, 1×3@85%, 1×1+@95%, 1×3@90%, 1×5@85%, 1×3@80%, 1×3@70%, 1×5+@65%.
Close-grip bench: 1×6@40%, 1×5@50%, 1×3@60%, then 1×5, 1×7, 1×4, 1×6, 1×8 all at 60% of bench max.

DAY 4
Deadlift: 1×5@75%, 2×3@85%, 1×1+@95%, 1×3@90%, 1×3@80%, 1×3@75%, 1×3@70%, 1×3+@65%.
Front squat: 1×5@35%, 1×5@45%, 1×3@55%, then 1×5, 1×7, 1×4, 1×6, 1×8 all at 55% of back-squat max.

WEEKLY PROGRESSION
Use the AMRAP result to update the training max: 0–1 reps, no increase; 2–3 reps, add about 2.5 kg; 4–5 reps, add about 2.5–5 kg; more than 5 reps, add about 5–7.5 kg.

EQUIPMENT MAPPING
Barbell bench and back squat are mapped to your Smith machine. Sumo deadlift is logged as barbell deadlift; use a sumo stance for that secondary movement.

SOURCE URL
https://www.boostcamp.app/coaches/r-fitness/nsuns-linear-progression
''',
    workouts: [
      TemplateWorkout('Day 1 · Bench / OHP', [
        TemplateExercise('Smith Machine Bench Press',
            sets: 9, repMin: 4, repMax: 8),
        TemplateExercise('Overhead Press',
            sets: 8, repMin: 3, repMax: 8),
      ]),
      TemplateWorkout('Day 2 · Squat / Sumo deadlift', [
        TemplateExercise('Smith Machine Squat',
            sets: 9, repMin: 1, repMax: 5),
        TemplateExercise('Barbell Deadlift',
            sets: 8, repMin: 3, repMax: 8),
      ]),
      TemplateWorkout('Day 3 · Bench / Close grip', [
        TemplateExercise('Smith Machine Bench Press',
            sets: 9, repMin: 1, repMax: 5),
        TemplateExercise('Close-Grip Bench Press',
            sets: 8, repMin: 3, repMax: 8),
      ]),
      TemplateWorkout('Day 4 · Deadlift / Front squat', [
        TemplateExercise('Barbell Deadlift',
            sets: 9, repMin: 1, repMax: 5),
        TemplateExercise('Front Squat',
            sets: 8, repMin: 3, repMax: 8),
      ]),
    ],
  ),
  StarterTemplate(
    name: '5/3/1 for Beginners · public program',
    description:
        'The free three-day 5/3/1 beginner cycle with First Set Last volume.',
    notes: '''
SOURCE
Jim Wendler’s publicly published 5/3/1 for Beginners structure, documented by The Fitness Wiki.

TRAINING MAX
Use a conservative training max. The routine is percentage-based and repeats over three weeks. Do not take AMRAP sets to technical failure.

WEEK 1 FOR EACH MAIN LIFT
5@65%, 5@75%, 5+@85%, then 5×5@65%.

WEEK 2
3@70%, 3@80%, 3+@90%, then 5×5@70%.

WEEK 3
5@75%, 3@85%, 1+@95%, then 5×5@75%.

WEEKLY DAYS
Day 1: squat then bench.
Day 2: deadlift then overhead press.
Day 3: bench then squat.

ASSISTANCE
Each day complete 50–100 total reps from one push, one pull, and one single-leg or core movement. This template uses Push-Up, Pull-Up, and Step-Up as editable placeholders.

AFTER THE CYCLE
Increase the training max conservatively before repeating the three-week wave, traditionally about 2.5 kg for upper-body lifts and 5 kg for lower-body lifts.

EQUIPMENT MAPPING
Barbell bench and squat are mapped to your Smith machine.

SOURCE URL
https://thefitness.wiki/routines/5-3-1-for-beginners/
''',
    workouts: [
      TemplateWorkout('W1 D1 · Squat / Bench', [
        TemplateExercise('Smith Machine Squat',
            sets: 8, repMin: 5, repMax: 5),
        TemplateExercise('Smith Machine Bench Press',
            sets: 8, repMin: 5, repMax: 5),
        TemplateExercise('Push-Up', sets: 1, repMin: 50, repMax: 100),
        TemplateExercise('Pull-Up', sets: 1, repMin: 50, repMax: 100),
        TemplateExercise('Step-Up', sets: 1, repMin: 50, repMax: 100),
      ]),
      TemplateWorkout('W1 D2 · Deadlift / OHP', [
        TemplateExercise('Barbell Deadlift',
            sets: 8, repMin: 5, repMax: 5),
        TemplateExercise('Overhead Press',
            sets: 8, repMin: 5, repMax: 5),
        TemplateExercise('Push-Up', sets: 1, repMin: 50, repMax: 100),
        TemplateExercise('Pull-Up', sets: 1, repMin: 50, repMax: 100),
        TemplateExercise('Step-Up', sets: 1, repMin: 50, repMax: 100),
      ]),
      TemplateWorkout('W1 D3 · Bench / Squat', [
        TemplateExercise('Smith Machine Bench Press',
            sets: 8, repMin: 5, repMax: 5),
        TemplateExercise('Smith Machine Squat',
            sets: 8, repMin: 5, repMax: 5),
        TemplateExercise('Push-Up', sets: 1, repMin: 50, repMax: 100),
        TemplateExercise('Pull-Up', sets: 1, repMin: 50, repMax: 100),
        TemplateExercise('Step-Up', sets: 1, repMin: 50, repMax: 100),
      ]),
      TemplateWorkout('W2 D1 · Squat / Bench', [
        TemplateExercise('Smith Machine Squat',
            sets: 8, repMin: 3, repMax: 5),
        TemplateExercise('Smith Machine Bench Press',
            sets: 8, repMin: 3, repMax: 5),
        TemplateExercise('Push-Up', sets: 1, repMin: 50, repMax: 100),
        TemplateExercise('Pull-Up', sets: 1, repMin: 50, repMax: 100),
        TemplateExercise('Step-Up', sets: 1, repMin: 50, repMax: 100),
      ]),
      TemplateWorkout('W2 D2 · Deadlift / OHP', [
        TemplateExercise('Barbell Deadlift',
            sets: 8, repMin: 3, repMax: 5),
        TemplateExercise('Overhead Press',
            sets: 8, repMin: 3, repMax: 5),
        TemplateExercise('Push-Up', sets: 1, repMin: 50, repMax: 100),
        TemplateExercise('Pull-Up', sets: 1, repMin: 50, repMax: 100),
        TemplateExercise('Step-Up', sets: 1, repMin: 50, repMax: 100),
      ]),
      TemplateWorkout('W2 D3 · Bench / Squat', [
        TemplateExercise('Smith Machine Bench Press',
            sets: 8, repMin: 3, repMax: 5),
        TemplateExercise('Smith Machine Squat',
            sets: 8, repMin: 3, repMax: 5),
        TemplateExercise('Push-Up', sets: 1, repMin: 50, repMax: 100),
        TemplateExercise('Pull-Up', sets: 1, repMin: 50, repMax: 100),
        TemplateExercise('Step-Up', sets: 1, repMin: 50, repMax: 100),
      ]),
      TemplateWorkout('W3 D1 · Squat / Bench', [
        TemplateExercise('Smith Machine Squat',
            sets: 8, repMin: 1, repMax: 5),
        TemplateExercise('Smith Machine Bench Press',
            sets: 8, repMin: 1, repMax: 5),
        TemplateExercise('Push-Up', sets: 1, repMin: 50, repMax: 100),
        TemplateExercise('Pull-Up', sets: 1, repMin: 50, repMax: 100),
        TemplateExercise('Step-Up', sets: 1, repMin: 50, repMax: 100),
      ]),
      TemplateWorkout('W3 D2 · Deadlift / OHP', [
        TemplateExercise('Barbell Deadlift',
            sets: 8, repMin: 1, repMax: 5),
        TemplateExercise('Overhead Press',
            sets: 8, repMin: 1, repMax: 5),
        TemplateExercise('Push-Up', sets: 1, repMin: 50, repMax: 100),
        TemplateExercise('Pull-Up', sets: 1, repMin: 50, repMax: 100),
        TemplateExercise('Step-Up', sets: 1, repMin: 50, repMax: 100),
      ]),
      TemplateWorkout('W3 D3 · Bench / Squat', [
        TemplateExercise('Smith Machine Bench Press',
            sets: 8, repMin: 1, repMax: 5),
        TemplateExercise('Smith Machine Squat',
            sets: 8, repMin: 1, repMax: 5),
        TemplateExercise('Push-Up', sets: 1, repMin: 50, repMax: 100),
        TemplateExercise('Pull-Up', sets: 1, repMin: 50, repMax: 100),
        TemplateExercise('Step-Up', sets: 1, repMin: 50, repMax: 100),
      ]),
    ],
  ),
];

class VolumeLandmark {
  const VolumeLandmark({
    required this.muscleGroup,
    required this.sets,
    required this.minimum,
    required this.targetLow,
    required this.targetHigh,
    required this.maximum,
  });

  final String muscleGroup;
  final int sets;
  final int minimum;
  final int targetLow;
  final int targetHigh;
  final int maximum;

  String get guidance {
    if (sets == 0) return 'No logged sets in this window';
    if (sets < minimum) return 'Below the starting range';
    if (sets <= targetHigh) return 'Within a useful working range';
    if (sets <= maximum) return 'Above the usual working range';
    return 'Review recovery before adding more';
  }
}

const volumeLandmarkDefaults = <String, (int, int, int, int)>{
  'chest': (6, 10, 16, 20),
  'back': (8, 12, 20, 24),
  'legs': (6, 10, 18, 22),
  'hamstrings': (4, 8, 14, 18),
  'glutes': (4, 8, 16, 20),
  'shoulders': (6, 10, 16, 20),
  'arms': (4, 8, 14, 18),
  'core': (2, 6, 12, 16),
  'calves': (4, 8, 16, 20),
  'posterior chain': (4, 8, 14, 18),
  'full body': (2, 4, 8, 12),
  'conditioning': (0, 2, 6, 10),
};

VolumeLandmark makeVolumeLandmark(String muscleGroup, int sets) {
  final values = volumeLandmarkDefaults[muscleGroup] ?? (4, 8, 14, 18);
  return VolumeLandmark(
    muscleGroup: muscleGroup,
    sets: sets,
    minimum: values.$1,
    targetLow: values.$2,
    targetHigh: values.$3,
    maximum: values.$4,
  );
}

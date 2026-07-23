// Original strength content used by the LifeOS implementation.

class StarterTemplate {
  const StarterTemplate({
    required this.name,
    required this.description,
    required this.workouts,
  });

  final String name;
  final String description;
  final List<TemplateWorkout> workouts;
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
  // Original adaptation of an openly posted 7chan /fit/ push/legs/pull split.
  // The public post used heavy bench/OHP/trap-bar work; this version adds the
  // vertical pull suggested in the thread and uses knee-friendlier leg options.
  StarterTemplate(
    name: 'Forum P/L/P · strength + size',
    description:
        'Six-workout rotation mixing heavy presses and trap-bar work with balanced hypertrophy. Adapted for your equipment and knees.',
    workouts: [
      TemplateWorkout('Push A · Bench strength', [
        TemplateExercise('Smith Machine Bench Press', sets: 5, repMin: 3, repMax: 5),
        TemplateExercise('Overhead Press', sets: 3, repMin: 8, repMax: 10),
        TemplateExercise('Dip', sets: 3, repMin: 6, repMax: 12),
        TemplateExercise('Lateral Raise', sets: 3, repMin: 12, repMax: 20),
      ]),
      TemplateWorkout('Legs A · Trap-bar strength', [
        TemplateExercise('Trap Bar Deadlift', sets: 5, repMin: 3, repMax: 5),
        TemplateExercise('Bulgarian Split Squat', sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Leg Extension (band)', sets: 3, repMin: 12, repMax: 20),
        TemplateExercise('Standing Calf Raise', sets: 3, repMin: 10, repMax: 15),
      ]),
      TemplateWorkout('Pull A · Vertical pull', [
        TemplateExercise('Pull-Up', sets: 4, repMin: 5, repMax: 10),
        TemplateExercise('Barbell Row', sets: 3, repMin: 8, repMax: 10),
        TemplateExercise('Face Pull', sets: 3, repMin: 12, repMax: 20),
        TemplateExercise('EZ-Bar Curl', sets: 3, repMin: 8, repMax: 12),
      ]),
      TemplateWorkout('Push B · Press strength', [
        TemplateExercise('Overhead Press', sets: 5, repMin: 3, repMax: 5),
        TemplateExercise('Dumbbell Bench Press', sets: 3, repMin: 8, repMax: 10),
        TemplateExercise('Incline Dumbbell Press', sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Triceps Pushdown', sets: 3, repMin: 10, repMax: 15),
      ]),
      TemplateWorkout('Legs B · Posterior chain', [
        TemplateExercise('Romanian Deadlift', sets: 4, repMin: 6, repMax: 10),
        TemplateExercise('Smith Machine Squat', sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Step-Up', sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Hip Thrust', sets: 3, repMin: 8, repMax: 12),
      ]),
      TemplateWorkout('Pull B · Back volume', [
        TemplateExercise('Lat Pulldown', sets: 4, repMin: 8, repMax: 12),
        TemplateExercise('Chest-Supported Row', sets: 4, repMin: 8, repMax: 12),
        TemplateExercise('Cable Rear Delt Fly', sets: 3, repMin: 12, repMax: 20),
        TemplateExercise('Hammer Curl', sets: 3, repMin: 8, repMax: 12),
      ]),
    ],
  ),
  // Street-lifting was repeatedly requested on the board. This is an original
  // balanced template rather than a copy of any linked commercial program.
  StarterTemplate(
    name: 'Street lifting · 4 days',
    description:
        'Weighted pull-up and dip emphasis, with enough rowing and lower-body work to keep the program balanced.',
    workouts: [
      TemplateWorkout('Pull strength', [
        TemplateExercise('Weighted Pull-Up', sets: 5, repMin: 3, repMax: 5),
        TemplateExercise('Barbell Row', sets: 4, repMin: 6, repMax: 10),
        TemplateExercise('EZ-Bar Curl', sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Hanging Knee Raise', sets: 3, repMin: 8, repMax: 15),
      ]),
      TemplateWorkout('Push strength', [
        TemplateExercise('Weighted Dip', sets: 5, repMin: 3, repMax: 5),
        TemplateExercise('Overhead Press', sets: 4, repMin: 6, repMax: 10),
        TemplateExercise('Close-Grip Bench Press', sets: 3, repMin: 6, repMax: 10),
        TemplateExercise('Lateral Raise', sets: 3, repMin: 12, repMax: 20),
      ]),
      TemplateWorkout('Pull volume + hinge', [
        TemplateExercise('Pull-Up', sets: 4, repMin: 6, repMax: 10),
        TemplateExercise('Seated Cable Row', sets: 4, repMin: 8, repMax: 12),
        TemplateExercise('Romanian Deadlift', sets: 3, repMin: 6, repMax: 10),
        TemplateExercise('Hammer Curl', sets: 3, repMin: 10, repMax: 15),
      ]),
      TemplateWorkout('Push volume + legs', [
        TemplateExercise('Dip', sets: 4, repMin: 6, repMax: 12),
        TemplateExercise('Incline Dumbbell Press', sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Step-Up', sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Hip Thrust', sets: 3, repMin: 8, repMax: 12),
      ]),
    ],
  ),
  // Hybrid lifting and conditioning was another recurring board request. This
  // plan is original and uses equipment already recorded in LifeOS.
  StarterTemplate(
    name: 'Hybrid strength + engine · 4 days',
    description:
        'Two strength sessions and two short conditioning sessions. Use the separate Zone 2 tracker for easy aerobic work.',
    workouts: [
      TemplateWorkout('Strength A', [
        TemplateExercise('Trap Bar Deadlift', sets: 4, repMin: 4, repMax: 6),
        TemplateExercise('Dumbbell Bench Press', sets: 4, repMin: 6, repMax: 10),
        TemplateExercise('Pull-Up', sets: 4, repMin: 5, repMax: 10),
        TemplateExercise('Farmer Carry', sets: 4, repMin: 20, repMax: 40),
      ]),
      TemplateWorkout('Engine A', [
        TemplateExercise('Kettlebell Swing', sets: 5, repMin: 15, repMax: 20),
        TemplateExercise('Push Press', sets: 4, repMin: 6, repMax: 10),
        TemplateExercise('Row Sprint', sets: 6, repMin: 10, repMax: 20),
        TemplateExercise('Dead Bug', sets: 3, repMin: 8, repMax: 12),
      ]),
      TemplateWorkout('Strength B', [
        TemplateExercise('Smith Machine Squat', sets: 3, repMin: 8, repMax: 12),
        TemplateExercise('Overhead Press', sets: 4, repMin: 6, repMax: 10),
        TemplateExercise('Seated Cable Row', sets: 4, repMin: 8, repMax: 12),
        TemplateExercise('Hip Thrust', sets: 3, repMin: 8, repMax: 12),
      ]),
      TemplateWorkout('Engine B', [
        TemplateExercise('Dumbbell Snatch', sets: 5, repMin: 6, repMax: 10),
        TemplateExercise('Battle Rope Wave', sets: 6, repMin: 20, repMax: 30),
        TemplateExercise('Air Bike Sprint', sets: 6, repMin: 10, repMax: 20),
        TemplateExercise('Pallof Press', sets: 3, repMin: 8, repMax: 12),
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

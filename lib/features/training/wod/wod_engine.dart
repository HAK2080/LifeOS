/// WOD generator — pure Dart, deterministic with a seed, testable.
/// Not a slot machine: every WOD has a purpose, stimulus, scaling and
/// substitutions, and respects equipment, difficulty and knee limits.
library;

import 'dart:math';

enum WodFormat { amrap, emom, roundsForTime, intervals }

enum Difficulty { easy, moderate, hard }

class Movement {
  const Movement(
    this.name, {
    this.equipment,
    this.kneeSafe = true,
    this.stimulus = 'mixed',
    this.scaling = '',
    this.substitute = '',
    this.baseReps = 10,
  });

  final String name;
  final String? equipment; // null = bodyweight
  final bool kneeSafe;
  final String stimulus; // engine | legs | upper | core | full
  final String scaling;
  final String substitute;
  final int baseReps;
}

const movementCatalog = <Movement>[
  Movement('Kettlebell Swing',
      equipment: 'Kettlebells',
      stimulus: 'full',
      baseReps: 15,
      scaling: 'Lighter bell, Russian swing',
      substitute: 'Dumbbell swing / hip hinge'),
  Movement('Goblet Squat',
      equipment: 'Kettlebells',
      kneeSafe: false,
      stimulus: 'legs',
      baseReps: 12,
      scaling: 'Squat to box, reduce depth',
      substitute: 'Box squat'),
  Movement('Kettlebell Clean & Press',
      equipment: 'Kettlebells',
      stimulus: 'upper',
      baseReps: 8,
      scaling: 'One arm at a time, lighter bell',
      substitute: 'Dumbbell push press'),
  Movement('Burpee',
      stimulus: 'engine',
      kneeSafe: false,
      baseReps: 10,
      scaling: 'Step back instead of jump',
      substitute: 'Up-down to bench'),
  Movement('Push-Up',
      stimulus: 'upper',
      baseReps: 12,
      scaling: 'On knees or hands elevated',
      substitute: 'Incline push-up'),
  Movement('Ring Row',
      equipment: 'Rings',
      stimulus: 'upper',
      baseReps: 10,
      scaling: 'Walk feet back to reduce angle',
      substitute: 'Dumbbell row'),
  Movement('Pull-Up',
      equipment: 'Pull-up rig',
      stimulus: 'upper',
      baseReps: 6,
      scaling: 'Band-assisted or jumping',
      substitute: 'Ring row'),
  Movement('Row (calories)',
      equipment: 'Air rower',
      stimulus: 'engine',
      baseReps: 12,
      scaling: 'Slow steady pace',
      substitute: 'Any cardio machine, matched effort'),
  Movement('SkiErg (calories)',
      equipment: 'SkiErg',
      stimulus: 'engine',
      baseReps: 12,
      scaling: 'Slow steady pace',
      substitute: 'Rower'),
  Movement('Air Bike (calories)',
      equipment: 'Stationary / air bike',
      stimulus: 'engine',
      baseReps: 12,
      scaling: 'Reduce pace, keep moving',
      substitute: 'Any cardio machine'),
  Movement('Box Step-Up',
      equipment: 'Plyometric boxes',
      stimulus: 'legs',
      baseReps: 12,
      scaling: 'Lower box',
      substitute: 'Walking lunge'),
  Movement('Box Jump',
      equipment: 'Plyometric boxes',
      kneeSafe: false,
      stimulus: 'legs',
      baseReps: 10,
      scaling: 'Step up instead of jump',
      substitute: 'Box step-up'),
  Movement('Wall Ball',
      equipment: 'Plyometric boxes',
      kneeSafe: false,
      stimulus: 'full',
      baseReps: 12,
      scaling: 'Lighter ball, shallower squat',
      substitute: 'Dumbbell thruster'),
  Movement('Battle Rope Waves (sec)',
      equipment: 'Battle ropes',
      stimulus: 'engine',
      baseReps: 20,
      scaling: 'Shorter intervals',
      substitute: 'Jumping jacks'),
  Movement('Dumbbell Thruster',
      equipment: 'Dumbbells',
      kneeSafe: false,
      stimulus: 'full',
      baseReps: 10,
      scaling: 'Lighter dumbbells, split into squat + press',
      substitute: 'Kettlebell press'),
  Movement('Dumbbell Snatch',
      equipment: 'Dumbbells',
      stimulus: 'full',
      baseReps: 10,
      scaling: 'From hang position, lighter weight',
      substitute: 'Kettlebell swing'),
  Movement('Farmer Carry (m)',
      equipment: 'Dumbbells',
      stimulus: 'core',
      baseReps: 40,
      scaling: 'Lighter load, shorter distance',
      substitute: 'Kettlebell carry'),
  Movement('Plank (sec)',
      stimulus: 'core',
      baseReps: 30,
      scaling: 'On knees',
      substitute: 'Dead bug'),
  Movement('Sit-Up',
      stimulus: 'core',
      baseReps: 15,
      scaling: 'Reduce range',
      substitute: 'Crunch'),
  Movement('Kettlebell Snatch',
      equipment: 'Kettlebells',
      stimulus: 'full',
      baseReps: 8,
      scaling: 'One-arm swing instead',
      substitute: 'Dumbbell snatch'),
];

class WodRequest {
  const WodRequest({
    required this.durationMin,
    required this.difficulty,
    required this.availableEquipment,
    this.kneeSafeOnly = false,
    this.stimulusFocus, // engine | legs | upper | core | full | null=mixed
    this.avoidTitles = const {},
    this.feeling, // fresh | normal | tired — nudges difficulty
  });

  final int durationMin;
  final Difficulty difficulty;
  final Set<String> availableEquipment;
  final bool kneeSafeOnly;
  final String? stimulusFocus;
  final Set<String> avoidTitles;
  final String? feeling;
}

class WodMovement {
  const WodMovement(this.movement, this.reps);

  final Movement movement;
  final int reps;
}

class Wod {
  const Wod({
    required this.title,
    required this.format,
    required this.purpose,
    required this.stimulus,
    required this.difficulty,
    required this.movements,
    required this.structure,
    required this.expectedDurationMin,
    required this.workRest,
  });

  final String title;
  final WodFormat format;
  final String purpose;
  final String stimulus;
  final Difficulty difficulty;
  final List<WodMovement> movements;
  final String structure; // human description of rounds/time
  final int expectedDurationMin;
  final String workRest;

  String get description {
    final lines = <String>[
      structure,
      '',
      for (final m in movements) '• ${m.reps} ${m.movement.name}',
      '',
      'Purpose: $purpose',
      'Stimulus: $stimulus',
      'Work:rest — $workRest',
      '',
      'Scaling:',
      for (final m in movements.where((m) => m.movement.scaling.isNotEmpty))
        '• ${m.movement.name}: ${m.movement.scaling}',
      'Substitutions:',
      for (final m in movements.where((m) => m.movement.substitute.isNotEmpty))
        '• ${m.movement.name} → ${m.movement.substitute}',
    ];
    return lines.join('\n');
  }
}

/// Movements doable with the given constraints.
List<Movement> eligibleMovements(WodRequest r) => movementCatalog
    .where((m) =>
        (m.equipment == null || r.availableEquipment.contains(m.equipment)) &&
        (!r.kneeSafeOnly || m.kneeSafe) &&
        (r.stimulusFocus == null ||
            m.stimulus == r.stimulusFocus ||
            m.stimulus == 'full'))
    .toList();

Wod generateWod(WodRequest r, {int? seed}) {
  final rng = Random(seed);
  var pool = eligibleMovements(r);
  if (pool.isEmpty) {
    // Bodyweight fallback is always possible.
    pool = movementCatalog
        .where((m) => m.equipment == null && (!r.kneeSafeOnly || m.kneeSafe))
        .toList();
  }
  pool.shuffle(rng);

  // Effective difficulty: feeling tired steps it down, fresh steps it up.
  var difficulty = r.difficulty;
  if (r.feeling == 'tired' && difficulty != Difficulty.easy) {
    difficulty = Difficulty.values[difficulty.index - 1];
  } else if (r.feeling == 'fresh' && difficulty != Difficulty.hard) {
    difficulty = Difficulty.values[difficulty.index + 1];
  }

  final movementCount = r.durationMin <= 12 ? 2 : (r.durationMin <= 25 ? 3 : 4);
  // Movement balance: avoid two movements with the same stimulus if we can.
  final chosen = <Movement>[];
  for (final m in pool) {
    if (chosen.length == movementCount) break;
    if (chosen.any((c) => c.stimulus == m.stimulus) &&
        pool.length > movementCount) {
      continue;
    }
    chosen.add(m);
  }
  while (chosen.length < movementCount && chosen.length < pool.length) {
    chosen.add(pool[chosen.length]);
  }

  final intensity = switch (difficulty) {
    Difficulty.easy => 0.7,
    Difficulty.moderate => 1.0,
    Difficulty.hard => 1.3,
  };

  final format = switch (r.durationMin) {
    <= 12 => WodFormat.amrap,
    <= 20 => rng.nextBool() ? WodFormat.emom : WodFormat.amrap,
    <= 30 => WodFormat.roundsForTime,
    _ => WodFormat.intervals,
  };

  final movements = [
    for (final m in chosen)
      WodMovement(m, max(3, (m.baseReps * intensity).round())),
  ];

  final (structure, workRest, purpose) = switch (format) {
    WodFormat.amrap => (
        'AMRAP ${r.durationMin} min — as many rounds as possible:',
        'continuous, pace to keep moving',
        'Sustained engine work at a repeatable pace.',
      ),
    WodFormat.emom => (
        'EMOM ${r.durationMin} min — one movement per minute, rotate:',
        '~40s work / ~20s rest each minute',
        'Quality reps under a clock with built-in rest.',
      ),
    WodFormat.roundsForTime => (
        '${(r.durationMin / 8).ceil()} rounds for time:',
        'self-paced, rest as needed to keep form',
        'Push the pace across fixed rounds.',
      ),
    WodFormat.intervals => (
        '${(r.durationMin / 10).floor()} blocks of 8 min on / 2 min off:',
        '8:2 work:rest blocks',
        'Longer intervals building aerobic capacity.',
      ),
  };

  final stimulusSet = movements.map((m) => m.movement.stimulus).toSet();
  final title = _titleFor(format, chosen, rng, r.avoidTitles);

  return Wod(
    title: title,
    format: format,
    purpose: purpose,
    stimulus: stimulusSet.join(' + '),
    difficulty: difficulty,
    movements: movements,
    structure: structure,
    expectedDurationMin: r.durationMin,
    workRest: workRest,
  );
}

String _titleFor(
    WodFormat format, List<Movement> chosen, Random rng, Set<String> avoid) {
  const names = [
    'Ember', 'Drift', 'Anchor', 'Summit', 'Harbor', 'Cedar',
    'Juniper', 'Basalt', 'Meridian', 'Aurora', 'Canyon', 'Atlas',
  ];
  final pool = names.where((n) => !avoid.contains(n)).toList();
  final list = pool.isEmpty ? names : pool;
  return list[rng.nextInt(list.length)];
}

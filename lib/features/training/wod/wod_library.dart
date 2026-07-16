/// Curated library of widely known benchmark workouts (facts about classic
/// workouts, described in our own words — no scraped databases).
library;

class LibraryWod {
  const LibraryWod({
    required this.name,
    required this.level, // beginner | intermediate | advanced
    required this.durationMin,
    required this.equipment, // needed equipment names, empty = bodyweight
    required this.stimulus,
    required this.description,
    this.kneeSafe = true,
  });

  final String name;
  final String level;
  final int durationMin;
  final List<String> equipment;
  final String stimulus;
  final String description;
  final bool kneeSafe;
}

const wodLibrary = <LibraryWod>[
  LibraryWod(
    name: 'Cindy',
    level: 'beginner',
    durationMin: 20,
    equipment: ['Pull-up rig'],
    stimulus: 'bodyweight engine',
    description: 'AMRAP 20 min:\n• 5 pull-ups\n• 10 push-ups\n• 15 air squats\n\n'
        'Scale: ring rows for pull-ups, knee push-ups, squat to box.',
    kneeSafe: false,
  ),
  LibraryWod(
    name: 'Annie',
    level: 'beginner',
    durationMin: 12,
    equipment: [],
    stimulus: 'core + coordination',
    description: '50-40-30-20-10 reps for time:\n• Double-unders (or 2× singles)\n• Sit-ups\n\n'
        'Scale: single-unders or jumping jacks.',
  ),
  LibraryWod(
    name: 'Helen',
    level: 'intermediate',
    durationMin: 15,
    equipment: ['Kettlebells'],
    stimulus: 'run + full body',
    description: '3 rounds for time:\n• 400 m run\n• 21 kettlebell swings (24/16 kg)\n• 12 pull-ups\n\n'
        'Scale: lighter bell, ring rows, 200 m run or 500 m row.',
  ),
  LibraryWod(
    name: 'Fran',
    level: 'advanced',
    durationMin: 10,
    equipment: ['Straight barbell', 'Pull-up rig'],
    stimulus: 'high-intensity sprint',
    description: '21-15-9 reps for time:\n• Thrusters (43/30 kg)\n• Pull-ups\n\n'
        'Scale: dumbbell thrusters, band-assisted pull-ups.',
    kneeSafe: false,
  ),
  LibraryWod(
    name: 'Grace',
    level: 'advanced',
    durationMin: 8,
    equipment: ['Straight barbell'],
    stimulus: 'barbell power',
    description: '30 clean & jerks for time (61/43 kg).\n\n'
        'Scale: reduce load, or dumbbell clean & jerks.',
  ),
  LibraryWod(
    name: 'Karen',
    level: 'intermediate',
    durationMin: 12,
    equipment: ['Plyometric boxes'],
    stimulus: 'leg endurance',
    description: '150 wall balls for time (9/6 kg).\n\n'
        'Scale: lighter ball, break into sets of 10–15.',
    kneeSafe: false,
  ),
  LibraryWod(
    name: 'Jackie',
    level: 'intermediate',
    durationMin: 12,
    equipment: ['Air rower', 'Straight barbell', 'Pull-up rig'],
    stimulus: 'row + light barbell',
    description: 'For time:\n• 1000 m row\n• 50 thrusters (20 kg bar)\n• 30 pull-ups\n\n'
        'Scale: empty bar or dumbbells, ring rows.',
    kneeSafe: false,
  ),
  LibraryWod(
    name: 'DT',
    level: 'advanced',
    durationMin: 15,
    equipment: ['Straight barbell'],
    stimulus: 'barbell grip + shoulders',
    description: '5 rounds for time (70/47.5 kg):\n• 12 deadlifts\n• 9 hang power cleans\n• 6 push jerks\n\n'
        'Scale: dumbbells or lighter bar.',
  ),
  LibraryWod(
    name: 'Fight Gone Bad',
    level: 'intermediate',
    durationMin: 17,
    equipment: ['Plyometric boxes', 'Air rower', 'Straight barbell'],
    stimulus: 'mixed engine, stations',
    description: '3 rounds, 1 min per station, 1 min rest between rounds:\n'
        '• Wall balls\n• Sumo deadlift high pulls\n• Box jumps\n• Push presses\n• Row (calories)\n\n'
        'Score is total reps. Scale loads freely.',
    kneeSafe: false,
  ),
  LibraryWod(
    name: 'Chief',
    level: 'beginner',
    durationMin: 19,
    equipment: ['Straight barbell'],
    stimulus: 'intervals, repeatable',
    description: '5 cycles of AMRAP 3 min, 1 min rest between:\n'
        '• 3 power cleans (61/43 kg)\n• 6 push-ups\n• 9 air squats\n\n'
        'Scale: dumbbells, lighter load.',
    kneeSafe: false,
  ),
  LibraryWod(
    name: 'Baseline',
    level: 'beginner',
    durationMin: 8,
    equipment: ['Air rower'],
    stimulus: 'simple test',
    description: 'For time:\n• 500 m row\n• 40 air squats\n• 30 sit-ups\n• 20 push-ups\n• 10 pull-ups\n\n'
        'Scale: ring rows, knee push-ups.',
    kneeSafe: false,
  ),
  LibraryWod(
    name: 'Tabata Something Else',
    level: 'beginner',
    durationMin: 16,
    equipment: [],
    stimulus: 'bodyweight intervals',
    description: 'Four Tabatas (8× 20s on / 10s off) with 1 min between:\n'
        '• Pull-ups (or rows)\n• Push-ups\n• Sit-ups\n• Air squats\n\n'
        'Score is total reps. Fully scalable — pick easier variations.',
    kneeSafe: false,
  ),
  LibraryWod(
    name: 'Loredo',
    level: 'intermediate',
    durationMin: 24,
    equipment: [],
    stimulus: 'bodyweight endurance',
    description: '6 rounds for time:\n• 24 air squats\n• 24 push-ups\n• 24 walking lunges\n• 400 m run\n\n'
        'Scale: 4 rounds, shorten the run.',
    kneeSafe: false,
  ),
  LibraryWod(
    name: 'Kettlebell 300',
    level: 'intermediate',
    durationMin: 25,
    equipment: ['Kettlebells'],
    stimulus: 'kettlebell everything',
    description: 'For time, partition freely:\n• 100 swings\n• 50 goblet squats\n'
        '• 50 push presses (25 each arm)\n• 50 rows (25 each arm)\n• 50 sit-ups\n\n'
        'Scale: cut volume in half.',
    kneeSafe: false,
  ),
  LibraryWod(
    name: 'Row Ladder',
    level: 'beginner',
    durationMin: 20,
    equipment: ['Air rower'],
    stimulus: 'pure engine, joint-friendly',
    description: '5 rounds:\n• 250 m row hard\n• 90 s easy spin or rest\n\n'
        'Knee-friendly and fully scalable by pace.',
  ),
];

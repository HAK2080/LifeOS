import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

class TaskLists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get reminderAt => dateTime().nullable()();
  IntColumn get listId => integer().nullable().references(TaskLists, #id)();
  TextColumn get attachmentPath => text().nullable()();
  RealColumn get manualPosition => real().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

class Subtasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer().references(Tasks, #id)();
  TextColumn get title => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
}

class EquipmentItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get notes => text().nullable()();
  BoolColumn get available => boolean().withDefault(const Constant(true))();
}

class CheckIns extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get day => text()(); // yyyy-MM-dd
  IntColumn get mood => integer().nullable()(); // 1-5
  IntColumn get energy => integer().nullable()();
  IntColumn get physical => integer().nullable()();
}

class GoodDeeds extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get day => text()();
  TextColumn get title => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
}

class FocusEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get day => text()();
  TextColumn get title => text()();
  // pending | completed | skipped
  TextColumn get status => text().withDefault(const Constant('pending'))();
}

// ---------- Training (Phase 2) ----------

class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get muscleGroup => text().nullable()(); // chest, back, legs...
  TextColumn get equipment => text().nullable()(); // free text, matches library
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
}

class WorkoutPlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get notes => text().nullable()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  IntColumn get defaultRestSetSec => integer().nullable()();
  IntColumn get defaultRestExerciseSec => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// One workout ("Day A") inside a plan; sequence order, not calendar.
class PlanWorkouts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get planId => integer().references(WorkoutPlans, #id)();
  TextColumn get name => text()();
  IntColumn get position => integer()();
}

class PlanExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get planWorkoutId => integer().references(PlanWorkouts, #id)();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get position => integer()();
  IntColumn get targetSets => integer().withDefault(const Constant(3))();
  IntColumn get repMin => integer().nullable()();
  IntColumn get repMax => integer().nullable()();
  IntColumn get restSetSec => integer().nullable()();
  IntColumn get restExerciseSec => integer().nullable()();
  // manual | double | coach
  TextColumn get progressionMode =>
      text().withDefault(const Constant('manual'))();
}

class WorkoutSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get planWorkoutId =>
      integer().nullable().references(PlanWorkouts, #id)();
  TextColumn get title => text().withDefault(const Constant('Workout'))();
  DateTimeColumn get startedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
}

class SessionExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(WorkoutSessions, #id)();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get position => integer()();
}

class SessionSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionExerciseId =>
      integer().references(SessionExercises, #id)();
  IntColumn get setNumber => integer()();
  RealColumn get weightKg => real().nullable()();
  IntColumn get reps => integer().nullable()();
  RealColumn get rir => real().nullable()();
  BoolColumn get pain => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

class Zone2Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get activity => text()(); // bike, rower, treadmill, skierg...
  DateTimeColumn get startedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get durationMin => integer()();
  IntColumn get inZoneMin => integer().nullable()();
  IntColumn get avgHr => integer().nullable()();
  TextColumn get notes => text().nullable()();
  // zone2 | walking | mobility — shared table for simple timed activity
  TextColumn get kind => text().withDefault(const Constant('zone2'))();
  IntColumn get steps => integer().nullable()(); // walking only
}

// ---------- Nutrition (Phase 3) ----------

class Meals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get calories => real()();
  RealColumn get proteinG => real().withDefault(const Constant(0))();
  RealColumn get carbsG => real().withDefault(const Constant(0))();
  RealColumn get fatG => real().withDefault(const Constant(0))();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  BoolColumn get hidden => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class MealLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get day => text()(); // yyyy-MM-dd
  IntColumn get mealId => integer().nullable().references(Meals, #id)();
  TextColumn get name => text()();
  RealColumn get portion => real().withDefault(const Constant(1.0))();
  RealColumn get calories => real()();
  RealColumn get proteinG => real().withDefault(const Constant(0))();
  RealColumn get carbsG => real().withDefault(const Constant(0))();
  RealColumn get fatG => real().withDefault(const Constant(0))();
  DateTimeColumn get loggedAt => dateTime().withDefault(currentDateAndTime)();
}

class WeightEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get day => text()();
  RealColumn get weightKg => real()();
  RealColumn get waistCm => real().nullable()();
  DateTimeColumn get loggedAt => dateTime().withDefault(currentDateAndTime)();
}

class WodSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  // coach | equipment | library | manual | kettlebell
  TextColumn get source => text().withDefault(const Constant('manual'))();
  DateTimeColumn get completedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get durationMin => integer().nullable()();
  TextColumn get result => text().nullable()(); // time, rounds, notes
  TextColumn get feeling => text().nullable()();
}

@DriftDatabase(tables: [
  TaskLists,
  Tasks,
  Subtasks,
  EquipmentItems,
  CheckIns,
  GoodDeeds,
  FocusEntries,
  Exercises,
  WorkoutPlans,
  PlanWorkouts,
  PlanExercises,
  WorkoutSessions,
  SessionExercises,
  SessionSets,
  Zone2Sessions,
  WodSessions,
  Meals,
  MealLogs,
  WeightEntries,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(driftDatabase(
          name: 'life_app',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ));

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  static const seedEquipment = [
    'Smith machine / functional trainer',
    'Adjustable bench',
    'Dumbbells',
    'Kettlebells',
    'Straight barbell',
    'EZ-curl bar',
    'Trap bar',
    'Plates',
    'Cable attachments',
    'Resistance bands',
    'Battle ropes',
    'Rings',
    'Pull-up rig',
    'Climbing rope',
    'Plyometric boxes',
    'Curved treadmill',
    'Air rower',
    'SkiErg',
    'Stationary / air bike',
  ];

  static const seedExercises = <(String, String, String)>[
    // (name, muscleGroup, equipment)
    ('Smith Machine Bench Press', 'chest', 'Smith machine / functional trainer'),
    ('Smith Machine Incline Press', 'chest', 'Smith machine / functional trainer'),
    ('Dumbbell Bench Press', 'chest', 'Dumbbells'),
    ('Incline Dumbbell Press', 'chest', 'Dumbbells'),
    ('Dumbbell Fly', 'chest', 'Dumbbells'),
    ('Cable Fly', 'chest', 'Cable attachments'),
    ('Push-Up', 'chest', ''),
    ('Ring Push-Up', 'chest', 'Rings'),
    ('Pull-Up', 'back', 'Pull-up rig'),
    ('Chin-Up', 'back', 'Pull-up rig'),
    ('Ring Row', 'back', 'Rings'),
    ('Barbell Row', 'back', 'Straight barbell'),
    ('Dumbbell Row', 'back', 'Dumbbells'),
    ('Lat Pulldown', 'back', 'Cable attachments'),
    ('Seated Cable Row', 'back', 'Cable attachments'),
    ('Trap Bar Deadlift', 'back', 'Trap bar'),
    ('Barbell Deadlift', 'back', 'Straight barbell'),
    ('Romanian Deadlift', 'hamstrings', 'Straight barbell'),
    ('Dumbbell Romanian Deadlift', 'hamstrings', 'Dumbbells'),
    ('Back Squat', 'legs', 'Straight barbell'),
    ('Smith Machine Squat', 'legs', 'Smith machine / functional trainer'),
    ('Goblet Squat', 'legs', 'Kettlebells'),
    ('Bulgarian Split Squat', 'legs', 'Dumbbells'),
    ('Walking Lunge', 'legs', 'Dumbbells'),
    ('Step-Up', 'legs', 'Plyometric boxes'),
    ('Box Squat', 'legs', 'Plyometric boxes'),
    ('Leg Extension (band)', 'legs', 'Resistance bands'),
    ('Overhead Press', 'shoulders', 'Straight barbell'),
    ('Dumbbell Shoulder Press', 'shoulders', 'Dumbbells'),
    ('Lateral Raise', 'shoulders', 'Dumbbells'),
    ('Rear Delt Fly', 'shoulders', 'Dumbbells'),
    ('Face Pull', 'shoulders', 'Cable attachments'),
    ('Barbell Curl', 'arms', 'Straight barbell'),
    ('EZ-Bar Curl', 'arms', 'EZ-curl bar'),
    ('Dumbbell Curl', 'arms', 'Dumbbells'),
    ('Hammer Curl', 'arms', 'Dumbbells'),
    ('Triceps Pushdown', 'arms', 'Cable attachments'),
    ('Overhead Triceps Extension', 'arms', 'Dumbbells'),
    ('Skull Crusher', 'arms', 'EZ-curl bar'),
    ('Dip', 'arms', 'Rings'),
    ('Kettlebell Swing', 'posterior chain', 'Kettlebells'),
    ('Kettlebell Clean', 'full body', 'Kettlebells'),
    ('Kettlebell Snatch', 'full body', 'Kettlebells'),
    ('Kettlebell Press', 'shoulders', 'Kettlebells'),
    ('Turkish Get-Up', 'full body', 'Kettlebells'),
    ('Kettlebell Front Rack Carry', 'core', 'Kettlebells'),
    ('Farmer Carry', 'core', 'Dumbbells'),
    ('Plank', 'core', ''),
    ('Hanging Knee Raise', 'core', 'Pull-up rig'),
    ('Cable Crunch', 'core', 'Cable attachments'),
    ('Hip Thrust', 'glutes', 'Straight barbell'),
    ('Calf Raise', 'calves', 'Dumbbells'),
    ('Box Jump', 'legs', 'Plyometric boxes'),
    ('Wall Ball', 'full body', 'Plyometric boxes'),
    ('Battle Rope Wave', 'conditioning', 'Battle ropes'),
    ('Rope Climb', 'back', 'Climbing rope'),
    ('SkiErg Sprint', 'conditioning', 'SkiErg'),
    ('Row Sprint', 'conditioning', 'Air rower'),
    ('Air Bike Sprint', 'conditioning', 'Stationary / air bike'),
    ('Burpee', 'full body', ''),
  ];

  Future<void> _seedExercises(Batch b) async {
    b.insertAll(
      exercises,
      seedExercises.map((e) => ExercisesCompanion.insert(
            name: e.$1,
            muscleGroup: Value(e.$2.isEmpty ? null : e.$2),
            equipment: Value(e.$3.isEmpty ? null : e.$3),
          )),
    );
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await batch((b) {
            b.insertAll(
              equipmentItems,
              seedEquipment
                  .map((e) => EquipmentItemsCompanion.insert(name: e)),
            );
            _seedExercises(b);
          });
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(exercises);
            await m.createTable(workoutPlans);
            await m.createTable(planWorkouts);
            await m.createTable(planExercises);
            await m.createTable(workoutSessions);
            await m.createTable(sessionExercises);
            await m.createTable(sessionSets);
            await m.createTable(zone2Sessions);
            await m.createTable(wodSessions);
            await batch(_seedExercises);
          }
          if (from < 3) {
            await m.createTable(meals);
            await m.createTable(mealLogs);
            await m.createTable(weightEntries);
          }
        },
      );
}

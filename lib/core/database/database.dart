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

// ---------- Growth & Goals (Phase 4) ----------

class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get protocolId =>
      text().nullable().references(WellnessProtocols, #id)();
  TextColumn get name => text()();
  TextColumn get purpose => text().nullable()();
  TextColumn get protocol => text().nullable()();
  // fixed | weekly | both | none
  TextColumn get scheduleType => text().withDefault(const Constant('none'))();
  TextColumn get fixedDays => text().nullable()(); // "1,3,5" (Mon=1)
  IntColumn get weeklyTarget => integer().nullable()();
  IntColumn get durationMin => integer().nullable()();
  TextColumn get minimumVersion => text().nullable()();
  TextColumn get reminderTime => text().nullable()(); // "07:30"
  TextColumn get notes => text().nullable()();
  TextColumn get evidenceLevel => text().nullable()();
  TextColumn get safetyNotes => text().nullable()();
  TextColumn get source => text().nullable()();
  IntColumn get reviewAfterDays => integer().nullable()();
  DateTimeColumn get lastReviewAt => dateTime().nullable()();
  // active | paused | stopped
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class HabitLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId => integer().references(Habits, #id)();
  TextColumn get day => text()();
  // completed | minimum | skipped
  TextColumn get status => text()();
}

class HabitReviews extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId => integer().references(Habits, #id)();
  DateTimeColumn get reviewedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get outcome => text()(); // keep | adjust | pause | stop
  BoolColumn get helped => boolean().nullable()();
  TextColumn get notes => text().nullable()();
}

@DataClassName('LifeGoal')
class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  // cardio | training | nutrition | body | recovery | custom
  TextColumn get kind => text().withDefault(const Constant('custom'))();
  TextColumn get target => text().nullable()();
  DateTimeColumn get deadline => dateTime().nullable()();
  // active | paused | completed
  TextColumn get status => text().withDefault(const Constant('active'))();
  BoolColumn get autoLink => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ---------- Nutrition (Phase 3) ----------

/// A reusable food entry, stored per serving so logs can preserve the values
/// used at the time they were created.
class Foods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get servingLabel =>
      text().withDefault(const Constant('1 serving'))();
  RealColumn get servingGrams => real().nullable()();
  RealColumn get calories => real()();
  RealColumn get proteinG => real().withDefault(const Constant(0))();
  RealColumn get carbsG => real().withDefault(const Constant(0))();
  RealColumn get fatG => real().withDefault(const Constant(0))();
  RealColumn get fiberG => real().withDefault(const Constant(0))();
  TextColumn get source => text().withDefault(const Constant('local'))();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  BoolColumn get hidden => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Recipes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get instructions => text().nullable()();
  RealColumn get servings => real().withDefault(const Constant(1))();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class RecipeIngredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recipeId => integer().references(Recipes, #id)();
  IntColumn get foodId => integer().nullable().references(Foods, #id)();
  TextColumn get name => text()();
  RealColumn get amount => real().withDefault(const Constant(1))();
  TextColumn get unit => text().withDefault(const Constant('serving'))();
  RealColumn get calories => real().withDefault(const Constant(0))();
  RealColumn get proteinG => real().withDefault(const Constant(0))();
  RealColumn get carbsG => real().withDefault(const Constant(0))();
  RealColumn get fatG => real().withDefault(const Constant(0))();
}

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
  DateTimeColumn get completedAt =>
      dateTime().withDefault(currentDateAndTime)();
  IntColumn get durationMin => integer().nullable()();
  TextColumn get result => text().nullable()(); // time, rounds, notes
  TextColumn get feeling => text().nullable()();
}

class WellnessProtocols extends Table {
  TextColumn get id => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get category => text()();
  TextColumn get title => text()();
  TextColumn get purpose => text()();
  TextColumn get instructions => text()();
  TextColumn get minimumVersion => text()();
  TextColumn get standardVersion => text()();
  TextColumn get frequency => text()();
  IntColumn get durationMinutes => integer().nullable()();
  TextColumn get bestTime => text()();
  TextColumn get evidenceLevel => text()();
  TextColumn get safetyNotes => text()();
  IntColumn get reviewPeriodDays => integer().withDefault(const Constant(28))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class WellnessSources extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get publisher => text()();
  TextColumn get url => text()();
}

class WellnessProtocolSources extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get protocolId => text().references(WellnessProtocols, #id)();
  TextColumn get sourceId => text().references(WellnessSources, #id)();
}

@DriftDatabase(
  tables: [
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
    Foods,
    Recipes,
    RecipeIngredients,
    WellnessProtocols,
    WellnessSources,
    WellnessProtocolSources,
    Meals,
    MealLogs,
    WeightEntries,
    Habits,
    HabitLogs,
    HabitReviews,
    Goals,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase()
    : super(
        driftDatabase(
          name: 'life_app',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 6;

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
    (
      'Smith Machine Bench Press',
      'chest',
      'Smith machine / functional trainer',
    ),
    (
      'Smith Machine Incline Press',
      'chest',
      'Smith machine / functional trainer',
    ),
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
    ('Machine Chest Press', 'chest', 'Smith machine / functional trainer'),
    ('Decline Dumbbell Press', 'chest', 'Dumbbells'),
    ('Close-Grip Push-Up', 'chest', ''),
    ('Chest-Supported Row', 'back', 'Dumbbells'),
    ('Single-Arm Cable Row', 'back', 'Cable attachments'),
    ('Straight-Arm Pulldown', 'back', 'Cable attachments'),
    ('Inverted Row', 'back', 'Rings'),
    ('Good Morning', 'hamstrings', 'Straight barbell'),
    ('Nordic Hamstring Curl', 'hamstrings', ''),
    ('Lying Leg Curl (band)', 'hamstrings', 'Resistance bands'),
    ('Front Squat', 'legs', 'Straight barbell'),
    ('Hack Squat', 'legs', 'Smith machine / functional trainer'),
    ('Reverse Lunge', 'legs', 'Dumbbells'),
    ('Reverse Step-Up', 'legs', 'Plyometric boxes'),
    ('Sissy Squat', 'legs', ''),
    ('Seated Calf Raise', 'calves', 'Dumbbells'),
    ('Standing Calf Raise', 'calves', 'Smith machine / functional trainer'),
    ('Arnold Press', 'shoulders', 'Dumbbells'),
    ('Landmine Press', 'shoulders', 'Straight barbell'),
    ('Cable Lateral Raise', 'shoulders', 'Cable attachments'),
    ('Cable Rear Delt Fly', 'shoulders', 'Cable attachments'),
    ('Upright Row', 'shoulders', 'Straight barbell'),
    ('Preacher Curl', 'arms', 'EZ-curl bar'),
    ('Incline Dumbbell Curl', 'arms', 'Dumbbells'),
    ('Cable Curl', 'arms', 'Cable attachments'),
    ('Close-Grip Bench Press', 'arms', 'Straight barbell'),
    ('Dumbbell Skull Crusher', 'arms', 'Dumbbells'),
    ('Cable Overhead Triceps Extension', 'arms', 'Cable attachments'),
    ('Cable Kickback', 'arms', 'Cable attachments'),
    ('Barbell Hip Thrust', 'glutes', 'Straight barbell'),
    ('Cable Pull-Through', 'glutes', 'Cable attachments'),
    ('Glute Bridge', 'glutes', ''),
    ('Single-Leg Hip Thrust', 'glutes', ''),
    ('Ab Wheel Rollout', 'core', ''),
    ('Dead Bug', 'core', ''),
    ('Pallof Press', 'core', 'Cable attachments'),
    ('Side Plank', 'core', ''),
    ('Weighted Plank', 'core', 'Plates'),
    ('Suitcase Carry', 'core', 'Dumbbells'),
    ('Barbell Clean', 'full body', 'Straight barbell'),
    ('Power Clean', 'full body', 'Straight barbell'),
    ('Push Press', 'full body', 'Straight barbell'),
    ('Thruster', 'full body', 'Dumbbells'),
    ('Dumbbell Snatch', 'full body', 'Dumbbells'),
    ('Man Maker', 'full body', 'Dumbbells'),
    ('Bear Crawl', 'full body', ''),
    ('Sled Push', 'conditioning', ''),
    ('Sled Pull', 'conditioning', ''),
    ('Assault Bike', 'conditioning', 'Stationary / air bike'),
    ('Rowing', 'conditioning', 'Air rower'),
    ('Farmer Walk', 'conditioning', 'Dumbbells'),
  ];

  Future<void> _seedExercises(Batch b) async {
    b.insertAll(
      exercises,
      seedExercises.map(
        (e) => ExercisesCompanion.insert(
          name: e.$1,
          muscleGroup: Value(e.$2.isEmpty ? null : e.$2),
          equipment: Value(e.$3.isEmpty ? null : e.$3),
        ),
      ),
    );
  }

  /// Adds newly shipped library entries without duplicating exercises in an
  /// existing local database.
  Future<void> seedMissingExercises() async {
    final existing = await select(exercises).get();
    final names = existing.map((e) => e.name.toLowerCase()).toSet();
    final missing = seedExercises.where(
      (e) => !names.contains(e.$1.toLowerCase()),
    );
    if (missing.isEmpty) return;
    await batch((b) {
      b.insertAll(
        exercises,
        missing.map(
          (e) => ExercisesCompanion.insert(
            name: e.$1,
            muscleGroup: Value(e.$2.isEmpty ? null : e.$2),
            equipment: Value(e.$3.isEmpty ? null : e.$3),
          ),
        ),
      );
    });
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await batch((b) {
        b.insertAll(
          equipmentItems,
          seedEquipment.map((e) => EquipmentItemsCompanion.insert(name: e)),
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
      if (from < 5) {
        await m.createTable(wellnessProtocols);
        await m.createTable(wellnessSources);
        await m.createTable(wellnessProtocolSources);
      }
      if (from < 4) {
        await m.createTable(habits);
        await m.createTable(habitLogs);
        await m.createTable(goals);
      }
      if (from < 5) {
        await m.createTable(habitReviews);
      }
      if (from < 5 && from >= 4) {
        await m.addColumn(habits, habits.protocolId);
      }
      if (from < 6) {
        await m.createTable(foods);
        await m.createTable(recipes);
        await m.createTable(recipeIngredients);
      }
    },
  );
}

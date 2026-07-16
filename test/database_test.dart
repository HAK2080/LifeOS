import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';

import 'package:life_app/core/database/database.dart';

import 'helpers/test_db.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  test('fresh database seeds equipment and exercises', () async {
    final equipment = await db.select(db.equipmentItems).get();
    expect(equipment.length, AppDatabase.seedEquipment.length);

    final exercises = await db.select(db.exercises).get();
    expect(exercises.length, AppDatabase.seedExercises.length);
    expect(exercises.every((e) => !e.isCustom), isTrue);
  });

  test('workout session with sets round-trips', () async {
    final exercise = await (db.select(db.exercises)..limit(1)).getSingle();
    final sessionId = await db
        .into(db.workoutSessions)
        .insert(WorkoutSessionsCompanion.insert());
    final seId = await db.into(db.sessionExercises).insert(
        SessionExercisesCompanion.insert(
            sessionId: sessionId, exerciseId: exercise.id, position: 0));
    await db.into(db.sessionSets).insert(SessionSetsCompanion.insert(
          sessionExerciseId: seId,
          setNumber: 1,
          weightKg: const Value(60),
          reps: const Value(8),
          rir: const Value(2),
          completedAt: Value(DateTime.now()),
        ));

    final sets = await db.select(db.sessionSets).get();
    expect(sets.single.weightKg, 60);
    expect(sets.single.reps, 8);
    expect(sets.single.pain, isFalse);
  });

  test('plan structure round-trips', () async {
    final planId = await db
        .into(db.workoutPlans)
        .insert(WorkoutPlansCompanion.insert(name: 'Upper/Lower'));
    final wId = await db.into(db.planWorkouts).insert(
        PlanWorkoutsCompanion.insert(
            planId: planId, name: 'Upper A', position: 0));
    final exercise = await (db.select(db.exercises)..limit(1)).getSingle();
    await db.into(db.planExercises).insert(PlanExercisesCompanion.insert(
          planWorkoutId: wId,
          exerciseId: exercise.id,
          position: 0,
          repMin: const Value(8),
          repMax: const Value(12),
        ));

    final pe = await db.select(db.planExercises).get();
    expect(pe.single.targetSets, 3); // default
    expect(pe.single.progressionMode, 'manual');
  });
}

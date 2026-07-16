import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:life_app/core/database/database.dart';
import 'package:life_app/features/training/training_repository.dart';
import 'package:life_app/features/training/strength/strength_content.dart';

import 'helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late TrainingRepository repo;

  setUp(() {
    db = testDatabase();
    repo = TrainingRepository(db);
  });
  tearDown(() => db.close());

  Future<int> logSession(int exerciseId, List<(double, int)> sets) async {
    final sessionId = await repo.startSession();
    final linkId = await repo.addExerciseToSession(sessionId, exerciseId);
    // addExerciseToSession creates one placeholder set; fill and extend.
    final existing = await (db.select(
      db.sessionSets,
    )..where((t) => t.sessionExerciseId.equals(linkId))).get();
    for (var i = 0; i < sets.length; i++) {
      final id = i < existing.length
          ? existing[i].id
          : await repo.addSet(linkId);
      await repo.updateSet(
        id,
        SessionSetsCompanion(
          weightKg: Value(sets[i].$1),
          reps: Value(sets[i].$2),
          completedAt: Value(DateTime.now()),
        ),
      );
    }
    await repo.finishSession(sessionId);
    return sessionId;
  }

  test('lastPerformance returns most recent finished session sets', () async {
    final exercise = await (db.select(db.exercises)..limit(1)).getSingle();
    await logSession(exercise.id, [(60, 10), (60, 9)]);
    await logSession(exercise.id, [(62.5, 8), (62.5, 8)]);

    final last = await repo.lastPerformance(exercise.id);
    expect(last, isNotNull);
    expect(last!.sets.length, 2);
    expect(last.sets.first.weightKg, 62.5);
  });

  test('new session prefills from last performance', () async {
    final exercise = await (db.select(db.exercises)..limit(1)).getSingle();
    await logSession(exercise.id, [(80, 5)]);

    final sessionId = await repo.startSession();
    final linkId = await repo.addExerciseToSession(sessionId, exercise.id);
    final sets = await (db.select(
      db.sessionSets,
    )..where((t) => t.sessionExerciseId.equals(linkId))).get();
    expect(sets.single.weightKg, 80);
    expect(sets.single.reps, 5);
    expect(sets.single.completedAt, isNull); // prefill, not logged
  });

  test('finishSession drops exercises without completed sets', () async {
    final exercises = await (db.select(db.exercises)..limit(2)).get();
    final sessionId = await repo.startSession();
    final keep = await repo.addExerciseToSession(sessionId, exercises[0].id);
    await repo.addExerciseToSession(sessionId, exercises[1].id); // untouched
    final keepSets = await (db.select(
      db.sessionSets,
    )..where((t) => t.sessionExerciseId.equals(keep))).get();
    await repo.updateSet(
      keepSets.single.id,
      SessionSetsCompanion(
        weightKg: const Value(40),
        reps: const Value(10),
        completedAt: Value(DateTime.now()),
      ),
    );
    await repo.finishSession(sessionId);

    final links = await (db.select(
      db.sessionExercises,
    )..where((t) => t.sessionId.equals(sessionId))).get();
    expect(links.length, 1);
    expect(links.single.id, keep);
  });

  test('nextPlanWorkout cycles by sequence and wraps', () async {
    final exercise = await (db.select(db.exercises)..limit(1)).getSingle();
    final planId = await repo.createPlan('UL');
    final a = await repo.addPlanWorkout(planId, 'Upper');
    final b = await repo.addPlanWorkout(planId, 'Lower');
    await repo.addPlanExercise(a, exercise.id);
    await repo.addPlanExercise(b, exercise.id);

    var next = await repo.nextPlanWorkout(planId);
    expect(next!.name, 'Upper');

    // Complete "Upper" → next is "Lower".
    var sessionId = await repo.startPlanSession(next);
    await repo.db
        .update(repo.db.sessionSets)
        .write(SessionSetsCompanion(completedAt: Value(DateTime.now())));
    await repo.finishSession(sessionId);
    next = await repo.nextPlanWorkout(planId);
    expect(next!.name, 'Lower');

    // Complete "Lower" → wraps to "Upper".
    sessionId = await repo.startPlanSession(next);
    await repo.db
        .update(repo.db.sessionSets)
        .write(SessionSetsCompanion(completedAt: Value(DateTime.now())));
    await repo.finishSession(sessionId);
    next = await repo.nextPlanWorkout(planId);
    expect(next!.name, 'Upper');
  });

  test('startPlanSession creates target set rows', () async {
    final exercise = await (db.select(db.exercises)..limit(1)).getSingle();
    final planId = await repo.createPlan('P');
    final w = await repo.addPlanWorkout(planId, 'Day 1');
    await repo.addPlanExercise(w, exercise.id, targetSets: 4);

    final workout = (await repo.nextPlanWorkout(planId))!;
    final sessionId = await repo.startPlanSession(workout);
    final links = await (db.select(
      db.sessionExercises,
    )..where((t) => t.sessionId.equals(sessionId))).get();
    final sets = await (db.select(
      db.sessionSets,
    )..where((t) => t.sessionExerciseId.equals(links.single.id))).get();
    expect(sets.length, 4);
  });

  test(
    'progress review groups completed sets and finds personal records',
    () async {
      final exercise = await (db.select(
        db.exercises,
      )..where((t) => t.name.equals('Dumbbell Bench Press'))).getSingle();
      await logSession(exercise.id, [(30, 10), (32.5, 8)]);

      final volume = await repo.recentVolume();
      expect(volume.single.muscleGroup, 'chest');
      expect(volume.single.sets, 2);
      expect(volume.single.guidance, 'Below the starting range');

      final records = await repo.personalRecords();
      expect(records.single.exerciseName, 'Dumbbell Bench Press');
      expect(records.single.maxWeightKg, 32.5);
      expect(records.single.bestReps, 8);
    },
  );

  test(
    'starter template creates a progressive plan from library exercises',
    () async {
      final planId = await repo.createStarterTemplate(starterTemplates.first);
      final plan = await (db.select(
        db.workoutPlans,
      )..where((t) => t.id.equals(planId))).getSingle();
      final workouts = await (db.select(
        db.planWorkouts,
      )..where((t) => t.planId.equals(planId))).get();
      final exercises = await (db.select(
        db.planExercises,
      )..where((t) => t.planWorkoutId.isIn(workouts.map((w) => w.id)))).get();
      expect(plan.name, starterTemplates.first.name);
      expect(workouts.length, 3);
      expect(exercises, isNotEmpty);
      expect(
        exercises.every((e) => e.progressionMode == 'progressive'),
        isTrue,
      );
    },
  );
}

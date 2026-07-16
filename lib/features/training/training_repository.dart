import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';
import '../../core/database/database_provider.dart';
import 'strength/strength_content.dart';

/// One exercise inside an active session, with its logged sets.
class SessionExerciseData {
  const SessionExerciseData(this.link, this.exercise, this.sets);

  final SessionExercise link;
  final Exercise exercise;
  final List<SessionSet> sets;
}

/// Previous performance of an exercise: the sets from its most recent
/// finished session (for "last time" display and prefill).
class LastPerformance {
  const LastPerformance(this.when, this.sets);

  final DateTime when;
  final List<SessionSet> sets;
}

class PersonalRecord {
  const PersonalRecord({
    required this.exerciseName,
    required this.maxWeightKg,
    required this.bestReps,
    required this.lastPerformed,
  });

  final String exerciseName;
  final double maxWeightKg;
  final int bestReps;
  final DateTime lastPerformed;
}

class TrainingRepository {
  TrainingRepository(this.db);

  final AppDatabase db;

  // ----- Exercises -----

  Stream<List<Exercise>> watchExercises() async* {
    await db.seedMissingExercises();
    yield* (db.select(
      db.exercises,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  Future<int> addCustomExercise(
    String name, {
    String? muscleGroup,
    String? equipment,
  }) => db
      .into(db.exercises)
      .insert(
        ExercisesCompanion.insert(
          name: name,
          muscleGroup: Value(muscleGroup),
          equipment: Value(equipment),
          isCustom: const Value(true),
        ),
      );

  // ----- Sessions -----

  /// The one unfinished session, if any (resume support).
  Stream<WorkoutSession?> watchActiveSession() =>
      (db.select(db.workoutSessions)
            ..where((t) => t.finishedAt.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
            ..limit(1))
          .watchSingleOrNull();

  Future<int> startSession({int? planWorkoutId, String title = 'Workout'}) => db
      .into(db.workoutSessions)
      .insert(
        WorkoutSessionsCompanion.insert(
          planWorkoutId: Value(planWorkoutId),
          title: Value(title),
        ),
      );

  Future<void> finishSession(int sessionId, {String? notes}) async {
    // Drop exercises with no completed sets, then close.
    final links = await (db.select(
      db.sessionExercises,
    )..where((t) => t.sessionId.equals(sessionId))).get();
    for (final link in links) {
      final sets =
          await (db.select(db.sessionSets)..where(
                (t) =>
                    t.sessionExerciseId.equals(link.id) &
                    t.completedAt.isNotNull(),
              ))
              .get();
      if (sets.isEmpty) {
        await (db.delete(
          db.sessionSets,
        )..where((t) => t.sessionExerciseId.equals(link.id))).go();
        await (db.delete(
          db.sessionExercises,
        )..where((t) => t.id.equals(link.id))).go();
      } else {
        // Remove never-completed placeholder sets.
        await (db.delete(db.sessionSets)..where(
              (t) =>
                  t.sessionExerciseId.equals(link.id) & t.completedAt.isNull(),
            ))
            .go();
      }
    }
    await (db.update(
      db.workoutSessions,
    )..where((t) => t.id.equals(sessionId))).write(
      WorkoutSessionsCompanion(
        finishedAt: Value(DateTime.now()),
        notes: Value(notes),
      ),
    );
  }

  Future<void> discardSession(int sessionId) async {
    final links = await (db.select(
      db.sessionExercises,
    )..where((t) => t.sessionId.equals(sessionId))).get();
    for (final link in links) {
      await (db.delete(
        db.sessionSets,
      )..where((t) => t.sessionExerciseId.equals(link.id))).go();
    }
    await (db.delete(
      db.sessionExercises,
    )..where((t) => t.sessionId.equals(sessionId))).go();
    await (db.delete(
      db.workoutSessions,
    )..where((t) => t.id.equals(sessionId))).go();
  }

  // ----- Exercises within a session -----

  Stream<List<SessionExerciseData>> watchSessionExercises(int sessionId) {
    // Join all three tables so the stream re-emits on set changes too.
    final q =
        (db.select(
          db.sessionExercises,
        )..where((t) => t.sessionId.equals(sessionId))).join([
          innerJoin(
            db.exercises,
            db.exercises.id.equalsExp(db.sessionExercises.exerciseId),
          ),
          leftOuterJoin(
            db.sessionSets,
            db.sessionSets.sessionExerciseId.equalsExp(db.sessionExercises.id),
          ),
        ]);
    return q.watch().map((rows) {
      final byLink = <int, SessionExerciseData>{};
      for (final row in rows) {
        final link = row.readTable(db.sessionExercises);
        final exercise = row.readTable(db.exercises);
        final set = row.readTableOrNull(db.sessionSets);
        final data = byLink.putIfAbsent(
          link.id,
          () => SessionExerciseData(link, exercise, []),
        );
        if (set != null) data.sets.add(set);
      }
      final result = byLink.values.toList()
        ..sort((a, b) => a.link.position.compareTo(b.link.position));
      for (final d in result) {
        d.sets.sort((a, b) => a.setNumber.compareTo(b.setNumber));
      }
      return result;
    });
  }

  Future<int> addExerciseToSession(int sessionId, int exerciseId) async {
    final count = await (db.select(
      db.sessionExercises,
    )..where((t) => t.sessionId.equals(sessionId))).get();
    final linkId = await db
        .into(db.sessionExercises)
        .insert(
          SessionExercisesCompanion.insert(
            sessionId: sessionId,
            exerciseId: exerciseId,
            position: count.length,
          ),
        );
    // Start with one empty set row, prefilled from last time.
    final last = await lastPerformance(exerciseId);
    await db
        .into(db.sessionSets)
        .insert(
          SessionSetsCompanion.insert(
            sessionExerciseId: linkId,
            setNumber: 1,
            weightKg: Value(last?.sets.firstOrNull?.weightKg),
            reps: Value(last?.sets.firstOrNull?.reps),
          ),
        );
    return linkId;
  }

  Future<void> removeSessionExercise(int linkId) async {
    await (db.delete(
      db.sessionSets,
    )..where((t) => t.sessionExerciseId.equals(linkId))).go();
    await (db.delete(
      db.sessionExercises,
    )..where((t) => t.id.equals(linkId))).go();
  }

  // ----- Sets -----

  Future<int> addSet(int linkId) async {
    final existing =
        await (db.select(db.sessionSets)
              ..where((t) => t.sessionExerciseId.equals(linkId))
              ..orderBy([(t) => OrderingTerm.desc(t.setNumber)]))
            .get();
    final prev = existing.firstOrNull;
    return db
        .into(db.sessionSets)
        .insert(
          SessionSetsCompanion.insert(
            sessionExerciseId: linkId,
            setNumber: (prev?.setNumber ?? 0) + 1,
            weightKg: Value(prev?.weightKg),
            reps: Value(prev?.reps),
          ),
        );
  }

  Future<void> updateSet(int setId, SessionSetsCompanion changes) => (db.update(
    db.sessionSets,
  )..where((t) => t.id.equals(setId))).write(changes);

  Future<void> deleteSet(int setId) =>
      (db.delete(db.sessionSets)..where((t) => t.id.equals(setId))).go();

  // ----- History -----

  /// Most recent finished session containing [exerciseId], with its sets.
  Future<LastPerformance?> lastPerformance(int exerciseId) async {
    final rows =
        await (db.select(db.sessionExercises).join([
                innerJoin(
                  db.workoutSessions,
                  db.workoutSessions.id.equalsExp(
                    db.sessionExercises.sessionId,
                  ),
                ),
              ])
              ..where(
                db.sessionExercises.exerciseId.equals(exerciseId) &
                    db.workoutSessions.finishedAt.isNotNull(),
              )
              ..orderBy([
                OrderingTerm.desc(db.workoutSessions.finishedAt),
                OrderingTerm.desc(db.workoutSessions.id),
              ])
              ..limit(1))
            .get();
    if (rows.isEmpty) return null;
    final link = rows.single.readTable(db.sessionExercises);
    final session = rows.single.readTable(db.workoutSessions);
    final sets =
        await (db.select(db.sessionSets)
              ..where((t) => t.sessionExerciseId.equals(link.id))
              ..orderBy([(t) => OrderingTerm.asc(t.setNumber)]))
            .get();
    return LastPerformance(session.finishedAt!, sets);
  }

  /// Full history for one exercise: (session, sets) newest first.
  Future<List<(WorkoutSession, List<SessionSet>)>> exerciseHistory(
    int exerciseId, {
    int limit = 30,
  }) async {
    final rows =
        await (db.select(db.sessionExercises).join([
                innerJoin(
                  db.workoutSessions,
                  db.workoutSessions.id.equalsExp(
                    db.sessionExercises.sessionId,
                  ),
                ),
              ])
              ..where(
                db.sessionExercises.exerciseId.equals(exerciseId) &
                    db.workoutSessions.finishedAt.isNotNull(),
              )
              ..orderBy([
                OrderingTerm.desc(db.workoutSessions.finishedAt),
                OrderingTerm.desc(db.workoutSessions.id),
              ])
              ..limit(limit))
            .get();
    final result = <(WorkoutSession, List<SessionSet>)>[];
    for (final row in rows) {
      final link = row.readTable(db.sessionExercises);
      final session = row.readTable(db.workoutSessions);
      final sets =
          await (db.select(db.sessionSets)
                ..where((t) => t.sessionExerciseId.equals(link.id))
                ..orderBy([(t) => OrderingTerm.asc(t.setNumber)]))
              .get();
      result.add((session, sets));
    }
    return result;
  }

  /// Completed working sets grouped by the exercise library's muscle group.
  Future<List<VolumeLandmark>> recentVolume({int days = 7}) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final rows =
        await (db.select(db.sessionSets).join([
              innerJoin(
                db.sessionExercises,
                db.sessionExercises.id.equalsExp(
                  db.sessionSets.sessionExerciseId,
                ),
              ),
              innerJoin(
                db.exercises,
                db.exercises.id.equalsExp(db.sessionExercises.exerciseId),
              ),
              innerJoin(
                db.workoutSessions,
                db.workoutSessions.id.equalsExp(db.sessionExercises.sessionId),
              ),
            ])..where(
              db.sessionSets.completedAt.isNotNull() &
                  db.workoutSessions.finishedAt.isNotNull() &
                  db.workoutSessions.finishedAt.isBiggerThanValue(cutoff),
            ))
            .get();
    final counts = <String, int>{};
    for (final row in rows) {
      final group = row.readTable(db.exercises).muscleGroup ?? 'other';
      counts[group] = (counts[group] ?? 0) + 1;
    }
    final groups = counts.keys.toList()..sort();
    return [
      for (final group in groups) makeVolumeLandmark(group, counts[group]!),
    ];
  }

  /// Heaviest completed set and highest rep count recorded for each exercise.
  Future<List<PersonalRecord>> personalRecords({int days = 3650}) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final rows =
        await (db.select(db.sessionSets).join([
              innerJoin(
                db.sessionExercises,
                db.sessionExercises.id.equalsExp(
                  db.sessionSets.sessionExerciseId,
                ),
              ),
              innerJoin(
                db.exercises,
                db.exercises.id.equalsExp(db.sessionExercises.exerciseId),
              ),
              innerJoin(
                db.workoutSessions,
                db.workoutSessions.id.equalsExp(db.sessionExercises.sessionId),
              ),
            ])..where(
              db.sessionSets.completedAt.isNotNull() &
                  db.workoutSessions.finishedAt.isNotNull() &
                  db.workoutSessions.finishedAt.isBiggerThanValue(cutoff),
            ))
            .get();
    final byName = <String, PersonalRecord>{};
    for (final row in rows) {
      final set = row.readTable(db.sessionSets);
      final exercise = row.readTable(db.exercises);
      final session = row.readTable(db.workoutSessions);
      if (set.weightKg == null ||
          set.reps == null ||
          session.finishedAt == null) {
        continue;
      }
      final old = byName[exercise.name];
      if (old == null ||
          set.weightKg! > old.maxWeightKg ||
          (set.weightKg == old.maxWeightKg && set.reps! > old.bestReps)) {
        byName[exercise.name] = PersonalRecord(
          exerciseName: exercise.name,
          maxWeightKg: set.weightKg!,
          bestReps: set.reps!,
          lastPerformed: session.finishedAt!,
        );
      }
    }
    return byName.values.toList()
      ..sort((a, b) => b.lastPerformed.compareTo(a.lastPerformed));
  }

  Future<PlanExercise?> planExerciseForSessionExercise(
    SessionExercise link,
  ) async {
    final session = await (db.select(
      db.workoutSessions,
    )..where((t) => t.id.equals(link.sessionId))).getSingleOrNull();
    if (session?.planWorkoutId == null) return null;
    return (db.select(db.planExercises)..where(
          (t) =>
              t.planWorkoutId.equals(session!.planWorkoutId!) &
              t.exerciseId.equals(link.exerciseId),
        ))
        .getSingleOrNull();
  }
}

extension PlanQueries on TrainingRepository {
  Stream<List<WorkoutPlan>> watchPlans() =>
      (db.select(db.workoutPlans)
            ..where((t) => t.archived.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<int> createPlan(String name) =>
      db.into(db.workoutPlans).insert(WorkoutPlansCompanion.insert(name: name));

  Future<void> archivePlan(int planId) =>
      (db.update(db.workoutPlans)..where((t) => t.id.equals(planId))).write(
        const WorkoutPlansCompanion(archived: Value(true)),
      );

  Stream<List<PlanWorkout>> watchPlanWorkouts(int planId) =>
      (db.select(db.planWorkouts)
            ..where((t) => t.planId.equals(planId))
            ..orderBy([(t) => OrderingTerm.asc(t.position)]))
          .watch();

  Future<int> addPlanWorkout(int planId, String name) async {
    final existing = await (db.select(
      db.planWorkouts,
    )..where((t) => t.planId.equals(planId))).get();
    return db
        .into(db.planWorkouts)
        .insert(
          PlanWorkoutsCompanion.insert(
            planId: planId,
            name: name,
            position: existing.length,
          ),
        );
  }

  Future<void> deletePlanWorkout(int workoutId) async {
    await (db.delete(
      db.planExercises,
    )..where((t) => t.planWorkoutId.equals(workoutId))).go();
    await (db.delete(
      db.planWorkouts,
    )..where((t) => t.id.equals(workoutId))).go();
  }

  Stream<List<(PlanExercise, Exercise)>> watchPlanExercises(int workoutId) {
    final q =
        (db.select(db.planExercises)
              ..where((t) => t.planWorkoutId.equals(workoutId))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .join([
              innerJoin(
                db.exercises,
                db.exercises.id.equalsExp(db.planExercises.exerciseId),
              ),
            ]);
    return q.watch().map(
      (rows) => rows
          .map(
            (r) => (r.readTable(db.planExercises), r.readTable(db.exercises)),
          )
          .toList(),
    );
  }

  Future<int> addPlanExercise(
    int workoutId,
    int exerciseId, {
    int targetSets = 3,
    int? repMin,
    int? repMax,
    String progressionMode = 'manual',
  }) async {
    final existing = await (db.select(
      db.planExercises,
    )..where((t) => t.planWorkoutId.equals(workoutId))).get();
    return db
        .into(db.planExercises)
        .insert(
          PlanExercisesCompanion.insert(
            planWorkoutId: workoutId,
            exerciseId: exerciseId,
            position: existing.length,
            targetSets: Value(targetSets),
            repMin: Value(repMin),
            repMax: Value(repMax),
            progressionMode: Value(progressionMode),
          ),
        );
  }

  Future<int> createStarterTemplate(StarterTemplate template) async {
    final available = await db.select(db.exercises).get();
    final byName = <String, Exercise>{
      for (final exercise in available) exercise.name.toLowerCase(): exercise,
    };
    final planId = await createPlan(template.name);
    for (final workout in template.workouts) {
      final workoutId = await addPlanWorkout(planId, workout.name);
      for (final item in workout.exercises) {
        final existing = byName[item.name.toLowerCase()];
        final exerciseId = existing?.id ?? await addCustomExercise(item.name);
        await addPlanExercise(
          workoutId,
          exerciseId,
          targetSets: item.sets,
          repMin: item.repMin,
          repMax: item.repMax,
          progressionMode: 'progressive',
        );
      }
    }
    return planId;
  }

  Future<void> updatePlanExercise(int id, PlanExercisesCompanion changes) =>
      (db.update(
        db.planExercises,
      )..where((t) => t.id.equals(id))).write(changes);

  Future<void> deletePlanExercise(int id) =>
      (db.delete(db.planExercises)..where((t) => t.id.equals(id))).go();

  /// Next workout by sequence: the one after the last finished session of
  /// this plan (wrapping), or the first if none yet. No calendar, no
  /// "missed" state — the plan simply waits.
  Future<PlanWorkout?> nextPlanWorkout(int planId) async {
    final workouts =
        await (db.select(db.planWorkouts)
              ..where((t) => t.planId.equals(planId))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    if (workouts.isEmpty) return null;
    final ids = workouts.map((w) => w.id).toList();
    final lastSession =
        await (db.select(db.workoutSessions)
              ..where(
                (t) => t.planWorkoutId.isIn(ids) & t.finishedAt.isNotNull(),
              )
              ..orderBy([
                (t) => OrderingTerm.desc(t.finishedAt),
                (t) => OrderingTerm.desc(t.id),
              ])
              ..limit(1))
            .getSingleOrNull();
    if (lastSession == null) return workouts.first;
    final lastIndex = workouts.indexWhere(
      (w) => w.id == lastSession.planWorkoutId,
    );
    return workouts[(lastIndex + 1) % workouts.length];
  }

  /// Start a session from a plan workout: adds each exercise with its
  /// target set count, prefilled from last performance.
  Future<int> startPlanSession(PlanWorkout workout) async {
    final sessionId = await startSession(
      planWorkoutId: workout.id,
      title: workout.name,
    );
    final planExercises =
        await (db.select(db.planExercises)
              ..where((t) => t.planWorkoutId.equals(workout.id))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    for (var i = 0; i < planExercises.length; i++) {
      final pe = planExercises[i];
      final linkId = await db
          .into(db.sessionExercises)
          .insert(
            SessionExercisesCompanion.insert(
              sessionId: sessionId,
              exerciseId: pe.exerciseId,
              position: i,
            ),
          );
      final last = await lastPerformance(pe.exerciseId);
      for (var s = 1; s <= pe.targetSets; s++) {
        final prev = last != null && last.sets.length >= s
            ? last.sets[s - 1]
            : null;
        await db
            .into(db.sessionSets)
            .insert(
              SessionSetsCompanion.insert(
                sessionExerciseId: linkId,
                setNumber: s,
                weightKg: Value(prev?.weightKg),
                reps: Value(prev?.reps),
              ),
            );
      }
    }
    return sessionId;
  }
}

final trainingRepositoryProvider = Provider<TrainingRepository>(
  (ref) => TrainingRepository(ref.watch(databaseProvider)),
);

final exercisesProvider = StreamProvider<List<Exercise>>(
  (ref) => ref.watch(trainingRepositoryProvider).watchExercises(),
);

final activeSessionProvider = StreamProvider<WorkoutSession?>(
  (ref) => ref.watch(trainingRepositoryProvider).watchActiveSession(),
);

final sessionExercisesProvider = StreamProvider.autoDispose
    .family<List<SessionExerciseData>, int>(
      (ref, sessionId) => ref
          .watch(trainingRepositoryProvider)
          .watchSessionExercises(sessionId),
    );

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';
import '../../core/database/database_provider.dart';
import 'protocols.dart';

String growthDayKey(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

class GrowthRepository {
  GrowthRepository(this.db);

  final AppDatabase db;

  Stream<List<Habit>> watchHabits() =>
      (db.select(db.habits)..orderBy([(h) => OrderingTerm.asc(h.name)])).watch();

  Stream<List<HabitLog>> watchLogs(String day) =>
      (db.select(db.habitLogs)..where((l) => l.day.equals(day))).watch();

  Future<int> addPreset(ProtocolPreset preset) => db.into(db.habits).insert(
        HabitsCompanion.insert(
          name: preset.name,
          purpose: Value(preset.purpose),
          protocol: Value(preset.protocol),
          scheduleType: Value(
              preset.suggestedWeeklyTarget == null ? 'none' : 'weekly'),
          weeklyTarget: Value(preset.suggestedWeeklyTarget),
          durationMin: Value(preset.durationMin),
          minimumVersion: Value(preset.minimumVersion),
          evidenceLevel: Value(preset.evidenceLevel),
          safetyNotes: Value(preset.safetyNotes),
          source: Value(preset.source),
          reviewAfterDays: Value(preset.reviewAfterDays),
        ),
      );

  Future<int> addCustom({
    required String name,
    String? purpose,
    String? protocol,
    String? minimumVersion,
    int? weeklyTarget,
  }) =>
      db.into(db.habits).insert(HabitsCompanion.insert(
            name: name,
            purpose: Value(purpose),
            protocol: Value(protocol),
            scheduleType: Value(weeklyTarget == null ? 'none' : 'weekly'),
            weeklyTarget: Value(weeklyTarget),
            minimumVersion: Value(minimumVersion),
            evidenceLevel: const Value('Personal preference'),
          ));

  Future<void> updateHabit(int id, HabitsCompanion changes) =>
      (db.update(db.habits)..where((h) => h.id.equals(id))).write(changes);

  Future<void> deleteHabit(int id) async {
    await (db.delete(db.habitLogs)..where((l) => l.habitId.equals(id))).go();
    await (db.delete(db.habits)..where((h) => h.id.equals(id))).go();
  }

  Future<void> setLog({
    required int habitId,
    required String day,
    required String status,
  }) async {
    final existing = await (db.select(db.habitLogs)
          ..where((l) => l.habitId.equals(habitId) & l.day.equals(day)))
        .getSingleOrNull();
    if (existing == null) {
      await db.into(db.habitLogs).insert(HabitLogsCompanion.insert(
            habitId: habitId,
            day: day,
            status: status,
          ));
    } else {
      await (db.update(db.habitLogs)..where((l) => l.id.equals(existing.id)))
          .write(HabitLogsCompanion(status: Value(status)));
    }
  }

  Future<void> clearLog(int habitId, String day) async {
    await (db.delete(db.habitLogs)
          ..where((l) => l.habitId.equals(habitId) & l.day.equals(day)))
        .go();
  }

  Stream<List<LifeGoal>> watchGoals() =>
      (db.select(db.goals)..orderBy([(g) => OrderingTerm.asc(g.name)])).watch();

  Future<int> addGoal({
    required String name,
    String? target,
    String kind = 'custom',
    DateTime? deadline,
  }) =>
      db.into(db.goals).insert(GoalsCompanion.insert(
            name: name,
            kind: Value(kind),
            target: Value(target),
            deadline: Value(deadline),
          ));

  Future<void> updateGoal(int id, GoalsCompanion changes) =>
      (db.update(db.goals)..where((g) => g.id.equals(id))).write(changes);

  Future<void> deleteGoal(int id) =>
      (db.delete(db.goals)..where((g) => g.id.equals(id))).go();
}

final growthRepositoryProvider = Provider<GrowthRepository>(
    (ref) => GrowthRepository(ref.watch(databaseProvider)));

final growthHabitsProvider = StreamProvider<List<Habit>>(
    (ref) => ref.watch(growthRepositoryProvider).watchHabits());

final growthLogsProvider = StreamProvider<List<HabitLog>>((ref) => ref
    .watch(growthRepositoryProvider)
    .watchLogs(growthDayKey(DateTime.now())));

final growthGoalsProvider = StreamProvider<List<LifeGoal>>(
    (ref) => ref.watch(growthRepositoryProvider).watchGoals());

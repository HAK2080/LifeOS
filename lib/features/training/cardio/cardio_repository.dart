import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/database.dart';
import '../../../core/database/database_provider.dart';

class CardioRepository {
  CardioRepository(this.db);

  final AppDatabase db;

  Stream<List<Zone2Session>> watchByKind(String kind, {int limit = 60}) =>
      (db.select(db.zone2Sessions)
            ..where((t) => t.kind.equals(kind))
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
            ..limit(limit))
          .watch();

  Future<int> log({
    required String kind,
    required String activity,
    required int durationMin,
    DateTime? startedAt,
    int? inZoneMin,
    int? avgHr,
    int? steps,
    String? notes,
  }) =>
      db.into(db.zone2Sessions).insert(Zone2SessionsCompanion.insert(
            kind: Value(kind),
            activity: activity,
            durationMin: durationMin,
            startedAt: startedAt == null ? const Value.absent() : Value(startedAt),
            inZoneMin: Value(inZoneMin),
            avgHr: Value(avgHr),
            steps: Value(steps),
            notes: Value(notes),
          ));

  Future<void> delete(int id) =>
      (db.delete(db.zone2Sessions)..where((t) => t.id.equals(id))).go();

  /// Total minutes this week (Mon–Sun) for a kind, across activities.
  Future<int> minutesThisWeek(String kind, {DateTime? now}) async {
    final today = now ?? DateTime.now();
    final monday = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: today.weekday - 1));
    final rows = await (db.select(db.zone2Sessions)
          ..where((t) =>
              t.kind.equals(kind) &
              t.startedAt.isBiggerOrEqualValue(monday)))
        .get();
    return rows.fold<int>(0, (sum, r) => sum + r.durationMin);
  }

  /// Steps logged today (walking entries).
  Future<int> stepsToday({DateTime? now}) async {
    final today = now ?? DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final rows = await (db.select(db.zone2Sessions)
          ..where((t) =>
              t.kind.equals('walking') &
              t.startedAt.isBiggerOrEqualValue(start)))
        .get();
    return rows.fold<int>(0, (sum, r) => sum + (r.steps ?? 0));
  }
}

final cardioRepositoryProvider = Provider<CardioRepository>(
    (ref) => CardioRepository(ref.watch(databaseProvider)));

final zone2SessionsProvider = StreamProvider<List<Zone2Session>>(
    (ref) => ref.watch(cardioRepositoryProvider).watchByKind('zone2'));

final walkingSessionsProvider = StreamProvider<List<Zone2Session>>(
    (ref) => ref.watch(cardioRepositoryProvider).watchByKind('walking'));

final mobilitySessionsProvider = StreamProvider<List<Zone2Session>>(
    (ref) => ref.watch(cardioRepositoryProvider).watchByKind('mobility'));

/// Weekly Zone 2 target in minutes; last-used activity/duration defaults.
final zone2PrefsProvider =
    AsyncNotifierProvider<Zone2PrefsNotifier, Zone2Prefs>(Zone2PrefsNotifier.new);

class Zone2Prefs {
  const Zone2Prefs(
      {this.weeklyTargetMin = 150,
      this.lastActivity = 'Bike',
      this.lastDurationMin = 30,
      this.dailyStepTarget});

  final int weeklyTargetMin;
  final String lastActivity;
  final int lastDurationMin;
  final int? dailyStepTarget;
}

class Zone2PrefsNotifier extends AsyncNotifier<Zone2Prefs> {
  @override
  Future<Zone2Prefs> build() async {
    final p = await SharedPreferences.getInstance();
    return Zone2Prefs(
      weeklyTargetMin: p.getInt('z2_weekly_target') ?? 150,
      lastActivity: p.getString('z2_last_activity') ?? 'Bike',
      lastDurationMin: p.getInt('z2_last_duration') ?? 30,
      dailyStepTarget: p.getInt('walk_step_target'),
    );
  }

  Future<void> save(
      {int? weeklyTargetMin,
      String? lastActivity,
      int? lastDurationMin,
      int? dailyStepTarget,
      bool clearStepTarget = false}) async {
    final p = await SharedPreferences.getInstance();
    if (weeklyTargetMin != null) await p.setInt('z2_weekly_target', weeklyTargetMin);
    if (lastActivity != null) await p.setString('z2_last_activity', lastActivity);
    if (lastDurationMin != null) await p.setInt('z2_last_duration', lastDurationMin);
    if (dailyStepTarget != null) await p.setInt('walk_step_target', dailyStepTarget);
    if (clearStepTarget) await p.remove('walk_step_target');
    ref.invalidateSelf();
  }
}

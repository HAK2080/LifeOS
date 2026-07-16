import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/database/database.dart';
import '../../core/database/database_provider.dart';
import '../../core/notifications/notification_service.dart';
import 'protocols.dart';

String growthDayKey(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

class GrowthRepository {
  GrowthRepository(this.db, this.notifications);

  final AppDatabase db;
  final NotificationService notifications;

  Stream<List<Habit>> watchHabits() => (db.select(
    db.habits,
  )..orderBy([(h) => OrderingTerm.asc(h.name)])).watch();

  Stream<List<HabitLog>> watchLogs(String day) =>
      (db.select(db.habitLogs)..where((l) => l.day.equals(day))).watch();

  Future<void> ensureProtocolsSeeded() async {
    if ((await db.select(db.wellnessProtocols).get()).isNotEmpty) return;
    final raw = await rootBundle.loadString(
      'assets/data/wellness_protocols_v1.json',
    );
    final protocols = WellnessProtocolSpec.parseSeed(raw);
    await db.transaction(() async {
      final sourceIds = <String>{};
      for (final protocol in protocols) {
        await db
            .into(db.wellnessProtocols)
            .insert(
              WellnessProtocolsCompanion.insert(
                id: protocol.id,
                version: Value(protocol.version),
                category: protocol.category,
                categoryGroup: Value(protocol.categoryGroup),
                title: protocol.title,
                purpose: protocol.purpose,
                instructions: protocol.instructions,
                minimumVersion: protocol.minimumVersion,
                standardVersion: protocol.standardVersion,
                frequency: protocol.frequency,
                durationMinutes: Value(protocol.durationMinutes),
                bestTime: protocol.bestTime,
                evidenceLevel: protocol.evidenceLevel,
                safetyNotes: protocol.safetyNotes,
                reviewPeriodDays: Value(protocol.reviewPeriodDays),
              ),
            );
        for (final source in protocol.sources) {
          if (sourceIds.add(source.id)) {
            await db
                .into(db.wellnessSources)
                .insert(
                  WellnessSourcesCompanion.insert(
                    id: source.id,
                    title: source.title,
                    publisher: source.publisher,
                    url: source.url,
                  ),
                );
          }
          await db
              .into(db.wellnessProtocolSources)
              .insert(
                WellnessProtocolSourcesCompanion.insert(
                  protocolId: protocol.id,
                  sourceId: source.id,
                ),
              );
        }
      }
    });
  }

  Stream<List<WellnessProtocolSpec>> watchProtocols() async* {
    await ensureProtocolsSeeded();
    final rows = await db.select(db.wellnessProtocols).get();
    final sources = await db.select(db.wellnessSources).get();
    final links = await db.select(db.wellnessProtocolSources).get();
    final sourcesById = {for (final source in sources) source.id: source};
    WellnessProtocolSpec toProtocol(WellnessProtocol row) {
      final sourceIds = links
          .where((link) => link.protocolId == row.id)
          .map((link) => link.sourceId);
      return WellnessProtocolSpec(
        id: row.id,
        version: row.version,
        category: row.category,
        categoryGroup: row.categoryGroup,
        title: row.title,
        purpose: row.purpose,
        instructions: row.instructions,
        minimumVersion: row.minimumVersion,
        standardVersion: row.standardVersion,
        frequency: row.frequency,
        durationMinutes: row.durationMinutes,
        bestTime: row.bestTime,
        evidenceLevel: row.evidenceLevel,
        safetyNotes: row.safetyNotes,
        reviewPeriodDays: row.reviewPeriodDays,
        sources: sourceIds
            .map((id) => sourcesById[id])
            .whereType<WellnessSource>()
            .map(
              (source) => WellnessSourceSpec(
                id: source.id,
                title: source.title,
                publisher: source.publisher,
                url: source.url,
              ),
            )
            .toList(growable: false),
      );
    }

    yield rows.map(toProtocol).toList(growable: false);
  }

  Future<int> addProtocol(WellnessProtocolSpec protocol) => db
      .into(db.habits)
      .insert(
        HabitsCompanion.insert(
          protocolId: Value(protocol.id),
          name: protocol.title,
          purpose: Value(protocol.purpose),
          protocol: Value(protocol.instructions),
          scheduleType: const Value('none'),
          durationMin: Value(protocol.durationMinutes),
          minimumVersion: Value(protocol.minimumVersion),
          evidenceLevel: Value(protocol.evidenceLevel),
          safetyNotes: Value(protocol.safetyNotes),
          source: Value(protocol.sources.map((s) => s.title).join('; ')),
          reviewAfterDays: Value(protocol.reviewPeriodDays),
        ),
      );

  Future<int> addCustom({
    required String name,
    String? purpose,
    String? protocol,
    String? minimumVersion,
    int? weeklyTarget,
  }) => db
      .into(db.habits)
      .insert(
        HabitsCompanion.insert(
          name: name,
          purpose: Value(purpose),
          protocol: Value(protocol),
          scheduleType: Value(weeklyTarget == null ? 'none' : 'weekly'),
          weeklyTarget: Value(weeklyTarget),
          minimumVersion: Value(minimumVersion),
          evidenceLevel: const Value('Personal preference'),
        ),
      );

  Future<void> updateHabit(int id, HabitsCompanion changes) =>
      (db.update(db.habits)..where((h) => h.id.equals(id))).write(changes);

  Future<void> setSchedule({
    required Habit habit,
    required String type,
    required List<int> days,
    int? weeklyTarget,
  }) async {
    await updateHabit(
      habit.id,
      HabitsCompanion(
        scheduleType: Value(type),
        fixedDays: Value(days.isEmpty ? null : days.join(',')),
        weeklyTarget: Value(weeklyTarget),
      ),
    );
  }

  Future<void> setReminder({
    required Habit habit,
    required int hour,
    required int minute,
  }) async {
    final time =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    await updateHabit(habit.id, HabitsCompanion(reminderTime: Value(time)));
    await notifications.scheduleHabitReminder(
      habitId: habit.id,
      title: habit.name,
      hour: hour,
      minute: minute,
    );
  }

  Future<void> clearReminder(int habitId) async {
    await updateHabit(
      habitId,
      const HabitsCompanion(reminderTime: Value(null)),
    );
    await notifications.cancelHabitReminder(habitId);
  }

  Future<void> markReviewed(int habitId) => updateHabit(
    habitId,
    HabitsCompanion(lastReviewAt: Value(DateTime.now())),
  );

  Future<void> deleteHabit(int id) async {
    final habit = await (db.select(
      db.habits,
    )..where((h) => h.id.equals(id))).getSingleOrNull();
    if (habit?.reminderTime != null) {
      await notifications.cancelHabitReminder(id);
    }
    await (db.delete(db.habitReviews)..where((r) => r.habitId.equals(id))).go();
    await (db.delete(db.habitLogs)..where((l) => l.habitId.equals(id))).go();
    await (db.delete(db.habits)..where((h) => h.id.equals(id))).go();
  }

  Future<void> addReview({
    required int habitId,
    required String outcome,
    bool? helped,
    String? notes,
  }) async {
    await db
        .into(db.habitReviews)
        .insert(
          HabitReviewsCompanion.insert(
            habitId: habitId,
            outcome: outcome,
            helped: Value(helped),
            notes: Value(notes),
          ),
        );
    final status = switch (outcome) {
      'pause' => 'paused',
      'stop' => 'stopped',
      _ => 'active',
    };
    await updateHabit(
      habitId,
      HabitsCompanion(
        status: Value(status),
        lastReviewAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setLog({
    required int habitId,
    required String day,
    required String status,
  }) async {
    final existing =
        await (db.select(db.habitLogs)
              ..where((l) => l.habitId.equals(habitId) & l.day.equals(day)))
            .getSingleOrNull();
    if (existing == null) {
      await db
          .into(db.habitLogs)
          .insert(
            HabitLogsCompanion.insert(
              habitId: habitId,
              day: day,
              status: status,
            ),
          );
    } else {
      await (db.update(db.habitLogs)..where((l) => l.id.equals(existing.id)))
          .write(HabitLogsCompanion(status: Value(status)));
    }
  }

  Future<void> clearLog(int habitId, String day) async {
    await (db.delete(
      db.habitLogs,
    )..where((l) => l.habitId.equals(habitId) & l.day.equals(day))).go();
  }

  /// Recent per-day records for a practice. The UI can show a calendar-like
  /// review without calculating streaks or assigning a score.
  Future<List<HabitLog>> habitHistory(int habitId, {int days = 28}) async {
    final start = growthDayKey(
      DateTime.now().subtract(Duration(days: days - 1)),
    );
    final logs =
        await (db.select(db.habitLogs)
              ..where((l) => l.habitId.equals(habitId))
              ..orderBy([(l) => OrderingTerm.desc(l.day)]))
            .get();
    return logs.where((log) => log.day.compareTo(start) >= 0).toList();
  }

  Stream<List<LifeGoal>> watchGoals() =>
      (db.select(db.goals)..orderBy([(g) => OrderingTerm.asc(g.name)])).watch();

  Future<int> addGoal({
    required String name,
    String? target,
    String kind = 'custom',
    DateTime? deadline,
  }) => db
      .into(db.goals)
      .insert(
        GoalsCompanion.insert(
          name: name,
          kind: Value(kind),
          target: Value(target),
          deadline: Value(deadline),
        ),
      );

  Future<void> updateGoal(int id, GoalsCompanion changes) =>
      (db.update(db.goals)..where((g) => g.id.equals(id))).write(changes);

  Future<void> deleteGoal(int id) =>
      (db.delete(db.goals)..where((g) => g.id.equals(id))).go();

  /// A deliberately lightweight automatic link. It reports useful activity
  /// without forcing the user to manually classify every action.
  Future<int> contributionCount(LifeGoal goal) async {
    switch (goal.kind) {
      case 'habit':
        final logs =
            await (db.select(db.habitLogs)..where(
                  (l) =>
                      l.status.equals('completed') | l.status.equals('minimum'),
                ))
                .get();
        return logs.length;
      case 'training':
        final sessions = await (db.select(
          db.workoutSessions,
        )..where((s) => s.finishedAt.isNotNull())).get();
        return sessions.length;
      case 'nutrition':
        final logs = await db.select(db.mealLogs).get();
        return logs.map((l) => l.day).toSet().length;
      case 'cardio':
        final sessions = await (db.select(
          db.zone2Sessions,
        )..where((s) => s.kind.equals('zone2'))).get();
        return sessions.fold<int>(0, (sum, s) => sum + s.durationMin);
      default:
        return 0;
    }
  }
}

final growthRepositoryProvider = Provider<GrowthRepository>(
  (ref) => GrowthRepository(
    ref.watch(databaseProvider),
    ref.watch(notificationServiceProvider),
  ),
);

final growthHabitsProvider = StreamProvider<List<Habit>>(
  (ref) => ref.watch(growthRepositoryProvider).watchHabits(),
);

final growthProtocolsProvider = StreamProvider<List<WellnessProtocolSpec>>(
  (ref) => ref.watch(growthRepositoryProvider).watchProtocols(),
);

final growthDayProvider = NotifierProvider<GrowthDayNotifier, String>(
  GrowthDayNotifier.new,
);

class GrowthDayNotifier extends Notifier<String> {
  @override
  String build() => growthDayKey(DateTime.now());

  void select(String day) => state = day;
}

final growthLogsProvider = StreamProvider.autoDispose
    .family<List<HabitLog>, String>(
      (ref, day) => ref.watch(growthRepositoryProvider).watchLogs(day),
    );

final growthGoalsProvider = StreamProvider<List<LifeGoal>>(
  (ref) => ref.watch(growthRepositoryProvider).watchGoals(),
);

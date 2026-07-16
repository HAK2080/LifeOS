import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:life_app/core/database/database.dart';
import 'package:life_app/features/growth/growth_repository.dart';
import 'package:life_app/features/growth/wellness_protocols.dart';
import 'package:life_app/core/notifications/notification_service.dart';

import 'helpers/test_db.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GrowthRepository repo;
  late AppDatabase db;

  setUp(() {
    db = testDatabase();
    repo = GrowthRepository(db, NotificationService());
  });

  tearDown(() => db.close());

  test('seeds the versioned Wellness protocol library', () async {
    await repo.ensureProtocolsSeeded();
    final protocols = await db.select(db.wellnessProtocols).get();
    final sources = await db.select(db.wellnessSources).get();
    expect(protocols, hasLength(15));
    expect(sources, isNotEmpty);
    expect(protocols.map((p) => p.category), contains('Morning light'));
  });

  test('adds a protocol and records one daily completion state', () async {
    final raw = await rootBundle.loadString(
        'assets/data/wellness_protocols_v1.json');
    final id = await repo.addProtocol(WellnessProtocolSpec.parseSeed(raw).first);
    final habits = await db.select(db.habits).get();
    expect(habits.single.id, id);
    expect(habits.single.name, 'Sleep schedule');
    expect(habits.single.scheduleType, 'none');

    await repo.setLog(habitId: id, day: '2026-07-16', status: 'minimum');
    await repo.setLog(habitId: id, day: '2026-07-16', status: 'completed');
    final logs = await repo.db.select(repo.db.habitLogs).get();
    expect(logs, hasLength(1));
    expect(logs.single.status, 'completed');
    final goalId = await repo.addGoal(name: 'Practice consistency', kind: 'habit');
    final goal = await (repo.db.select(repo.db.goals)
          ..where((g) => g.id.equals(goalId)))
        .getSingle();
    expect(await repo.contributionCount(goal), 1);
  });

  test('removes a habit and its logs', () async {
    final id = await repo.addCustom(name: 'Custom practice');
    await repo.setLog(habitId: id, day: '2026-07-16', status: 'skipped');
    await repo.deleteHabit(id);
    expect(await repo.db.select(repo.db.habits).get(), isEmpty);
    expect(await repo.db.select(repo.db.habitLogs).get(), isEmpty);
  });

  test('creates and updates a lightweight goal', () async {
    final id = await repo.addGoal(name: 'Read consistently', target: '15 min');
    final goal = (await repo.db.select(repo.db.goals).get()).single;
    expect(goal.id, id);
    expect(goal.target, '15 min');
    await repo.updateGoal(id, const GoalsCompanion(status: Value('completed')));
    expect((await repo.db.select(repo.db.goals).get()).single.status, 'completed');
  });
}

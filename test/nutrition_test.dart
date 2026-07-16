import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:life_app/core/database/database.dart';
import 'package:life_app/features/nutrition/nutrition_logic.dart';
import 'package:life_app/features/nutrition/nutrition_repository.dart';

import 'helpers/test_db.dart';

void main() {
  group('suggestTargets', () {
    const base = Profile(weightKg: 80, heightCm: 180, age: 35);

    test('maintenance is plausible for 80kg/180cm/35y male', () {
      final t = suggestTargets(base);
      expect(t.calories, inInclusiveRange(2500, 3000));
      expect(t.proteinG, 144); // 1.8 g/kg
      expect(t.explanation, contains('suggestions'));
    });

    test('fat-loss target is below maintenance, surplus above', () {
      final maintain = suggestTargets(base);
      final cut = suggestTargets(const Profile(
          weightKg: 80, heightCm: 180, age: 35, goal: Goal.loseFat));
      final bulk = suggestTargets(const Profile(
          weightKg: 80, heightCm: 180, age: 35, goal: Goal.buildMuscle));
      expect(cut.calories, lessThan(maintain.calories));
      expect(bulk.calories, greaterThan(maintain.calories));
    });

    test('macros are internally consistent', () {
      final t = suggestTargets(base);
      final kcalFromMacros =
          t.proteinG * 4 + t.carbsG * 4 + t.fatG * 9;
      expect((kcalFromMacros - t.calories).abs(), lessThan(20));
    });
  });

  group('weightTrend', () {
    test('smooths a noisy series', () {
      final trend = weightTrend([80, 81, 79, 80.5, 79.5]);
      expect(trend.length, 5);
      // Trend never overshoots the raw jump.
      expect((trend[1] - trend[0]).abs(), lessThan(1.0));
    });

    test('empty input → empty output', () {
      expect(weightTrend([]), isEmpty);
    });
  });

  group('enoughDataForTargetChange', () {
    test('true with 10 of last 14 days logged', () {
      final now = DateTime(2026, 7, 16);
      final days = {
        for (var i = 0; i < 10; i++)
          '2026-07-${(16 - i).toString().padLeft(2, '0')}'
      };
      expect(enoughDataForTargetChange(days, now: now), isTrue);
    });

    test('false with sparse logging', () {
      final now = DateTime(2026, 7, 16);
      expect(
          enoughDataForTargetChange({'2026-07-16', '2026-07-15'}, now: now),
          isFalse);
    });
  });

  group('NutritionRepository', () {
    late AppDatabase db;
    late NutritionRepository repo;

    setUp(() {
      db = testDatabase();
      repo = NutritionRepository(db);
    });
    tearDown(() => db.close());

    test('portion scaling applies to all macros', () async {
      final id = await repo.saveMeal(
          name: 'Chicken & rice',
          calories: 600,
          proteinG: 45,
          carbsG: 70,
          fatG: 12);
      await repo.logMeal(
          day: '2026-07-16',
          name: 'Chicken & rice',
          calories: 600,
          proteinG: 45,
          carbsG: 70,
          fatG: 12,
          mealId: id,
          portion: 0.8);
      final logs = await repo.watchLogs('2026-07-16').first;
      expect(logs.single.calories, closeTo(480, 0.01));
      expect(logs.single.proteinG, closeTo(36, 0.01));
      expect(logs.single.portion, 0.8);
    });

    test('totals sum the day', () async {
      await repo.logMeal(
          day: '2026-07-16', name: 'A', calories: 300, proteinG: 20);
      await repo.logMeal(
          day: '2026-07-16', name: 'B', calories: 450, proteinG: 30);
      await repo.logMeal(
          day: '2026-07-15', name: 'other day', calories: 999);
      final logs = await repo.watchLogs('2026-07-16').first;
      final totals = repo.totals(logs);
      expect(totals.calories, 750);
      expect(totals.proteinG, 50);
    });

    test('frequent meals ranks pinned first, then by log count', () async {
      final a = await repo.saveMeal(name: 'Oats', calories: 350);
      final b = await repo.saveMeal(name: 'Eggs', calories: 250);
      final c = await repo.saveMeal(name: 'Shake', calories: 200);
      // Log Eggs twice, Oats once.
      for (final (id, n) in [(a, 1), (b, 2)]) {
        for (var i = 0; i < n; i++) {
          await repo.logMeal(
              day: '2026-07-1$i', name: 'x', calories: 1, mealId: id);
        }
      }
      await repo.updateMeal(
          c, const MealsCompanion(pinned: Value(true)));
      final frequent = await repo.frequentMeals();
      expect(frequent.first.id, c); // pinned wins
      expect(frequent[1].id, b); // most logged next
    });
  });
}

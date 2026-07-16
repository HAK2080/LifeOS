import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/database/database.dart';
import '../../core/database/database_provider.dart';
import '../today/today_data.dart' show dayKey;

class DayTotals {
  const DayTotals(this.calories, this.proteinG, this.carbsG, this.fatG);

  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
}

class NutritionRepository {
  NutritionRepository(this.db);

  final AppDatabase db;

  // ----- Saved meals -----

  Stream<List<Meal>> watchMeals({bool includeHidden = false}) {
    final q = db.select(db.meals)
      ..orderBy([
        (t) => OrderingTerm.desc(t.pinned),
        (t) => OrderingTerm.asc(t.name),
      ]);
    if (!includeHidden) q.where((t) => t.hidden.equals(false));
    return q.watch();
  }

  Future<int> saveMeal({
    required String name,
    required double calories,
    double proteinG = 0,
    double carbsG = 0,
    double fatG = 0,
  }) =>
      db.into(db.meals).insert(MealsCompanion.insert(
            name: name,
            calories: calories,
            proteinG: Value(proteinG),
            carbsG: Value(carbsG),
            fatG: Value(fatG),
          ));

  Future<void> updateMeal(int id, MealsCompanion changes) =>
      (db.update(db.meals)..where((t) => t.id.equals(id))).write(changes);

  Future<void> deleteMeal(int id) =>
      (db.delete(db.meals)..where((t) => t.id.equals(id))).go();

  // ----- Logging -----

  Stream<List<MealLog>> watchLogs(String day) => (db.select(db.mealLogs)
        ..where((t) => t.day.equals(day))
        ..orderBy([(t) => OrderingTerm.asc(t.loggedAt)]))
      .watch();

  Future<int> logMeal({
    required String day,
    required String name,
    required double calories,
    double proteinG = 0,
    double carbsG = 0,
    double fatG = 0,
    int? mealId,
    double portion = 1.0,
  }) =>
      db.into(db.mealLogs).insert(MealLogsCompanion.insert(
            day: day,
            name: name,
            mealId: Value(mealId),
            portion: Value(portion),
            calories: calories * portion,
            proteinG: Value(proteinG * portion),
            carbsG: Value(carbsG * portion),
            fatG: Value(fatG * portion),
          ));

  Future<void> deleteLog(int id) =>
      (db.delete(db.mealLogs)..where((t) => t.id.equals(id))).go();

  DayTotals totals(List<MealLog> logs) => DayTotals(
        logs.fold(0.0, (s, l) => s + l.calories),
        logs.fold(0.0, (s, l) => s + l.proteinG),
        logs.fold(0.0, (s, l) => s + l.carbsG),
        logs.fold(0.0, (s, l) => s + l.fatG),
      );

  /// Most frequently logged saved meals (for Quick Log).
  Future<List<Meal>> frequentMeals({int limit = 6}) async {
    final counts = <int, int>{};
    final logs = await db.select(db.mealLogs).get();
    for (final l in logs) {
      if (l.mealId != null) counts[l.mealId!] = (counts[l.mealId!] ?? 0) + 1;
    }
    final all = await (db.select(db.meals)
          ..where((t) => t.hidden.equals(false)))
        .get();
    all.sort((a, b) {
      final pinned = (b.pinned ? 1 : 0).compareTo(a.pinned ? 1 : 0);
      if (pinned != 0) return pinned;
      return (counts[b.id] ?? 0).compareTo(counts[a.id] ?? 0);
    });
    return all.take(limit).toList();
  }

  /// Days (yyyy-MM-dd) that have at least one log — for target-change gating.
  Future<Set<String>> daysWithLogs() async {
    final logs = await db.select(db.mealLogs).get();
    return logs.map((l) => l.day).toSet();
  }

  // ----- Weight -----

  Stream<List<WeightEntry>> watchWeights({int limit = 90}) =>
      (db.select(db.weightEntries)
            ..orderBy([(t) => OrderingTerm.desc(t.day)])
            ..limit(limit))
          .watch();

  Future<int> logWeight(double weightKg, {double? waistCm}) =>
      db.into(db.weightEntries).insert(WeightEntriesCompanion.insert(
            day: dayKey(DateTime.now()),
            weightKg: weightKg,
            waistCm: Value(waistCm),
          ));

  Future<void> deleteWeight(int id) =>
      (db.delete(db.weightEntries)..where((t) => t.id.equals(id))).go();
}

final nutritionRepositoryProvider = Provider<NutritionRepository>(
    (ref) => NutritionRepository(ref.watch(databaseProvider)));

final savedMealsProvider = StreamProvider<List<Meal>>(
    (ref) => ref.watch(nutritionRepositoryProvider).watchMeals());

final todayLogsProvider = StreamProvider<List<MealLog>>((ref) =>
    ref.watch(nutritionRepositoryProvider).watchLogs(dayKey(DateTime.now())));

final weightsProvider = StreamProvider<List<WeightEntry>>(
    (ref) => ref.watch(nutritionRepositoryProvider).watchWeights());

/// Approved macro targets (user-approved only; suggestions never auto-apply).
class ApprovedTargets {
  const ApprovedTargets(
      {this.calories, this.proteinG, this.carbsG, this.fatG});

  final int? calories;
  final int? proteinG;
  final int? carbsG;
  final int? fatG;

  bool get isSet => calories != null;
}

final approvedTargetsProvider =
    AsyncNotifierProvider<ApprovedTargetsNotifier, ApprovedTargets>(
        ApprovedTargetsNotifier.new);

class ApprovedTargetsNotifier extends AsyncNotifier<ApprovedTargets> {
  @override
  Future<ApprovedTargets> build() async {
    final p = await SharedPreferences.getInstance();
    return ApprovedTargets(
      calories: p.getInt('target_calories'),
      proteinG: p.getInt('target_protein'),
      carbsG: p.getInt('target_carbs'),
      fatG: p.getInt('target_fat'),
    );
  }

  Future<void> approve(
      {required int calories,
      required int proteinG,
      required int carbsG,
      required int fatG}) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('target_calories', calories);
    await p.setInt('target_protein', proteinG);
    await p.setInt('target_carbs', carbsG);
    await p.setInt('target_fat', fatG);
    ref.invalidateSelf();
  }
}

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

class RecipeIngredientDraft {
  const RecipeIngredientDraft({
    required this.name,
    required this.amount,
    required this.unit,
    this.foodId,
    this.calories = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
  });

  final int? foodId;
  final String name;
  final double amount;
  final String unit;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
}

class RecipeDetails {
  const RecipeDetails(this.recipe, this.ingredients);

  final Recipe recipe;
  final List<RecipeIngredient> ingredients;

  DayTotals get totals => DayTotals(
    ingredients.fold(0, (sum, item) => sum + item.calories),
    ingredients.fold(0, (sum, item) => sum + item.proteinG),
    ingredients.fold(0, (sum, item) => sum + item.carbsG),
    ingredients.fold(0, (sum, item) => sum + item.fatG),
  );

  DayTotals get perServing => DayTotals(
    totals.calories / recipe.servings,
    totals.proteinG / recipe.servings,
    totals.carbsG / recipe.servings,
    totals.fatG / recipe.servings,
  );
}

class NutritionRepository {
  NutritionRepository(this.db);

  final AppDatabase db;

  // ----- Food library -----

  Stream<List<Food>> watchFoods({bool includeHidden = false}) {
    final q = db.select(db.foods)
      ..orderBy([
        (t) => OrderingTerm.desc(t.pinned),
        (t) => OrderingTerm.asc(t.name),
      ]);
    if (!includeHidden) q.where((t) => t.hidden.equals(false));
    return q.watch();
  }

  Future<int> saveFood({
    required String name,
    String? brand,
    String? barcode,
    String servingLabel = '1 serving',
    double? servingGrams,
    required double calories,
    double proteinG = 0,
    double carbsG = 0,
    double fatG = 0,
    double fiberG = 0,
    String source = 'local',
  }) => db
      .into(db.foods)
      .insert(
        FoodsCompanion.insert(
          name: name,
          brand: Value(brand),
          barcode: Value(barcode),
          servingLabel: Value(servingLabel),
          servingGrams: Value(servingGrams),
          calories: calories,
          proteinG: Value(proteinG),
          carbsG: Value(carbsG),
          fatG: Value(fatG),
          fiberG: Value(fiberG),
          source: Value(source),
        ),
      );

  Future<void> updateFood(int id, FoodsCompanion changes) =>
      (db.update(db.foods)..where((t) => t.id.equals(id))).write(changes);

  Future<void> deleteFood(int id) =>
      (db.update(db.foods)..where((t) => t.id.equals(id))).write(
        const FoodsCompanion(hidden: Value(true)),
      );

  Future<int> logFood({
    required String day,
    required Food food,
    double portion = 1,
  }) => logMeal(
    day: day,
    name: food.name,
    calories: food.calories,
    proteinG: food.proteinG,
    carbsG: food.carbsG,
    fatG: food.fatG,
    portion: portion,
  );

  // ----- Recipes -----

  Stream<List<Recipe>> watchRecipes() =>
      (db.select(db.recipes)..orderBy([
            (t) => OrderingTerm.desc(t.pinned),
            (t) => OrderingTerm.asc(t.name),
          ]))
          .watch();

  Stream<List<RecipeIngredient>> watchRecipeIngredients(int recipeId) =>
      (db.select(db.recipeIngredients)
            ..where((t) => t.recipeId.equals(recipeId))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .watch();

  Future<RecipeDetails?> recipeDetails(int recipeId) async {
    final recipe = await (db.select(
      db.recipes,
    )..where((t) => t.id.equals(recipeId))).getSingleOrNull();
    if (recipe == null) return null;
    final ingredients = await (db.select(
      db.recipeIngredients,
    )..where((t) => t.recipeId.equals(recipeId))).get();
    return RecipeDetails(recipe, ingredients);
  }

  Future<int> createRecipe({
    required String name,
    double servings = 1,
    String? notes,
    String? instructions,
    List<RecipeIngredientDraft> ingredients = const [],
  }) async {
    final recipeId = await db
        .into(db.recipes)
        .insert(
          RecipesCompanion.insert(
            name: name,
            servings: Value(servings <= 0 ? 1 : servings),
            notes: Value(notes),
            instructions: Value(instructions),
          ),
        );
    for (final item in ingredients) {
      await db
          .into(db.recipeIngredients)
          .insert(
            RecipeIngredientsCompanion.insert(
              recipeId: recipeId,
              foodId: Value(item.foodId),
              name: item.name,
              amount: Value(item.amount),
              unit: Value(item.unit),
              calories: Value(item.calories),
              proteinG: Value(item.proteinG),
              carbsG: Value(item.carbsG),
              fatG: Value(item.fatG),
            ),
          );
    }
    return recipeId;
  }

  Future<void> deleteRecipe(int id) async {
    await (db.delete(
      db.recipeIngredients,
    )..where((t) => t.recipeId.equals(id))).go();
    await (db.delete(db.recipes)..where((t) => t.id.equals(id))).go();
  }

  Future<int?> logRecipe({
    required String day,
    required int recipeId,
    double portion = 1,
  }) async {
    final details = await recipeDetails(recipeId);
    if (details == null) return null;
    final macros = details.perServing;
    return logMeal(
      day: day,
      name: details.recipe.name,
      calories: macros.calories,
      proteinG: macros.proteinG,
      carbsG: macros.carbsG,
      fatG: macros.fatG,
      portion: portion,
    );
  }

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
  }) => db
      .into(db.meals)
      .insert(
        MealsCompanion.insert(
          name: name,
          calories: calories,
          proteinG: Value(proteinG),
          carbsG: Value(carbsG),
          fatG: Value(fatG),
        ),
      );

  Future<void> updateMeal(int id, MealsCompanion changes) =>
      (db.update(db.meals)..where((t) => t.id.equals(id))).write(changes);

  Future<void> deleteMeal(int id) =>
      (db.delete(db.meals)..where((t) => t.id.equals(id))).go();

  // ----- Logging -----

  Stream<List<MealLog>> watchLogs(String day) =>
      (db.select(db.mealLogs)
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
  }) => db
      .into(db.mealLogs)
      .insert(
        MealLogsCompanion.insert(
          day: day,
          name: name,
          mealId: Value(mealId),
          portion: Value(portion),
          calories: calories * portion,
          proteinG: Value(proteinG * portion),
          carbsG: Value(carbsG * portion),
          fatG: Value(fatG * portion),
        ),
      );

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
    final all = await (db.select(
      db.meals,
    )..where((t) => t.hidden.equals(false))).get();
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

  Future<int> logWeight(double weightKg, {double? waistCm}) => db
      .into(db.weightEntries)
      .insert(
        WeightEntriesCompanion.insert(
          day: dayKey(DateTime.now()),
          weightKg: weightKg,
          waistCm: Value(waistCm),
        ),
      );

  Future<void> deleteWeight(int id) =>
      (db.delete(db.weightEntries)..where((t) => t.id.equals(id))).go();
}

final nutritionRepositoryProvider = Provider<NutritionRepository>(
  (ref) => NutritionRepository(ref.watch(databaseProvider)),
);

final savedMealsProvider = StreamProvider<List<Meal>>(
  (ref) => ref.watch(nutritionRepositoryProvider).watchMeals(),
);

final foodsProvider = StreamProvider<List<Food>>(
  (ref) => ref.watch(nutritionRepositoryProvider).watchFoods(),
);

final recipesProvider = StreamProvider<List<Recipe>>(
  (ref) => ref.watch(nutritionRepositoryProvider).watchRecipes(),
);

final recipeIngredientsProvider = StreamProvider.autoDispose
    .family<List<RecipeIngredient>, int>(
      (ref, recipeId) => ref
          .watch(nutritionRepositoryProvider)
          .watchRecipeIngredients(recipeId),
    );

final todayLogsProvider = StreamProvider<List<MealLog>>(
  (ref) =>
      ref.watch(nutritionRepositoryProvider).watchLogs(dayKey(DateTime.now())),
);

final nutritionDayProvider = NotifierProvider<NutritionDayNotifier, String>(
  NutritionDayNotifier.new,
);

class NutritionDayNotifier extends Notifier<String> {
  @override
  String build() => dayKey(DateTime.now());

  void select(String day) => state = day;
}

final nutritionLogsProvider = StreamProvider.autoDispose
    .family<List<MealLog>, String>(
      (ref, day) => ref.watch(nutritionRepositoryProvider).watchLogs(day),
    );

final weightsProvider = StreamProvider<List<WeightEntry>>(
  (ref) => ref.watch(nutritionRepositoryProvider).watchWeights(),
);

/// Approved macro targets (user-approved only; suggestions never auto-apply).
class ApprovedTargets {
  const ApprovedTargets({this.calories, this.proteinG, this.carbsG, this.fatG});

  final int? calories;
  final int? proteinG;
  final int? carbsG;
  final int? fatG;

  bool get isSet => calories != null;
}

final approvedTargetsProvider =
    AsyncNotifierProvider<ApprovedTargetsNotifier, ApprovedTargets>(
      ApprovedTargetsNotifier.new,
    );

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

  Future<void> approve({
    required int calories,
    required int proteinG,
    required int carbsG,
    required int fatG,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('target_calories', calories);
    await p.setInt('target_protein', proteinG);
    await p.setInt('target_carbs', carbsG);
    await p.setInt('target_fat', fatG);
    ref.invalidateSelf();
  }
}

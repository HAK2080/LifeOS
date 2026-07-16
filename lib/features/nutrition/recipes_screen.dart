import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/style.dart';
import '../../core/database/database.dart';
import '../today/today_data.dart' show dayKey;
import 'nutrition_repository.dart';

class RecipesScreen extends ConsumerWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipesProvider).value ?? const <Recipe>[];
    return Scaffold(
      appBar: AppBar(title: const Text('Recipes')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New recipe'),
        onPressed: () => _createRecipe(context, ref),
      ),
      body: recipes.isEmpty
          ? const Center(
              child: Text('No recipes yet. Add one from your food library.'),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                for (final recipe in recipes) _RecipeCard(recipe: recipe),
              ],
            ),
    );
  }

  Future<void> _createRecipe(BuildContext context, WidgetRef ref) async {
    final foods = await ref
        .read(nutritionRepositoryProvider)
        .watchFoods()
        .first;
    if (!context.mounted) return;
    final result = await showModalBottomSheet<_RecipeDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _RecipeBuilder(foods: foods),
    );
    if (result == null) return;
    await ref
        .read(nutritionRepositoryProvider)
        .createRecipe(
          name: result.name,
          servings: result.servings,
          notes: result.notes,
          instructions: result.instructions,
          ingredients: result.ingredients,
        );
  }
}

class _RecipeCard extends ConsumerWidget {
  const _RecipeCard({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredients =
        ref.watch(recipeIngredientsProvider(recipe.id)).value ?? [];
    final calories =
        ingredients.fold<double>(0, (sum, item) => sum + item.calories) /
        recipe.servings;
    final protein =
        ingredients.fold<double>(0, (sum, item) => sum + item.proteinG) /
        recipe.servings;
    final repo = ref.read(nutritionRepositoryProvider);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(18, 14, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  recipe.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: 'Log one serving today',
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => repo.logRecipe(
                  day: dayKey(DateTime.now()),
                  recipeId: recipe.id,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') repo.deleteRecipe(recipe.id);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'delete', child: Text('Delete recipe')),
                ],
              ),
            ],
          ),
          Text(
            '${recipe.servings} serving(s) · ${calories.round()} kcal · P ${protein.round()} g',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (ingredients.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              ingredients
                  .map((item) => '${item.name} × ${item.amount} ${item.unit}')
                  .join(' · '),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _RecipeDraft {
  const _RecipeDraft({
    required this.name,
    required this.servings,
    required this.ingredients,
    this.notes,
    this.instructions,
  });

  final String name;
  final double servings;
  final String? notes;
  final String? instructions;
  final List<RecipeIngredientDraft> ingredients;
}

class _RecipeBuilder extends StatefulWidget {
  const _RecipeBuilder({required this.foods});

  final List<Food> foods;

  @override
  State<_RecipeBuilder> createState() => _RecipeBuilderState();
}

class _RecipeBuilderState extends State<_RecipeBuilder> {
  final name = TextEditingController();
  final servings = TextEditingController(text: '1');
  final notes = TextEditingController();
  final instructions = TextEditingController();
  final ingredients = <RecipeIngredientDraft>[];

  @override
  void dispose() {
    name.dispose();
    servings.dispose();
    notes.dispose();
    instructions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('New recipe', style: Theme.of(context).textTheme.titleLarge),
            TextField(
              controller: name,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Recipe name'),
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              controller: servings,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Number of servings',
              ),
            ),
            TextField(
              controller: notes,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
            TextField(
              controller: instructions,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Instructions (optional)',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Ingredients',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  onPressed: _addIngredient,
                ),
              ],
            ),
            if (ingredients.isEmpty)
              const Text(
                'Add foods from your local library. Recipe values are calculated from their saved serving data.',
              ),
            for (var i = 0; i < ingredients.length; i++)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(ingredients[i].name),
                subtitle: Text(
                  '${ingredients[i].amount} ${ingredients[i].unit} · ${ingredients[i].calories.round()} kcal',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => ingredients.removeAt(i)),
                ),
              ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: name.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(
                      context,
                      _RecipeDraft(
                        name: name.text.trim(),
                        servings: double.tryParse(servings.text) ?? 1,
                        notes: notes.text.trim().isEmpty
                            ? null
                            : notes.text.trim(),
                        instructions: instructions.text.trim().isEmpty
                            ? null
                            : instructions.text.trim(),
                        ingredients: List.unmodifiable(ingredients),
                      ),
                    ),
              child: const Text('Save recipe'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addIngredient() async {
    if (widget.foods.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add a food first.')));
      return;
    }
    final food = await showModalBottomSheet<Food>(
      context: context,
      showDragHandle: true,
      builder: (c) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        children: [
          Text('Choose a food', style: Theme.of(c).textTheme.titleLarge),
          for (final item in widget.foods)
            ListTile(
              title: Text(item.name),
              subtitle: Text(
                '${item.servingLabel} · ${item.calories.round()} kcal',
              ),
              onTap: () => Navigator.pop(c, item),
            ),
        ],
      ),
    );
    if (food == null || !mounted) return;
    final amountController = TextEditingController(text: '1');
    final amount = await showDialog<double>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Amount of ${food.name}'),
        content: TextField(
          controller: amountController,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Servings (${food.servingLabel})',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(c, double.tryParse(amountController.text)),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    amountController.dispose();
    if (amount == null || amount <= 0 || !mounted) return;
    setState(
      () => ingredients.add(
        RecipeIngredientDraft(
          foodId: food.id,
          name: food.name,
          amount: amount,
          unit: food.servingLabel,
          calories: food.calories * amount,
          proteinG: food.proteinG * amount,
          carbsG: food.carbsG * amount,
          fatG: food.fatG * amount,
        ),
      ),
    );
  }
}

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/style.dart';
import '../../core/database/database.dart';
import '../today/today_data.dart' show dayKey;
import 'nutrition_repository.dart';

class FoodLibraryScreen extends ConsumerStatefulWidget {
  const FoodLibraryScreen({super.key});

  @override
  ConsumerState<FoodLibraryScreen> createState() => _FoodLibraryScreenState();
}

class _FoodLibraryScreenState extends ConsumerState<FoodLibraryScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final foods = ref.watch(foodsProvider).value ?? const <Food>[];
    final normalized = query.trim().toLowerCase();
    final filtered = foods.where((food) {
      return normalized.isEmpty ||
          food.name.toLowerCase().contains(normalized) ||
          (food.brand?.toLowerCase().contains(normalized) ?? false) ||
          (food.barcode?.contains(normalized) ?? false);
    }).toList();
    final repo = ref.read(nutritionRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food library'),
        actions: [
          IconButton(
            tooltip: 'Add food',
            icon: const Icon(Icons.add),
            onPressed: () => _addFood(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search foods, brands, or barcodes',
              ),
              onChanged: (value) => setState(() => query = value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${filtered.length} saved foods',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'No foods yet. Add a food with the values from its label or a trusted source.',
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final food = filtered[index];
                      return _FoodCard(
                        food: food,
                        onPin: () => repo.updateFood(
                          food.id,
                          FoodsCompanion(pinned: Value(!food.pinned)),
                        ),
                        onLog: () => _logFood(context, food),
                        onHide: () => repo.deleteFood(food.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _addFood(BuildContext context) async {
    final result = await showDialog<_FoodFormResult>(
      context: context,
      builder: (_) => const _FoodFormDialog(),
    );
    if (result == null) return;
    await ref
        .read(nutritionRepositoryProvider)
        .saveFood(
          name: result.name,
          brand: result.brand,
          barcode: result.barcode,
          servingLabel: result.servingLabel,
          servingGrams: result.servingGrams,
          calories: result.calories,
          proteinG: result.proteinG,
          carbsG: result.carbsG,
          fatG: result.fatG,
          fiberG: result.fiberG,
        );
  }

  Future<void> _logFood(BuildContext context, Food food) async {
    final amount = TextEditingController(text: '1');
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Log ${food.name}'),
        content: TextField(
          controller: amount,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Servings (${food.servingLabel})',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Log'),
          ),
        ],
      ),
    );
    final portion = double.tryParse(amount.text);
    if (ok == true && portion != null && portion > 0) {
      await ref
          .read(nutritionRepositoryProvider)
          .logFood(day: dayKey(DateTime.now()), food: food, portion: portion);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Food logged.')));
      }
    }
    amount.dispose();
  }
}

class _FoodCard extends StatelessWidget {
  const _FoodCard({
    required this.food,
    required this.onPin,
    required this.onLog,
    required this.onHide,
  });

  final Food food;
  final VoidCallback onPin;
  final VoidCallback onLog;
  final VoidCallback onHide;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          const Icon(Icons.restaurant_outlined, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.name, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '${food.brand == null ? '' : '${food.brand} · '}${food.servingLabel} · ${food.calories.round()} kcal · P ${food.proteinG.round()} g',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Pin food',
            icon: Icon(food.pinned ? Icons.push_pin : Icons.push_pin_outlined),
            color: food.pinned ? AppColors.accentDeep : null,
            onPressed: onPin,
          ),
          IconButton(
            tooltip: 'Log food',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: onLog,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'hide') onHide();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'hide', child: Text('Hide')),
            ],
          ),
        ],
      ),
    );
  }
}

class _FoodFormResult {
  const _FoodFormResult({
    required this.name,
    required this.servingLabel,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.fiberG,
    this.brand,
    this.barcode,
    this.servingGrams,
  });

  final String name;
  final String? brand;
  final String? barcode;
  final String servingLabel;
  final double? servingGrams;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
}

class _FoodFormDialog extends StatefulWidget {
  const _FoodFormDialog();

  @override
  State<_FoodFormDialog> createState() => _FoodFormDialogState();
}

class _FoodFormDialogState extends State<_FoodFormDialog> {
  final name = TextEditingController();
  final brand = TextEditingController();
  final barcode = TextEditingController();
  final serving = TextEditingController(text: '1 serving');
  final grams = TextEditingController();
  final calories = TextEditingController();
  final protein = TextEditingController();
  final carbs = TextEditingController();
  final fat = TextEditingController();
  final fiber = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      name,
      brand,
      barcode,
      serving,
      grams,
      calories,
      protein,
      carbs,
      fat,
      fiber,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add food'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: name,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Food name'),
              ),
              TextField(
                controller: brand,
                decoration: const InputDecoration(
                  labelText: 'Brand (optional)',
                ),
              ),
              TextField(
                controller: barcode,
                decoration: const InputDecoration(
                  labelText: 'Barcode (optional)',
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: serving,
                      decoration: const InputDecoration(labelText: 'Serving'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: grams,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: 'Grams'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Nutrition per serving',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: calories,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Calories'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: protein,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Protein'),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: carbs,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Carbs'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: fat,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Fat'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: fiber,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Fiber'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (name.text.trim().isEmpty) return;
            Navigator.pop(
              context,
              _FoodFormResult(
                name: name.text.trim(),
                brand: brand.text.trim().isEmpty ? null : brand.text.trim(),
                barcode: barcode.text.trim().isEmpty
                    ? null
                    : barcode.text.trim(),
                servingLabel: serving.text.trim().isEmpty
                    ? '1 serving'
                    : serving.text.trim(),
                servingGrams: double.tryParse(grams.text),
                calories: double.tryParse(calories.text) ?? 0,
                proteinG: double.tryParse(protein.text) ?? 0,
                carbsG: double.tryParse(carbs.text) ?? 0,
                fatG: double.tryParse(fat.text) ?? 0,
                fiberG: double.tryParse(fiber.text) ?? 0,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

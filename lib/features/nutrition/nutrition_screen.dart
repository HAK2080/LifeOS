import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../app/style.dart';
import '../../core/database/database.dart';
import '../../core/media/temporary_file_cleanup.dart';
import '../settings/settings_screen.dart' as settings;
import '../today/today_data.dart' show dayKey;
import 'nutrition_logic.dart';
import 'nutrition_repository.dart';
import 'food_services.dart';

final _frequentMealsProvider = FutureProvider<List<Meal>>((ref) {
  ref.watch(todayLogsProvider);
  ref.watch(savedMealsProvider);
  return ref.watch(nutritionRepositoryProvider).frequentMeals();
});

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(todayLogsProvider).value ?? [];
    final repo = ref.read(nutritionRepositoryProvider);
    final totals = repo.totals(logs);
    final targets =
        ref.watch(approvedTargetsProvider).value ?? const ApprovedTargets();
    final frequent = ref.watch(_frequentMealsProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        actions: [
          IconButton(
            tooltip: 'Food library',
            icon: const Icon(Icons.search),
            onPressed: () => _foodLibrarySheet(context, ref),
          ),
          IconButton(
            tooltip: 'Goals',
            icon: const Icon(Icons.flag_outlined),
            onPressed: () => _goalsSheet(context, ref),
          ),
          IconButton(
            tooltip: 'Progress',
            icon: const Icon(Icons.trending_up),
            onPressed: () => _progressSheet(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          AppCard(
            tinted: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle("Today's intake"),
                const SizedBox(height: 12),
                _MacroRow(
                    label: 'Calories',
                    value: totals.calories,
                    target: targets.calories?.toDouble(),
                    unit: 'kcal'),
                _MacroRow(
                    label: 'Protein',
                    value: totals.proteinG,
                    target: targets.proteinG?.toDouble(),
                    unit: 'g'),
                _MacroRow(
                    label: 'Carbs',
                    value: totals.carbsG,
                    target: targets.carbsG?.toDouble(),
                    unit: 'g'),
                _MacroRow(
                    label: 'Fat',
                    value: totals.fatG,
                    target: targets.fatG?.toDouble(),
                    unit: 'g'),
                if (!targets.isSet)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                        'No targets set — tap the flag to see a suggestion. '
                        'Nothing is ever applied without your approval.',
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Log meal'),
                  onPressed: () => _logMealDialog(context, ref),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.bookmark_outline),
                  label: const Text('Saved meals'),
                  onPressed: () => _savedMealsSheet(context, ref),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(Icons.photo_camera_outlined, size: 18),
                label: const Text('Photo'),
                onPressed: () => _photoMeal(context, ref),
              ),
              ActionChip(
                avatar: const Icon(Icons.mic_none_outlined, size: 18),
                label: const Text('Voice'),
                onPressed: () => _voiceMeal(context, ref),
              ),
              ActionChip(
                avatar: const Icon(Icons.qr_code_scanner_outlined, size: 18),
                label: const Text('Barcode'),
                onPressed: () => _barcodeMeal(context, ref),
              ),
            ],
          ),
          if (frequent.isNotEmpty) ...[
            const SizedBox(height: 16),
            const SectionTitle('Quick log'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in frequent)
                  ActionChip(
                    avatar: m.pinned
                        ? const Icon(Icons.push_pin,
                            size: 16, color: AppColors.accentDeep)
                        : null,
                    label: Text('${m.name} · ${m.calories.round()} kcal'),
                    onPressed: () => repo.logMeal(
                      day: dayKey(DateTime.now()),
                      name: m.name,
                      calories: m.calories,
                      proteinG: m.proteinG,
                      carbsG: m.carbsG,
                      fatG: m.fatG,
                      mealId: m.id,
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'All estimates remain editable. Photos are temporary and deleted '
            'after the estimate step; AI food recognition can be added behind '
            'the same replaceable flow later.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (logs.isNotEmpty) ...[
            const SizedBox(height: 16),
            const SectionTitle('Logged today'),
            for (final l in logs)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.name +
                    (l.portion != 1.0
                        ? ' (${(l.portion * 100).round()}%)'
                        : '')),
                subtitle: Text(
                  '${l.calories.round()} kcal · P ${l.proteinG.round()} · '
                  'C ${l.carbsG.round()} · F ${l.fatG.round()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => repo.deleteLog(l.id),
                ),
              ),
          ],
        ],
      ),
    );
  }

  // ----- Log meal (manual) -----

  Future<void> _logMealDialog(BuildContext context, WidgetRef ref,
      {String initialName = ''}) async {
    final name = TextEditingController(text: initialName);
    final cal = TextEditingController();
    final protein = TextEditingController();
    final carbs = TextEditingController();
    final fat = TextEditingController();
    var save = false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setDialog) => AlertDialog(
          title: const Text('Log meal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: name,
                    autofocus: true,
                    decoration:
                        const InputDecoration(labelText: 'What was it?')),
                const SizedBox(height: 8),
                TextField(
                    controller: cal,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Calories')),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: TextField(
                          controller: protein,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'P (g)'))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: TextField(
                          controller: carbs,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'C (g)'))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: TextField(
                          controller: fat,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'F (g)'))),
                ]),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Save for reuse'),
                  value: save,
                  onChanged: (v) => setDialog(() => save = v ?? false),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Log')),
          ],
        ),
      ),
    );
    if (ok != true || name.text.trim().isEmpty) return;
    final repo = ref.read(nutritionRepositoryProvider);
    final calories = double.tryParse(cal.text) ?? 0;
    final p = double.tryParse(protein.text) ?? 0;
    final cb = double.tryParse(carbs.text) ?? 0;
    final f = double.tryParse(fat.text) ?? 0;
    int? mealId;
    if (save) {
      mealId = await repo.saveMeal(
          name: name.text.trim(),
          calories: calories,
          proteinG: p,
          carbsG: cb,
          fatG: f);
    }
    await repo.logMeal(
      day: dayKey(DateTime.now()),
      name: name.text.trim(),
      calories: calories,
      proteinG: p,
      carbsG: cb,
      fatG: f,
      mealId: mealId,
    );
  }

  Future<void> _photoMeal(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;
    try {
      final estimate = await ref.read(foodRecognitionServiceProvider)
          .estimateFromImage(photo.path);
      if (context.mounted) {
        await _logMealDialog(context, ref,
            initialName: estimate?.name ?? 'Photo estimate - edit this meal');
      }
    } finally {
      // Keep no user image after the editable estimate step.
      try {
        await deleteTemporaryPath(photo.path);
      } catch (_) {
        // Some providers return a read-only temporary URI.
      }
    }
  }

  Future<void> _voiceMeal(BuildContext context, WidgetRef ref) async {
    final speech = SpeechToText();
    if (!await speech.initialize()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Speech recognition is unavailable.')));
      }
      return;
    }
    if (!context.mounted) return;
    final words = await showDialog<String>(
      context: context,
      builder: (_) => _VoiceMealDialog(speech: speech),
    );
    await speech.stop();
    if (words != null && words.trim().isNotEmpty && context.mounted) {
      await _logMealDialog(context, ref, initialName: words.trim());
    }
  }

  Future<void> _barcodeMeal(BuildContext context, WidgetRef ref) async {
    final code = await showDialog<String>(
      context: context,
      builder: (c) => Dialog(
        child: SizedBox(
          width: 320,
          height: 420,
          child: MobileScanner(
            onDetect: (capture) {
              if (capture.barcodes.isEmpty) return;
              final value = capture.barcodes.first.rawValue;
              if (value != null && value.isNotEmpty && c.mounted) {
                Navigator.pop(c, value);
              }
            },
          ),
        ),
      ),
    );
    if (code != null && context.mounted) {
      final product = await ref.read(barcodeProductServiceProvider).lookup(code);
      if (!context.mounted) return;
      await _logMealDialog(context, ref,
          initialName: product?.name ?? 'Barcode $code');
    }
  }

  // ----- Saved meals -----

  void _foodLibrarySheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _FoodLibrarySheet(),
    );
  }

  void _savedMealsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (c) => Consumer(
        builder: (c, sheetRef, _) {
          final meals = sheetRef.watch(savedMealsProvider).value ?? [];
          final repo = sheetRef.read(nutritionRepositoryProvider);
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.8,
            builder: (c, scroll) => ListView(
              controller: scroll,
              padding: const EdgeInsets.all(20),
              children: [
                Text('Saved meals', style: Theme.of(c).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (meals.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                        'Nothing saved yet — tick "Save for reuse" when logging.'),
                  ),
                for (final m in meals)
                  AppCard(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(m.name,
                                  style: Theme.of(c).textTheme.titleMedium),
                            ),
                            IconButton(
                              icon: Icon(
                                  m.pinned
                                      ? Icons.push_pin
                                      : Icons.push_pin_outlined,
                                  size: 18,
                                  color: m.pinned
                                      ? AppColors.accentDeep
                                      : null),
                              tooltip: 'Pin to Quick Log',
                              onPressed: () => repo.updateMeal(m.id,
                                  MealsCompanion(pinned: Value(!m.pinned))),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (v) async {
                                switch (v) {
                                  case 'edit':
                                    await _editMeal(c, repo, m);
                                  case 'hide':
                                    await repo.updateMeal(m.id,
                                        const MealsCompanion(hidden: Value(true)));
                                  case 'delete':
                                    await repo.deleteMeal(m.id);
                                }
                              },
                              itemBuilder: (c) => const [
                                PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Rename / edit')),
                                PopupMenuItem(
                                    value: 'hide', child: Text('Hide')),
                                PopupMenuItem(
                                    value: 'delete', child: Text('Delete')),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          '${m.calories.round()} kcal · P ${m.proteinG.round()} · C ${m.carbsG.round()} · F ${m.fatG.round()}',
                          style: Theme.of(c).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          children: [
                            for (final step in portionSteps)
                              ActionChip(
                                label: Text(step == 1.0
                                    ? 'Log'
                                    : '${step > 1 ? '+' : '−'}${((step - 1).abs() * 100).round()}%'),
                                onPressed: () async {
                                  await repo.logMeal(
                                    day: dayKey(DateTime.now()),
                                    name: m.name,
                                    calories: m.calories,
                                    proteinG: m.proteinG,
                                    carbsG: m.carbsG,
                                    fatG: m.fatG,
                                    mealId: m.id,
                                    portion: step,
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _editMeal(
      BuildContext context, NutritionRepository repo, Meal m) async {
    final name = TextEditingController(text: m.name);
    final cal = TextEditingController(text: m.calories.round().toString());
    final protein = TextEditingController(text: m.proteinG.round().toString());
    final carbs = TextEditingController(text: m.carbsG.round().toString());
    final fat = TextEditingController(text: m.fatG.round().toString());
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Edit meal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 8),
            TextField(
                controller: cal,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Calories')),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child: TextField(
                      controller: protein,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'P'))),
              const SizedBox(width: 8),
              Expanded(
                  child: TextField(
                      controller: carbs,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'C'))),
              const SizedBox(width: 8),
              Expanded(
                  child: TextField(
                      controller: fat,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'F'))),
            ]),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (ok == true) {
      await repo.updateMeal(
          m.id,
          MealsCompanion(
            name: Value(name.text.trim()),
            calories: Value(double.tryParse(cal.text) ?? m.calories),
            proteinG: Value(double.tryParse(protein.text) ?? m.proteinG),
            carbsG: Value(double.tryParse(carbs.text) ?? m.carbsG),
            fatG: Value(double.tryParse(fat.text) ?? m.fatG),
          ));
    }
  }

  // ----- Goals -----

  Future<void> _goalsSheet(BuildContext context, WidgetRef ref) async {
    final profile =
        ref.read(settings.profileProvider).value ?? const settings.ProfileData();
    final targets =
        ref.read(approvedTargetsProvider).value ?? const ApprovedTargets();
    final daysLogged =
        await ref.read(nutritionRepositoryProvider).daysWithLogs();
    if (!context.mounted) return;

    MacroTargets? suggestion;
    if (profile.weightKg != null &&
        profile.heightCm != null &&
        profile.age != null) {
      suggestion = suggestTargets(Profile(
        weightKg: profile.weightKg!,
        heightCm: profile.heightCm!,
        age: profile.age!,
        goal: switch (profile.goal) {
          'Lose fat' => Goal.loseFat,
          'Build muscle' => Goal.buildMuscle,
          'Recomposition' => Goal.recomposition,
          'General health' => Goal.generalHealth,
          _ => Goal.maintain,
        },
      ));
    }
    final enoughData = enoughDataForTargetChange(daysLogged);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (c) => Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text('Goals', style: Theme.of(c).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (targets.isSet) ...[
              Text('Current (approved by you):',
                  style: Theme.of(c).textTheme.titleMedium),
              Text(
                  '${targets.calories} kcal · P ${targets.proteinG} g · C ${targets.carbsG} g · F ${targets.fatG} g'),
              const SizedBox(height: 12),
            ],
            if (suggestion == null)
              const Text(
                  'Fill in weight, height and age in Settings to get a suggested target.')
            else ...[
              Text('Suggestion:', style: Theme.of(c).textTheme.titleMedium),
              Text(
                  '${suggestion.calories} kcal · P ${suggestion.proteinG} g · C ${suggestion.carbsG} g · F ${suggestion.fatG} g'),
              const SizedBox(height: 8),
              Text(suggestion.explanation,
                  style: Theme.of(c).textTheme.bodySmall),
              const SizedBox(height: 8),
              if (targets.isSet && !enoughData)
                Text(
                  'Tip: log meals on ~10 of the last 14 days before changing '
                  'targets — trends beat guesses.',
                  style: Theme.of(c).textTheme.bodySmall?.copyWith(
                      color: AppColors.accentDeep),
                ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () async {
                  await ref.read(approvedTargetsProvider.notifier).approve(
                        calories: suggestion!.calories,
                        proteinG: suggestion.proteinG,
                        carbsG: suggestion.carbsG,
                        fatG: suggestion.fatG,
                      );
                  if (c.mounted) Navigator.pop(c);
                },
                child: const Text('Approve these targets'),
              ),
            ],
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _manualTargets(c, ref, targets),
              child: const Text('Set my own numbers'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _manualTargets(BuildContext context, WidgetRef ref,
      ApprovedTargets current) async {
    final cal =
        TextEditingController(text: current.calories?.toString() ?? '');
    final p = TextEditingController(text: current.proteinG?.toString() ?? '');
    final cb = TextEditingController(text: current.carbsG?.toString() ?? '');
    final f = TextEditingController(text: current.fatG?.toString() ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Your targets'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: cal,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Calories')),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child: TextField(
                      controller: p,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'P (g)'))),
              const SizedBox(width: 8),
              Expanded(
                  child: TextField(
                      controller: cb,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'C (g)'))),
              const SizedBox(width: 8),
              Expanded(
                  child: TextField(
                      controller: f,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'F (g)'))),
            ]),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (ok == true) {
      final calories = int.tryParse(cal.text);
      if (calories != null) {
        await ref.read(approvedTargetsProvider.notifier).approve(
              calories: calories,
              proteinG: int.tryParse(p.text) ?? 0,
              carbsG: int.tryParse(cb.text) ?? 0,
              fatG: int.tryParse(f.text) ?? 0,
            );
      }
      if (context.mounted) Navigator.pop(context);
    }
  }

  // ----- Progress -----

  void _progressSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (c) => Consumer(
        builder: (c, sheetRef, _) {
          final weights = sheetRef.watch(weightsProvider).value ?? [];
          final repo = sheetRef.read(nutritionRepositoryProvider);
          final ordered = weights.reversed.toList(); // oldest first
          final trend = weightTrend(
              [for (final w in ordered) w.weightKg]);
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            builder: (c, scroll) => ListView(
              controller: scroll,
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Progress',
                          style: Theme.of(c).textTheme.titleLarge),
                    ),
                    FilledButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Log weight'),
                      onPressed: () async {
                        final w = TextEditingController();
                        final ok = await showDialog<bool>(
                          context: c,
                          builder: (d) => AlertDialog(
                            title: const Text('Weight (kg)'),
                            content: TextField(
                                controller: w,
                                autofocus: true,
                                keyboardType: const TextInputType
                                    .numberWithOptions(decimal: true)),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(d, false),
                                  child: const Text('Cancel')),
                              FilledButton(
                                  onPressed: () => Navigator.pop(d, true),
                                  child: const Text('Log')),
                            ],
                          ),
                        );
                        final v = double.tryParse(w.text);
                        if (ok == true && v != null) await repo.logWeight(v);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (trend.isNotEmpty)
                  Text(
                    'Trend: ${trend.last.toStringAsFixed(1)} kg'
                    '${trend.length > 7 ? ' (${(trend.last - trend[trend.length - 8]) >= 0 ? '+' : ''}${(trend.last - trend[trend.length - 8]).toStringAsFixed(1)} kg over last 7 entries)' : ''}',
                    style: Theme.of(c).textTheme.bodyMedium,
                  )
                else
                  const Text('Log your weight whenever you like — the trend '
                      'smooths daily noise. Optional, never pushed.'),
                const SizedBox(height: 8),
                for (var i = weights.length - 1; i >= 0; i--)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                        '${weights[weights.length - 1 - i].weightKg.toStringAsFixed(1)} kg'),
                    subtitle: Text(weights[weights.length - 1 - i].day),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => repo
                          .deleteWeight(weights[weights.length - 1 - i].id),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FoodLibrarySheet extends ConsumerStatefulWidget {
  const _FoodLibrarySheet();

  @override
  ConsumerState<_FoodLibrarySheet> createState() => _FoodLibrarySheetState();
}

class _FoodLibrarySheetState extends ConsumerState<_FoodLibrarySheet> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meals = ref.watch(savedMealsProvider).value ?? [];
    final normalized = _query.trim().toLowerCase();
    final filtered = normalized.isEmpty
        ? meals
        : meals
            .where((m) => m.name.toLowerCase().contains(normalized))
            .toList();
    final repo = ref.read(nutritionRepositoryProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      builder: (c, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.all(20),
        children: [
          Text('Food library', style: Theme.of(c).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('Search your saved foods and log them locally. Nothing requires an account.',
              style: Theme.of(c).textTheme.bodySmall),
          const SizedBox(height: 12),
          TextField(
            controller: _search,
            autofocus: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search saved foods',
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No saved foods match. Log a meal and choose Save for reuse.'),
            ),
          for (final meal in filtered)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(meal.name),
              subtitle: Text(
                  '${meal.calories.round()} kcal · P ${meal.proteinG.round()} · C ${meal.carbsG.round()} · F ${meal.fatG.round()}'),
              trailing: IconButton(
                tooltip: 'Log today',
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => repo.logMeal(
                  day: dayKey(DateTime.now()),
                  name: meal.name,
                  calories: meal.calories,
                  proteinG: meal.proteinG,
                  carbsG: meal.carbsG,
                  fatG: meal.fatG,
                  mealId: meal.id,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _VoiceMealDialog extends StatefulWidget {
  const _VoiceMealDialog({required this.speech});

  final SpeechToText speech;

  @override
  State<_VoiceMealDialog> createState() => _VoiceMealDialogState();
}

class _VoiceMealDialogState extends State<_VoiceMealDialog> {
  String words = '';

  @override
  void initState() {
    super.initState();
    widget.speech.listen(onResult: (result) {
      if (!mounted) return;
      setState(() => words = result.recognizedWords);
      if (result.finalResult && words.trim().isNotEmpty) {
        Navigator.pop(context, words);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Describe the meal'),
      content: Text(words.isEmpty ? 'Listening…' : words),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
      ],
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow(
      {required this.label,
      required this.value,
      required this.target,
      required this.unit});

  final String label;
  final double value;
  final double? target;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fmt = NumberFormat.decimalPattern();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                  width: 76,
                  child:
                      Text(label, style: Theme.of(context).textTheme.bodyMedium)),
              Text(
                '${fmt.format(value.round())}${target != null ? ' / ${fmt.format(target!.round())}' : ''} $unit',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (target != null && target! > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (value / target!).clamp(0, 1),
                  minHeight: 6,
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

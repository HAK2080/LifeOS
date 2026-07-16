import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/style.dart';
import '../../../core/database/database.dart';
import '../training_repository.dart';

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
  String query = '';
  String? muscleGroup;

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(exercisesProvider).value ?? const <Exercise>[];
    final groups =
        all.map((e) => e.muscleGroup).whereType<String>().toSet().toList()
          ..sort();
    final normalized = query.trim().toLowerCase();
    final exercises = all.where((e) {
      final matchesQuery =
          normalized.isEmpty ||
          e.name.toLowerCase().contains(normalized) ||
          (e.equipment?.toLowerCase().contains(normalized) ?? false);
      return matchesQuery &&
          (muscleGroup == null || e.muscleGroup == muscleGroup);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise library'),
        actions: [
          IconButton(
            tooltip: 'Add exercise',
            icon: const Icon(Icons.add),
            onPressed: () => _addExercise(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by exercise or equipment',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => query = value),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: muscleGroup == null,
                  onSelected: (_) => setState(() => muscleGroup = null),
                ),
                const SizedBox(width: 8),
                for (final group in groups) ...[
                  ChoiceChip(
                    label: Text(group),
                    selected: muscleGroup == group,
                    onSelected: (_) => setState(() => muscleGroup = group),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${exercises.length} exercises',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) =>
                  _ExerciseRow(exercise: exercises[index]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addExercise(BuildContext context) async {
    final name = TextEditingController();
    final muscle = TextEditingController();
    final equipment = TextEditingController();
    final save = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Add exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: muscle,
              decoration: const InputDecoration(
                labelText: 'Muscle group (optional)',
              ),
            ),
            TextField(
              controller: equipment,
              decoration: const InputDecoration(
                labelText: 'Equipment (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, name.text.trim().isNotEmpty),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (save == true) {
      await ref
          .read(trainingRepositoryProvider)
          .addCustomExercise(
            name.text.trim(),
            muscleGroup: muscle.text.trim().isEmpty ? null : muscle.text.trim(),
            equipment: equipment.text.trim().isEmpty
                ? null
                : equipment.text.trim(),
          );
    }
    name.dispose();
    muscle.dispose();
    equipment.dispose();
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.fitness_center_outlined, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  [
                    if (exercise.muscleGroup != null) exercise.muscleGroup!,
                    if (exercise.equipment != null) exercise.equipment!,
                    if (exercise.isCustom) 'Custom',
                  ].join(' · '),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

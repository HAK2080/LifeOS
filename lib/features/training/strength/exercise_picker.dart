import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/style.dart';
import '../training_repository.dart';

/// Searchable exercise picker. Returns the chosen exercise id, or null.
Future<int?> pickExercise(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _ExercisePickerSheet(),
  );
}

class _ExercisePickerSheet extends ConsumerStatefulWidget {
  const _ExercisePickerSheet();

  @override
  ConsumerState<_ExercisePickerSheet> createState() =>
      _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends ConsumerState<_ExercisePickerSheet> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(exercisesProvider).value ?? [];
    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? all
        : all
            .where((e) =>
                e.name.toLowerCase().contains(q) ||
                (e.muscleGroup ?? '').toLowerCase().contains(q))
            .toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search exercises…',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => query = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: filtered.length + 1,
              itemBuilder: (context, i) {
                if (i == filtered.length) {
                  return ListTile(
                    leading:
                        const Icon(Icons.add, color: AppColors.accent),
                    title: Text(q.isEmpty
                        ? 'Add custom exercise'
                        : 'Add "${query.trim()}"'),
                    onTap: () async {
                      final name = q.isEmpty
                          ? await _askName(context)
                          : query.trim();
                      if (name == null || name.isEmpty) return;
                      final id = await ref
                          .read(trainingRepositoryProvider)
                          .addCustomExercise(name);
                      if (context.mounted) Navigator.pop(context, id);
                    },
                  );
                }
                final e = filtered[i];
                return ListTile(
                  title: Text(e.name),
                  subtitle: e.muscleGroup == null
                      ? null
                      : Text(e.muscleGroup!,
                          style: Theme.of(context).textTheme.bodySmall),
                  trailing: e.isCustom
                      ? Icon(Icons.person_outline,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurfaceVariant)
                      : null,
                  onTap: () => Navigator.pop(context, e.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _askName(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('New exercise'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Exercise name'),
          onSubmitted: (v) => Navigator.pop(c, v.trim()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(c, controller.text.trim()),
              child: const Text('Add')),
        ],
      ),
    );
  }
}

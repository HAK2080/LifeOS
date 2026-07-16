import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/style.dart';
import '../../../core/database/database.dart';
import '../training_repository.dart';
import 'exercise_picker.dart';
import 'plan_import.dart';
import 'strength_content.dart';

final plansProvider = StreamProvider<List<WorkoutPlan>>(
  (ref) => ref.watch(trainingRepositoryProvider).watchPlans(),
);

final planWorkoutsProvider = StreamProvider.autoDispose
    .family<List<PlanWorkout>, int>(
      (ref, planId) =>
          ref.watch(trainingRepositoryProvider).watchPlanWorkouts(planId),
    );

final planExercisesProvider = StreamProvider.autoDispose
    .family<List<(PlanExercise, Exercise)>, int>(
      (ref, workoutId) =>
          ref.watch(trainingRepositoryProvider).watchPlanExercises(workoutId),
    );

class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(plansProvider).value ?? [];
    final repo = ref.read(trainingRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Plans'),
        actions: [
          IconButton(
            tooltip: 'Import from text',
            icon: const Icon(Icons.content_paste_go),
            onPressed: () => _importFromText(context, repo),
          ),
          IconButton(
            tooltip: 'Starter templates',
            icon: const Icon(Icons.auto_awesome_outlined),
            onPressed: () => _chooseTemplate(context, repo),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New plan'),
        onPressed: () async {
          final name = await _askText(
            context,
            'New plan',
            'e.g. Upper / Lower',
          );
          if (name != null && name.isNotEmpty) await repo.createPlan(name);
        },
      ),
      body: plans.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No plans yet. Create one, or import from text — '
                  'progress moves by sequence, never by calendar.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [for (final plan in plans) _PlanCard(plan: plan)],
            ),
    );
  }

  Future<void> _chooseTemplate(
    BuildContext context,
    TrainingRepository repo,
  ) async {
    final template = await showModalBottomSheet<StarterTemplate>(
      context: context,
      showDragHandle: true,
      builder: (c) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Text('Starter templates', style: Theme.of(c).textTheme.titleLarge),
          const SizedBox(height: 4),
          const Text(
            'Use one as a starting point, then edit every exercise and target.',
          ),
          const SizedBox(height: 12),
          for (final template in starterTemplates)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(template.name),
              subtitle: Text(template.description),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pop(c, template),
            ),
        ],
      ),
    );
    if (template == null) return;
    await repo.createStarterTemplate(template);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${template.name} added to your plans.')),
      );
    }
  }

  Future<void> _importFromText(
    BuildContext context,
    TrainingRepository repo,
  ) async {
    final controller = TextEditingController();
    final nameController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Import plan from text'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Plan name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                maxLines: 10,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  hintText:
                      'Upper A:\nBench Press 3x8-12\nBarbell Row 3x10\n\n'
                      'Lower A:\nBack Squat 4x5',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final parsed = parsePlanText(controller.text);
    if (parsed.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nothing recognisable — try "Exercise 3x8-12" lines.',
            ),
          ),
        );
      }
      return;
    }
    final exercises = await repo.db.select(repo.db.exercises).get();
    final planId = await repo.createPlan(
      nameController.text.trim().isEmpty
          ? 'Imported plan'
          : nameController.text.trim(),
    );
    for (final w in parsed) {
      final workoutId = await repo.addPlanWorkout(planId, w.name);
      for (final e in w.exercises) {
        final existing = exercises
            .where((x) => x.name.toLowerCase() == e.name.toLowerCase())
            .firstOrNull;
        final exerciseId = existing?.id ?? await repo.addCustomExercise(e.name);
        await repo.addPlanExercise(
          workoutId,
          exerciseId,
          targetSets: e.sets,
          repMin: e.repMin,
          repMax: e.repMax,
        );
      }
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported ${parsed.length} workout(s).')),
      );
    }
  }
}

class _PlanCard extends ConsumerWidget {
  const _PlanCard({required this.plan});

  final WorkoutPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(planWorkoutsProvider(plan.id)).value ?? [];
    final repo = ref.read(trainingRepositoryProvider);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'archive') repo.archivePlan(plan.id);
                },
                itemBuilder: (c) => const [
                  PopupMenuItem(value: 'archive', child: Text('Archive plan')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final w in workouts) _WorkoutTile(plan: plan, workout: w),
          Row(
            children: [
              TextButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add workout'),
                onPressed: () async {
                  final name = await _askText(
                    context,
                    'New workout',
                    'e.g. Upper A',
                  );
                  if (name != null && name.isNotEmpty) {
                    await repo.addPlanWorkout(plan.id, name);
                  }
                },
              ),
              const Spacer(),
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Start next'),
                onPressed: workouts.isEmpty
                    ? null
                    : () async {
                        final next = await repo.nextPlanWorkout(plan.id);
                        if (next == null) return;
                        final id = await repo.startPlanSession(next);
                        if (context.mounted) {
                          context.go('/training/strength/session/$id');
                        }
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WorkoutTile extends ConsumerWidget {
  const _WorkoutTile({required this.plan, required this.workout});

  final WorkoutPlan plan;
  final PlanWorkout workout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(planExercisesProvider(workout.id)).value ?? [];
    final repo = ref.read(trainingRepositoryProvider);

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      shape: const Border(),
      title: Text(workout.name, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(
        '${exercises.length} exercise(s)',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      children: [
        for (final (pe, exercise) in exercises)
          ListTile(
            dense: true,
            contentPadding: const EdgeInsets.only(left: 8),
            title: Text(exercise.name),
            subtitle: Text(
              '${pe.targetSets} sets'
              '${pe.repMin != null ? ' × ${pe.repMin}${pe.repMax != null ? '–${pe.repMax}' : ''} reps' : ''}'
              ' · ${pe.progressionMode}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.tune, size: 18),
                  tooltip: 'Targets & progression',
                  onPressed: () => _editTargets(context, repo, pe),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => repo.deletePlanExercise(pe.id),
                ),
              ],
            ),
          ),
        Row(
          children: [
            TextButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add exercise'),
              onPressed: () async {
                final picked = await pickExercise(context, ref);
                if (picked != null) {
                  await repo.addPlanExercise(workout.id, picked);
                }
              },
            ),
            const Spacer(),
            TextButton(
              onPressed: () => repo.deletePlanWorkout(workout.id),
              child: const Text('Delete workout'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _editTargets(
    BuildContext context,
    TrainingRepository repo,
    PlanExercise pe,
  ) async {
    final sets = TextEditingController(text: pe.targetSets.toString());
    final repMin = TextEditingController(text: pe.repMin?.toString() ?? '');
    final repMax = TextEditingController(text: pe.repMax?.toString() ?? '');
    final rest = TextEditingController(text: pe.restSetSec?.toString() ?? '');
    var mode = pe.progressionMode;
    await showDialog<void>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setDialogState) => AlertDialog(
          title: const Text('Targets & progression'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: sets,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Sets'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: repMin,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Rep min'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: repMax,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Rep max'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: rest,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Rest between sets (sec, optional)',
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'manual', label: Text('Manual')),
                  ButtonSegment(value: 'double', label: Text('Double')),
                  ButtonSegment(value: 'coach', label: Text('Coach')),
                  ButtonSegment(value: 'progressive', label: Text('RIR')),
                ],
                selected: {mode},
                onSelectionChanged: (s) => setDialogState(() => mode = s.first),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await repo.updatePlanExercise(
                  pe.id,
                  PlanExercisesCompanion(
                    targetSets: Value(int.tryParse(sets.text) ?? pe.targetSets),
                    repMin: Value(int.tryParse(repMin.text)),
                    repMax: Value(int.tryParse(repMax.text)),
                    restSetSec: Value(int.tryParse(rest.text)),
                    progressionMode: Value(mode),
                  ),
                );
                if (c.mounted) Navigator.pop(c);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String?> _askText(
  BuildContext context,
  String title,
  String hint,
) async {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(hintText: hint),
        onSubmitted: (v) => Navigator.pop(c, v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(c, controller.text.trim()),
          child: const Text('Create'),
        ),
      ],
    ),
  );
}

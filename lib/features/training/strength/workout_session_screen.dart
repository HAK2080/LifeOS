import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/style.dart';
import '../../../core/database/database.dart';
import '../progression.dart';
import '../rest_timer.dart';
import '../training_repository.dart';
import 'exercise_picker.dart';

class WorkoutSessionScreen extends ConsumerWidget {
  const WorkoutSessionScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(sessionExercisesProvider(sessionId));
    final repo = ref.read(trainingRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/training/strength'),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'discard') {
                final sure = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Discard workout?'),
                    content: const Text(
                        'This deletes the session and its sets. Nothing else is affected.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: const Text('Keep')),
                      FilledButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: const Text('Discard')),
                    ],
                  ),
                );
                if (sure == true) {
                  await repo.discardSession(sessionId);
                  if (context.mounted) context.go('/training/strength');
                }
              }
            },
            itemBuilder: (c) => const [
              PopupMenuItem(value: 'discard', child: Text('Discard workout')),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Finish'),
              onPressed: () async {
                ref.read(restTimerProvider.notifier).skip();
                await repo.finishSession(sessionId);
                if (context.mounted) context.go('/training/strength');
              },
            ),
          ),
        ],
      ),
      body: exercises.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Something went wrong: $e')),
        data: (list) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            for (final data in list)
              _ExerciseCard(sessionId: sessionId, data: data),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add exercise'),
              onPressed: () async {
                final picked = await pickExercise(context, ref);
                if (picked != null) {
                  await repo.addExerciseToSession(sessionId, picked);
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const RestTimerBar(),
    );
  }
}

class _ExerciseCard extends ConsumerStatefulWidget {
  const _ExerciseCard({required this.sessionId, required this.data});

  final int sessionId;
  final SessionExerciseData data;

  @override
  ConsumerState<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends ConsumerState<_ExerciseCard> {
  LastPerformance? last;
  bool lastLoaded = false;

  @override
  void initState() {
    super.initState();
    ref
        .read(trainingRepositoryProvider)
        .lastPerformance(widget.data.exercise.id)
        .then((v) {
      if (mounted) setState(() { last = v; lastLoaded = true; });
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(trainingRepositoryProvider);
    final scheme = Theme.of(context).colorScheme;
    final data = widget.data;

    Recommendation? hint;
    if (lastLoaded && last != null && last!.sets.isNotEmpty) {
      hint = recommendNext(ProgressionInput(
        lastSets: last!.sets
            .where((s) => s.weightKg != null && s.reps != null)
            .map((s) => SetResult(
                weightKg: s.weightKg!,
                reps: s.reps!,
                rir: s.rir,
                pain: s.pain))
            .toList(),
      ));
    }

    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(data.exercise.name,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 18, color: scheme.text2),
                tooltip: 'Remove exercise',
                onPressed: () => repo.removeSessionExercise(data.link.id),
              ),
            ],
          ),
          if (last != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                'Last time (${DateFormat.MMMd().format(last!.when)}): '
                '${_summary(last!.sets)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          if (hint != null && hint.action != ProgressionAction.keepSame)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Coach: ${hint.reason}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.accentDeep),
              ),
            ),
          Row(
            children: [
              const SizedBox(width: 32),
              Expanded(
                  child: Text('kg',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall)),
              const SizedBox(width: 8),
              Expanded(
                  child: Text('reps',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall)),
              const SizedBox(width: 88),
            ],
          ),
          for (final set in data.sets)
            _SetRow(
                key: ValueKey(set.id),
                set: set,
                lastSet: last == null || last!.sets.length < set.setNumber
                    ? null
                    : last!.sets[set.setNumber - 1]),
          const SizedBox(height: 4),
          TextButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add set'),
            onPressed: () => repo.addSet(data.link.id),
          ),
        ],
      ),
    );
  }

  String _summary(List<SessionSet> sets) {
    final done = sets.where((s) => s.reps != null).toList();
    if (done.isEmpty) return '—';
    final w = done.first.weightKg;
    final reps = done.map((s) => s.reps).join(', ');
    return '${w == null ? '' : '${_fmtW(w)} kg × '}$reps';
  }

  String _fmtW(double w) =>
      w == w.roundToDouble() ? w.round().toString() : w.toStringAsFixed(1);
}

class _SetRow extends ConsumerStatefulWidget {
  const _SetRow({super.key, required this.set, this.lastSet});

  final SessionSet set;
  final SessionSet? lastSet;

  @override
  ConsumerState<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends ConsumerState<_SetRow> {
  late final TextEditingController _weight;
  late final TextEditingController _reps;

  @override
  void initState() {
    super.initState();
    _weight = TextEditingController(
        text: widget.set.weightKg == null ? '' : _fmt(widget.set.weightKg!));
    _reps = TextEditingController(
        text: widget.set.reps?.toString() ?? '');
  }

  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    super.dispose();
  }

  String _fmt(double w) =>
      w == w.roundToDouble() ? w.round().toString() : w.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(trainingRepositoryProvider);
    final done = widget.set.completedAt != null;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text('${widget.set.setNumber}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Serif',
                    fontWeight: FontWeight.w600,
                    color: scheme.text2)),
          ),
          Expanded(
            child: TextField(
              controller: _weight,
              textAlign: TextAlign.center,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.lastSet?.weightKg == null
                    ? '—'
                    : _fmt(widget.lastSet!.weightKg!),
              ),
              onChanged: (v) => repo.updateSet(widget.set.id,
                  SessionSetsCompanion(weightKg: Value(double.tryParse(v)))),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _reps,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.lastSet?.reps?.toString() ?? '—',
              ),
              onChanged: (v) => repo.updateSet(widget.set.id,
                  SessionSetsCompanion(reps: Value(int.tryParse(v)))),
            ),
          ),
          SizedBox(
            width: 44,
            child: IconButton(
              tooltip: 'Set options',
              icon: Icon(
                widget.set.pain
                    ? Icons.warning_amber
                    : Icons.more_horiz,
                size: 20,
                color: widget.set.pain
                    ? Theme.of(context).colorScheme.error
                    : scheme.text2,
              ),
              onPressed: () => _setOptions(context, repo),
            ),
          ),
          SizedBox(
            width: 44,
            child: IconButton(
              tooltip: done ? 'Completed' : 'Complete set (starts rest)',
              icon: Icon(
                done ? Icons.check_circle : Icons.check_circle_outline,
                color: done ? AppColors.accent : scheme.text2,
              ),
              onPressed: () async {
                if (done) {
                  await repo.updateSet(widget.set.id,
                      const SessionSetsCompanion(completedAt: Value(null)));
                } else {
                  await repo.updateSet(
                      widget.set.id,
                      SessionSetsCompanion(
                          completedAt: Value(DateTime.now())));
                  final rest = ref.read(defaultRestProvider).value ?? 120;
                  ref.read(restTimerProvider.notifier).start(rest);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setOptions(BuildContext context, dynamic repo) async {
    final rirController = TextEditingController(
        text: widget.set.rir?.toString() ?? '');
    final notesController =
        TextEditingController(text: widget.set.notes ?? '');
    var pain = widget.set.pain;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (c) => StatefulBuilder(
        builder: (c, setSheetState) => Padding(
          padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(c).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Set ${widget.set.setNumber} options',
                  style: Theme.of(c).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: rirController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'RIR (reps in reserve, optional)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Pain / discomfort on this set'),
                value: pain,
                onChanged: (v) => setSheetState(() => pain = v),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      await repo.deleteSet(widget.set.id);
                      if (c.mounted) Navigator.pop(c);
                    },
                    child: const Text('Delete set'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () async {
                      await repo.updateSet(
                          widget.set.id,
                          SessionSetsCompanion(
                            rir: Value(
                                double.tryParse(rirController.text)),
                            notes: Value(notesController.text.trim().isEmpty
                                ? null
                                : notesController.text.trim()),
                            pain: Value(pain),
                          ));
                      if (c.mounted) Navigator.pop(c);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

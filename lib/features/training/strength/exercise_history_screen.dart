import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/style.dart';
import '../../../core/database/database.dart';
import '../training_repository.dart';

class ExerciseHistoryScreen extends ConsumerStatefulWidget {
  const ExerciseHistoryScreen({super.key});

  @override
  ConsumerState<ExerciseHistoryScreen> createState() =>
      _ExerciseHistoryScreenState();
}

class _ExerciseHistoryScreenState extends ConsumerState<ExerciseHistoryScreen> {
  Exercise? selected;
  List<(WorkoutSession, List<SessionSet>)> history = const [];
  String query = '';

  @override
  Widget build(BuildContext context) {
    if (selected != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(selected!.name),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => selected = null),
          ),
        ),
        body: history.isEmpty
            ? Center(
                child: Text('No logged sessions yet.',
                    style: Theme.of(context).textTheme.bodyMedium))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final (session, sets) in history)
                    AppCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              DateFormat.yMMMEd()
                                  .format(session.finishedAt!),
                              style:
                                  Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 6),
                          for (final s in sets.where((s) => s.reps != null))
                            Text(
                              'Set ${s.setNumber}:  '
                              '${s.weightKg == null ? '' : '${_fmt(s.weightKg!)} kg × '}'
                              '${s.reps}'
                              '${s.rir == null ? '' : '  @ RIR ${_fmt(s.rir!)}'}'
                              '${s.pain ? '  ⚠ pain' : ''}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
      );
    }

    final all = ref.watch(exercisesProvider).value ?? [];
    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? all
        : all.where((e) => e.name.toLowerCase().contains(q)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Exercise History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search exercises…',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => query = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final e = filtered[i];
                return ListTile(
                  title: Text(e.name),
                  subtitle: e.muscleGroup == null ? null : Text(e.muscleGroup!),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final h = await ref
                        .read(trainingRepositoryProvider)
                        .exerciseHistory(e.id);
                    setState(() {
                      selected = e;
                      history = h;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);
}

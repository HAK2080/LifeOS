import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/style.dart';
import 'cardio_repository.dart';

const _areas = [
  'Full body',
  'Hips',
  'Shoulders',
  'Spine',
  'Hamstrings',
  'Ankles / knees',
  'Neck',
  'Breathing',
  'Foam rolling',
];

class MobilityScreen extends ConsumerWidget {
  const MobilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(mobilitySessionsProvider).value ?? [];
    // Consistency, not performance: sessions this week.
    final monday = DateTime.now().subtract(
        Duration(days: DateTime.now().weekday - 1));
    final thisWeek = sessions
        .where((s) => s.startedAt
            .isAfter(DateTime(monday.year, monday.month, monday.day)))
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Mobility / Recovery')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            tinted: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('This week'),
                const SizedBox(height: 8),
                Text(
                  thisWeek == 0
                      ? 'No sessions yet this week — even 5 minutes counts.'
                      : '$thisWeek session${thisWeek == 1 ? '' : 's'} — consistency is the whole game.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Log a session'),
            onPressed: () => _log(context, ref),
          ),
          const SizedBox(height: 18),
          if (sessions.isNotEmpty) ...[
            const SectionTitle('History'),
            for (final s in sessions.take(20))
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${s.activity} — ${s.durationMin} min'),
                subtitle: Text(DateFormat.MMMEd().format(s.startedAt),
                    style: Theme.of(context).textTheme.bodySmall),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () =>
                      ref.read(cardioRepositoryProvider).delete(s.id),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _log(BuildContext context, WidgetRef ref) async {
    var area = 'Full body';
    final minutes = TextEditingController(text: '15');
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setDialog) => AlertDialog(
          title: const Text('Mobility / recovery'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final a in _areas)
                    ChoiceChip(
                      label: Text(a),
                      selected: area == a,
                      onSelected: (_) => setDialog(() => area = a),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                  controller: minutes,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Minutes')),
            ],
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
    if (ok == true) {
      await ref.read(cardioRepositoryProvider).log(
            kind: 'mobility',
            activity: area,
            durationMin: int.tryParse(minutes.text) ?? 15,
          );
    }
  }
}

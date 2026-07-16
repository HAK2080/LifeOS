import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/style.dart';
import 'cardio_repository.dart';

final stepsTodayProvider = FutureProvider<int>((ref) {
  ref.watch(walkingSessionsProvider);
  return ref.watch(cardioRepositoryProvider).stepsToday();
});

class WalkingScreen extends ConsumerWidget {
  const WalkingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(zone2PrefsProvider).value ?? const Zone2Prefs();
    final steps = ref.watch(stepsTodayProvider).value ?? 0;
    final sessions = ref.watch(walkingSessionsProvider).value ?? [];
    final target = prefs.dailyStepTarget;

    return Scaffold(
      appBar: AppBar(title: const Text('Walking')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            tinted: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('Today'),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(NumberFormat.decimalPattern().format(steps),
                        style: const TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 42,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                          target == null ? 'steps' : 'of ${NumberFormat.decimalPattern().format(target)} steps',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _editTarget(context, ref, prefs),
                      child: Text(target == null ? 'Set target' : 'Target'),
                    ),
                  ],
                ),
                if (target != null && steps < target)
                  Text(
                    'A short walk would close the gap — no pressure.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                Text(
                  'Step import from Health Connect arrives soon; manual entry always works.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Log a walk'),
            onPressed: () => _log(context, ref),
          ),
          const SizedBox(height: 18),
          if (sessions.isNotEmpty) ...[
            const SectionTitle('History'),
            for (final s in sessions.take(20))
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${s.activity} — ${s.durationMin} min'
                    '${s.steps != null ? ' · ${NumberFormat.decimalPattern().format(s.steps)} steps' : ''}'),
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

  Future<void> _editTarget(
      BuildContext context, WidgetRef ref, Zone2Prefs prefs) async {
    final controller = TextEditingController(
        text: prefs.dailyStepTarget?.toString() ?? '');
    await showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Daily step target (optional)'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'e.g. 8000 — empty to disable'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final v = int.tryParse(controller.text);
              await ref.read(zone2PrefsProvider.notifier).save(
                  dailyStepTarget: v, clearStepTarget: v == null);
              if (c.mounted) Navigator.pop(c);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _log(BuildContext context, WidgetRef ref) async {
    var type = 'Walk';
    final minutes = TextEditingController(text: '30');
    final steps = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setDialog) => AlertDialog(
          title: const Text('Log walking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 6,
                children: [
                  for (final t in ['Walk', 'Treadmill', 'Rucking'])
                    ChoiceChip(
                      label: Text(t),
                      selected: type == t,
                      onSelected: (_) => setDialog(() => type = t),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                  controller: minutes,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Minutes')),
              const SizedBox(height: 8),
              TextField(
                  controller: steps,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Steps (optional)')),
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
            kind: 'walking',
            activity: type,
            durationMin: int.tryParse(minutes.text) ?? 30,
            steps: int.tryParse(steps.text),
          );
      ref.invalidate(stepsTodayProvider);
    }
  }
}

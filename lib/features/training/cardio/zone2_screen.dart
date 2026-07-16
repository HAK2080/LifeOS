import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/style.dart';
import 'cardio_repository.dart';

const zone2Activities = [
  'Bike',
  'Rower',
  'Treadmill',
  'SkiErg',
  'Walking',
  'Custom',
];

/// Weekly minutes provider (recomputes when sessions change).
final zone2WeekMinutesProvider = FutureProvider<int>((ref) {
  ref.watch(zone2SessionsProvider); // rebuild on new sessions
  return ref.watch(cardioRepositoryProvider).minutesThisWeek('zone2');
});

class Zone2Screen extends ConsumerWidget {
  const Zone2Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(zone2PrefsProvider).value ?? const Zone2Prefs();
    final week = ref.watch(zone2WeekMinutesProvider).value ?? 0;
    final sessions = ref.watch(zone2SessionsProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Zone 2')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            tinted: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('This week'),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$week',
                        style: const TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 42,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('of ${prefs.weeklyTargetMin} min',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _editTarget(context, ref, prefs),
                      child: const Text('Target'),
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: prefs.weeklyTargetMin == 0
                        ? 0
                        : (week / prefs.weeklyTargetMin).clamp(0, 1),
                    minHeight: 8,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start session'),
                  onPressed: () => _startSession(context, ref, prefs),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Log manually'),
                  onPressed: () => _manualLog(context, ref, prefs),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (sessions.isNotEmpty) ...[
            const SectionTitle('History'),
            const SizedBox(height: 6),
            for (final s in sessions.take(20))
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${s.activity} — ${s.durationMin} min'),
                subtitle: Text(
                  '${DateFormat.MMMEd().format(s.startedAt)}'
                  '${s.avgHr != null ? ' · avg ${s.avgHr} bpm' : ''}'
                  '${s.notes != null ? ' · ${s.notes}' : ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
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
    final controller =
        TextEditingController(text: prefs.weeklyTargetMin.toString());
    final v = await showDialog<int>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Weekly Zone 2 target (minutes)'),
        content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          FilledButton(
              onPressed: () =>
                  Navigator.pop(c, int.tryParse(controller.text)),
              child: const Text('Save')),
        ],
      ),
    );
    if (v != null) {
      await ref.read(zone2PrefsProvider.notifier).save(weeklyTargetMin: v);
    }
  }

  Future<void> _manualLog(
      BuildContext context, WidgetRef ref, Zone2Prefs prefs) async {
    var activity = prefs.lastActivity;
    final duration =
        TextEditingController(text: prefs.lastDurationMin.toString());
    final hr = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setDialog) => AlertDialog(
          title: const Text('Log Zone 2'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final a in zone2Activities)
                    ChoiceChip(
                      label: Text(a),
                      selected: activity == a,
                      onSelected: (_) => setDialog(() => activity = a),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                  controller: duration,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Minutes')),
              const SizedBox(height: 8),
              TextField(
                  controller: hr,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Avg heart rate (optional)')),
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
      final mins = int.tryParse(duration.text) ?? prefs.lastDurationMin;
      await ref.read(cardioRepositoryProvider).log(
            kind: 'zone2',
            activity: activity,
            durationMin: mins,
            avgHr: int.tryParse(hr.text),
          );
      await ref
          .read(zone2PrefsProvider.notifier)
          .save(lastActivity: activity, lastDurationMin: mins);
      ref.invalidate(zone2WeekMinutesProvider);
    }
  }

  void _startSession(BuildContext context, WidgetRef ref, Zone2Prefs prefs) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      builder: (_) => _LiveSessionSheet(prefs: prefs),
    );
  }
}

class _LiveSessionSheet extends ConsumerStatefulWidget {
  const _LiveSessionSheet({required this.prefs});

  final Zone2Prefs prefs;

  @override
  ConsumerState<_LiveSessionSheet> createState() => _LiveSessionSheetState();
}

class _LiveSessionSheetState extends ConsumerState<_LiveSessionSheet> {
  late String activity = widget.prefs.lastActivity;
  late int targetMin = widget.prefs.lastDurationMin;
  int elapsedSec = 0;
  bool running = false;
  bool started = false;
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() {
      started = true;
      running = true;
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (running && mounted) setState(() => elapsedSec++);
    });
  }

  @override
  Widget build(BuildContext context) {
    final m = (elapsedSec ~/ 60).toString();
    final s = (elapsedSec % 60).toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle('Zone 2 session'),
          const SizedBox(height: 12),
          if (!started) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final a in zone2Activities)
                  ChoiceChip(
                    label: Text(a),
                    selected: activity == a,
                    onSelected: (_) => setState(() => activity = a),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Planned: $targetMin min',
                    style: Theme.of(context).textTheme.bodyMedium),
                Expanded(
                  child: Slider(
                    value: targetMin.toDouble(),
                    min: 10,
                    max: 90,
                    divisions: 16,
                    onChanged: (v) => setState(() => targetMin = v.round()),
                  ),
                ),
              ],
            ),
            Text(
              'Live heart rate arrives with Health Connect. For now the timer '
              'tracks your minutes — log HR after if you want.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const Spacer(),
                FilledButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                  onPressed: _start,
                ),
              ],
            ),
          ] else ...[
            Center(
              child: Text('$m:$s',
                  style: const TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 64,
                      fontWeight: FontWeight.w600)),
            ),
            Center(
              child: Text('$activity · planned $targetMin min',
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 36,
                  tooltip: running ? 'Pause' : 'Resume',
                  icon: Icon(running
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline),
                  onPressed: () => setState(() => running = !running),
                ),
                const SizedBox(width: 12),
                IconButton(
                  iconSize: 36,
                  tooltip: '+5 min planned',
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => setState(() => targetMin += 5),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  icon: const Icon(Icons.stop),
                  label: const Text('Finish'),
                  onPressed: () async {
                    _ticker?.cancel();
                    final mins = (elapsedSec / 60).round();
                    if (mins > 0) {
                      await ref.read(cardioRepositoryProvider).log(
                            kind: 'zone2',
                            activity: activity,
                            durationMin: mins,
                          );
                      await ref.read(zone2PrefsProvider.notifier).save(
                          lastActivity: activity, lastDurationMin: targetMin);
                      ref.invalidate(zone2WeekMinutesProvider);
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
          const SafeArea(child: SizedBox.shrink()),
        ],
      ),
    );
  }
}

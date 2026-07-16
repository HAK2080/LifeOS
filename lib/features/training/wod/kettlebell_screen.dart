import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/style.dart';
import 'wod_engine.dart';
import 'wod_repository.dart';

class _KbSession {
  const _KbSession(this.type, this.title, this.blurb, this.body, this.minutes);

  final String type;
  final String title;
  final String blurb;
  final String body;
  final int minutes;
}

const _kbSessions = <_KbSession>[
  _KbSession(
    'Strength', 'Heavy Day', 'Low reps, full rest — build pressing power',
    '5 rounds, rest 2 min between:\n'
    '• 5 clean & press each arm (heavy but crisp)\n'
    '• 5 goblet squats\n'
    '• 30 s farmer hold\n\n'
    'Purpose: strength with a bell — quality over pace.\n'
    'Scale: lighter bell, 3 rounds.',
    25,
  ),
  _KbSession(
    'Conditioning', 'Swing Engine', 'Simple, brutal, repeatable',
    'EMOM 16 min, alternating:\n'
    '• Odd minutes: 15 swings\n'
    '• Even minutes: 10 goblet squats (or step-ups for knee-friendly)\n\n'
    'Purpose: aerobic power with built-in rest.\n'
    'Scale: 12 min, lighter bell.',
    16,
  ),
  _KbSession(
    'Complex', 'The Classic Complex', 'One bell, no putting it down',
    '4 rounds each side, rest 90 s between rounds:\n'
    '• 5 swings → 4 cleans → 3 presses → 2 front squats → 1 snatch\n\n'
    'Purpose: full-body flow under fatigue.\n'
    'Scale: drop the snatch, use a lighter bell.',
    20,
  ),
  _KbSession(
    'EMOM', 'Snatch EMOM', 'Crisp singles, every minute',
    'EMOM 12 min:\n'
    '• 6 snatches, alternating arms each minute\n\n'
    'Purpose: power endurance and grip.\n'
    'Scale: one-arm swings instead of snatches.',
    12,
  ),
  _KbSession(
    'AMRAP', 'Bell Triplet', 'Steady rounds, no heroics',
    'AMRAP 15 min:\n'
    '• 10 swings\n• 8 goblet lunges (or step-ups)\n• 6 push presses\n\n'
    'Purpose: sustained mixed work.\n'
    'Scale: reduce reps to 8/6/4.',
    15,
  ),
  _KbSession(
    'Technique', 'Skill Practice', 'Grease the groove, no clock',
    '20 min relaxed practice:\n'
    '• Turkish get-up — 5 slow reps each side\n'
    '• Windmill — 5 each side, light\n'
    '• Swing technique — 5×10 crisp reps\n\n'
    'Purpose: movement quality. Stop while it still feels good.',
    20,
  ),
];

class KettlebellScreen extends ConsumerWidget {
  const KettlebellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kettlebell')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final s in _kbSessions)
            AppCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              onTap: () => _show(context, ref, s),
              child: Row(
                children: [
                  const Icon(Icons.sports_gymnastics,
                      size: 26, color: AppColors.accent),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${s.type} — ${s.title}',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 3),
                        Text('${s.blurb} · ~${s.minutes} min',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            onTap: () => _custom(context, ref),
            child: Row(
              children: [
                const Icon(Icons.shuffle, size: 26, color: AppColors.accent),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Custom / surprise me',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 3),
                      Text('Generate a fresh kettlebell session',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _show(BuildContext context, WidgetRef ref, _KbSession s) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (c) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle('${s.type} — ${s.title}'),
            const SizedBox(height: 12),
            Text(s.body,
                style:
                    Theme.of(c).textTheme.bodyMedium?.copyWith(height: 1.6)),
            const SizedBox(height: 20),
            SafeArea(
              child: FilledButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Did it — log'),
                onPressed: () async {
                  await ref.read(wodRepositoryProvider).logWod(
                        title: '${s.type}: ${s.title}',
                        description: s.body,
                        source: 'kettlebell',
                        durationMin: s.minutes,
                      );
                  if (c.mounted) Navigator.pop(c);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _custom(BuildContext context, WidgetRef ref) {
    final wod = generateWod(const WodRequest(
      durationMin: 15,
      difficulty: Difficulty.moderate,
      availableEquipment: {'Kettlebells'},
    ));
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (c) => Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          shrinkWrap: true,
          children: [
            SectionTitle(wod.title),
            const SizedBox(height: 12),
            Text(wod.description,
                style:
                    Theme.of(c).textTheme.bodyMedium?.copyWith(height: 1.6)),
            const SizedBox(height: 20),
            SafeArea(
              child: FilledButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Did it — log'),
                onPressed: () async {
                  await ref.read(wodRepositoryProvider).logWod(
                        title: wod.title,
                        description: wod.description,
                        source: 'kettlebell',
                        durationMin: wod.expectedDurationMin,
                      );
                  if (c.mounted) Navigator.pop(c);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

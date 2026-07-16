import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/style.dart';
import '../../equipment/equipment_screen.dart';
import 'wod_engine.dart';
import 'wod_library.dart';
import 'wod_repository.dart';

class WodScreen extends ConsumerWidget {
  const WodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('WOD / Conditioning')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tile(context, Icons.psychology_outlined, 'Coach Suggestion',
              'Built around how you feel today',
              () => _coachFlow(context, ref)),
          _tile(context, Icons.handyman_outlined, 'Choose Equipment',
              'Pick gear, get a structured WOD around it',
              () => _equipmentFlow(context, ref)),
          _tile(context, Icons.menu_book_outlined, 'Browse Existing WODs',
              'Classic benchmarks, filtered to your level',
              () => _browseFlow(context, ref)),
          _tile(context, Icons.edit_outlined, 'Enter WOD Manually',
              'Log anything you did elsewhere',
              () => _manualFlow(context, ref)),
          const SizedBox(height: 8),
          const _RecentWods(),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, String blurb,
      VoidCallback onTap) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 26, color: AppColors.accent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(blurb, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Set<String> _availableEquipment(WidgetRef ref) {
    final items = ref.read(equipmentProvider).value ?? [];
    return items.where((e) => e.available).map((e) => e.name).toSet();
  }

  Future<void> _coachFlow(BuildContext context, WidgetRef ref) async {
    var duration = 15;
    var difficulty = Difficulty.moderate;
    var feeling = 'normal';
    var kneeSafe = false;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (c) => StatefulBuilder(
        builder: (c, setSheet) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Coach suggestion', style: Theme.of(c).textTheme.titleLarge),
              const SizedBox(height: 14),
              Text('How do you feel?', style: Theme.of(c).textTheme.bodyMedium),
              const SizedBox(height: 6),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'tired', label: Text('Tired')),
                  ButtonSegment(value: 'normal', label: Text('Normal')),
                  ButtonSegment(value: 'fresh', label: Text('Fresh')),
                ],
                selected: {feeling},
                onSelectionChanged: (s) => setSheet(() => feeling = s.first),
              ),
              const SizedBox(height: 14),
              Text('Duration: $duration min',
                  style: Theme.of(c).textTheme.bodyMedium),
              Slider(
                value: duration.toDouble(),
                min: 8,
                max: 40,
                divisions: 16,
                onChanged: (v) => setSheet(() => duration = v.round()),
              ),
              SegmentedButton<Difficulty>(
                segments: const [
                  ButtonSegment(value: Difficulty.easy, label: Text('Easy')),
                  ButtonSegment(
                      value: Difficulty.moderate, label: Text('Moderate')),
                  ButtonSegment(value: Difficulty.hard, label: Text('Hard')),
                ],
                selected: {difficulty},
                onSelectionChanged: (s) => setSheet(() => difficulty = s.first),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Knee-friendly only'),
                value: kneeSafe,
                onChanged: (v) => setSheet(() => kneeSafe = v),
              ),
              SafeArea(
                child: FilledButton(
                  onPressed: () => Navigator.pop(c, true),
                  child: const Text('Build my WOD'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    final equipment = _availableEquipment(ref);
    final avoid = await ref.read(wodRepositoryProvider).completedTitles();
    final wod = generateWod(WodRequest(
      durationMin: duration,
      difficulty: difficulty,
      availableEquipment: equipment,
      kneeSafeOnly: kneeSafe,
      avoidTitles: avoid,
      feeling: feeling,
    ));
    if (context.mounted) _showWod(context, ref, wod.title, wod.description, 'coach', wod.expectedDurationMin);
  }

  Future<void> _equipmentFlow(BuildContext context, WidgetRef ref) async {
    final all = _availableEquipment(ref);
    final selected = <String>{};
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (c) => StatefulBuilder(
        builder: (c, setSheet) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Build around equipment',
                  style: Theme.of(c).textTheme.titleLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final e in all)
                    FilterChip(
                      label: Text(e),
                      selected: selected.contains(e),
                      onSelected: (v) => setSheet(
                          () => v ? selected.add(e) : selected.remove(e)),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              SafeArea(
                child: FilledButton(
                  onPressed: selected.isEmpty
                      ? null
                      : () => Navigator.pop(c, true),
                  child: const Text('Build WOD'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    final avoid = await ref.read(wodRepositoryProvider).completedTitles();
    final wod = generateWod(WodRequest(
      durationMin: 18,
      difficulty: Difficulty.moderate,
      availableEquipment: selected,
      avoidTitles: avoid,
    ));
    if (context.mounted) _showWod(context, ref, wod.title, wod.description, 'equipment', wod.expectedDurationMin);
  }

  Future<void> _browseFlow(BuildContext context, WidgetRef ref) async {
    final done = await ref.read(wodRepositoryProvider).completedTitles();
    final equipment = _availableEquipment(ref);
    if (!context.mounted) return;
    var level = 'beginner';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (c) => StatefulBuilder(
        builder: (c, setSheet) {
          final filtered = wodLibrary
              .where((w) =>
                  w.level == level &&
                  w.equipment.every(equipment.contains))
              .toList()
            ..sort((a, b) {
              // Never-done first — avoid suggesting exact repeats.
              final aDone = done.contains(a.name) ? 1 : 0;
              final bDone = done.contains(b.name) ? 1 : 0;
              return aDone.compareTo(bDone);
            });
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            builder: (c, scroll) => ListView(
              controller: scroll,
              padding: const EdgeInsets.all(20),
              children: [
                Text('Benchmark WODs', style: Theme.of(c).textTheme.titleLarge),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'beginner', label: Text('Beginner')),
                    ButtonSegment(
                        value: 'intermediate', label: Text('Intermediate')),
                    ButtonSegment(value: 'advanced', label: Text('Advanced')),
                  ],
                  selected: {level},
                  onSelectionChanged: (s) => setSheet(() => level = s.first),
                ),
                const SizedBox(height: 12),
                if (filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                        'Nothing at this level fits your available equipment.'),
                  ),
                for (final w in filtered)
                  AppCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    onTap: () {
                      Navigator.pop(c);
                      _showWod(context, ref, w.name, w.description, 'library',
                          w.durationMin);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(w.name,
                                  style:
                                      Theme.of(c).textTheme.titleMedium),
                            ),
                            if (done.contains(w.name))
                              Text('done before',
                                  style: Theme.of(c).textTheme.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('~${w.durationMin} min · ${w.stimulus}',
                            style: Theme.of(c).textTheme.bodySmall),
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

  Future<void> _manualFlow(BuildContext context, WidgetRef ref) async {
    final title = TextEditingController();
    final desc = TextEditingController();
    final result = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Log a WOD'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: title,
                decoration: const InputDecoration(hintText: 'Name')),
            const SizedBox(height: 8),
            TextField(
                controller: desc,
                maxLines: 4,
                decoration:
                    const InputDecoration(hintText: 'What was in it?')),
            const SizedBox(height: 8),
            TextField(
                controller: result,
                decoration: const InputDecoration(
                    hintText: 'Result (time, rounds…)')),
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
    );
    if (ok == true && title.text.trim().isNotEmpty) {
      await ref.read(wodRepositoryProvider).logWod(
            title: title.text.trim(),
            description: desc.text.trim(),
            source: 'manual',
            result: result.text.trim().isEmpty ? null : result.text.trim(),
          );
    }
  }

  void _showWod(BuildContext context, WidgetRef ref, String title,
      String description, String source, int durationMin) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (c) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        builder: (c, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.all(20),
          children: [
            SectionTitle(title),
            const SizedBox(height: 4),
            Text('~$durationMin min', style: Theme.of(c).textTheme.bodySmall),
            const SizedBox(height: 12),
            Text(description,
                style: Theme.of(c).textTheme.bodyMedium?.copyWith(height: 1.6)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Did it — log'),
                    onPressed: () async {
                      final result = TextEditingController();
                      final logged = await showDialog<bool>(
                        context: c,
                        builder: (d) => AlertDialog(
                          title: const Text('Result'),
                          content: TextField(
                            controller: result,
                            autofocus: true,
                            decoration: const InputDecoration(
                                hintText: 'Time, rounds, how it felt…'),
                          ),
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
                      if (logged == true) {
                        await ref.read(wodRepositoryProvider).logWod(
                              title: title,
                              description: description,
                              source: source,
                              durationMin: durationMin,
                              result: result.text.trim().isEmpty
                                  ? null
                                  : result.text.trim(),
                            );
                        if (c.mounted) Navigator.pop(c);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentWods extends ConsumerWidget {
  const _RecentWods();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(completedWodsProvider).value ?? [];
    if (recent.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Completed'),
        const SizedBox(height: 8),
        for (final w in recent.take(10))
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(w.title),
            subtitle: Text(
              '${w.source}${w.result == null ? '' : ' · ${w.result}'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Text(
              '${w.completedAt.day}/${w.completedAt.month}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

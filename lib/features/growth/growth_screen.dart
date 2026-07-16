import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;

import '../../app/style.dart';
import '../../core/database/database.dart';
import 'growth_repository.dart';
import 'protocols.dart';

class GrowthScreen extends ConsumerWidget {
  const GrowthScreen({super.key});

  static const _tiles = [
    (Icons.bedtime_outlined, 'Sleep', 'sleep'),
    (Icons.psychology_outlined, 'Memory', 'memory'),
    (Icons.center_focus_strong_outlined, 'Focus', 'focus'),
    (Icons.spa_outlined, 'Stress', 'stress'),
    (Icons.air, 'Breathing', 'breathing'),
    (Icons.hot_tub_outlined, 'Sauna', 'sauna'),
    (Icons.ac_unit, 'Cold exposure', 'cold'),
    (Icons.light_mode_outlined, 'Red-light therapy', 'redlight'),
    (Icons.menu_book_outlined, 'Reading', 'reading'),
    (Icons.accessibility_new_outlined, 'Mobility', 'mobility'),
    (Icons.favorite_outline, 'Mental wellbeing', 'wellbeing'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(growthHabitsProvider).value ?? [];
    final logs = ref.watch(growthLogsProvider).value ?? [];
    final goals = ref.watch(growthGoalsProvider).value ?? [];
    final logByHabit = {for (final log in logs) log.habitId: log.status};
    final repo = ref.read(growthRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Growth'),
        actions: [
          IconButton(
            tooltip: 'Add custom habit',
            icon: const Icon(Icons.add),
            onPressed: () => _addCustom(context, repo),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text('What do you want to improve?',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          if (habits.isNotEmpty) ...[
            const SectionTitle('Your practices'),
            const SizedBox(height: 8),
            for (final habit in habits)
              _HabitCard(
                habit: habit,
                status: logByHabit[habit.id],
                onStatus: (status) => repo.setLog(
                    habitId: habit.id,
                    day: growthDayKey(DateTime.now()),
                    status: status),
                onOpen: () => _habitDetails(context, repo, habit),
              ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              const Expanded(child: SectionTitle('Goals')),
              TextButton.icon(
                onPressed: () => _addGoal(context, repo),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
          if (goals.isEmpty)
            Text('Keep goals lightweight. Add only what helps you choose your next action.',
                style: Theme.of(context).textTheme.bodySmall)
          else
            for (final goal in goals)
              _GoalCard(
                goal: goal,
                onStatus: (status) => repo.updateGoal(
                    goal.id, GoalsCompanion(status: Value(status))),
                onDelete: () => repo.deleteGoal(goal.id),
              ),
          const SizedBox(height: 16),
          const SectionTitle('Start with a protocol'),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              for (final (icon, title, id) in _tiles)
                AppCard(
                  padding: const EdgeInsets.all(16),
                  onTap: () {
                    final preset = protocolPresets.firstWhere((p) => p.id == id);
                    _protocolDetails(context, repo, preset);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: AppColors.accent),
                      const SizedBox(height: 8),
                      Text(title,
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text('No streaks, scores, or overdue pressure. Keep, adjust, pause, or stop any practice.',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Future<void> _protocolDetails(BuildContext context, GrowthRepository repo,
      ProtocolPreset preset) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _ProtocolSheet(
        preset: preset,
        onAdd: () async {
          await repo.addPreset(preset);
          if (sheetContext.mounted) Navigator.pop(sheetContext);
        },
      ),
    );
  }

  Future<void> _habitDetails(
      BuildContext context, GrowthRepository repo, Habit habit) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Wrap(
            runSpacing: 10,
            children: [
              Text(habit.name, style: Theme.of(context).textTheme.titleLarge),
              if (habit.purpose != null) Text(habit.purpose!),
              if (habit.protocol != null) Text(habit.protocol!),
              if (habit.minimumVersion != null)
                Text('Minimum version: ${habit.minimumVersion!}'),
              if (habit.evidenceLevel != null)
                Text('Evidence: ${habit.evidenceLevel!}'),
              if (habit.safetyNotes != null)
                Text('Safety: ${habit.safetyNotes!}'),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await repo.updateHabit(habit.id, HabitsCompanion(
                            status: Value(habit.status == 'active'
                                ? 'paused'
                                : 'active')));
                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                      },
                      child: Text(habit.status == 'active' ? 'Pause' : 'Resume'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        await repo.deleteHabit(habit.id);
                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                      },
                      child: const Text('Remove'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addCustom(BuildContext context, GrowthRepository repo) async {
    final name = TextEditingController();
    final purpose = TextEditingController();
    final minimum = TextEditingController();
    final target = TextEditingController();
    final added = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Custom practice'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, autofocus: true, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: purpose, decoration: const InputDecoration(labelText: 'Purpose (optional)')),
            TextField(controller: minimum, decoration: const InputDecoration(labelText: 'Minimum version (optional)')),
            TextField(controller: target, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Weekly target (optional)')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Add')),
        ],
      ),
    );
    if (added == true && name.text.trim().isNotEmpty) {
      await repo.addCustom(
        name: name.text.trim(),
        purpose: purpose.text.trim().isEmpty ? null : purpose.text.trim(),
        minimumVersion: minimum.text.trim().isEmpty ? null : minimum.text.trim(),
        weeklyTarget: int.tryParse(target.text),
      );
    }
  }

  Future<void> _addGoal(BuildContext context, GrowthRepository repo) async {
    final name = TextEditingController();
    final target = TextEditingController();
    final added = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New goal'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, autofocus: true, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: target, decoration: const InputDecoration(labelText: 'Target (optional)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Add')),
        ],
      ),
    );
    if (added == true && name.text.trim().isNotEmpty) {
      await repo.addGoal(
        name: name.text.trim(),
        target: target.text.trim().isEmpty ? null : target.text.trim(),
      );
    }
  }
}

class _ProtocolSheet extends StatelessWidget {
  const _ProtocolSheet({required this.preset, required this.onAdd});

  final ProtocolPreset preset;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Wrap(
          runSpacing: 10,
          children: [
            Text(preset.name, style: Theme.of(context).textTheme.titleLarge),
            Text(preset.purpose),
            Text(preset.explanation),
            Text(preset.protocol),
            Text('Minimum version: ${preset.minimumVersion}'),
            Text('Evidence: ${preset.evidenceLevel}'),
            if (preset.safetyNotes != null) Text('Safety: ${preset.safetyNotes!}'),
            Text('Source: ${preset.source}', style: Theme.of(context).textTheme.bodySmall),
            FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add to my practices')),
          ],
        ),
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({
    required this.habit,
    required this.status,
    required this.onStatus,
    required this.onOpen,
  });

  final Habit habit;
  final String? status;
  final ValueChanged<String> onStatus;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final muted = habit.status != 'active';
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
          onTap: onOpen,
          child: Row(children: [
            Expanded(
                child: Text(habit.name,
                    style: Theme.of(context).textTheme.titleMedium)),
            if (muted) const Chip(label: Text('Paused')),
            const Icon(Icons.chevron_right),
          ]),
        ),
        if (habit.weeklyTarget != null)
          Text('${habit.weeklyTarget} times per week · consistency over perfection',
              style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Wrap(spacing: 6, children: [
          for (final option in const [
            ('completed', 'Done'),
            ('minimum', 'Minimum'),
            ('skipped', 'Skipped'),
          ])
            ChoiceChip(
              label: Text(option.$2),
              selected: status == option.$1,
              onSelected: muted ? null : (_) => onStatus(option.$1),
            ),
        ]),
      ]),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.onStatus,
    required this.onDelete,
  });

  final LifeGoal goal;
  final ValueChanged<String> onStatus;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(goal.name, style: Theme.of(context).textTheme.titleMedium)),
          IconButton(onPressed: onDelete, icon: const Icon(Icons.close, size: 19)),
        ]),
        if (goal.target != null) Text(goal.target!, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        Wrap(spacing: 6, children: [
          for (final option in const [
            ('active', 'Active'),
            ('paused', 'Paused'),
            ('completed', 'Done'),
          ])
            ChoiceChip(
              label: Text(option.$2),
              selected: goal.status == option.$1,
              onSelected: (_) => onStatus(option.$1),
            ),
        ]),
      ]),
    );
  }
}

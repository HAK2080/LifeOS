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
                repo: repo,
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
              Text(_scheduleSummary(habit)),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                      await _editSchedule(context, repo, habit);
                    },
                    icon: const Icon(Icons.event_repeat_outlined),
                    label: const Text('Schedule'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      if (habit.reminderTime == null) {
                        final time = await showTimePicker(
                            context: context, initialTime: TimeOfDay.now());
                        if (time != null) {
                          await repo.setReminder(
                              habit: habit,
                              hour: time.hour,
                              minute: time.minute);
                        }
                      } else {
                        await repo.clearReminder(habit.id);
                      }
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                    },
                    icon: Icon(habit.reminderTime == null
                        ? Icons.notifications_outlined
                        : Icons.notifications_off_outlined),
                    label: Text(habit.reminderTime == null
                        ? 'Reminder'
                        : 'Remove reminder'),
                  ),
                ),
              ]),
              if (_reviewDue(habit))
                OutlinedButton.icon(
                  onPressed: () async {
                    await repo.markReviewed(habit.id);
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  },
                  icon: const Icon(Icons.rate_review_outlined),
                  label: const Text('Mark review complete'),
                ),
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

  String _scheduleSummary(Habit habit) {
    final schedule = switch (habit.scheduleType) {
      'fixed' => 'Fixed days: ${_dayNames(habit.fixedDays)}',
      'weekly' => 'Flexible target: ${habit.weeklyTarget ?? 0}/week',
      'both' => 'Fixed days + ${habit.weeklyTarget ?? 0}/week',
      _ => 'No schedule',
    };
    return '$schedule${habit.reminderTime == null ? '' : ' · Reminder ${habit.reminderTime}'}';
  }

  String _dayNames(String? csv) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final days = (csv ?? '')
        .split(',')
        .map(int.tryParse)
        .whereType<int>()
        .where((d) => d >= 1 && d <= 7)
        .map((d) => names[d - 1]);
    return days.isEmpty ? 'none selected' : days.join(', ');
  }

  bool _reviewDue(Habit habit) {
    if (habit.reviewAfterDays == null) return false;
    final last = habit.lastReviewAt ?? habit.createdAt;
    return DateTime.now().isAfter(last.add(Duration(days: habit.reviewAfterDays!)));
  }

  Future<void> _editSchedule(
      BuildContext context, GrowthRepository repo, Habit habit) async {
    var type = habit.scheduleType;
    var days = (habit.fixedDays ?? '')
        .split(',')
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
    final target = TextEditingController(text: habit.weeklyTarget?.toString() ?? '');
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (c, setState) => AlertDialog(
          title: const Text('Practice schedule'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<String>(
                initialValue: type,
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('No schedule')),
                  DropdownMenuItem(value: 'fixed', child: Text('Fixed days')),
                  DropdownMenuItem(value: 'weekly', child: Text('Flexible weekly target')),
                  DropdownMenuItem(value: 'both', child: Text('Fixed days + weekly target')),
                ],
                onChanged: (v) => setState(() => type = v ?? 'none'),
              ),
              if (type == 'fixed' || type == 'both') ...[
                const SizedBox(height: 10),
                Wrap(spacing: 4, children: [
                  for (var day = 1; day <= 7; day++)
                    FilterChip(
                      label: Text(_dayNames('$day')),
                      selected: days.contains(day),
                      onSelected: (selected) => setState(() => selected
                          ? days.add(day)
                          : days.remove(day)),
                    ),
                ]),
              ],
              if (type == 'weekly' || type == 'both')
                TextField(
                    controller: target,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Times per week')),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (result == true) {
      await repo.setSchedule(
          habit: habit,
          type: type,
          days: days.toList()..sort(),
          weeklyTarget: int.tryParse(target.text));
    }
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
    var kind = 'custom';
    final added = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (c, setState) => AlertDialog(
          title: const Text('New goal'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, autofocus: true, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: target, decoration: const InputDecoration(labelText: 'Target (optional)')),
            DropdownButtonFormField<String>(
              initialValue: kind,
              decoration: const InputDecoration(labelText: 'Automatic link'),
              items: const [
                DropdownMenuItem(value: 'custom', child: Text('None')),
                DropdownMenuItem(value: 'habit', child: Text('Growth practices')),
                DropdownMenuItem(value: 'training', child: Text('Strength training')),
                DropdownMenuItem(value: 'nutrition', child: Text('Nutrition logging days')),
                DropdownMenuItem(value: 'cardio', child: Text('Zone 2 minutes')),
              ],
              onChanged: (value) => setState(() => kind = value ?? 'custom'),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Add')),
          ],
        ),
      ),
    );
    if (added == true && name.text.trim().isNotEmpty) {
      await repo.addGoal(
        name: name.text.trim(),
        target: target.text.trim().isEmpty ? null : target.text.trim(),
        kind: kind,
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
    required this.repo,
    required this.onStatus,
    required this.onDelete,
  });

  final LifeGoal goal;
  final GrowthRepository repo;
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
        if (goal.kind != 'custom')
          FutureBuilder<int>(
            future: repo.contributionCount(goal),
            builder: (context, snapshot) => Text(
              'Automatically linked activity: ${snapshot.data ?? 0}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
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

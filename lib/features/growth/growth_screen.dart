import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../app/style.dart';
import '../../core/database/database.dart';
import 'growth_repository.dart';
import 'wellness_protocols.dart';

IconData _iconForCategory(String category) => switch (category) {
  'Sleep' => Icons.bedtime_outlined,
  'Morning light' => Icons.wb_sunny_outlined,
  'Caffeine' => Icons.coffee_outlined,
  'Zone 2' => Icons.monitor_heart_outlined,
  'Strength' => Icons.fitness_center_outlined,
  'Walking' => Icons.directions_walk,
  'Breathing' => Icons.air,
  'Meditation' => Icons.self_improvement,
  'Sauna' => Icons.hot_tub_outlined,
  'Cold exposure' => Icons.ac_unit,
  'Nutrition habits' => Icons.restaurant_outlined,
  'Reading' => Icons.menu_book_outlined,
  'Social connection' => Icons.people_outline,
  'Focus' => Icons.center_focus_strong_outlined,
  'Mobility' => Icons.accessibility_new_outlined,
  _ => Icons.spa_outlined,
};

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({required this.selected, required this.onSelected});

  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    const families = [
      'Diet',
      'Exercise',
      'Sleep',
      'Preventive Health',
      'Mental Health',
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        FilterChip(
          label: const Text('All'),
          selected: selected == null,
          onSelected: (_) => onSelected(null),
        ),
        for (final family in families)
          FilterChip(
            label: Text(family),
            selected: selected == family,
            onSelected: (_) => onSelected(family),
          ),
      ],
    );
  }
}

class _PracticeDaySelector extends ConsumerWidget {
  const _PracticeDaySelector({required this.day});

  final String day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateTime.tryParse(day) ?? DateTime.now();
    final today = growthDayKey(DateTime.now());
    void move(int amount) {
      ref
          .read(growthDayProvider.notifier)
          .select(growthDayKey(date.add(Duration(days: amount))));
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => move(-1),
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Text(
              day == today ? 'Today' : DateFormat.yMMMMd().format(date),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            onPressed: day == today ? null : () => move(1),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class GrowthScreen extends ConsumerStatefulWidget {
  const GrowthScreen({super.key});

  @override
  ConsumerState<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends ConsumerState<GrowthScreen> {
  String? selectedFamily;

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(growthHabitsProvider).value ?? [];
    final protocols = ref.watch(growthProtocolsProvider).value ?? [];
    final selectedDay = ref.watch(growthDayProvider);
    final logs = ref.watch(growthLogsProvider(selectedDay)).value ?? [];
    final goals = ref.watch(growthGoalsProvider).value ?? [];
    final logByHabit = {for (final log in logs) log.habitId: log.status};
    final repo = ref.read(growthRepositoryProvider);
    final filteredProtocols = selectedFamily == null
        ? protocols
        : protocols
              .where((protocol) => protocol.categoryGroup == selectedFamily)
              .toList();

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
          Text(
            'What do you want to improve?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          _PracticeDaySelector(day: selectedDay),
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
                  day: selectedDay,
                  status: status,
                ),
                onOpen: () => _habitDetails(context, repo, habit, protocols),
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
            Text(
              'Keep goals lightweight. Add only what helps you choose your next action.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            for (final goal in goals)
              _GoalCard(
                goal: goal,
                repo: repo,
                onStatus: (status) => repo.updateGoal(
                  goal.id,
                  GoalsCompanion(status: Value(status)),
                ),
                onDelete: () => repo.deleteGoal(goal.id),
              ),
          const SizedBox(height: 16),
          const SectionTitle('Start with a protocol'),
          const SizedBox(height: 8),
          _CategoryFilter(
            selected: selectedFamily,
            onSelected: (value) => setState(() => selectedFamily = value),
          ),
          const SizedBox(height: 10),
          if (protocols.isEmpty)
            const Center(child: CircularProgressIndicator())
          else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                for (final protocol in filteredProtocols)
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () {
                      _protocolDetails(context, repo, protocol);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _iconForCategory(protocol.category),
                          color: AppColors.accent,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          protocol.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${protocol.categoryGroup} · ${protocol.evidenceLevel}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 10),
          Text(
            'No streaks, scores, or overdue pressure. Keep, adjust, pause, or stop any practice.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Future<void> _protocolDetails(
    BuildContext context,
    GrowthRepository repo,
    WellnessProtocolSpec preset,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _ProtocolSheet(
        preset: preset,
        onAdd: () async {
          await repo.addProtocol(preset);
          if (sheetContext.mounted) Navigator.pop(sheetContext);
        },
      ),
    );
  }

  Future<void> _habitDetails(
    BuildContext context,
    GrowthRepository repo,
    Habit habit,
    List<WellnessProtocolSpec> protocols,
  ) async {
    final protocol = protocols
        .where((item) => item.id == habit.protocolId)
        .firstOrNull;
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
              if (protocol != null && protocol.sources.isNotEmpty) ...[
                const Text('Sources'),
                for (final source in protocol.sources)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(source.title),
                    subtitle: SelectableText(source.url),
                    trailing: IconButton(
                      tooltip: 'Copy source link',
                      icon: const Icon(Icons.copy_outlined, size: 18),
                      onPressed: () =>
                          Clipboard.setData(ClipboardData(text: source.url)),
                    ),
                  ),
              ],
              Text(_scheduleSummary(habit)),
              Row(
                children: [
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
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            await repo.setReminder(
                              habit: habit,
                              hour: time.hour,
                              minute: time.minute,
                            );
                          }
                        } else {
                          await repo.clearReminder(habit.id);
                        }
                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                      },
                      icon: Icon(
                        habit.reminderTime == null
                            ? Icons.notifications_outlined
                            : Icons.notifications_off_outlined,
                      ),
                      label: Text(
                        habit.reminderTime == null
                            ? 'Reminder'
                            : 'Remove reminder',
                      ),
                    ),
                  ),
                ],
              ),
              if (_reviewDue(habit))
                OutlinedButton.icon(
                  onPressed: () async {
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                    await _reviewHabit(context, repo, habit);
                  },
                  icon: const Icon(Icons.rate_review_outlined),
                  label: const Text('Review this practice'),
                ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                        await _showHistory(context, repo, habit);
                      },
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: const Text('History'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await repo.updateHabit(
                          habit.id,
                          HabitsCompanion(
                            status: Value(
                              habit.status == 'active' ? 'paused' : 'active',
                            ),
                          ),
                        );
                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                      },
                      child: Text(
                        habit.status == 'active' ? 'Pause' : 'Resume',
                      ),
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
    return DateTime.now().isAfter(
      last.add(Duration(days: habit.reviewAfterDays!)),
    );
  }

  Future<void> _showHistory(
    BuildContext context,
    GrowthRepository repo,
    Habit habit,
  ) async {
    final logs = await repo.habitHistory(habit.id);
    if (!context.mounted) return;
    final byDay = {for (final log in logs) log.day: log.status};
    final today = DateTime.now();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text(
              '${habit.name} history',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Last 28 days · no streak or score calculation',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            for (var offset = 0; offset < 28; offset++) ...[
              Builder(
                builder: (context) {
                  final date = today.subtract(Duration(days: offset));
                  final key = growthDayKey(date);
                  final status = byDay[key];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Icon(
                      status == 'completed'
                          ? Icons.check_circle_outline
                          : status == 'minimum'
                          ? Icons.remove_circle_outline
                          : status == 'skipped'
                          ? Icons.skip_next_outlined
                          : Icons.radio_button_unchecked,
                      color: status == null
                          ? Theme.of(context).colorScheme.outline
                          : AppColors.accent,
                    ),
                    title: Text(DateFormat.yMMMd().format(date)),
                    trailing: Text(status ?? 'Not logged'),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _reviewHabit(
    BuildContext context,
    GrowthRepository repo,
    Habit habit,
  ) async {
    final notes = TextEditingController();
    var outcome = 'keep';
    bool? helped;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (c, setDialogState) => AlertDialog(
          title: Text('Review ${habit.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: outcome,
                  decoration: const InputDecoration(labelText: 'Decision'),
                  items: const [
                    DropdownMenuItem(value: 'keep', child: Text('Keep')),
                    DropdownMenuItem(value: 'adjust', child: Text('Adjust')),
                    DropdownMenuItem(value: 'pause', child: Text('Pause')),
                    DropdownMenuItem(value: 'stop', child: Text('Stop')),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => outcome = value ?? 'keep'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<bool?>(
                  initialValue: helped,
                  decoration: const InputDecoration(labelText: 'Did it help?'),
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Yes')),
                    DropdownMenuItem(value: false, child: Text('Not yet')),
                  ],
                  onChanged: (value) => setDialogState(() => helped = value),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notes,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save review'),
            ),
          ],
        ),
      ),
    );
    if (saved == true) {
      await repo.addReview(
        habitId: habit.id,
        outcome: outcome,
        helped: helped,
        notes: notes.text.trim().isEmpty ? null : notes.text.trim(),
      );
    }
    notes.dispose();
  }

  Future<void> _editSchedule(
    BuildContext context,
    GrowthRepository repo,
    Habit habit,
  ) async {
    var type = habit.scheduleType;
    var days = (habit.fixedDays ?? '')
        .split(',')
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
    final target = TextEditingController(
      text: habit.weeklyTarget?.toString() ?? '',
    );
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (c, setState) => AlertDialog(
          title: const Text('Practice schedule'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: type,
                  items: const [
                    DropdownMenuItem(value: 'none', child: Text('No schedule')),
                    DropdownMenuItem(value: 'fixed', child: Text('Fixed days')),
                    DropdownMenuItem(
                      value: 'weekly',
                      child: Text('Flexible weekly target'),
                    ),
                    DropdownMenuItem(
                      value: 'both',
                      child: Text('Fixed days + weekly target'),
                    ),
                  ],
                  onChanged: (v) => setState(() => type = v ?? 'none'),
                ),
                if (type == 'fixed' || type == 'both') ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 4,
                    children: [
                      for (var day = 1; day <= 7; day++)
                        FilterChip(
                          label: Text(_dayNames('$day')),
                          selected: days.contains(day),
                          onSelected: (selected) => setState(
                            () => selected ? days.add(day) : days.remove(day),
                          ),
                        ),
                    ],
                  ),
                ],
                if (type == 'weekly' || type == 'both')
                  TextField(
                    controller: target,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Times per week',
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (result == true) {
      await repo.setSchedule(
        habit: habit,
        type: type,
        days: days.toList()..sort(),
        weeklyTarget: int.tryParse(target.text),
      );
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: purpose,
                decoration: const InputDecoration(
                  labelText: 'Purpose (optional)',
                ),
              ),
              TextField(
                controller: minimum,
                decoration: const InputDecoration(
                  labelText: 'Minimum version (optional)',
                ),
              ),
              TextField(
                controller: target,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weekly target (optional)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (added == true && name.text.trim().isNotEmpty) {
      await repo.addCustom(
        name: name.text.trim(),
        purpose: purpose.text.trim().isEmpty ? null : purpose.text.trim(),
        minimumVersion: minimum.text.trim().isEmpty
            ? null
            : minimum.text.trim(),
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: target,
                decoration: const InputDecoration(
                  labelText: 'Target (optional)',
                ),
              ),
              DropdownButtonFormField<String>(
                initialValue: kind,
                decoration: const InputDecoration(labelText: 'Automatic link'),
                items: const [
                  DropdownMenuItem(value: 'custom', child: Text('None')),
                  DropdownMenuItem(
                    value: 'habit',
                    child: Text('Growth practices'),
                  ),
                  DropdownMenuItem(
                    value: 'training',
                    child: Text('Strength training'),
                  ),
                  DropdownMenuItem(
                    value: 'nutrition',
                    child: Text('Nutrition logging days'),
                  ),
                  DropdownMenuItem(
                    value: 'cardio',
                    child: Text('Zone 2 minutes'),
                  ),
                ],
                onChanged: (value) => setState(() => kind = value ?? 'custom'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Add'),
            ),
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

  final WellnessProtocolSpec preset;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Wrap(
          runSpacing: 10,
          children: [
            Text(preset.title, style: Theme.of(context).textTheme.titleLarge),
            Text(
              preset.category,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Text(preset.purpose),
            Text(preset.instructions),
            Text('Minimum version: ${preset.minimumVersion}'),
            Text('Standard version: ${preset.standardVersion}'),
            Text(
              'Frequency: ${preset.frequency} · Best time: ${preset.bestTime}',
            ),
            if (preset.durationMinutes != null)
              Text('Duration: ${preset.durationMinutes} minutes'),
            Text('Evidence: ${preset.evidenceLevel}'),
            Text('Safety: ${preset.safetyNotes}'),
            if (preset.sources.isNotEmpty) ...[
              const Text('Sources'),
              for (final source in preset.sources)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text('${source.title} · ${source.publisher}'),
                  subtitle: SelectableText(source.url),
                  trailing: IconButton(
                    tooltip: 'Copy source link',
                    icon: const Icon(Icons.copy_outlined, size: 18),
                    onPressed: () =>
                        Clipboard.setData(ClipboardData(text: source.url)),
                  ),
                ),
            ],
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add to my practices'),
            ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onOpen,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    habit.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (muted) const Chip(label: Text('Paused')),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          if (habit.weeklyTarget != null)
            Text(
              '${habit.weeklyTarget} times per week · consistency over perfection',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [
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
            ],
          ),
        ],
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.close, size: 19),
              ),
            ],
          ),
          if (goal.target != null)
            Text(goal.target!, style: Theme.of(context).textTheme.bodySmall),
          if (goal.kind != 'custom')
            FutureBuilder<int>(
              future: repo.contributionCount(goal),
              builder: (context, snapshot) => Text(
                'Automatically linked activity: ${snapshot.data ?? 0}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: [
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
            ],
          ),
        ],
      ),
    );
  }
}

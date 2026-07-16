import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/database.dart';
import 'task_logic.dart';
import 'task_repository.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final _entryController = TextEditingController();
  int? _filterListId; // null = all

  @override
  void initState() {
    super.initState();
    // Quietly clean up tasks completed more than 3 days ago.
    Future.microtask(
        () => ref.read(taskRepositoryProvider).purgeExpiredCompleted());
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(allTasksProvider);
    final lists = ref.watch(taskListsProvider).value ?? [];
    final repo = ref.read(taskRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            tooltip: 'New category',
            icon: const Icon(Icons.create_new_folder_outlined),
            onPressed: () => _addCategory(context, repo),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _entryController,
                    decoration: const InputDecoration(
                      hintText: 'Add a task…',
                      prefixIcon: Icon(Icons.add),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _quickAdd(),
                  ),
                ),
                IconButton(
                  tooltip: 'Add with details',
                  icon: const Icon(Icons.tune),
                  onPressed: () async {
                    final title = _entryController.text.trim();
                    final id = await repo.quickAdd(
                        title.isEmpty ? 'New task' : title);
                    _entryController.clear();
                    if (!mounted) return;
                    final all = ref.read(allTasksProvider).value ?? [];
                    final task = all.where((t) => t.id == id).firstOrNull;
                    if (task != null && context.mounted) {
                      _openDetails(context, task);
                    }
                  },
                ),
              ],
            ),
          ),
          if (lists.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: _filterListId == null,
                      onSelected: (_) => setState(() => _filterListId = null),
                    ),
                  ),
                  for (final l in lists)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(l.name),
                        selected: _filterListId == l.id,
                        onSelected: (_) =>
                            setState(() => _filterListId = l.id),
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: tasksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Something went wrong: $e')),
              data: (all) {
                final filtered = _filterListId == null
                    ? all
                    : all.where((t) => t.listId == _filterListId).toList();
                final ordered = displayOrder(filtered, DateTime.now());
                final openCount =
                    ordered.where((t) => t.completedAt == null).length;
                if (ordered.isEmpty) {
                  return Center(
                    child: Text('Nothing here — add anything on your mind.',
                        style: Theme.of(context).textTheme.bodyMedium),
                  );
                }
                if (_filterListId == null && lists.isNotEmpty) {
                  final groups = groupTasksByCategory(all, DateTime.now());
                  return ListView(
                    padding: const EdgeInsets.only(bottom: 96),
                    children: [
                      for (final category in lists)
                        if (groups[category.id]?.isNotEmpty ?? false)
                          _CategorySection(
                            title: category.name,
                            tasks: groups[category.id]!,
                            repo: repo,
                            onOpen: _openDetails,
                          ),
                      if (groups[null]?.isNotEmpty ?? false)
                        _CategorySection(
                          title: 'Uncategorized',
                          tasks: groups[null]!,
                          repo: repo,
                          onOpen: _openDetails,
                        ),
                    ],
                  );
                }
                return ReorderableListView.builder(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: ordered.length,
                  buildDefaultDragHandles: false,
                  onReorderItem: (oldIndex, newIndex) =>
                      _onReorder(ordered, openCount, oldIndex, newIndex),
                  itemBuilder: (context, i) {
                    final t = ordered[i];
                    final isOpen = t.completedAt == null;
                    return _TaskTile(
                      key: ValueKey(t.id),
                      task: t,
                      index: i,
                      draggable: isOpen,
                      onToggle: () => repo.setCompleted(t.id, isOpen),
                      onTap: () => _openDetails(context, t),
                      onDelete: () => repo.deleteTask(t.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addCategory(
      BuildContext context, TaskRepository repo) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('New category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Work, Home, Health'),
          onSubmitted: (value) => Navigator.pop(c, value),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(c, controller.text),
              child: const Text('Create')),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) {
      await repo.addList(name.trim());
    }
    controller.dispose();
  }

  void _quickAdd() {
    final text = _entryController.text.trim();
    if (text.isEmpty) return;
    ref.read(taskRepositoryProvider).quickAdd(text);
    _entryController.clear();
  }

  void _onReorder(
      List<Task> ordered, int openCount, int oldIndex, int newIndex) {
    // Only open tasks reorder; completed stay at the bottom.
    // newIndex is already adjusted for the removed item (onReorderItem).
    if (oldIndex >= openCount) return;
    if (newIndex >= openCount) newIndex = openCount - 1;
    final open = ordered.sublist(0, openCount);
    final moved = open.removeAt(oldIndex);
    open.insert(newIndex, moved);
    final before = newIndex > 0 ? open[newIndex - 1] : null;
    final after = newIndex < open.length - 1 ? open[newIndex + 1] : null;
    ref
        .read(taskRepositoryProvider)
        .setManualPosition(moved.id, manualPositionBetween(before, after));
  }

  void _openDetails(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => TaskDetailsSheet(taskId: task.id),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.tasks,
    required this.repo,
    required this.onOpen,
  });

  final String title;
  final List<Task> tasks;
  final TaskRepository repo;
  final void Function(BuildContext, Task) onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          child: Row(
            children: [
              Icon(Icons.folder_open_outlined,
                  size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text('${tasks.length}',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        for (final task in tasks)
          _TaskTile(
            key: ValueKey('category-${task.id}'),
            task: task,
            index: 0,
            draggable: false,
            onToggle: () => repo.setCompleted(
                task.id, task.completedAt == null),
            onTap: () => onOpen(context, task),
            onDelete: () => repo.deleteTask(task.id),
          ),
      ],
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    super.key,
    required this.task,
    required this.index,
    required this.draggable,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  final Task task;
  final int index;
  final bool draggable;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final done = task.completedAt != null;
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey('dismiss-${task.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: theme.colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.delete_outline),
      ),
      child: ListTile(
        leading: Checkbox(value: done, onChanged: (_) => onToggle()),
        title: Text(
          task.title,
          style: done
              ? TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: theme.colorScheme.outline)
              : null,
        ),
        subtitle: task.dueDate != null && !done
            ? Text(DateFormat.MMMEd().format(task.dueDate!))
            : null,
        trailing: draggable
            ? ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_handle),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}

class TaskDetailsSheet extends ConsumerStatefulWidget {
  const TaskDetailsSheet({super.key, required this.taskId});

  final int taskId;

  @override
  ConsumerState<TaskDetailsSheet> createState() => _TaskDetailsSheetState();
}

class _TaskDetailsSheetState extends ConsumerState<TaskDetailsSheet> {
  final _subtaskController = TextEditingController();

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(allTasksProvider).value ?? [];
    final task = all.where((t) => t.id == widget.taskId).firstOrNull;
    if (task == null) return const SizedBox.shrink();
    final repo = ref.read(taskRepositoryProvider);
    final lists = ref.watch(taskListsProvider).value ?? [];

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: task.title,
              style: Theme.of(context).textTheme.titleLarge,
              decoration: const InputDecoration(hintText: 'Task'),
              onFieldSubmitted: (v) => repo.updateTask(
                  task.id, TasksCompanion(title: Value(v.trim()))),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: task.notes ?? '',
              maxLines: 3,
              minLines: 1,
              decoration: const InputDecoration(hintText: 'Notes'),
              onChanged: (v) => repo.updateTask(
                  task.id,
                  TasksCompanion(
                      notes: Value(v.trim().isEmpty ? null : v.trim()))),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip(
                  context,
                  icon: Icons.event,
                  label: task.dueDate == null
                      ? 'Due date'
                      : DateFormat.MMMEd().format(task.dueDate!),
                  selected: task.dueDate != null,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                      initialDate: task.dueDate ?? DateTime.now(),
                    );
                    if (picked != null) {
                      repo.updateTask(
                          task.id, TasksCompanion(dueDate: Value(picked)));
                    }
                  },
                  onClear: task.dueDate == null
                      ? null
                      : () => repo.updateTask(
                          task.id, const TasksCompanion(dueDate: Value(null))),
                ),
                _chip(
                  context,
                  icon: Icons.notifications_outlined,
                  label: task.reminderAt == null
                      ? 'Reminder'
                      : DateFormat.MMMEd().add_jm().format(task.reminderAt!),
                  selected: task.reminderAt != null,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDate: task.reminderAt ?? DateTime.now(),
                    );
                    if (date == null || !context.mounted) return;
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time == null) return;
                    final when = DateTime(date.year, date.month, date.day,
                        time.hour, time.minute);
                    repo.updateTask(
                        task.id, TasksCompanion(reminderAt: Value(when)));
                  },
                  onClear: task.reminderAt == null
                      ? null
                      : () => repo.updateTask(task.id,
                          const TasksCompanion(reminderAt: Value(null))),
                ),
                _chip(
                  context,
                  icon: Icons.label_outline,
                  label: task.listId == null
                      ? 'Category'
                      : (lists
                              .where((l) => l.id == task.listId)
                              .firstOrNull
                              ?.name ??
                          'Category'),
                  selected: task.listId != null,
                  onTap: () => _pickList(context, repo, task, lists),
                  onClear: task.listId == null
                      ? null
                      : () => repo.updateTask(
                          task.id, const TasksCompanion(listId: Value(null))),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SubtasksSection(
                taskId: task.id, controller: _subtaskController),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context,
      {required IconData icon,
      required String label,
      required bool selected,
      required VoidCallback onTap,
      VoidCallback? onClear}) {
    return InputChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      selected: selected,
      onPressed: onTap,
      onDeleted: onClear,
    );
  }

  Future<void> _pickList(BuildContext context, TaskRepository repo, Task task,
      List<TaskList> lists) async {
    final controller = TextEditingController();
    await showModalBottomSheet(
      context: context,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final l in lists)
              ListTile(
                title: Text(l.name),
                onTap: () {
                  repo.updateTask(
                      task.id, TasksCompanion(listId: Value(l.id)));
                  Navigator.pop(c);
                },
              ),
            ListTile(
              leading: const Icon(Icons.add),
              title: TextField(
                controller: controller,
                decoration: const InputDecoration(
                    hintText: 'New category (e.g. Work)'),
                onSubmitted: (v) async {
                  if (v.trim().isEmpty) return;
                  final id = await repo.addList(v.trim());
                  await repo.updateTask(
                      task.id, TasksCompanion(listId: Value(id)));
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

class _SubtasksSection extends ConsumerWidget {
  const _SubtasksSection({required this.taskId, required this.controller});

  final int taskId;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(taskRepositoryProvider);
    return StreamBuilder(
      stream: repo.watchSubtasks(taskId),
      builder: (context, snapshot) {
        final subtasks = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final s in subtasks)
              Row(
                children: [
                  Checkbox(
                      value: s.done,
                      onChanged: (v) =>
                          repo.setSubtaskDone(s.id, v ?? false)),
                  Expanded(
                    child: Text(s.title,
                        style: s.done
                            ? const TextStyle(
                                decoration: TextDecoration.lineThrough)
                            : null),
                  ),
                  IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => repo.deleteSubtask(s.id)),
                ],
              ),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Add subtask (optional)',
                prefixIcon: Icon(Icons.subdirectory_arrow_right),
              ),
              onSubmitted: (v) {
                if (v.trim().isEmpty) return;
                repo.addSubtask(taskId, v.trim());
                controller.clear();
              },
            ),
          ],
        );
      },
    );
  }
}

import '../../core/database/database.dart';

/// Days a completed task stays visible (crossed out) before disappearing.
const completedVisibleDays = 3;

bool isCompletedVisible(Task t, DateTime now) {
  final done = t.completedAt;
  if (done == null) return true;
  return now.difference(done).inDays < completedVisibleDays;
}

/// Sort key for open tasks:
/// - manual drag position wins when set
/// - dated tasks sort by due date
/// - undated tasks keep creation order
double openSortKey(Task t) {
  if (t.manualPosition != null) return t.manualPosition!;
  final anchor = t.dueDate ?? t.createdAt;
  return anchor.millisecondsSinceEpoch.toDouble();
}

/// Returns open tasks (sorted) followed by visible completed tasks
/// (most recently completed first).
List<Task> displayOrder(List<Task> all, DateTime now) {
  final open = all.where((t) => t.completedAt == null).toList()
    ..sort((a, b) {
      final c = openSortKey(a).compareTo(openSortKey(b));
      return c != 0 ? c : a.id.compareTo(b.id);
    });
  final done = all
      .where((t) => t.completedAt != null && isCompletedVisible(t, now))
      .toList()
    ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
  return [...open, ...done];
}

/// Groups tasks into visual categories while preserving the task ordering
/// rules within each category. A null key is the uncategorized section.
Map<int?, List<Task>> groupTasksByCategory(
    List<Task> all, DateTime now) {
  final groups = <int?, List<Task>>{};
  for (final task in displayOrder(all, now)) {
    groups.putIfAbsent(task.listId, () => []).add(task);
  }
  return groups;
}

/// New manual position when dropping between [before] and [after]
/// (either may be null at list edges).
double manualPositionBetween(Task? before, Task? after) {
  if (before == null && after == null) return 0;
  if (before == null) return openSortKey(after!) - 1000000;
  if (after == null) return openSortKey(before) + 1000000;
  return (openSortKey(before) + openSortKey(after)) / 2;
}

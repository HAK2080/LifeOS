import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';
import '../../core/database/database_provider.dart';
import '../../core/notifications/notification_service.dart';

class TaskRepository {
  TaskRepository(this.db, this.notifications);

  final AppDatabase db;
  final NotificationService notifications;

  Stream<List<Task>> watchAll() => db.select(db.tasks).watch();

  Stream<List<TaskList>> watchLists() => db.select(db.taskLists).watch();

  Stream<List<Subtask>> watchSubtasks(int taskId) =>
      (db.select(db.subtasks)..where((t) => t.taskId.equals(taskId))).watch();

  Future<int> quickAdd(String title) =>
      db.into(db.tasks).insert(TasksCompanion.insert(title: title));

  Future<void> updateTask(int id, TasksCompanion changes) async {
    await (db.update(db.tasks)..where((t) => t.id.equals(id))).write(changes);
    if (changes.reminderAt.present) {
      final when = changes.reminderAt.value;
      if (when == null) {
        await notifications.cancelTaskReminder(id);
      } else {
        final task = await (db.select(db.tasks)..where((t) => t.id.equals(id)))
            .getSingle();
        await notifications.scheduleTaskReminder(
            taskId: id, title: task.title, when: when);
      }
    }
  }

  Future<void> setCompleted(int id, bool completed) =>
      (db.update(db.tasks)..where((t) => t.id.equals(id))).write(
        TasksCompanion(
            completedAt:
                Value(completed ? DateTime.now() : null)),
      );

  Future<void> deleteTask(int id) async {
    await (db.delete(db.subtasks)..where((t) => t.taskId.equals(id))).go();
    await (db.delete(db.tasks)..where((t) => t.id.equals(id))).go();
    await notifications.cancelTaskReminder(id);
  }

  Future<void> setManualPosition(int id, double position) =>
      (db.update(db.tasks)..where((t) => t.id.equals(id)))
          .write(TasksCompanion(manualPosition: Value(position)));

  Future<int> addList(String name) =>
      db.into(db.taskLists).insert(TaskListsCompanion.insert(name: name));

  Future<int> addSubtask(int taskId, String title) => db
      .into(db.subtasks)
      .insert(SubtasksCompanion.insert(taskId: taskId, title: title));

  Future<void> setSubtaskDone(int id, bool done) =>
      (db.update(db.subtasks)..where((t) => t.id.equals(id)))
          .write(SubtasksCompanion(done: Value(done)));

  Future<void> deleteSubtask(int id) =>
      (db.delete(db.subtasks)..where((t) => t.id.equals(id))).go();

  /// Purge completed tasks older than the visibility window.
  Future<void> purgeExpiredCompleted() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 3));
    await (db.delete(db.tasks)
          ..where((t) =>
              t.completedAt.isNotNull() &
              t.completedAt.isSmallerThanValue(cutoff)))
        .go();
  }
}

final taskRepositoryProvider = Provider<TaskRepository>((ref) => TaskRepository(
    ref.watch(databaseProvider), ref.watch(notificationServiceProvider)));

final allTasksProvider = StreamProvider<List<Task>>(
    (ref) => ref.watch(taskRepositoryProvider).watchAll());

final taskListsProvider = StreamProvider<List<TaskList>>(
    (ref) => ref.watch(taskRepositoryProvider).watchLists());

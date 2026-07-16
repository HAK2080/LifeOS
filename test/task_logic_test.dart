import 'package:flutter_test/flutter_test.dart';

import 'package:life_app/core/database/database.dart';
import 'package:life_app/features/tasks/task_logic.dart';

Task makeTask({
  required int id,
  DateTime? due,
  DateTime? created,
  DateTime? completed,
  double? manual,
}) {
  return Task(
    id: id,
    title: 'task $id',
    notes: null,
    dueDate: due,
    reminderAt: null,
    listId: null,
    attachmentPath: null,
    manualPosition: manual,
    createdAt: created ?? DateTime(2026, 7, 1),
    completedAt: completed,
  );
}

void main() {
  final now = DateTime(2026, 7, 16, 12);

  group('displayOrder', () {
    test('undated tasks keep creation order', () {
      final tasks = [
        makeTask(id: 2, created: DateTime(2026, 7, 2)),
        makeTask(id: 1, created: DateTime(2026, 7, 1)),
        makeTask(id: 3, created: DateTime(2026, 7, 3)),
      ];
      expect(displayOrder(tasks, now).map((t) => t.id), [1, 2, 3]);
    });

    test('dated tasks appear according to date', () {
      final tasks = [
        makeTask(id: 1, created: DateTime(2026, 7, 1)), // undated, oldest
        makeTask(id: 2, due: DateTime(2026, 6, 20)),
        makeTask(id: 3, due: DateTime(2026, 8, 1)),
      ];
      final order = displayOrder(tasks, now).map((t) => t.id).toList();
      expect(order.first, 2); // earliest due date first
      expect(order.indexOf(1) < order.indexOf(3), isTrue);
    });

    test('manual position overrides automatic ordering', () {
      final tasks = [
        makeTask(id: 1, due: DateTime(2026, 6, 20)),
        makeTask(id: 2, due: DateTime(2026, 8, 1), manual: 0),
      ];
      expect(displayOrder(tasks, now).map((t) => t.id), [2, 1]);
    });

    test('completed tasks move to the bottom', () {
      final tasks = [
        makeTask(id: 1, completed: now.subtract(const Duration(hours: 2))),
        makeTask(id: 2),
      ];
      expect(displayOrder(tasks, now).map((t) => t.id), [2, 1]);
    });

    test('completed tasks disappear after three days', () {
      final tasks = [
        makeTask(id: 1, completed: now.subtract(const Duration(days: 4))),
        makeTask(id: 2, completed: now.subtract(const Duration(days: 2))),
        makeTask(id: 3),
      ];
      expect(displayOrder(tasks, now).map((t) => t.id), [3, 2]);
    });
  });

  group('manualPositionBetween', () {
    test('drops before the first item', () {
      final after = makeTask(id: 1, manual: 100);
      expect(manualPositionBetween(null, after), lessThan(100));
    });

    test('drops after the last item', () {
      final before = makeTask(id: 1, manual: 100);
      expect(manualPositionBetween(before, null), greaterThan(100));
    });

    test('drops between two items', () {
      final a = makeTask(id: 1, manual: 100);
      final b = makeTask(id: 2, manual: 200);
      expect(manualPositionBetween(a, b), 150);
    });
  });
}

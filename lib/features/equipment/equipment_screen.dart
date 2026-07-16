import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';
import '../../core/database/database_provider.dart';

final equipmentProvider = StreamProvider<List<EquipmentItem>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.equipmentItems)
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .watch();
});

class EquipmentScreen extends ConsumerWidget {
  const EquipmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final items = ref.watch(equipmentProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Equipment')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add'),
        onPressed: () => _edit(context, db, null),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'One global library — used across all training features. '
              'Adding from photos comes with the AI phase; photos are always '
              'deleted after extraction.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          for (final e in items)
            SwitchListTile(
              title: Text(e.name),
              subtitle: e.notes == null ? null : Text(e.notes!),
              value: e.available,
              onChanged: (v) => (db.update(db.equipmentItems)
                    ..where((t) => t.id.equals(e.id)))
                  .write(EquipmentItemsCompanion(available: Value(v))),
              secondary: IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _edit(context, db, e),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _edit(
      BuildContext context, AppDatabase db, EquipmentItem? item) async {
    final nameController = TextEditingController(text: item?.name ?? '');
    final notesController = TextEditingController(text: item?.notes ?? '');
    await showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(item == null ? 'Add equipment' : 'Edit equipment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: item == null,
              decoration: const InputDecoration(hintText: 'Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              decoration:
                  const InputDecoration(hintText: 'Notes (weights, sizes…)'),
            ),
          ],
        ),
        actions: [
          if (item != null)
            TextButton(
              onPressed: () async {
                await (db.delete(db.equipmentItems)
                      ..where((t) => t.id.equals(item.id)))
                    .go();
                if (c.mounted) Navigator.pop(c);
              },
              child: const Text('Remove'),
            ),
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final notes = notesController.text.trim();
              if (item == null) {
                await db.into(db.equipmentItems).insert(
                    EquipmentItemsCompanion.insert(
                        name: name,
                        notes: Value(notes.isEmpty ? null : notes)));
              } else {
                await (db.update(db.equipmentItems)
                      ..where((t) => t.id.equals(item.id)))
                    .write(EquipmentItemsCompanion(
                        name: Value(name),
                        notes: Value(notes.isEmpty ? null : notes)));
              }
              if (c.mounted) Navigator.pop(c);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

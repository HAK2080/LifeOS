import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

class TaskLists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get reminderAt => dateTime().nullable()();
  IntColumn get listId => integer().nullable().references(TaskLists, #id)();
  TextColumn get attachmentPath => text().nullable()();
  RealColumn get manualPosition => real().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

class Subtasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer().references(Tasks, #id)();
  TextColumn get title => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
}

class EquipmentItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get notes => text().nullable()();
  BoolColumn get available => boolean().withDefault(const Constant(true))();
}

class CheckIns extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get day => text()(); // yyyy-MM-dd
  IntColumn get mood => integer().nullable()(); // 1-5
  IntColumn get energy => integer().nullable()();
  IntColumn get physical => integer().nullable()();
}

class GoodDeeds extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get day => text()();
  TextColumn get title => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
}

class FocusEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get day => text()();
  TextColumn get title => text()();
  // pending | completed | skipped
  TextColumn get status => text().withDefault(const Constant('pending'))();
}

@DriftDatabase(tables: [
  TaskLists,
  Tasks,
  Subtasks,
  EquipmentItems,
  CheckIns,
  GoodDeeds,
  FocusEntries,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(driftDatabase(
          name: 'life_app',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ));

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  static const seedEquipment = [
    'Smith machine / functional trainer',
    'Adjustable bench',
    'Dumbbells',
    'Kettlebells',
    'Straight barbell',
    'EZ-curl bar',
    'Trap bar',
    'Plates',
    'Cable attachments',
    'Resistance bands',
    'Battle ropes',
    'Rings',
    'Pull-up rig',
    'Climbing rope',
    'Plyometric boxes',
    'Curved treadmill',
    'Air rower',
    'SkiErg',
    'Stationary / air bike',
  ];

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await batch((b) {
            b.insertAll(
              equipmentItems,
              seedEquipment
                  .map((e) => EquipmentItemsCompanion.insert(name: e)),
            );
          });
        },
      );
}

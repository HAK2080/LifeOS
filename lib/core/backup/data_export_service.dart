import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../database/database.dart';
import 'encrypted_backup_codec.dart';

/// Creates a portable, human-readable snapshot of the local database.
///
/// The export is deliberately JSON rather than a raw SQLite file so it can be
/// inspected, migrated, and restored without exposing internal database files.
class DataExportService {
  const DataExportService(this.database);

  final AppDatabase database;

  Future<String> buildJson() async {
    final tables = <String, dynamic>{
      'taskLists': await _rows(database.select(database.taskLists)),
      'tasks': await _rows(database.select(database.tasks)),
      'subtasks': await _rows(database.select(database.subtasks)),
      'equipmentItems': await _rows(database.select(database.equipmentItems)),
      'checkIns': await _rows(database.select(database.checkIns)),
      'goodDeeds': await _rows(database.select(database.goodDeeds)),
      'focusEntries': await _rows(database.select(database.focusEntries)),
      'exercises': await _rows(database.select(database.exercises)),
      'workoutPlans': await _rows(database.select(database.workoutPlans)),
      'planWorkouts': await _rows(database.select(database.planWorkouts)),
      'planExercises': await _rows(database.select(database.planExercises)),
      'workoutSessions': await _rows(database.select(database.workoutSessions)),
      'sessionExercises': await _rows(database.select(database.sessionExercises)),
      'sessionSets': await _rows(database.select(database.sessionSets)),
      'zone2Sessions': await _rows(database.select(database.zone2Sessions)),
      'wodSessions': await _rows(database.select(database.wodSessions)),
      'meals': await _rows(database.select(database.meals)),
      'mealLogs': await _rows(database.select(database.mealLogs)),
      'weightEntries': await _rows(database.select(database.weightEntries)),
      'habits': await _rows(database.select(database.habits)),
      'habitLogs': await _rows(database.select(database.habitLogs)),
      'goals': await _rows(database.select(database.goals)),
    };

    return const JsonEncoder.withIndent('  ').convert({
      'format': 'life-local-backup',
      'version': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'tables': tables,
    });
  }

  Future<ShareResult> share() async {
    return _shareBytes(
      utf8.encode(await buildJson()),
      name: 'life-backup.json',
      text: 'Life local backup',
    );
  }

  Future<ShareResult> shareEncrypted(String password) async {
    final encrypted = await const EncryptedBackupCodec()
        .encrypt(await buildJson(), password);
    return _shareBytes(
      utf8.encode(encrypted),
      name: 'life-encrypted-backup.json',
      text: 'Life encrypted local backup',
    );
  }

  Future<ShareResult> _shareBytes(
      List<int> bytes, {
      required String name,
      required String text,
    }) {
    return SharePlus.instance.share(ShareParams(
      text: text,
      files: [XFile.fromData(Uint8List.fromList(bytes), name: name, mimeType: 'application/json')],
    ));
  }

  Future<void> pickAndRestore() async {
    await _pickAndReadBackup((source) => restoreJson(source));
  }

  Future<void> pickAndRestoreEncrypted(String password) async {
    await _pickAndReadBackup((source) async {
      final clear = await const EncryptedBackupCodec().decrypt(source, password);
      await restoreJson(clear);
    });
  }

  Future<void> _pickAndReadBackup(Future<void> Function(String) restore) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    final bytes = picked?.files.single.bytes;
    if (bytes == null) throw const FormatException('No backup file selected');
    await restore(utf8.decode(bytes));
  }

  Future<void> restoreJson(String source) async {
    final decoded = jsonDecode(source);
    if (decoded is! Map || decoded['format'] != 'life-local-backup') {
      throw const FormatException('Not a Life local backup');
    }
    if (decoded['version'] != 1 || decoded['tables'] is! Map) {
      throw const FormatException('Unsupported Life backup version');
    }
    final tables = Map<String, dynamic>.from(decoded['tables'] as Map);
    final orderedTables = <String>[
      'task_lists', 'tasks', 'subtasks', 'equipment_items', 'check_ins',
      'good_deeds', 'focus_entries', 'exercises', 'workout_plans',
      'plan_workouts', 'plan_exercises', 'workout_sessions',
      'session_exercises', 'session_sets', 'zone2_sessions', 'wod_sessions',
      'meals', 'meal_logs', 'weight_entries', 'habits', 'habit_logs', 'goals',
    ];
    await database.transaction(() async {
      for (final table in orderedTables.reversed) {
        await database.customStatement('DELETE FROM $table');
      }
      for (final table in orderedTables) {
        final key = _camelCase(table);
        final rows = tables[key];
        if (rows is! List) continue;
        for (final rawRow in rows) {
          if (rawRow is! Map || rawRow.isEmpty) {
            throw const FormatException('Backup contains an invalid row');
          }
          final row = Map<String, dynamic>.from(rawRow);
          final columns = row.keys.map(_snakeCase).toList();
          final values = row.values.map(_sqlValue).toList();
          final placeholders = List.filled(columns.length, '?').join(', ');
          await database.customStatement(
            'INSERT INTO $table (${columns.join(', ')}) VALUES ($placeholders)',
            values,
          );
        }
      }
    });
  }

  Future<List<Map<String, dynamic>>> _rows(Selectable<dynamic> query) async {
    final rows = await query.get();
    return rows
        .map((row) => (row as dynamic).toJson() as Map<String, dynamic>)
        .toList();
  }

  String _camelCase(String value) => value.split('_').first +
      value.split('_').skip(1).map((part) => part[0].toUpperCase() + part.substring(1)).join();

  String _snakeCase(String value) => value.replaceAllMapped(
        RegExp(r'([A-Z])'),
        (match) => '_${match.group(1)!.toLowerCase()}',
      );

  dynamic _sqlValue(dynamic value) => value is bool ? (value ? 1 : 0) : value;
}

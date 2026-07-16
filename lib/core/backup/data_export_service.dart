import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:share_plus/share_plus.dart';

import '../database/database.dart';

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
    final bytes = Uint8List.fromList(utf8.encode(await buildJson()));
    return SharePlus.instance.share(ShareParams(
      text: 'Life local backup',
      files: [XFile.fromData(bytes, name: 'life-backup.json', mimeType: 'application/json')],
    ));
  }

  Future<List<Map<String, dynamic>>> _rows(Selectable<dynamic> query) async {
    final rows = await query.get();
    return rows
        .map((row) => (row as dynamic).toJson() as Map<String, dynamic>)
        .toList();
  }
}

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_app/core/backup/data_export_service.dart';
import 'package:life_app/core/database/database.dart';

import 'helpers/test_db.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  test('exports all local tables in a versioned JSON envelope', () async {
    await db.into(db.tasks).insert(const TasksCompanion(title: Value('Review')));

    final decoded = jsonDecode(await DataExportService(db).buildJson())
        as Map<String, dynamic>;

    expect(decoded['format'], 'life-local-backup');
    expect(decoded['version'], 1);
    expect((decoded['tables'] as Map<String, dynamic>)['tasks'], hasLength(1));
    expect(
      ((decoded['tables'] as Map<String, dynamic>)['tasks'] as List).single['title'],
      'Review',
    );
  });
}

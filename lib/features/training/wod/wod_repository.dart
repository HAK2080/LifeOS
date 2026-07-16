import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/database/database_provider.dart';

class WodRepository {
  WodRepository(this.db);

  final AppDatabase db;

  Stream<List<WodSession>> watchCompleted({int limit = 50}) =>
      (db.select(db.wodSessions)
            ..orderBy([(t) => OrderingTerm.desc(t.completedAt)])
            ..limit(limit))
          .watch();

  Future<Set<String>> completedTitles() async {
    final rows = await db.select(db.wodSessions).get();
    return rows.map((r) => r.title).toSet();
  }

  Future<int> logWod({
    required String title,
    required String description,
    required String source,
    int? durationMin,
    String? result,
    String? feeling,
  }) =>
      db.into(db.wodSessions).insert(WodSessionsCompanion.insert(
            title: title,
            description: description,
            source: Value(source),
            durationMin: Value(durationMin),
            result: Value(result),
            feeling: Value(feeling),
          ));
}

final wodRepositoryProvider =
    Provider<WodRepository>((ref) => WodRepository(ref.watch(databaseProvider)));

final completedWodsProvider = StreamProvider<List<WodSession>>(
    (ref) => ref.watch(wodRepositoryProvider).watchCompleted());

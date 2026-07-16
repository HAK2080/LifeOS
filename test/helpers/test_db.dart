import 'package:drift/native.dart';

import 'package:life_app/core/database/database.dart';

/// In-memory AppDatabase for host tests. The sqlite3 package provides the
/// native library through Dart native assets (build hooks).
AppDatabase testDatabase() => AppDatabase.forTesting(NativeDatabase.memory());

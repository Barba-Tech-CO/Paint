import 'package:sqflite/sqflite.dart';

/// Creates utility tables (pending_operations and dashboard_cache)
Future<void> createUtilityTables(Database db) async {
  await db.execute('''
    CREATE TABLE pending_operations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      operation_type TEXT NOT NULL,
      data TEXT NOT NULL,
      created_at TEXT NOT NULL,
      retry_count INTEGER DEFAULT 0,
      last_retry_at TEXT
    )
  ''');

  await db.execute('''
    CREATE TABLE dashboard_cache (
      cache_key TEXT PRIMARY KEY,
      data TEXT NOT NULL,
      cached_at TEXT NOT NULL,
      expires_at TEXT NOT NULL
    )
  ''');

  await db.execute(
    'CREATE INDEX idx_pending_operations_type ON pending_operations(operation_type)',
  );
}

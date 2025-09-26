import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Provides a single sqflite [Database] instance and manages schema creation.
class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'paint_pro_local.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE estimates (
        id TEXT PRIMARY KEY,
        project_name TEXT,
        client_name TEXT,
        contact_id TEXT,
        additional_notes TEXT,
        project_type TEXT,
        status TEXT NOT NULL,
        total_area REAL,
        paintable_area REAL,
        total_cost REAL,
        photos TEXT,
        photos_data TEXT,
        elements TEXT,
        zones TEXT,
        materials TEXT,
        totals TEXT,
        created_at TEXT,
        updated_at TEXT,
        completed_at TEXT,
        is_synced INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'pending'
      )
    ''');

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

    await db.execute('''
      CREATE TABLE quotes (
        id INTEGER PRIMARY KEY,
        user_id INTEGER,
        original_name TEXT NOT NULL,
        display_name TEXT,
        file_path TEXT NOT NULL,
        r2_url TEXT,
        file_hash TEXT,
        status TEXT NOT NULL,
        materials_extracted INTEGER DEFAULT 0,
        extraction_metadata TEXT,
        error_message TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 1,
        sync_status TEXT DEFAULT 'synced'
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_estimates_sync_status ON estimates(sync_status)',
    );
    await db.execute(
      'CREATE INDEX idx_estimates_created_at ON estimates(created_at)',
    );
    await db.execute(
      'CREATE INDEX idx_pending_operations_type ON pending_operations(operation_type)',
    );
    await db.execute(
      'CREATE INDEX idx_quotes_sync_status ON quotes(sync_status)',
    );
    await db.execute(
      'CREATE INDEX idx_quotes_created_at ON quotes(created_at)',
    );
    await db.execute(
      'CREATE INDEX idx_quotes_user_id ON quotes(user_id)',
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}


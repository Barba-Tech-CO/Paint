import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../data/tables/contacts_table.dart';
import '../data/tables/estimates_table.dart';
import '../data/tables/materials_table.dart';
import '../data/tables/pdf_uploads_table.dart';
import '../data/tables/users_table.dart';
import '../data/tables/utility_tables.dart';

/// Provides a single sqflite [Database] instance and manages schema creation.
///
/// This database replicates the exact structure from paint_pro_api for offline-first support.
class DatabaseService {
  static Database? _database;
  static const _databaseName = 'paint_pro_local.db';
  static const _databaseVersion = 3;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  Future<void> _onOpen(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create all tables
    await createUsersTable(db);
    await createContactsTable(db);
    await createEstimatesTable(db);
    await createPdfUploadsTable(db);
    await createMaterialsTable(db);
    await createUtilityTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration from version 1 to 2
    if (oldVersion < 2) {
      // quotes table was added
      await db.execute('''
        CREATE TABLE IF NOT EXISTS quotes (
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
        'CREATE INDEX IF NOT EXISTS idx_quotes_sync_status ON quotes(sync_status)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_quotes_created_at ON quotes(created_at)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_quotes_user_id ON quotes(user_id)',
      );
    }

    // Migration from version 2 to 3 - Complete database restructure
    if (oldVersion < 3) {
      // Drop old quotes table if exists (will be replaced by pdf_uploads)
      await db.execute('DROP TABLE IF EXISTS quotes');

      // Create all new tables
      await _createV3Tables(db);

      // Migrate existing estimates data
      await _migrateEstimatesV3(db);
    }
  }

  /// Creates all tables for version 3
  Future<void> _createV3Tables(Database db) async {
    // Check if tables already exist before creating
    var tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('users', 'contacts', 'pdf_uploads', 'materials')",
    );

    var existingTables = tables.map((t) => t['name'] as String).toSet();

    if (!existingTables.contains('users')) {
      await createUsersTable(db);
    }

    if (!existingTables.contains('contacts')) {
      await createContactsTable(db);
    }

    if (!existingTables.contains('pdf_uploads')) {
      await createPdfUploadsTable(db);
    }

    if (!existingTables.contains('materials')) {
      await createMaterialsTable(db);
    }

    // Add new columns to estimates if table exists
    var estimatesExists = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='estimates'",
    );

    if (estimatesExists.isNotEmpty) {
      // Add user_id column if it doesn't exist
      try {
        await db.execute('ALTER TABLE estimates ADD COLUMN user_id INTEGER');
      } catch (e) {
        // Column might already exist
      }

      // Add other missing columns
      var columns = [
        'ghl_estimate_id TEXT',
        'ghl_contact_id TEXT',
        'wall_condition TEXT',
        'has_accent_wall INTEGER DEFAULT 0',
        'complete INTEGER DEFAULT 0',
        'estimated_timeline_days INTEGER',
        'ghl_folder_name TEXT',
        'photos_uploaded_at TEXT',
        'measurements_completed_at TEXT',
        'sent_to_client_at TEXT',
        'labor_calculation TEXT',
      ];

      for (var column in columns) {
        try {
          await db.execute('ALTER TABLE estimates ADD COLUMN $column');
        } catch (e) {
          // Column might already exist
        }
      }
    }
  }

  /// Migrates existing estimates data to version 3 format
  Future<void> _migrateEstimatesV3(Database db) async {
    // Set default values for new required columns
    await db.execute('''
      UPDATE estimates 
      SET wall_condition = 'good' 
      WHERE wall_condition IS NULL OR wall_condition = ''
    ''');

    await db.execute('''
      UPDATE estimates 
      SET has_accent_wall = 0 
      WHERE has_accent_wall IS NULL
    ''');

    await db.execute('''
      UPDATE estimates 
      SET complete = 0 
      WHERE complete IS NULL
    ''');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

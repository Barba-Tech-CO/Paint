import 'package:sqflite/sqflite.dart';

/// Creates estimates table and indexes
Future<void> createEstimatesTable(Database db) async {
  await db.execute('''
    CREATE TABLE estimates (
      id INTEGER PRIMARY KEY,
      user_id INTEGER,
      ghl_estimate_id TEXT,
      ghl_contact_id TEXT,
      contact TEXT NOT NULL,
      project_name TEXT,
      client_name TEXT,
      project_type TEXT,
      additional_notes TEXT,
      status TEXT NOT NULL DEFAULT 'draft',
      photos_data TEXT,
      measurements TEXT,
      paint_elements TEXT,
      wall_condition TEXT NOT NULL,
      has_accent_wall INTEGER DEFAULT 0,
      extra_notes TEXT,
      materials_calculation TEXT,
      labor_calculation TEXT,
      total_cost REAL NOT NULL,
      complete INTEGER DEFAULT 0,
      estimated_timeline_days INTEGER,
      ghl_folder_name TEXT,
      photos_uploaded_at TEXT,
      measurements_completed_at TEXT,
      sent_to_client_at TEXT,
      created_at TEXT,
      updated_at TEXT,
      zones TEXT,
      materials TEXT,
      totals TEXT,
      sync_status TEXT DEFAULT 'pending',
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )
  ''');

  await db.execute('CREATE INDEX idx_estimates_user_id ON estimates(user_id)');
  await db.execute(
    'CREATE INDEX idx_estimates_ghl_estimate_id ON estimates(ghl_estimate_id)',
  );
  await db.execute(
    'CREATE INDEX idx_estimates_ghl_contact_id ON estimates(ghl_contact_id)',
  );
  await db.execute('CREATE INDEX idx_estimates_status ON estimates(status)');
  await db.execute(
    'CREATE INDEX idx_estimates_created_at ON estimates(created_at)',
  );
  await db.execute(
    'CREATE INDEX idx_estimates_sync_status ON estimates(sync_status)',
  );
}

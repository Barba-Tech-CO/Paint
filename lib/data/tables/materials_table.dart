import 'package:sqflite/sqflite.dart';

/// Creates materials table and indexes
Future<void> createMaterialsTable(Database db) async {
  await db.execute('''
    CREATE TABLE materials (
      id INTEGER PRIMARY KEY,
      user_id INTEGER,
      pdf_upload_id INTEGER,
      zone_id INTEGER,
      type TEXT NOT NULL DEFAULT 'liquid',
      name TEXT NOT NULL,
      brand TEXT NOT NULL,
      description TEXT,
      color TEXT,
      quantity REAL NOT NULL,
      unit TEXT NOT NULL,
      unit_price REAL NOT NULL,
      total_cost REAL NOT NULL,
      finish TEXT,
      quality_grade TEXT,
      category TEXT,
      specifications TEXT,
      line_number INTEGER,
      created_at TEXT,
      updated_at TEXT,
      sync_status TEXT DEFAULT 'pending',
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
      FOREIGN KEY (pdf_upload_id) REFERENCES pdf_uploads(id) ON DELETE CASCADE
    )
  ''');

  await db.execute('CREATE INDEX idx_materials_user_id ON materials(user_id)');
  await db.execute(
    'CREATE INDEX idx_materials_pdf_upload_id ON materials(pdf_upload_id)',
  );
  await db.execute('CREATE INDEX idx_materials_brand ON materials(brand)');
  await db.execute('CREATE INDEX idx_materials_type ON materials(type)');
  await db.execute(
    'CREATE INDEX idx_materials_category ON materials(category)',
  );
  await db.execute(
    'CREATE INDEX idx_materials_sync_status ON materials(sync_status)',
  );
}

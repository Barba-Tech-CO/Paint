import 'package:sqflite/sqflite.dart';

/// Creates pdf_uploads table and indexes
/// This table structure matches exactly the API's pdf_uploads table
Future<void> createPdfUploadsTable(Database db) async {
  await db.execute('''
    CREATE TABLE pdf_uploads (
      id INTEGER PRIMARY KEY,
      user_id INTEGER NOT NULL,
      original_name TEXT NOT NULL,
      display_name TEXT,
      file_path TEXT NOT NULL,
      r2_url TEXT,
      file_hash TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'pending',
      materials_extracted INTEGER DEFAULT 0,
      extraction_metadata TEXT,
      error_message TEXT,
      created_at TEXT,
      updated_at TEXT,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )
  ''');

  await db.execute(
    'CREATE INDEX idx_pdf_uploads_user_id ON pdf_uploads(user_id)',
  );
  await db.execute(
    'CREATE INDEX idx_pdf_uploads_status ON pdf_uploads(status)',
  );
  await db.execute(
    'CREATE INDEX idx_pdf_uploads_user_status ON pdf_uploads(user_id, status)',
  );
  await db.execute(
    'CREATE INDEX idx_pdf_uploads_created_at ON pdf_uploads(created_at)',
  );
  await db.execute(
    'CREATE UNIQUE INDEX idx_pdf_uploads_user_file_hash ON pdf_uploads(user_id, file_hash)',
  );
}

import 'package:sqflite/sqflite.dart';

/// Creates users table and indexes
Future<void> createUsersTable(Database db) async {
  await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      email_verified_at TEXT,
      remember_token TEXT,
      ghl_business_id TEXT,
      ghl_phone TEXT,
      ghl_website TEXT,
      ghl_address TEXT,
      ghl_city TEXT,
      ghl_state TEXT,
      ghl_postal_code TEXT,
      ghl_country TEXT,
      ghl_description TEXT,
      created_at TEXT,
      updated_at TEXT
    )
  ''');

  await db.execute('CREATE INDEX idx_users_email ON users(email)');
}

import 'package:sqflite/sqflite.dart';

/// Creates contacts table and indexes
Future<void> createContactsTable(Database db) async {
  await db.execute('''
    CREATE TABLE contacts (
      id INTEGER PRIMARY KEY,
      user_id INTEGER,
      ghl_id TEXT,
      location_id TEXT,
      first_name TEXT,
      last_name TEXT,
      email TEXT,
      phone TEXT,
      phone_label TEXT,
      company_name TEXT,
      business_name TEXT,
      address TEXT,
      city TEXT,
      state TEXT,
      postal_code TEXT,
      country TEXT,
      additional_emails TEXT,
      additional_phones TEXT,
      custom_fields TEXT,
      tags TEXT,
      type TEXT,
      source TEXT,
      dnd INTEGER DEFAULT 0,
      dnd_settings TEXT,
      sync_status TEXT DEFAULT 'synced',
      last_synced_at TEXT,
      sync_error TEXT,
      ghl_created_at TEXT,
      ghl_updated_at TEXT,
      created_at TEXT,
      updated_at TEXT,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )
  ''');

  await db.execute('CREATE INDEX idx_contacts_user_id ON contacts(user_id)');
  await db.execute('CREATE INDEX idx_contacts_ghl_id ON contacts(ghl_id)');
  await db.execute('CREATE INDEX idx_contacts_email ON contacts(email)');
  await db.execute('CREATE INDEX idx_contacts_phone ON contacts(phone)');
  await db.execute(
    'CREATE INDEX idx_contacts_sync_status ON contacts(sync_status)',
  );
  await db.execute(
    'CREATE INDEX idx_contacts_location_id ON contacts(location_id)',
  );
}

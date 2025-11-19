import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/contacts/contact_model.dart';

class ContactDatabaseService {
  static Database? _database;
  static const String _tableName = 'contacts'; // Aligned with API table name

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'contacts_database.db');

    return await openDatabase(
      path,
      version: 6,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY, -- Mirrors API id (from API, not auto-increment)
        user_id INTEGER NOT NULL, -- User isolation (required)

        -- GoHighLevel Identifiers (both nullable to support local-only contacts)
        ghl_id TEXT UNIQUE, -- Unique ID in GoHighLevel (nullable for local contacts)
        location_id TEXT, -- GoHighLevel location ID (nullable - API manages this)
        
        -- Personal Information
        first_name TEXT,
        last_name TEXT,
        email TEXT,
        phone TEXT,
        phone_label TEXT,
        
        -- Company Information
        company_name TEXT,
        business_name TEXT,
        
        -- Full Address
        address TEXT,
        city TEXT,
        state TEXT,
        postal_code TEXT,
        country TEXT,
        
        -- Complex Data (JSON as TEXT in SQLite)
        additional_emails TEXT, -- JSON: ["email1@example.com", "email2@example.com"]
        additional_phones TEXT, -- JSON: ["+1234567890", "+0987654321"]
        custom_fields TEXT, -- JSON: [{"id":"field1", "key":"project_type", "field_value":"exterior"}]
        tags TEXT, -- JSON: ["prospect", "paint-service"]
        
        -- Settings
        type TEXT, -- lead, contact, etc
        source TEXT, -- Contact source
        dnd INTEGER DEFAULT 0, -- Do Not Disturb (0=false, 1=true)
        dnd_settings TEXT, -- JSON: {"Call": {"status": "active"}, "Email": {"status": "inactive"}}
        
        -- Offline-First Sync Control
        sync_status TEXT DEFAULT 'synced', -- synced, pending, error
        last_synced_at TEXT, -- ISO 8601 timestamp
        sync_error TEXT,
        
        -- GoHighLevel Timestamps
        ghl_created_at TEXT, -- ISO 8601 timestamp
        ghl_updated_at TEXT, -- ISO 8601 timestamp
        created_at TEXT, -- ISO 8601 timestamp
        updated_at TEXT -- ISO 8601 timestamp
      )
    ''');

    // Create indexes for better performance - Aligned with API indexes
    await db.execute(
      'CREATE INDEX idx_contacts_user_id ON $_tableName(user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_contacts_ghl_id ON $_tableName(ghl_id)',
    );
    await db.execute(
      'CREATE INDEX idx_contacts_location_id ON $_tableName(location_id)',
    );
    await db.execute(
      'CREATE INDEX idx_contacts_email ON $_tableName(email)',
    );
    await db.execute(
      'CREATE INDEX idx_contacts_phone ON $_tableName(phone)',
    );
    await db.execute(
      'CREATE INDEX idx_contacts_sync_status ON $_tableName(sync_status)',
    );
    await db.execute(
      'CREATE INDEX idx_contacts_user_sync ON $_tableName(user_id, sync_status, updated_at)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 6) {
      // Recreate table with aligned structure (ghl_contacts -> contacts with location_id)
      await db.execute('DROP TABLE IF EXISTS ghl_contacts');
      await db.execute('DROP TABLE IF EXISTS $_tableName');
      await _onCreate(db, newVersion);
    }
  }

  /// Clears all data from the database (useful for testing or major schema changes)
  Future<void> clearDatabase() async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS $_tableName');
    await db.execute('DELETE FROM sqlite_sequence WHERE name = "$_tableName"');
    _database = null; // Force recreation on next access
  }

  /// Inserts a new contact into the local database (mirrors API data)
  Future<int> insertContact(ContactModel contact) async {
    final db = await database;

    final data = contact.toMap();

    // Use INSERT OR REPLACE to handle duplicates gracefully
    return await db.insert(
      _tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates an existing contact in the local database
  Future<int> updateContact(ContactModel contact) async {
    final db = await database;

    if (contact.id == null) {
      throw Exception('Cannot update contact without id (API primary key)');
    }

    final data = contact.toMap();
    data.remove('id');

    return await db.update(
      _tableName,
      data,
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  /// Deletes a contact from the local database
  Future<int> deleteContact(String ghlId) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: 'ghl_id = ?',
      whereArgs: [ghlId],
    );
  }

  /// Gets a single contact by GHL ID
  Future<ContactModel?> getContact(String ghlId) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'ghl_id = ?',
      whereArgs: [ghlId],
    );

    if (maps.isEmpty) return null;
    return ContactModel.fromMap(maps.first);
  }

  /// Gets all contacts from the local database for a specific user
  Future<List<ContactModel>> getAllContacts({
    int? userId,
    int? limit,
    int? offset,
  }) async {
    final db = await database;

    final maps = await db.query(
      _tableName,
      where: userId != null ? 'user_id = ?' : null,
      whereArgs: userId != null ? [userId] : null,
      limit: limit,
      offset: offset,
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => ContactModel.fromMap(map)).toList();
  }

  /// Gets contacts by sync status for a specific user
  Future<List<ContactModel>> getContactsBySyncStatus(
    SyncStatus status, {
    int? userId,
  }) async {
    final db = await database;

    final where = userId != null
        ? 'sync_status = ? AND user_id = ?'
        : 'sync_status = ?';
    final whereArgs = userId != null ? [status.name, userId] : [status.name];

    final maps = await db.query(
      _tableName,
      where: where,
      whereArgs: whereArgs,
    );

    return maps.map((map) => ContactModel.fromMap(map)).toList();
  }

  /// Gets pending contacts for synchronization
  Future<List<ContactModel>> getPendingContacts({int? userId}) async {
    return await getContactsBySyncStatus(SyncStatus.pending, userId: userId);
  }

  /// Gets contacts with sync errors
  Future<List<ContactModel>> getErrorContacts({int? userId}) async {
    return await getContactsBySyncStatus(SyncStatus.error, userId: userId);
  }

  /// Updates sync status for a contact
  Future<int> updateSyncStatus(
    String ghlId,
    SyncStatus status, {
    String? error,
  }) async {
    final db = await database;
    final data = <String, dynamic>{
      'sync_status': status.name,
      'last_synced_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (error != null) {
      data['sync_error'] = error;
    }

    return await db.update(
      _tableName,
      data,
      where: 'ghl_id = ?',
      whereArgs: [ghlId],
    );
  }

  /// Searches contacts by name, email, or phone for a specific user
  Future<List<ContactModel>> searchContacts(
    String query, {
    int? userId,
  }) async {
    final db = await database;
    final searchQuery = '%$query%';

    final where = userId != null
        ? '''
        (first_name LIKE ? OR 
        last_name LIKE ? OR 
        email LIKE ? OR 
        phone LIKE ? OR
        company_name LIKE ?) AND user_id = ?
      '''
        : '''
        first_name LIKE ? OR 
        last_name LIKE ? OR 
        email LIKE ? OR 
        phone LIKE ? OR
        company_name LIKE ?
      ''';

    final whereArgs = userId != null
        ? [
            searchQuery,
            searchQuery,
            searchQuery,
            searchQuery,
            searchQuery,
            userId,
          ]
        : [
            searchQuery,
            searchQuery,
            searchQuery,
            searchQuery,
            searchQuery,
          ];

    final maps = await db.query(
      _tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => ContactModel.fromMap(map)).toList();
  }

  /// Gets the total count of contacts for a specific user
  Future<int> getContactsCount({int? userId}) async {
    final db = await database;
    final query = userId != null
        ? 'SELECT COUNT(*) as count FROM $_tableName WHERE user_id = ?'
        : 'SELECT COUNT(*) as count FROM $_tableName';
    final result = await db.rawQuery(
      query,
      userId != null ? [userId] : null,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Closes the database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}

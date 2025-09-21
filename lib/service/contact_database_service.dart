import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/contacts/contact_model.dart';

class ContactDatabaseService {
  static Database? _database;
  static const String _tableName = 'ghl_contacts';

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
      version:
          3, // Updated version to force migration for API contract compliance
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER, -- Isolamento por usuário
        
        -- Identificadores GoHighLevel
        ghl_id TEXT UNIQUE NOT NULL, -- ID único no GoHighLevel
        location_id TEXT NOT NULL, -- ID da localização no GHL
        
        -- Informações Pessoais
        first_name TEXT,
        last_name TEXT,
        email TEXT,
        phone TEXT,
        phone_label TEXT,
        
        -- Informações Empresa
        company_name TEXT,
        business_name TEXT,
        
        -- Endereço Completo
        address TEXT,
        city TEXT,
        state TEXT,
        postal_code TEXT,
        country TEXT,
        
        -- Dados Complexos (JSON como TEXT no SQLite)
        additional_emails TEXT, -- JSON: ["email1@example.com", "email2@example.com"]
        additional_phones TEXT, -- JSON: ["+1234567890", "+0987654321"]
        custom_fields TEXT, -- JSON: [{"id":"field1", "key":"project_type", "field_value":"exterior"}]
        tags TEXT, -- JSON: ["prospect", "paint-service"]
        
        -- Configurações
        type TEXT, -- lead, contact, etc
        source TEXT, -- Fonte do contato
        dnd INTEGER DEFAULT 0, -- Do Not Disturb (0=false, 1=true)
        dnd_settings TEXT, -- JSON: {"Call": {"status": "active"}, "Email": {"status": "inactive"}}
        
        -- Controle de Sincronização Offline-First
        sync_status TEXT DEFAULT 'synced', -- synced, pending, error
        last_synced_at TEXT, -- ISO 8601 timestamp
        sync_error TEXT,
        
        -- Timestamps GoHighLevel
        ghl_created_at TEXT, -- ISO 8601 timestamp
        ghl_updated_at TEXT, -- ISO 8601 timestamp
        created_at TEXT, -- ISO 8601 timestamp
        updated_at TEXT -- ISO 8601 timestamp
      )
    ''');

    // Create indexes for better performance - Following API contract requirements
    await db.execute(
      'CREATE INDEX idx_ghl_contacts_user_id ON $_tableName(user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_ghl_contacts_ghl_id ON $_tableName(ghl_id)',
    );
    await db.execute(
      'CREATE INDEX idx_ghl_contacts_location_id ON $_tableName(location_id)',
    );
    await db.execute(
      'CREATE INDEX idx_ghl_contacts_email ON $_tableName(email)',
    );
    await db.execute(
      'CREATE INDEX idx_ghl_contacts_phone ON $_tableName(phone)',
    );
    await db.execute(
      'CREATE INDEX idx_ghl_contacts_sync_status ON $_tableName(sync_status)',
    );
    await db.execute(
      'CREATE INDEX idx_ghl_contacts_location_sync ON $_tableName(location_id, sync_status)',
    );
    await db.execute(
      'CREATE INDEX idx_ghl_contacts_user_sync ON $_tableName(user_id, sync_status, updated_at)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // For API contract compliance, recreate the table with updated schema
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

  /// Inserts a new contact into the local database
  Future<int> insertContact(ContactModel contact) async {
    final db = await database;

    // Ensure ghlId is not null
    if (contact.ghlId == null || contact.ghlId!.isEmpty) {
      throw Exception('ghlId cannot be null or empty');
    }

    final data = contact.toMap();
    data.remove('id');

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

    // Ensure ghlId is not null
    if (contact.ghlId == null || contact.ghlId!.isEmpty) {
      throw Exception('ghlId cannot be null or empty');
    }

    final data = contact.toMap();
    data.remove('id'); // Remove localId as it's auto-generated

    return await db.update(
      _tableName,
      data,
      where: 'ghl_id = ?',
      whereArgs: [contact.ghlId],
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

  /// Gets all contacts from the local database
  Future<List<ContactModel>> getAllContacts({
    int? limit,
    int? offset,
  }) async {
    final db = await database;

    final maps = await db.query(
      _tableName,
      limit: limit,
      offset: offset,
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => ContactModel.fromMap(map)).toList();
  }

  /// Gets contacts by sync status
  Future<List<ContactModel>> getContactsBySyncStatus(SyncStatus status) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'sync_status = ?',
      whereArgs: [status.name],
    );

    return maps.map((map) => ContactModel.fromMap(map)).toList();
  }

  /// Gets pending contacts for synchronization
  Future<List<ContactModel>> getPendingContacts() async {
    return await getContactsBySyncStatus(SyncStatus.pending);
  }

  /// Gets contacts with sync errors
  Future<List<ContactModel>> getErrorContacts() async {
    return await getContactsBySyncStatus(SyncStatus.error);
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

  /// Searches contacts by name, email, or phone
  Future<List<ContactModel>> searchContacts(String query) async {
    final db = await database;
    final searchQuery = '%$query%';

    final maps = await db.query(
      _tableName,
      where: '''
        first_name LIKE ? OR 
        last_name LIKE ? OR 
        email LIKE ? OR 
        phone LIKE ? OR
        company_name LIKE ?
      ''',
      whereArgs: [
        searchQuery,
        searchQuery,
        searchQuery,
        searchQuery,
        searchQuery,
      ],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => ContactModel.fromMap(map)).toList();
  }

  /// Gets the total count of contacts
  Future<int> getContactsCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName',
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

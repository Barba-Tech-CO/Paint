import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/models.dart';

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
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ghl_id TEXT UNIQUE NOT NULL,
        location_id TEXT NOT NULL,
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
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_ghl_id ON $_tableName (ghl_id)');
    await db.execute(
      'CREATE INDEX idx_location_id ON $_tableName (location_id)',
    );
    await db.execute('CREATE INDEX idx_email ON $_tableName (email)');
    await db.execute('CREATE INDEX idx_phone ON $_tableName (phone)');
    await db.execute(
      'CREATE INDEX idx_sync_status ON $_tableName (sync_status)',
    );
  }

  /// Inserts a new contact into the local database
  Future<int> insertContact(ContactModel contact) async {
    final db = await database;

    // Ensure ghlId is not null
    if (contact.ghlId == null || contact.ghlId!.isEmpty) {
      throw Exception('ghlId cannot be null or empty');
    }

    final data = contact.toMap();
    data.remove('id'); // Remove localId as it's auto-generated

    return await db.insert(_tableName, data);
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

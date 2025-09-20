import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/material_models/material_model.dart';

class MaterialDatabaseService {
  static Database? _database;
  static const String _tableName = 'materials';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'materials_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        code TEXT NOT NULL,
        price REAL NOT NULL,
        price_unit TEXT NOT NULL,
        type TEXT NOT NULL,
        quality TEXT NOT NULL,
        description TEXT,
        image_url TEXT,
        is_available INTEGER DEFAULT 1,
        
        -- Controle de Sincronização Offline-First
        sync_status TEXT DEFAULT 'synced',
        last_synced_at TEXT,
        sync_error TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Create indexes for better performance
    await db.execute('''
      CREATE INDEX idx_materials_type ON $_tableName(type)
    ''');

    await db.execute('''
      CREATE INDEX idx_materials_quality ON $_tableName(quality)
    ''');

    await db.execute('''
      CREATE INDEX idx_materials_sync_status ON $_tableName(sync_status)
    ''');

    await db.execute('''
      CREATE INDEX idx_materials_name ON $_tableName(name)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here if needed
    if (oldVersion < 1) {
      // Migration logic for version 1
    }
  }

  /// Inserts or updates a material in the local database
  Future<int> upsertMaterial(MaterialModel material) async {
    final db = await database;

    final data = {
      'id': material.id,
      'name': material.name,
      'code': material.code,
      'price': material.price,
      'price_unit': material.priceUnit,
      'type': material.type.name,
      'quality': material.quality.name,
      'description': material.description,
      'image_url': material.imageUrl,
      'is_available': material.isAvailable ? 1 : 0,
      'sync_status': 'synced',
      'last_synced_at': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    return await db.insert(
      _tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Inserts or updates multiple materials in batch
  Future<void> upsertMaterials(List<MaterialModel> materials) async {
    final db = await database;

    await db.transaction((txn) async {
      for (final material in materials) {
        final data = {
          'id': material.id,
          'name': material.name,
          'code': material.code,
          'price': material.price,
          'price_unit': material.priceUnit,
          'type': material.type.name,
          'quality': material.quality.name,
          'description': material.description,
          'image_url': material.imageUrl,
          'is_available': material.isAvailable ? 1 : 0,
          'sync_status': 'synced',
          'last_synced_at': DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        await txn.insert(
          _tableName,
          data,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// Gets all materials from the local database
  Future<List<MaterialModel>> getAllMaterials({
    int? limit,
    int? offset,
  }) async {
    final db = await database;

    String query = 'SELECT * FROM $_tableName ORDER BY name ASC';
    List<dynamic> whereArgs = [];

    if (limit != null) {
      query += ' LIMIT ?';
      whereArgs.add(limit);
    }

    if (offset != null) {
      query += ' OFFSET ?';
      whereArgs.add(offset);
    }

    final maps = await db.rawQuery(query, whereArgs);
    final materials = maps.map((map) => _mapToMaterialModel(map)).toList();
    return materials;
  }

  /// Gets materials with filters from the local database
  Future<List<MaterialModel>> getMaterialsWithFilter({
    String? searchTerm,
    String? type,
    String? quality,
    double? minPrice,
    double? maxPrice,
    int? limit,
    int? offset,
  }) async {
    final db = await database;

    String query = 'SELECT * FROM $_tableName WHERE 1=1';
    List<dynamic> whereArgs = [];

    if (searchTerm != null && searchTerm.isNotEmpty) {
      query += ' AND (name LIKE ? OR code LIKE ?)';
      whereArgs.add('%$searchTerm%');
      whereArgs.add('%$searchTerm%');
    }

    if (type != null) {
      query += ' AND type = ?';
      whereArgs.add(type);
    }

    if (quality != null) {
      query += ' AND quality = ?';
      whereArgs.add(quality);
    }

    if (minPrice != null) {
      query += ' AND price >= ?';
      whereArgs.add(minPrice);
    }

    if (maxPrice != null) {
      query += ' AND price <= ?';
      whereArgs.add(maxPrice);
    }

    query += ' ORDER BY name ASC';

    if (limit != null) {
      query += ' LIMIT ?';
      whereArgs.add(limit);
    }

    if (offset != null) {
      query += ' OFFSET ?';
      whereArgs.add(offset);
    }

    final maps = await db.rawQuery(query, whereArgs);
    return maps.map((map) => _mapToMaterialModel(map)).toList();
  }

  /// Gets a single material by ID
  Future<MaterialModel?> getMaterialById(String id) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _mapToMaterialModel(maps.first);
  }

  /// Gets the total count of materials
  Future<int> getMaterialsCount({
    String? searchTerm,
    String? type,
    String? quality,
    double? minPrice,
    double? maxPrice,
  }) async {
    final db = await database;

    String query = 'SELECT COUNT(*) as count FROM $_tableName WHERE 1=1';
    List<dynamic> whereArgs = [];

    if (searchTerm != null && searchTerm.isNotEmpty) {
      query += ' AND (name LIKE ? OR code LIKE ?)';
      whereArgs.add('%$searchTerm%');
      whereArgs.add('%$searchTerm%');
    }

    if (type != null) {
      query += ' AND type = ?';
      whereArgs.add(type);
    }

    if (quality != null) {
      query += ' AND quality = ?';
      whereArgs.add(quality);
    }

    if (minPrice != null) {
      query += ' AND price >= ?';
      whereArgs.add(minPrice);
    }

    if (maxPrice != null) {
      query += ' AND price <= ?';
      whereArgs.add(maxPrice);
    }

    final result = await db.rawQuery(query, whereArgs);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Deletes a material from the local database
  Future<int> deleteMaterial(String id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clears all materials from the local database
  Future<void> clearAllMaterials() async {
    final db = await database;
    await db.delete(_tableName);
  }

  /// Updates sync status for a material
  Future<void> updateSyncStatus(
    String id,
    String status, {
    String? error,
  }) async {
    final db = await database;
    await db.update(
      _tableName,
      {
        'sync_status': status,
        'last_synced_at': DateTime.now().toIso8601String(),
        'sync_error': error,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Verifica se há materiais no cache local
  Future<bool> hasMaterials() async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName',
      );
      final count = result.first['count'] as int;
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  /// Converts database map to MaterialModel
  MaterialModel _mapToMaterialModel(Map<String, dynamic> map) {
    return MaterialModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      priceUnit: map['price_unit'] ?? 'Gal',
      type: MaterialType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MaterialType.interior,
      ),
      quality: MaterialQuality.values.firstWhere(
        (e) => e.name == map['quality'],
        orElse: () => MaterialQuality.economic,
      ),
      description: map['description'],
      imageUrl: map['image_url'],
      isAvailable: (map['is_available'] ?? 1) == 1,
    );
  }
}

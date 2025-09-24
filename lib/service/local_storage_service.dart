import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/estimates/estimate_element_model.dart';
import '../model/estimates/estimate_model.dart';
import '../model/estimates/estimate_status.dart';
import '../model/estimates/estimate_totals_model.dart';
import '../model/estimates/floor_dimensions_model.dart';
import '../model/estimates/material_item_model.dart';
import '../model/estimates/project_type.dart';
import '../model/estimates/surface_areas_model.dart';
import '../model/estimates/zone_data_model.dart';
import '../model/estimates/zone_model.dart';
import '../model/projects/project_model.dart';
import '../model/quotes_data/quote_model.dart';
import '../model/quotes_data/quote_status.dart';
import '../utils/logger/app_logger.dart';

class LocalStorageService {
  static Database? _database;
  final AppLogger _logger;

  LocalStorageService(this._logger);

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'paint_pro_local.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create estimates table
    await db.execute('''
      CREATE TABLE estimates (
        id TEXT PRIMARY KEY,
        project_name TEXT,
        client_name TEXT,
        contact_id TEXT,
        additional_notes TEXT,
        project_type TEXT,
        status TEXT NOT NULL,
        total_area REAL,
        paintable_area REAL,
        total_cost REAL,
        photos TEXT,
        photos_data TEXT,
        elements TEXT,
        zones TEXT,
        materials TEXT,
        totals TEXT,
        created_at TEXT,
        updated_at TEXT,
        completed_at TEXT,
        is_synced INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'pending'
      )
    ''');

    // Create pending operations table for sync queue
    await db.execute('''
      CREATE TABLE pending_operations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation_type TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        last_retry_at TEXT
      )
    ''');

    // Create dashboard cache table
    await db.execute('''
      CREATE TABLE dashboard_cache (
        cache_key TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        cached_at TEXT NOT NULL,
        expires_at TEXT NOT NULL
      )
    ''');

    // Create quotes table for offline caching
    await db.execute('''
      CREATE TABLE quotes (
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

    // Create indexes for better performance
    await db.execute(
      'CREATE INDEX idx_estimates_sync_status ON estimates(sync_status)',
    );
    await db.execute(
      'CREATE INDEX idx_estimates_created_at ON estimates(created_at)',
    );
    await db.execute(
      'CREATE INDEX idx_pending_operations_type ON pending_operations(operation_type)',
    );
    await db.execute(
      'CREATE INDEX idx_quotes_sync_status ON quotes(sync_status)',
    );
    await db.execute(
      'CREATE INDEX idx_quotes_created_at ON quotes(created_at)',
    );
    await db.execute(
      'CREATE INDEX idx_quotes_user_id ON quotes(user_id)',
    );
  }

  // Estimate operations
  Future<String> saveEstimate(EstimateModel estimate) async {
    final db = await database;
    final id = estimate.id ?? DateTime.now().millisecondsSinceEpoch.toString();

    final estimateData = estimate.copyWith(
      id: id,
      updatedAt: DateTime.now(),
    );

    await db.insert(
      'estimates',
      _estimateToMap(estimateData),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return id;
  }

  Future<EstimateModel?> getEstimate(String id) async {
    final db = await database;
    final maps = await db.query(
      'estimates',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _mapToEstimate(maps.first);
    }
    return null;
  }

  Future<List<EstimateModel>> getAllEstimates() async {
    final db = await database;
    final maps = await db.query(
      'estimates',
      orderBy: 'created_at DESC',
    );

    final estimates = maps.map(_mapToEstimate).toList();
    return estimates;
  }

  Future<List<EstimateModel>> getUnsyncedEstimates() async {
    final db = await database;
    final maps = await db.query(
      'estimates',
      where: 'is_synced = ?',
      whereArgs: [0],
      orderBy: 'created_at ASC',
    );

    return maps.map(_mapToEstimate).toList();
  }

  Future<void> updateEstimate(EstimateModel estimate) async {
    final db = await database;
    await db.update(
      'estimates',
      _estimateToMap(estimate.copyWith(updatedAt: DateTime.now())),
      where: 'id = ?',
      whereArgs: [estimate.id],
    );
  }

  Future<void> markEstimateAsSynced(String id) async {
    final db = await database;
    await db.update(
      'estimates',
      {
        'is_synced': 1,
        'sync_status': 'synced',
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteEstimate(String id) async {
    final db = await database;
    await db.delete(
      'estimates',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Pending operations queue
  Future<void> addPendingOperation(
    String operationType,
    Map<String, dynamic> data,
  ) async {
    final db = await database;
    await db.insert(
      'pending_operations',
      {
        'operation_type': operationType,
        'data': jsonEncode(data),
        'created_at': DateTime.now().toIso8601String(),
        'retry_count': 0,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getPendingOperations() async {
    final db = await database;
    return await db.query(
      'pending_operations',
      orderBy: 'created_at ASC',
    );
  }

  Future<void> removePendingOperation(int id) async {
    final db = await database;
    await db.delete(
      'pending_operations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> incrementRetryCount(int id) async {
    final db = await database;

    // Get current retry count
    final result = await db.rawQuery(
      'SELECT retry_count FROM pending_operations WHERE id = ?',
      [id],
    );

    if (result.isNotEmpty) {
      final currentCount = result.first['retry_count'] as int;
      await db.update(
        'pending_operations',
        {
          'retry_count': currentCount + 1,
          'last_retry_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // Helper methods
  Map<String, dynamic> _estimateToMap(EstimateModel estimate) {
    try {
      // Safely encode photos
      String? photosJson;
      try {
        photosJson = estimate.photos != null
            ? jsonEncode(estimate.photos)
            : null;
      } catch (e) {
        _logger.error(
          'Error encoding photos: $e, type: ${estimate.photos.runtimeType}',
        );
        photosJson = null;
      }

      // Safely encode photosData
      String? photosDataJson;
      try {
        photosDataJson = estimate.photosData != null
            ? jsonEncode(estimate.photosData)
            : null;
      } catch (e) {
        _logger.error(
          'Error encoding photosData: $e, type: ${estimate.photosData.runtimeType}',
        );
        photosDataJson = null;
      }

      // Safely encode elements
      String? elementsJson;
      try {
        elementsJson = estimate.elements != null
            ? jsonEncode(estimate.elements!.map((e) => e.toJson()).toList())
            : null;
      } catch (e) {
        _logger.error(
          'Error encoding elements: $e, type: ${estimate.elements.runtimeType}',
        );
        elementsJson = null;
      }

      // Safely encode zones
      String? zonesJson;
      try {
        zonesJson = estimate.zones != null
            ? jsonEncode(estimate.zones!.map((z) => _zoneToMap(z)).toList())
            : null;
      } catch (e) {
        _logger.error(
          'Error encoding zones: $e, type: ${estimate.zones.runtimeType}',
        );
        _logger.error('Zone data: ${estimate.zones}');
        zonesJson = '[]'; // Empty array instead of null to avoid further issues
      }

      // Safely encode materials
      String? materialsJson;
      try {
        materialsJson = estimate.materials != null
            ? jsonEncode(
                estimate.materials!.map((m) => _materialToMap(m)).toList(),
              )
            : null;
      } catch (e) {
        _logger.error(
          'Error encoding materials: $e, type: ${estimate.materials.runtimeType}',
        );
        materialsJson = null;
      }

      // Safely encode totals
      String? totalsJson;
      try {
        totalsJson = estimate.totals != null
            ? jsonEncode(_totalsToMap(estimate.totals!))
            : null;
      } catch (e) {
        _logger.error(
          'Error encoding totals: $e, type: ${estimate.totals.runtimeType}',
        );
        totalsJson = null;
      }

      return {
        'id': estimate.id,
        'project_name': estimate.projectName,
        'client_name': estimate.clientName,
        'contact_id': estimate.contactId,
        'additional_notes': estimate.additionalNotes,
        'project_type': estimate.projectType?.name,
        'status': estimate.status.name,
        'total_area': estimate.totalArea,
        'paintable_area': estimate.paintableArea,
        'total_cost': estimate.totalCost,
        'photos': photosJson,
        'photos_data': photosDataJson,
        'elements': elementsJson,
        'zones': zonesJson,
        'materials': materialsJson,
        'totals': totalsJson,
        'created_at': estimate.createdAt?.toIso8601String(),
        'updated_at': estimate.updatedAt?.toIso8601String(),
        'completed_at': estimate.completedAt?.toIso8601String(),
      };
    } catch (e) {
      _logger.error('Error in _estimateToMap: $e');
      _logger.error('Estimate ID: ${estimate.id}');
      _logger.error('Estimate project name: ${estimate.projectName}');
      rethrow;
    }
  }

  EstimateModel _mapToEstimate(Map<String, dynamic> map) {
    try {
      return EstimateModel(
        id: map['id'],
        projectName: map['project_name'],
        clientName: map['client_name'],
        contactId: map['contact_id'],
        additionalNotes: map['additional_notes'],
        projectType: map['project_type'] != null
            ? ProjectType.values.firstWhere(
                (e) => e.name == map['project_type'],
                orElse: () => ProjectType.both,
              )
            : null,
        status: EstimateStatus.values.firstWhere(
          (e) => e.name == map['status'],
          orElse: () => EstimateStatus.draft,
        ),
        totalArea: map['total_area'],
        paintableArea: map['paintable_area'],
        totalCost: map['total_cost'],
        photos: map['photos'] != null
            ? (map['photos'] is String
                  ? List<String>.from(jsonDecode(map['photos']))
                  : List<String>.from(map['photos']))
            : null,
        photosData: map['photos_data'] != null
            ? (map['photos_data'] is String
                  ? List<String>.from(jsonDecode(map['photos_data']))
                  : List<String>.from(map['photos_data']))
            : null,
        elements: map['elements'] != null
            ? (map['elements'] is String
                  ? (jsonDecode(map['elements']) as List)
                        .map(
                          (e) => EstimateElement.fromJson(
                            e as Map<String, dynamic>,
                          ),
                        )
                        .toList()
                  : (map['elements'] as List)
                        .map(
                          (e) => EstimateElement.fromJson(
                            e as Map<String, dynamic>,
                          ),
                        )
                        .toList())
            : null,
        zones: map['zones'] != null
            ? (map['zones'] is String
                  ? (jsonDecode(map['zones']) as List)
                        .map((z) => _mapToZone(z as Map<String, dynamic>))
                        .toList()
                  : (map['zones'] as List)
                        .map((z) => _mapToZone(z as Map<String, dynamic>))
                        .toList())
            : null,
        materials: map['materials'] != null
            ? (map['materials'] is String
                  ? (jsonDecode(map['materials']) as List)
                        .map((m) => _mapToMaterial(m as Map<String, dynamic>))
                        .toList()
                  : (map['materials'] as List)
                        .map((m) => _mapToMaterial(m as Map<String, dynamic>))
                        .toList())
            : null,
        totals: map['totals'] != null
            ? (map['totals'] is String
                  ? _mapToTotals(
                      jsonDecode(map['totals']) as Map<String, dynamic>,
                    )
                  : _mapToTotals(map['totals'] as Map<String, dynamic>))
            : null,
        createdAt: _parseDateTime(map['created_at']),
        updatedAt: _parseDateTime(map['updated_at']),
        completedAt: _parseDateTime(map['completed_at']),
      );
    } catch (e) {
      _logger.error('Error in _mapToEstimate: $e');
      _logger.error('Map data: $map');
      rethrow;
    }
  }

  // Project operations (mapped from estimates)
  Future<String> saveProject(ProjectModel project) async {
    // Convert project to estimate format for storage
    final estimate = EstimateModel(
      id: project.id.toString(),
      projectName: project.projectName,
      clientName: project.personName,
      status: EstimateStatus.draft,
      createdAt: DateTime.now(),
    );

    return await saveEstimate(estimate);
  }

  Future<List<ProjectModel>> getAllProjects() async {
    final estimates = await getAllEstimates();
    final projects = estimates.map(_mapEstimateToProject).toList();
    return projects;
  }

  ProjectModel _mapEstimateToProject(EstimateModel estimate) {
    final created = estimate.createdAt != null
        ? '${estimate.createdAt!.day.toString().padLeft(2, '0')}/${estimate.createdAt!.month.toString().padLeft(2, '0')}/${estimate.createdAt!.year % 100}'
        : '';

    return ProjectModel(
      id: int.tryParse(estimate.id ?? '') ?? estimate.hashCode,
      projectName: estimate.projectName ?? 'Estimate',
      personName: estimate.clientName ?? '',
      zonesCount: estimate.zones?.length ?? 0,
      createdDate: created,
      image: estimate.photos?.isNotEmpty == true
          ? estimate.photos!.first
          : (estimate.photosData?.isNotEmpty == true
                ? estimate.photosData!.first
                : ''),
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Helper method to safely parse DateTime from various data types
  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    try {
      if (value is DateTime) {
        return value;
      } else if (value is String) {
        return DateTime.parse(value);
      } else if (value is Map<String, dynamic>) {
        // Handle case where value might be a Map with date information
        return null; // Skip complex date objects for now
      } else {
        // Try to convert to string first, then parse
        return DateTime.parse(value.toString());
      }
    } catch (e) {
      _logger.warning('Failed to parse DateTime from value: $value, error: $e');
      return null;
    }
  }

  // Helper methods for serialization
  Map<String, dynamic> _zoneToMap(ZoneModel zone) {
    try {
      return {
        'id': zone.id,
        'name': zone.name,
        'zone_type': zone.zoneType,
        'data': zone.data.map((d) => _zoneDataToMap(d)).toList(),
      };
    } catch (e) {
      _logger.error('Error in _zoneToMap: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _zoneDataToMap(ZoneDataModel data) {
    try {
      return {
        'floor_dimensions': {
          'length': data.floorDimensions.length,
          'width': data.floorDimensions.width,
          'unit': data.floorDimensions.unit,
        },
        'surface_areas': data.surfaceAreas.values,
        'photos': data.photoPaths,
      };
    } catch (e) {
      _logger.error('Error in _zoneDataToMap: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _materialToMap(MaterialItemModel material) {
    return {
      'id': material.id,
      'unit': material.unit,
      'quantity': material.quantity,
      'unit_price': material.unitPrice,
    };
  }

  Map<String, dynamic> _totalsToMap(dynamic totals) {
    if (totals is EstimateTotalsModel) {
      return {
        'materials_cost': totals.materialsCost,
        'grand_total': totals.grandTotal,
      };
    } else if (totals is Map<String, dynamic>) {
      // Handle case where totals is already a map (defensive programming)
      return {
        'materials_cost': totals['materials_cost'],
        'grand_total': totals['grand_total'],
      };
    } else {
      throw ArgumentError(
        'Expected EstimateTotalsModel or Map<String, dynamic>, got ${totals.runtimeType}',
      );
    }
  }

  ZoneModel _mapToZone(Map<String, dynamic> map) {
    return ZoneModel(
      id: map['id'],
      name: map['name'],
      zoneType: map['zone_type'],
      data: (map['data'] as List)
          .map((d) => _mapToZoneData(d as Map<String, dynamic>))
          .toList(),
    );
  }

  ZoneDataModel _mapToZoneData(Map<String, dynamic> map) {
    // Handle floor_dimensions - could be Map or JSON string
    Map<String, dynamic> floorDimensions;
    if (map['floor_dimensions'] is String) {
      floorDimensions =
          jsonDecode(map['floor_dimensions']) as Map<String, dynamic>;
    } else {
      floorDimensions = map['floor_dimensions'] as Map<String, dynamic>;
    }

    // Handle surface_areas - could be Map or JSON string
    Map<String, dynamic> surfaceAreas;
    if (map['surface_areas'] is String) {
      surfaceAreas = jsonDecode(map['surface_areas']) as Map<String, dynamic>;
    } else {
      surfaceAreas = map['surface_areas'] as Map<String, dynamic>;
    }

    return ZoneDataModel(
      floorDimensions: FloorDimensionsModel(
        length: floorDimensions['length']?.toDouble() ?? 0.0,
        width: floorDimensions['width']?.toDouble() ?? 0.0,
        unit: floorDimensions['unit'] ?? 'ft',
      ),
      surfaceAreas: SurfaceAreasModel(
        values: surfaceAreas.map(
          (key, value) => MapEntry(key, value?.toDouble() ?? 0.0),
        ),
      ),
      photoPaths: List<String>.from(map['photos'] ?? []),
    );
  }

  MaterialItemModel _mapToMaterial(Map<String, dynamic> map) {
    return MaterialItemModel(
      id: map['id'],
      unit: map['unit'],
      quantity: map['quantity']?.toDouble(),
      unitPrice: map['unit_price']?.toDouble(),
    );
  }

  EstimateTotalsModel _mapToTotals(Map<String, dynamic> map) {
    return EstimateTotalsModel(
      materialsCost: map['materials_cost']?.toDouble(),
      grandTotal: map['grand_total']?.toDouble(),
    );
  }

  // Dashboard cache operations
  Future<void> saveDashboardCache(
    String cacheKey,
    Map<String, dynamic> data,
  ) async {
    final db = await database;
    await db.insert(
      'dashboard_cache',
      {
        'cache_key': cacheKey,
        'data': json.encode(data),
        'cached_at': data['cached_at'],
        'expires_at': data['expires_at'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getDashboardCache(String cacheKey) async {
    final db = await database;
    final maps = await db.query(
      'dashboard_cache',
      where: 'cache_key = ?',
      whereArgs: [cacheKey],
    );

    if (maps.isNotEmpty) {
      final data =
          json.decode(maps.first['data'] as String) as Map<String, dynamic>;
      return data;
    }
    return null;
  }

  Future<void> removeDashboardCache(String cacheKey) async {
    final db = await database;
    await db.delete(
      'dashboard_cache',
      where: 'cache_key = ?',
      whereArgs: [cacheKey],
    );
  }

  Future<void> clearExpiredDashboardCache() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    await db.delete(
      'dashboard_cache',
      where: 'expires_at < ?',
      whereArgs: [now],
    );
  }

  // Quote operations
  Future<int> saveQuote(QuoteModel quote) async {
    final db = await database;
    await db.insert(
      'quotes',
      _quoteToMap(quote),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return quote.id;
  }

  Future<QuoteModel?> getQuote(int id) async {
    final db = await database;
    final maps = await db.query(
      'quotes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _mapToQuote(maps.first);
    }
    return null;
  }

  Future<List<QuoteModel>> getAllQuotes() async {
    final db = await database;
    final maps = await db.query(
      'quotes',
      orderBy: 'created_at DESC',
    );

    return maps.map(_mapToQuote).toList();
  }

  Future<void> updateQuote(QuoteModel quote) async {
    final db = await database;
    await db.update(
      'quotes',
      _quoteToMap(quote),
      where: 'id = ?',
      whereArgs: [quote.id],
    );
  }

  Future<void> deleteQuote(int id) async {
    final db = await database;
    await db.delete(
      'quotes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markQuoteAsSynced(int id) async {
    final db = await database;
    await db.update(
      'quotes',
      {
        'is_synced': 1,
        'sync_status': 'synced',
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Map<String, dynamic> _quoteToMap(QuoteModel quote) {
    return {
      'id': quote.id,
      'user_id': quote.userId,
      'original_name': quote.originalName,
      'display_name': quote.displayName,
      'file_path': quote.filePath,
      'r2_url': quote.r2Url,
      'file_hash': quote.fileHash,
      'status': quote.status.name,
      'materials_extracted': quote.materialsExtracted,
      'extraction_metadata': quote.extractionMetadata != null
          ? json.encode(quote.extractionMetadata)
          : null,
      'error_message': quote.errorMessage,
      'created_at': quote.createdAt.toIso8601String(),
      'updated_at': quote.updatedAt.toIso8601String(),
      'is_synced': 1,
      'sync_status': 'synced',
    };
  }

  QuoteModel _mapToQuote(Map<String, dynamic> map) {
    return QuoteModel(
      id: map['id'],
      userId: map['user_id'],
      originalName: map['original_name'],
      displayName: map['display_name'],
      filePath: map['file_path'],
      r2Url: map['r2_url'],
      fileHash: map['file_hash'],
      status: QuoteStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => QuoteStatus.pending,
      ),
      materialsExtracted: map['materials_extracted'] ?? 0,
      extractionMetadata: map['extraction_metadata'] != null
          ? json.decode(map['extraction_metadata']) as Map<String, dynamic>
          : null,
      errorMessage: map['error_message'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}

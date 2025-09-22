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

    _logger.info('Estimate saved locally with ID: $id');
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

    return maps.map(_mapToEstimate).toList();
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
      'photos': estimate.photos != null ? jsonEncode(estimate.photos) : null,
      'photos_data': estimate.photosData != null
          ? jsonEncode(estimate.photosData)
          : null,
      'elements': estimate.elements != null
          ? jsonEncode(estimate.elements!.map((e) => e.toJson()).toList())
          : null,
      'zones': estimate.zones != null
          ? jsonEncode(estimate.zones!.map((z) => _zoneToMap(z)).toList())
          : null,
      'materials': estimate.materials != null
          ? jsonEncode(
              estimate.materials!.map((m) => _materialToMap(m)).toList(),
            )
          : null,
      'totals': estimate.totals != null
          ? jsonEncode(_totalsToMap(estimate.totals!))
          : null,
      'created_at': estimate.createdAt?.toIso8601String(),
      'updated_at': estimate.updatedAt?.toIso8601String(),
      'completed_at': estimate.completedAt?.toIso8601String(),
    };
  }

  EstimateModel _mapToEstimate(Map<String, dynamic> map) {
    return EstimateModel(
      id: map['id'],
      projectName: map['project_name'],
      clientName: map['client_name'],
      contactId: map['contact_id'],
      additionalNotes: map['additional_notes'],
      projectType: map['project_type'] != null
          ? ProjectType.values.firstWhere(
              (e) => e.name == map['project_type'],
              orElse: () => ProjectType.other,
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
          ? List<String>.from(jsonDecode(map['photos']))
          : null,
      photosData: map['photos_data'] != null
          ? List<String>.from(jsonDecode(map['photos_data']))
          : null,
      elements: map['elements'] != null
          ? (jsonDecode(map['elements']) as List)
                .map((e) => EstimateElement.fromJson(e))
                .toList()
          : null,
      zones: map['zones'] != null
          ? (jsonDecode(map['zones']) as List)
                .map((z) => _mapToZone(z))
                .toList()
          : null,
      materials: map['materials'] != null
          ? (jsonDecode(map['materials']) as List)
                .map((m) => _mapToMaterial(m))
                .toList()
          : null,
      totals: map['totals'] != null
          ? _mapToTotals(jsonDecode(map['totals']))
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'])
          : null,
    );
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
    return estimates.map(_mapEstimateToProject).toList();
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
      image: estimate.photos?.isNotEmpty == true ? estimate.photos!.first : '',
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  // Helper methods for serialization
  Map<String, dynamic> _zoneToMap(ZoneModel zone) {
    return {
      'id': zone.id,
      'name': zone.name,
      'zone_type': zone.zoneType,
      'data': zone.data.map((d) => _zoneDataToMap(d)).toList(),
    };
  }

  Map<String, dynamic> _zoneDataToMap(ZoneDataModel data) {
    return {
      'floor_dimensions': {
        'length': data.floorDimensions.length,
        'width': data.floorDimensions.width,
        'unit': data.floorDimensions.unit,
      },
      'surface_areas': data.surfaceAreas.values,
      'photos': data.photoPaths,
    };
  }

  Map<String, dynamic> _materialToMap(MaterialItemModel material) {
    return {
      'id': material.id,
      'unit': material.unit,
      'quantity': material.quantity,
      'unit_price': material.unitPrice,
    };
  }

  Map<String, dynamic> _totalsToMap(EstimateTotalsModel totals) {
    return {
      'materials_cost': totals.materialsCost,
      'grand_total': totals.grandTotal,
    };
  }

  ZoneModel _mapToZone(Map<String, dynamic> map) {
    return ZoneModel(
      id: map['id'],
      name: map['name'],
      zoneType: map['zone_type'],
      data: (map['data'] as List).map((d) => _mapToZoneData(d)).toList(),
    );
  }

  ZoneDataModel _mapToZoneData(Map<String, dynamic> map) {
    final floorDimensions = map['floor_dimensions'] as Map<String, dynamic>;
    final surfaceAreas = map['surface_areas'] as Map<String, dynamic>;

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
    _logger.info('Dashboard cache saved with key: $cacheKey');
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
    _logger.info('Dashboard cache removed for key: $cacheKey');
  }

  Future<void> clearExpiredDashboardCache() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    await db.delete(
      'dashboard_cache',
      where: 'expires_at < ?',
      whereArgs: [now],
    );
    _logger.info('Expired dashboard cache cleared');
  }
}

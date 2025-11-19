import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../model/estimates/estimate_element_model.dart';
import '../../model/estimates/estimate_model.dart';
import '../../model/estimates/estimate_status.dart';
import '../../model/estimates/estimate_totals_model.dart';
import '../../model/estimates/material_item_model.dart';
import '../../model/estimates/project_type.dart';
import '../../model/estimates/zone_model.dart';
import '../../model/projects/project_model.dart';
import '../../config/app_config.dart';
import '../../utils/logger/app_logger.dart';
import '../database_service.dart';

class EstimatesLocalService {
  final DatabaseService _dbService;
  final AppLogger _logger;

  EstimatesLocalService(this._dbService, this._logger);

  Future<String> saveEstimate(EstimateModel estimate) async {
    final db = await _dbService.database;
    final id = estimate.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final estimateData = estimate.copyWith(id: id, updatedAt: DateTime.now());

    await db.insert(
      'estimates',
      _estimateToMap(estimateData),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<EstimateModel?> getEstimate(String id) async {
    final db = await _dbService.database;
    final maps = await db.query('estimates', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return _mapToEstimate(maps.first);
    return null;
  }

  Future<List<EstimateModel>> getAllEstimates() async {
    final db = await _dbService.database;
    final maps = await db.query('estimates', orderBy: 'created_at DESC');
    return maps.map(_mapToEstimate).toList();
  }

  Future<List<EstimateModel>> getUnsyncedEstimates() async {
    final db = await _dbService.database;
    final maps = await db.query(
      'estimates',
      where: 'is_synced = ?',
      whereArgs: [0],
      orderBy: 'created_at ASC',
    );
    return maps.map(_mapToEstimate).toList();
  }

  Future<void> updateEstimate(EstimateModel estimate) async {
    final db = await _dbService.database;
    await db.update(
      'estimates',
      _estimateToMap(estimate.copyWith(updatedAt: DateTime.now())),
      where: 'id = ?',
      whereArgs: [estimate.id],
    );
  }

  Future<void> markEstimateAsSynced(String id) async {
    final db = await _dbService.database;
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
    final db = await _dbService.database;
    await db.delete('estimates', where: 'id = ?', whereArgs: [id]);
  }

  // Project operations mapped to estimates storage
  Future<String> saveProject(ProjectModel project) async {
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

  // Helpers
  Map<String, dynamic> _estimateToMap(EstimateModel estimate) {
    try {
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

      String? zonesJson;
      try {
        // Use EstimateModel.toJson() to normalize nested structures before encoding.
        zonesJson = estimate.zones != null
            ? jsonEncode((estimate.toJson()['zones']) ?? [])
            : null;
      } catch (e) {
        _logger.error(
          'Error encoding zones: $e, type: ${estimate.zones.runtimeType}',
        );
        _logger.error('Zone data: ${estimate.zones}');
        zonesJson = '[]';
      }

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
        photos: _safeStringListFromDynamic(map['photos']),
        photosData: _safeStringListFromDynamic(map['photos_data']),
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
                        .map(
                          (z) => ZoneModel.fromMap(z as Map<String, dynamic>),
                        )
                        .toList()
                  : (map['zones'] as List)
                        .map(
                          (z) => ZoneModel.fromMap(z as Map<String, dynamic>),
                        )
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

  String _adjustImageUrl(String originalUrl) {
    final baseHost = AppConfig.baseUrl.replaceAll(RegExp(r"/api/?$"), '');
    if (originalUrl.startsWith('http://') || originalUrl.startsWith('https://')) {
      if (!AppConfig.isProduction) {
        return originalUrl.replaceAll(
          'https://paintpro.barbatech.company',
          baseHost,
        );
      }
      return originalUrl;
    }
    final normalized = originalUrl.replaceFirst(RegExp(r'^/+'), '');
    return '$baseHost/$normalized';
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
      image: estimate.photosData?.isNotEmpty == true
          ? _adjustImageUrl(estimate.photosData!.first)
          : (estimate.photos?.isNotEmpty == true
                ? _adjustImageUrl(estimate.photos!.first)
                : ''),
    );
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      if (value is Map<String, dynamic>) return null;
      return DateTime.parse(value.toString());
    } catch (e) {
      _logger.warning('Failed to parse DateTime from value: $value, error: $e');
      return null;
    }
  }

  List<String>? _safeStringListFromDynamic(dynamic value) {
    if (value == null) return null;
    try {
      final List<dynamic> rawList = value is String
          ? (jsonDecode(value) as List)
          : (value is List ? value : const []);
      final List<String> out = [];
      for (final item in rawList) {
        if (item is String) {
          out.add(item);
        } else if (item is Map<String, dynamic>) {
          final url = item['url'] ?? item['path'];
          if (url is String) {
            out.add(url);
          } else {
            out.add(item.toString());
          }
        } else {
          out.add(item.toString());
        }
      }
      return out;
    } catch (e) {
      _logger.warning('Failed to parse list<String>: $e');
      return null;
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

  MaterialItemModel _mapToMaterial(Map<String, dynamic> map) {
    return MaterialItemModel(
      id: map['id'],
      unit: map['unit'],
      quantity: map['quantity']?.toDouble(),
      unitPrice: map['unit_price']?.toDouble(),
    );
  }

  Map<String, dynamic> _totalsToMap(dynamic totals) {
    if (totals is EstimateTotalsModel) {
      return {
        'materials_cost': totals.materialsCost,
        'grand_total': totals.grandTotal,
      };
    } else if (totals is Map<String, dynamic>) {
      return {
        'materials_cost': totals['materials_cost'],
        'grand_total': totals['grand_total'],
      };
    } else {
      throw ArgumentError('Invalid totals type: ${totals.runtimeType}');
    }
  }

  EstimateTotalsModel _mapToTotals(Map<String, dynamic> map) {
    return EstimateTotalsModel(
      materialsCost: map['materials_cost']?.toDouble() ?? 0.0,
      grandTotal: map['grand_total']?.toDouble() ?? 0.0,
    );
  }
}

import 'package:dio/dio.dart';

import 'estimate_status.dart';
import 'project_type.dart';
import 'estimate_element_model.dart';
import 'zone_model.dart';
import 'zone_data_model.dart';
import 'floor_dimensions_model.dart';
import 'surface_areas_model.dart';
import 'material_item_model.dart';
import 'estimate_totals_model.dart';

// Enums moved to separate files (estimate_status.dart, project_type.dart)

class EstimateModel {
  final String? id;
  final String? projectName;
  final String? clientName;
  final String? contactId;
  final String? additionalNotes;
  final ProjectType? projectType;
  final EstimateStatus status;
  final double? totalArea;
  final double? paintableArea;
  final double? totalCost;
  final List<String>? photos;
  final List<EstimateElement>? elements;
  final List<ZoneModel>? zones;
  final List<MaterialItemModel>? materials;
  final EstimateTotalsModel? totals;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  EstimateModel({
    this.id,
    this.projectName,
    this.clientName,
    this.contactId,
    this.additionalNotes,
    this.projectType,
    required this.status,
    this.totalArea,
    this.paintableArea,
    this.totalCost,
    this.photos,
    this.elements,
    this.zones,
    this.materials,
    this.totals,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  factory EstimateModel.fromJson(Map<String, dynamic> json) {
    EstimateStatus parseStatus(String? value) {
      switch (value) {
        case 'pending':
          return EstimateStatus.pending;
        case 'photos_uploaded':
          return EstimateStatus.photosUploaded;
        case 'elements_selected':
          return EstimateStatus.elementsSelected;
        case 'completed':
          return EstimateStatus.completed;
        case 'sent':
          return EstimateStatus.sent;
        case 'cancelled':
          return EstimateStatus.cancelled;
        case 'draft':
        default:
          return EstimateStatus.draft;
      }
    }

    Map<String, num> parseSurfaceAreas(Map<String, dynamic> sa) {
      final Map<String, num> result = {};

      // Handle the new API structure where surface_areas contains arrays
      for (final entry in sa.entries) {
        final key = entry.key;
        final value = entry.value;

        if (value is List) {
          // For arrays like walls, ceiling, trim, calculate total area
          double totalArea = 0.0;
          for (final item in value) {
            if (item is Map<String, dynamic>) {
              // Look for area fields in the item
              final area = item['net_area'] ?? item['area'] ?? 0.0;
              if (area is num) {
                totalArea += area.toDouble();
              }
            }
          }
          result[key] = totalArea;
        } else if (value is num) {
          // For direct numeric values
          result[key] = value;
        }
      }

      return result;
    }

    List<ZoneModel>? parseZones(dynamic value) {
      if (value is List) {
        return value.map((z) {
          final mz = z as Map<String, dynamic>;
          final dataList = (mz['data'] as List?) ?? const [];
          final parsedData = dataList.map((d) {
            final md = d as Map<String, dynamic>;
            final fd = (md['floor_dimensions'] as Map?) ?? {};
            final sa =
                (md['surface_areas'] as Map<String, dynamic>?) ??
                <String, dynamic>{};
            final photos = (md['photos'] as List?)?.cast<String>() ?? const [];
            return ZoneDataModel(
              floorDimensions: FloorDimensionsModel(
                length: (fd['length'] as num?) ?? 0,
                width: (fd['width'] as num?) ?? 0,
                height: (fd['height'] as num?) ?? 0,
                unit: (fd['unit'] as String?) ?? 'ft',
              ),
              surfaceAreas: SurfaceAreasModel(
                values: parseSurfaceAreas(sa),
              ),
              photoPaths: photos,
            );
          }).toList();
          return ZoneModel(
            id: mz['id']?.toString(),
            name: (mz['name'] as String?) ?? '',
            zoneType: (mz['zone_type'] as String?) ?? '',
            data: parsedData,
          );
        }).toList();
      }
      return null;
    }

    List<MaterialItemModel>? parseMaterials(dynamic value) {
      if (value is List) {
        return value.map((m) {
          final mm = m as Map<String, dynamic>;
          return MaterialItemModel(
            id: mm['id']?.toString(),
            unit: mm['unit'] as String?,
            quantity: (mm['quantity'] as num?),
            unitPrice: (mm['unit_price'] as num?),
          );
        }).toList();
      }
      return null;
    }

    EstimateTotalsModel? parseTotals(dynamic value) {
      if (value is Map<String, dynamic>) {
        return EstimateTotalsModel(
          materialsCost: (value['materials_cost'] as num?),
          grandTotal: (value['grand_total'] as num?),
        );
      }
      return null;
    }

    return EstimateModel(
      id: json['id']?.toString(),
      projectName: json['project_name'] as String?,
      clientName: json['client_name'] as String?,
      contactId: json['contact_id']?.toString(),
      additionalNotes: json['additional_notes'] as String?,
      projectType: json['project_type'] != null
          ? ProjectType.values.firstWhere(
              (e) => e.name == json['project_type'],
              orElse: () => ProjectType.other,
            )
          : null,
      status: parseStatus(json['status'] as String?),
      totalArea: (json['total_area'] as num?)?.toDouble(),
      paintableArea: (json['paintable_area'] as num?)?.toDouble(),
      totalCost: (json['total_cost'] as num?)?.toDouble(),
      photos: json['photos'] != null ? List<String>.from(json['photos']) : null,
      elements: json['elements'] != null
          ? (json['elements'] as List<dynamic>)
                .map((element) => EstimateElement.fromJson(element))
                .toList()
          : null,
      zones: parseZones(json['zones']),
      materials: parseMaterials(json['materials']),
      totals: parseTotals(json['totals']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    String statusToBackend(EstimateStatus s) {
      switch (s) {
        case EstimateStatus.pending:
          return 'pending';
        case EstimateStatus.photosUploaded:
          return 'photos_uploaded';
        case EstimateStatus.elementsSelected:
          return 'elements_selected';
        case EstimateStatus.completed:
          return 'completed';
        case EstimateStatus.sent:
          return 'sent';
        case EstimateStatus.cancelled:
          return 'cancelled';
        case EstimateStatus.draft:
          return 'draft';
      }
    }

    return {
      'id': id,
      'project_name': projectName,
      'client_name': clientName,
      'contact_id': contactId,
      'additional_notes': additionalNotes,
      'project_type': projectType?.name,
      'status': statusToBackend(status),
      'total_area': totalArea,
      'paintable_area': paintableArea,
      'total_cost': totalCost,
      'photos': photos,
      'elements': elements?.map((e) => e.toJson()).toList(),
      'zones': zones
          ?.map(
            (z) => {
              'id': z.id,
              'name': z.name,
              'zone_type': z.zoneType,
              'data': z.data
                  .map(
                    (d) => {
                      'floor_dimensions': {
                        'length': d.floorDimensions.length,
                        'width': d.floorDimensions.width,
                        'height': d.floorDimensions.height,
                        'unit': d.floorDimensions.unit,
                      },
                      'surface_areas': d.surfaceAreas.values,
                      'photos': d.photoPaths,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
      'materials': materials
          ?.map(
            (m) => {
              'id': m.id,
              'unit': m.unit,
              'quantity': m.quantity,
              'unit_price': m.unitPrice,
            },
          )
          .toList(),
      'totals': totals == null
          ? null
          : {
              'materials_cost': totals!.materialsCost,
              'grand_total': totals!.grandTotal,
            },
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  EstimateModel copyWith({
    String? id,
    String? projectName,
    String? clientName,
    String? contactId,
    String? additionalNotes,
    ProjectType? projectType,
    EstimateStatus? status,
    double? totalArea,
    double? paintableArea,
    double? totalCost,
    List<String>? photos,
    List<EstimateElement>? elements,
    List<ZoneModel>? zones,
    List<MaterialItemModel>? materials,
    EstimateTotalsModel? totals,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return EstimateModel(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      clientName: clientName ?? this.clientName,
      contactId: contactId ?? this.contactId,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      projectType: projectType ?? this.projectType,
      status: status ?? this.status,
      totalArea: totalArea ?? this.totalArea,
      paintableArea: paintableArea ?? this.paintableArea,
      totalCost: totalCost ?? this.totalCost,
      photos: photos ?? this.photos,
      elements: elements ?? this.elements,
      zones: zones ?? this.zones,
      materials: materials ?? this.materials,
      totals: totals ?? this.totals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Constrói FormData no formato esperado pelo backend para criação multipart
  Future<FormData> toFormData() async {
    final formData = FormData();

    void addIfNotNull(String key, String? value) {
      if (value != null) {
        formData.fields.add(MapEntry(key, value));
      }
    }

    // Campos simples
    addIfNotNull('contact_id', contactId);
    addIfNotNull('project_name', projectName);
    formData.fields.add(
      MapEntry('additional_notes', additionalNotes ?? ''),
    );

    // Zones
    if (zones != null) {
      for (var i = 0; i < zones!.length; i++) {
        final z = zones![i];
        addIfNotNull('zones[$i][id]', z.id);
        formData.fields.add(MapEntry('zones[$i][name]', z.name));
        // zone_type apenas na primeira zona
        if (i == 0) {
          formData.fields.add(MapEntry('zones[$i][zone_type]', z.zoneType));
        }

        for (var k = 0; k < z.data.length; k++) {
          final d = z.data[k];
          // Floor dimensions
          formData.fields
            ..add(
              MapEntry(
                'zones[$i][data][$k][floor_dimensions][length]',
                d.floorDimensions.length.toString(),
              ),
            )
            ..add(
              MapEntry(
                'zones[$i][data][$k][floor_dimensions][width]',
                d.floorDimensions.width.toString(),
              ),
            )
            ..add(
              MapEntry(
                'zones[$i][data][$k][floor_dimensions][height]',
                d.floorDimensions.height.toString(),
              ),
            )
            ..add(
              MapEntry(
                'zones[$i][data][$k][floor_dimensions][unit]',
                d.floorDimensions.unit,
              ),
            );

          // Surface areas
          d.surfaceAreas.values.forEach((key, value) {
            formData.fields.add(
              MapEntry(
                'zones[$i][data][$k][surface_areas][$key]',
                value.toString(),
              ),
            );
          });

          // Photos
          for (final path in d.photoPaths) {
            formData.files.add(
              MapEntry(
                'zones[$i][data][$k][photos][]',
                await MultipartFile.fromFile(path),
              ),
            );
          }
        }
      }
    }

    // Materials
    if (materials != null) {
      for (var i = 0; i < materials!.length; i++) {
        final m = materials![i];
        addIfNotNull('materials[$i][id]', m.id);
        addIfNotNull('materials[$i][unit]', m.unit);
        addIfNotNull('materials[$i][quantity]', m.quantity?.toString());
        addIfNotNull('materials[$i][unit_price]', m.unitPrice?.toString());
      }
    }

    // Totals
    if (totals != null) {
      addIfNotNull('totals[materials_cost]', totals!.materialsCost?.toString());
      addIfNotNull('totals[grand_total]', totals!.grandTotal?.toString());
    }

    return formData;
  }
}

// Other response models moved to their own files.

import 'estimate_status.dart';
import 'project_type.dart';
import 'materials_calculation_model.dart';
import 'zone_detail_model.dart';
import 'material_detail_model.dart';
import 'totals_detail_model.dart';
import 'photo_data_model.dart';
import 'measurement_detail_model.dart';
import '../../utils/json_parser_helper.dart';

class EstimateDetailModel {
  final int id;
  final String contactId;
  final String contact;
  final String projectName;
  final String clientName;
  final ProjectType projectType;
  final EstimateStatus status;
  final String wallCondition;
  final bool hasAccentWall;
  final String additionalNotes;
  final MaterialsCalculationModel materialsCalculation;
  final double totalCost;
  final bool complete;
  final List<ZoneDetailModel> zones;
  final List<MaterialDetailModel> materials;
  final TotalsDetailModel totals;
  final List<PhotoDataModel> photosData;
  final List<MeasurementDetailModel> measurements;
  final DateTime? photosUploadedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  EstimateDetailModel({
    required this.id,
    required this.contactId,
    required this.contact,
    required this.projectName,
    required this.clientName,
    required this.projectType,
    required this.status,
    required this.wallCondition,
    required this.hasAccentWall,
    required this.additionalNotes,
    required this.materialsCalculation,
    required this.totalCost,
    required this.complete,
    required this.zones,
    required this.materials,
    required this.totals,
    required this.photosData,
    required this.measurements,
    this.photosUploadedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EstimateDetailModel.fromJson(Map<String, dynamic> json) {
    return EstimateDetailModel(
      id: json['id'] ?? 0,
      contactId: json['contact_id'] ?? '',
      contact: json['contact'] ?? '',
      projectName: json['project_name'] ?? '',
      clientName: json['client_name'] ?? '',
      projectType: _parseProjectType(json['project_type']),
      status: _parseStatus(json['status']),
      wallCondition: json['wall_condition'] ?? 'good',
      hasAccentWall: json['has_accent_wall'] ?? false,
      additionalNotes: json['additional_notes'] ?? '',
      materialsCalculation: MaterialsCalculationModel.fromJson(
        json['materials_calculation'] ?? {},
      ),
      totalCost: parseDouble(json['total_cost']),
      complete: json['complete'] ?? false,
      zones:
          (json['zones'] as List<dynamic>?)
              ?.map((zone) => ZoneDetailModel.fromJson(zone))
              .toList() ??
          [],
      materials:
          (json['materials'] as List<dynamic>?)
              ?.map((material) => MaterialDetailModel.fromJson(material))
              .toList() ??
          [],
      totals: TotalsDetailModel.fromJson(json['totals'] ?? {}),
      photosData:
          (json['photos_data'] as List<dynamic>?)
              ?.map(
                (photoUrl) => PhotoDataModel(
                  id: '',
                  filename: '',
                  url: photoUrl.toString(),
                  size: 0,
                  mimeType: '',
                  zoneId: '',
                  uploadedAt: DateTime.now(),
                ),
              )
              .toList() ??
          [],
      measurements:
          (json['measurements'] as List<dynamic>?)
              ?.map(
                (measurement) => MeasurementDetailModel.fromJson(measurement),
              )
              .toList() ??
          [],
      photosUploadedAt: json['photos_uploaded_at'] != null
          ? DateTime.parse(json['photos_uploaded_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contact_id': contactId,
      'contact': contact,
      'project_name': projectName,
      'client_name': clientName,
      'project_type': projectType.name,
      'status': _statusToString(status),
      'wall_condition': wallCondition,
      'has_accent_wall': hasAccentWall,
      'additional_notes': additionalNotes,
      'materials_calculation': materialsCalculation.toJson(),
      'total_cost': totalCost,
      'complete': complete,
      'zones': zones.map((zone) => zone.toJson()).toList(),
      'materials': materials.map((material) => material.toJson()).toList(),
      'totals': totals.toJson(),
      'photos_data': photosData.map((photo) => photo.toJson()).toList(),
      'measurements': measurements
          .map((measurement) => measurement.toJson())
          .toList(),
      'photos_uploaded_at': photosUploadedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static ProjectType _parseProjectType(String? value) {
    switch (value) {
      case 'interior':
        return ProjectType.interior;
      case 'exterior':
        return ProjectType.exterior;
      case 'both':
        return ProjectType.both;
      default:
        return ProjectType.both;
    }
  }

  static EstimateStatus _parseStatus(String? value) {
    switch (value) {
      case 'draft':
        return EstimateStatus.draft;
      case 'photos_uploaded':
        return EstimateStatus.photosUploaded;
      case 'elements_selected':
        return EstimateStatus.elementsSelected;
      case 'materials_calculated':
        return EstimateStatus.completed;
      case 'completed':
        return EstimateStatus.completed;
      case 'sent':
        return EstimateStatus.sent;
      default:
        return EstimateStatus.draft;
    }
  }

  static String _statusToString(EstimateStatus status) {
    switch (status) {
      case EstimateStatus.draft:
        return 'draft';
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
      case EstimateStatus.pending:
        return 'pending';
    }
  }
}

import 'estimate_model.dart';
import 'estimate_status.dart';
import 'estimate_totals.dart';
import 'material_create_item.dart';
import 'zones/zone_response_model.dart';

/// Complete estimate response from backend
class EstimateResponse {
  final int id;
  final String contactId;
  final String projectName;
  final String additionalNotes;
  final List<ZoneResponseModel> zones;
  final List<MaterialCreateItem> materials;
  final EstimateTotals totals;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EstimateResponse({
    required this.id,
    required this.contactId,
    required this.projectName,
    required this.additionalNotes,
    required this.zones,
    required this.materials,
    required this.totals,
    this.createdAt,
    this.updatedAt,
  });

  factory EstimateResponse.fromJson(Map<String, dynamic> json) {
    return EstimateResponse(
      id: json['id'] ?? 0,
      contactId: json['contact_id'] ?? '',
      projectName: json['project_name'] ?? '',
      additionalNotes: json['additional_notes'] ?? '',
      zones:
          (json['zones'] as List<dynamic>?)
              ?.map((z) => ZoneResponseModel.fromJson(z))
              .toList() ??
          [],
      materials:
          (json['materials'] as List<dynamic>?)
              ?.map((m) => MaterialCreateItem.fromJson(m))
              .toList() ??
          [],
      totals: EstimateTotals.fromJson(json['totals'] ?? {}),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  /// Convert to existing EstimateModel for compatibility
  EstimateModel toEstimateModel() {
    // Calculate total cost from materials
    final materialsCost = materials.fold<double>(
      0.0,
      (sum, material) =>
          sum + (material.quantity.toDouble() * material.unitPrice.toDouble()),
    );

    // Convert zones to photos list
    final allPhotos = <String>[];
    for (final zone in zones) {
      for (final data in zone.data) {
        allPhotos.addAll(data.photos);
      }
    }

    return EstimateModel(
      id: id.toString(),
      projectName: projectName,
      clientName: null, // Not provided in new structure
      status: EstimateStatus.draft, // Default status
      totalCost: materialsCost,
      photos: allPhotos,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

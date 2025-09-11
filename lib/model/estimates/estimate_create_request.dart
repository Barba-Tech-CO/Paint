import 'zones/zone_create_model.dart';
import 'material_create_item.dart';
import 'estimate_totals.dart';

/// Main request model for creating estimate with multipart data
class EstimateCreateRequest {
  final String contactId;
  final String projectName;
  final String? additionalNotes;
  final List<ZoneCreateModel> zones;
  final List<MaterialCreateItem> materials;
  final EstimateTotals totals;

  EstimateCreateRequest({
    required this.contactId,
    required this.projectName,
    this.additionalNotes,
    required this.zones,
    required this.materials,
    required this.totals,
  });

  Map<String, dynamic> toJson() {
    return {
      'contact_id': contactId,
      'project_name': projectName,
      'additional_notes': additionalNotes ?? '',
      'zones': zones.map((z) => z.toJson()).toList(),
      'materials': materials.map((m) => m.toJson()).toList(),
      'totals': totals.toJson(),
    };
  }

  factory EstimateCreateRequest.fromJson(Map<String, dynamic> json) {
    return EstimateCreateRequest(
      contactId: json['contact_id'] ?? '',
      projectName: json['project_name'] ?? '',
      additionalNotes: json['additional_notes'],
      zones:
          (json['zones'] as List<dynamic>?)
              ?.map((z) => ZoneCreateModel.fromJson(z))
              .toList() ??
          [],
      materials:
          (json['materials'] as List<dynamic>?)
              ?.map((m) => MaterialCreateItem.fromJson(m))
              .toList() ??
          [],
      totals: EstimateTotals.fromJson(json['totals'] ?? {}),
    );
  }
}

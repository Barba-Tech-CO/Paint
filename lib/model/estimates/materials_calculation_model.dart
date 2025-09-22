import '../../utils/json_parser_helper.dart';

class MaterialsCalculationModel {
  final double gallonsNeeded;
  final int cansNeeded;
  final String unit;
  final double coveragePerGallon;
  final double totalArea;
  final double? primerGallons;
  final double? paintGallons;
  final double? wasteFactor;

  MaterialsCalculationModel({
    required this.gallonsNeeded,
    required this.cansNeeded,
    required this.unit,
    required this.coveragePerGallon,
    required this.totalArea,
    this.primerGallons,
    this.paintGallons,
    this.wasteFactor,
  });

  factory MaterialsCalculationModel.fromJson(Map<String, dynamic> json) {
    // Handle the actual API response structure

    // Calculate total area from zones if available
    double totalArea = 0.0;
    if (json.containsKey('zones') && json['zones'] is List) {
      final zones = json['zones'] as List<dynamic>;
      for (final zone in zones) {
        if (zone is Map<String, dynamic> && zone.containsKey('data')) {
          final zoneData = zone['data'] as List<dynamic>? ?? [];
          for (final data in zoneData) {
            if (data is Map<String, dynamic> &&
                data.containsKey('surface_areas')) {
              final surfaceAreas =
                  data['surface_areas'] as Map<String, dynamic>? ?? {};
              totalArea +=
                  parseDouble(surfaceAreas['walls']) +
                  parseDouble(surfaceAreas['ceiling']);
            }
          }
        }
      }
    }

    // If no zones data, try to get from total_area field
    if (totalArea == 0.0) {
      totalArea = parseDouble(json['total_area']);
    }

    return MaterialsCalculationModel(
      gallonsNeeded: parseDouble(json['gallons_needed']),
      cansNeeded: json['cans_needed'] ?? 0,
      unit: json['unit'] ?? 'gallon',
      coveragePerGallon: parseDouble(json['coverage_per_gallon']) == 0.0
          ? 350.0
          : parseDouble(json['coverage_per_gallon']),
      totalArea: totalArea,
      primerGallons: json['primer_gallons'] != null
          ? parseDouble(json['primer_gallons'])
          : null,
      paintGallons: json['paint_gallons'] != null
          ? parseDouble(json['paint_gallons'])
          : null,
      wasteFactor: json['waste_factor'] != null
          ? parseDouble(json['waste_factor'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gallons_needed': gallonsNeeded,
      'cans_needed': cansNeeded,
      'unit': unit,
      'coverage_per_gallon': coveragePerGallon,
      'total_area': totalArea,
      'primer_gallons': primerGallons,
      'paint_gallons': paintGallons,
      'waste_factor': wasteFactor,
    };
  }
}

import 'door_model.dart';
import 'window_model.dart';
import '../../utils/json_parser_helper.dart';

class MeasurementDataModel {
  final double height;
  final double width;
  final double? perimeter;
  final List<DoorModel> doors;
  final List<WindowModel> windows;
  final double totalArea;
  final double? openingsArea;
  final double paintableArea;
  final double? ceilingArea;
  final bool includeCeiling;

  MeasurementDataModel({
    required this.height,
    required this.width,
    this.perimeter,
    required this.doors,
    required this.windows,
    required this.totalArea,
    this.openingsArea,
    required this.paintableArea,
    this.ceilingArea,
    required this.includeCeiling,
  });

  factory MeasurementDataModel.fromJson(Map<String, dynamic> json) {
    // Handle the actual API response structure
    final floorDimensions =
        json['floor_dimensions'] as Map<String, dynamic>? ?? {};
    final surfaceAreas = json['surface_areas'] as Map<String, dynamic>? ?? {};

    return MeasurementDataModel(
      height: parseDouble(floorDimensions['length']),
      width: parseDouble(floorDimensions['width']),
      perimeter: null, // Not provided in API response
      doors: [], // Not provided in API response
      windows: [], // Not provided in API response
      totalArea: parseDouble(surfaceAreas['walls']),
      openingsArea: null, // Not provided in API response
      paintableArea: parseDouble(surfaceAreas['walls']),
      ceilingArea: parseDouble(surfaceAreas['ceiling']),
      includeCeiling: surfaceAreas['ceiling'] != null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'width': width,
      'perimeter': perimeter,
      'doors': doors.map((door) => door.toJson()).toList(),
      'windows': windows.map((window) => window.toJson()).toList(),
      'total_area': totalArea,
      'openings_area': openingsArea,
      'paintable_area': paintableArea,
      'ceiling_area': ceilingArea,
      'include_ceiling': includeCeiling,
    };
  }
}

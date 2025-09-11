import 'dart:io';
import 'zone_type.dart';
import 'floor_dimensions.dart';
import 'surface_areas.dart';

/// Zone model for creation with photos and dimensions
class ZoneCreateModel {
  final String id;
  final String name;
  final ZoneType? zoneType; // Only for first zone
  final FloorDimensions floorDimensions;
  final SurfaceAreas surfaceAreas;
  final List<File> photos;

  ZoneCreateModel({
    required this.id,
    required this.name,
    this.zoneType,
    required this.floorDimensions,
    required this.surfaceAreas,
    required this.photos,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'name': name,
      'data': [
        {
          'floor_dimensions': floorDimensions.toJson(),
          'surface_areas': surfaceAreas.toJson(),
        },
      ],
    };

    if (zoneType != null) {
      json['zone_type'] = zoneType!.name;
    }

    return json;
  }

  factory ZoneCreateModel.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    final firstData = dataList.isNotEmpty ? dataList[0] : <String, dynamic>{};

    return ZoneCreateModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      zoneType: json['zone_type'] != null
          ? ZoneType.fromString(json['zone_type'])
          : null,
      floorDimensions: FloorDimensions.fromJson(
        firstData['floor_dimensions'] ?? {},
      ),
      surfaceAreas: SurfaceAreas.fromJson(firstData['surface_areas'] ?? {}),
      photos: [], // Photos are handled separately in multipart
    );
  }
}

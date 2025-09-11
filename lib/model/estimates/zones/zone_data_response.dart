import '../floor_dimensions.dart';
import '../surface/surface_areas.dart';

/// Zone data response from backend
class ZoneDataResponse {
  final FloorDimensions floorDimensions;
  final SurfaceAreas surfaceAreas;
  final List<String> photos;

  ZoneDataResponse({
    required this.floorDimensions,
    required this.surfaceAreas,
    required this.photos,
  });

  factory ZoneDataResponse.fromJson(Map<String, dynamic> json) {
    return ZoneDataResponse(
      floorDimensions: FloorDimensions.fromJson(json['floor_dimensions'] ?? {}),
      surfaceAreas: SurfaceAreas.fromJson(json['surface_areas'] ?? {}),
      photos:
          (json['photos'] as List<dynamic>?)
              ?.map((p) => p.toString())
              .toList() ??
          [],
    );
  }
}

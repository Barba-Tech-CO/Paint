import 'floor_dimensions_model.dart';
import 'surface_areas_model.dart';

class ZoneDataModel {
  final FloorDimensionsModel floorDimensions;
  final SurfaceAreasModel surfaceAreas;
  final List<String> photoPaths;

  ZoneDataModel({
    required this.floorDimensions,
    required this.surfaceAreas,
    required this.photoPaths,
  });
}

import 'dart:convert';
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

  Map<String, dynamic> toMap() {
    return {
      'floor_dimensions': floorDimensions.toMap(),
      'surface_areas': surfaceAreas.toMap(),
      'photos': photoPaths,
    };
  }

  factory ZoneDataModel.fromMap(Map<String, dynamic> map) {
    dynamic fd = map['floor_dimensions'];
    if (fd is String) {
      try {
        fd = jsonDecode(fd);
      } catch (_) {
        fd = {};
      }
    }

    dynamic sa = map['surface_areas'];
    if (sa is String) {
      try {
        sa = jsonDecode(sa);
      } catch (_) {
        sa = {};
      }
    }

    return ZoneDataModel(
      floorDimensions:
          FloorDimensionsModel.fromMap((fd as Map?)?.cast<String, dynamic>() ?? const {}),
      surfaceAreas:
          SurfaceAreasModel.fromMap((sa as Map?)?.cast<String, dynamic>() ?? const {}),
      photoPaths: _stringListFromDynamic(map['photos']) ?? const <String>[],
    );
  }

  static List<String>? _stringListFromDynamic(dynamic value) {
    if (value == null) return null;
    try {
      final List<dynamic> list = value is String
          ? (jsonDecode(value) as List)
          : (value is List ? value : const []);
      return list.map((e) => e is String ? e : e.toString()).toList();
    } catch (_) {
      return null;
    }
  }
}

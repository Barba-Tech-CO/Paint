import 'package:flutter/material.dart';

import '../../model/projects/project_card_model.dart';

class EditZoneViewModel extends ChangeNotifier {
  ProjectCardModel? _zone;
  String _zoneTitle = '';
  double _width = 0.0;
  double _length = 0.0;
  double _walls = 0.0;
  double _ceiling = 0.0;
  double _trim = 0.0;
  List<String> _photos = [];

  // Getters
  ProjectCardModel? get zone => _zone;
  String get zoneTitle => _zoneTitle;
  double get width => _width;
  double get length => _length;
  double get walls => _walls;
  double get ceiling => _ceiling;
  double get trim => _trim;
  List<String> get photos => _photos;

  // Callbacks
  VoidCallback? onZoneDeleted;
  VoidCallback? onZoneUpdated;

  /// Initialize data from zone
  void initializeData(ProjectCardModel? zone) {
    _zone = zone;

    if (zone != null) {
      _zoneTitle = zone.title;

      // Parse floor dimensions from "14' x 16'" format
      final dimensions = zone.floorDimensionValue
          .replaceAll("'", "")
          .split(" x ");
      _width = double.tryParse(dimensions.first) ?? 0.0;
      _length = dimensions.length > 1
          ? (double.tryParse(dimensions.last) ?? 0.0)
          : 0.0;

      // Parse surface areas from zone fields
      _walls =
          double.tryParse(zone.areaPaintable.replaceAll(" sq ft", "")) ?? 0.0;
      _ceiling = zone.ceilingArea != null
          ? double.tryParse(zone.ceilingArea!.replaceAll(" sq ft", "")) ?? 0.0
          : double.tryParse(zone.floorAreaValue.replaceAll(" sq ft", "")) ??
                0.0;
      _trim = zone.trimLength != null
          ? double.tryParse(zone.trimLength!.replaceAll(" linear ft", "")) ??
                0.0
          : 0.0;

      // Initialize photos with zone image (se disponível)
      _photos = zone.image.isNotEmpty ? [zone.image] : [];
    } else {
      // Sem mocks: valores vazios/iniciais
      _zoneTitle = '';
      _width = 0.0;
      _length = 0.0;
      _walls = 0.0;
      _ceiling = 0.0;
      _trim = 0.0;
      _photos = [];
    }

    notifyListeners();
  }

  /// Update zone title
  void updateZoneTitle(String title) {
    _zoneTitle = title;
    notifyListeners();
  }

  /// Update dimensions and recalculate areas
  void updateDimensions(double width, double length) {
    _width = width;
    _length = length;
    // Recalculate surface areas if needed
    _ceiling = width * length;
    notifyListeners();
  }

  /// Update walls area
  void updateWalls(double walls) {
    _walls = walls;
    notifyListeners();
  }

  /// Update ceiling area
  void updateCeiling(double ceiling) {
    _ceiling = ceiling;
    notifyListeners();
  }

  /// Update trim length
  void updateTrim(double trim) {
    _trim = trim;
    notifyListeners();
  }

  /// Update photos
  void updatePhotos(List<String> photos) {
    _photos = photos;
    notifyListeners();
  }

  /// Save zone changes
  void saveZone() {
    if (_zone != null) {
      // Update the zone with new values
      // This would typically call a service or repository
      onZoneUpdated?.call();
    }
  }

  /// Delete zone
  void deleteZone() {
    if (_zone != null) {
      // Delete the zone
      // This would typically call a service or repository
      onZoneDeleted?.call();
    }
  }

  /// Calculate total paintable area
  double get totalPaintableArea => _walls + _ceiling + _trim;

  /// Calculate floor area
  double get floorArea => _width * _length;

  /// Check if zone has valid dimensions
  bool get hasValidDimensions => _width > 0 && _length > 0;

  /// Check if zone has valid areas
  bool get hasValidAreas => _walls > 0 || _ceiling > 0 || _trim > 0;
}

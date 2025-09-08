import 'package:flutter/foundation.dart';
import '../model/models.dart';

class OverviewZonesViewModel extends ChangeNotifier {
  List<MaterialModel> _selectedMaterials = [];
  List<ProjectCardModel> _selectedZones = [];

  List<MaterialModel> get selectedMaterials => _selectedMaterials;
  List<ProjectCardModel> get selectedZones => _selectedZones;
  int get materialsCount => _selectedMaterials.length;
  int get zonesCount => _selectedZones.length;
  double get totalMaterialsCost {
    return _selectedMaterials.fold(
      0.0,
      (sum, material) => sum + material.price,
    );
  }

  String get totalArea {
    if (_selectedZones.isNotEmpty) {
      final totalAreaValue = _selectedZones.fold(0.0, (sum, zone) {
        final areaStr = zone.floorAreaValue.replaceAll(' sq ft', '');
        return sum + (double.tryParse(areaStr) ?? 0.0);
      });
      return '${totalAreaValue.toInt()} sq ft';
    }
    return '631 sq ft';
  }

  String get paintType => _selectedMaterials.isNotEmpty
      ? _selectedMaterials.first.type.displayName
      : 'Interior';

  void setSelectedMaterials(List<MaterialModel> materials) {
    _selectedMaterials = materials;
    notifyListeners();
  }

  void setSelectedZones(List<ProjectCardModel> zones) {
    _selectedZones = zones;
    notifyListeners();
  }

  void addZone(ProjectCardModel zone) {
    if (!_selectedZones.contains(zone)) {
      _selectedZones.add(zone);
      notifyListeners();
    }
  }

  void removeZone(ProjectCardModel zone) {
    _selectedZones.remove(zone);
    notifyListeners();
  }

  void clearZones() {
    _selectedZones.clear();
    notifyListeners();
  }

  void addMaterial(MaterialModel material) {
    if (!_selectedMaterials.contains(material)) {
      _selectedMaterials.add(material);
      notifyListeners();
    }
  }

  void removeMaterial(MaterialModel material) {
    _selectedMaterials.remove(material);
    notifyListeners();
  }

  void clearMaterials() {
    _selectedMaterials.clear();
    notifyListeners();
  }

  double get laborCost => 405.00;
  double get suppliesCost => 45.00;

  double get totalProjectCost => totalMaterialsCost + laborCost + suppliesCost;

  String get floorDimensions {
    if (_selectedZones.isNotEmpty) {
      return _selectedZones.first.floorDimensionValue;
    }
    return '14 X 16';
  }

  String get floorArea {
    if (_selectedZones.isNotEmpty) {
      return _selectedZones.first.floorAreaValue;
    }
    return '224 sq ft';
  }

  String get rooms {
    if (_selectedZones.isNotEmpty) {
      return _selectedZones.map((zone) => zone.title).join(', ');
    }
    return 'Living Room';
  }

  List<String> get formattedZones {
    return _selectedZones
        .map((zone) => '${zone.title} - ${zone.floorAreaValue}')
        .toList();
  }
}

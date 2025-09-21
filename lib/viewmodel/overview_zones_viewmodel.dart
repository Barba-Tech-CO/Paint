import 'package:flutter/foundation.dart';

import '../model/material_models/material_model.dart';
import '../model/projects/project_card_model.dart';
import '../use_case/estimates/project_calculation_use_case.dart';

class OverviewZonesViewModel extends ChangeNotifier {
  final ProjectCalculationUseCase _projectCalculationUseCase =
      ProjectCalculationUseCase();

  List<MaterialModel> _selectedMaterials = [];
  List<ProjectCardModel> _selectedZones = [];
  Map<MaterialModel, int> _materialQuantities = {};

  List<MaterialModel> get selectedMaterials => _selectedMaterials;
  List<ProjectCardModel> get selectedZones => _selectedZones;
  Map<MaterialModel, int> get materialQuantities => _materialQuantities;
  int get materialsCount => _selectedMaterials.length;
  int get zonesCount => _selectedZones.length;
  double get totalMaterialsCost {
    return _projectCalculationUseCase.calculateMaterialsCost(
      _selectedMaterials,
      _materialQuantities,
    );
  }

  String get totalArea {
    return _projectCalculationUseCase.calculateTotalArea(_selectedZones);
  }

  String get paintType => _selectedMaterials.isNotEmpty
      ? _selectedMaterials.first.type.displayName
      : 'Interior';

  void setSelectedMaterials(List<MaterialModel> materials) {
    _selectedMaterials = materials;
    notifyListeners();
  }

  void setMaterialQuantities(Map<MaterialModel, int> quantities) {
    _materialQuantities = Map.from(quantities);
    notifyListeners();
  }

  void setSelectedZones(List<ProjectCardModel> zones) {
    _selectedZones = zones;
    notifyListeners();
  }

  /// Obtém a quantidade de um material
  int getQuantity(MaterialModel material) {
    return _materialQuantities[material] ?? 1;
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

  void addMaterial(MaterialModel material, {int quantity = 1}) {
    if (!_selectedMaterials.contains(material)) {
      _selectedMaterials.add(material);
      _materialQuantities[material] = quantity;
      notifyListeners();
    }
  }

  void removeMaterial(MaterialModel material) {
    _selectedMaterials.remove(material);
    _materialQuantities.remove(material);
    notifyListeners();
  }

  void clearMaterials() {
    _selectedMaterials.clear();
    _materialQuantities.clear();
    notifyListeners();
  }

  double get totalProjectCost =>
      _projectCalculationUseCase.calculateTotalProjectCost(
        totalMaterialsCost,
      );

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
    return _projectCalculationUseCase.formatZonesForDisplay(_selectedZones);
  }
}

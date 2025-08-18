import 'package:flutter/foundation.dart';
import '../model/models.dart';

class OverviewZonesViewModel extends ChangeNotifier {
  List<MaterialModel> _selectedMaterials = [];

  // Getters
  List<MaterialModel> get selectedMaterials => _selectedMaterials;
  int get materialsCount => _selectedMaterials.length;

  // Cálculos de preço
  double get totalMaterialsCost {
    return _selectedMaterials.fold(
      0.0,
      (sum, material) => sum + material.price,
    );
  }

  // Estatísticas do projeto (mock data - você pode calcular baseado nos materiais)
  String get totalArea => '631 sq ft';
  String get paintType => _selectedMaterials.isNotEmpty
      ? _selectedMaterials.first.type.displayName
      : 'Interior';

  // Métodos para gerenciar materiais
  void setSelectedMaterials(List<MaterialModel> materials) {
    _selectedMaterials = materials;
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

  // Calcula custos adicionais (mão de obra, etc)
  double get laborCost => 405.00; // Baseado no mock mostrado na imagem
  double get suppliesCost => 45.00; // Baseado no mock mostrado na imagem

  double get totalProjectCost => totalMaterialsCost + laborCost + suppliesCost;

  // Informações das zonas (mock data - integre com ZonesViewModel se necessário)
  String get floorDimensions => '14 X 16';
  String get floorArea => '224 sq ft';
  String get rooms => 'Living Room';
}

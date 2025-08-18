import 'package:flutter/foundation.dart';
import '../model/models.dart';

class OverviewZonesViewModel extends ChangeNotifier {
  List<MaterialModel> _selectedMaterials = [];
  List<ZonesCardModel> _selectedZones = [];

  // Getters
  List<MaterialModel> get selectedMaterials => _selectedMaterials;
  List<ZonesCardModel> get selectedZones => _selectedZones;
  int get materialsCount => _selectedMaterials.length;
  int get zonesCount => _selectedZones.length; // Cálculos de preço
  double get totalMaterialsCost {
    return _selectedMaterials.fold(
      0.0,
      (sum, material) => sum + material.price,
    );
  }

  // Estatísticas do projeto (calculadas baseado nas zonas e materiais)
  String get totalArea {
    if (_selectedZones.isNotEmpty) {
      // Calcula a área total das zonas selecionadas
      final totalAreaValue = _selectedZones.fold(0.0, (sum, zone) {
        final areaStr = zone.floorAreaValue.replaceAll(' sq ft', '');
        return sum + (double.tryParse(areaStr) ?? 0.0);
      });
      return '${totalAreaValue.toInt()} sq ft';
    }
    return '631 sq ft'; // fallback
  }

  String get paintType => _selectedMaterials.isNotEmpty
      ? _selectedMaterials.first.type.displayName
      : 'Interior';

  // Métodos para gerenciar materiais
  void setSelectedMaterials(List<MaterialModel> materials) {
    _selectedMaterials = materials;
    notifyListeners();
  }

  // Métodos para gerenciar zonas
  void setSelectedZones(List<ZonesCardModel> zones) {
    _selectedZones = zones;
    notifyListeners();
  }

  void addZone(ZonesCardModel zone) {
    if (!_selectedZones.contains(zone)) {
      _selectedZones.add(zone);
      notifyListeners();
    }
  }

  void removeZone(ZonesCardModel zone) {
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

  // Calcula custos adicionais (mão de obra, etc)
  double get laborCost => 405.00; // Baseado no mock mostrado na imagem
  double get suppliesCost => 45.00; // Baseado no mock mostrado na imagem

  double get totalProjectCost => totalMaterialsCost + laborCost + suppliesCost;

  // Informações das zonas (calculadas das zonas selecionadas)
  String get floorDimensions {
    if (_selectedZones.isNotEmpty) {
      return _selectedZones.first.floorDimensionValue;
    }
    return '14 X 16'; // fallback
  }

  String get floorArea {
    if (_selectedZones.isNotEmpty) {
      return _selectedZones.first.floorAreaValue;
    }
    return '224 sq ft'; // fallback
  }

  String get rooms {
    if (_selectedZones.isNotEmpty) {
      return _selectedZones.map((zone) => zone.title).join(', ');
    }
    return 'Living Room'; // fallback
  }

  // Método para obter as zonas formatadas para exibição
  List<String> get formattedZones {
    return _selectedZones
        .map((zone) => '${zone.title} - ${zone.floorAreaValue}')
        .toList();
  }

  /*
  EXEMPLO DE USO - Como navegar das zonas para o overview:
  
  Em qualquer View que tenha zonas selecionadas, você pode fazer:
  
  // Para navegar apenas com zonas:
  context.push('/overview-zones', extra: {'zones': selectedZonesList});
  
  // Para navegar com materiais e zonas:
  context.push('/overview-zones', extra: {
    'materials': selectedMaterialsList,
    'zones': selectedZonesList,
  });
  
  // Exemplo prático no ZonesDetailsView:
  void _navigateToOverview() {
    final selectedZones = _listViewModel.zones; // ou só as selecionadas
    context.push('/overview-zones', extra: {'zones': selectedZones});
  }
  */
}

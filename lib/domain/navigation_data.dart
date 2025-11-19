import '../../model/material_models/material_model.dart';
import '../../model/projects/project_card_model.dart';

/// Classe de dados para navegação
class NavigationData {
  final List<MaterialModel>? selectedMaterials;
  final Map<MaterialModel, int>? materialQuantities;
  final List<ProjectCardModel>? selectedZones;
  final Map<String, dynamic>? projectData;

  const NavigationData({
    this.selectedMaterials,
    this.materialQuantities,
    this.selectedZones,
    this.projectData,
  });

  factory NavigationData.empty() {
    return const NavigationData(
      selectedMaterials: null,
      materialQuantities: null,
      selectedZones: null,
      projectData: null,
    );
  }

  bool get hasMaterials =>
      selectedMaterials != null && selectedMaterials!.isNotEmpty;
  bool get hasZones => selectedZones != null && selectedZones!.isNotEmpty;
  bool get hasQuantities =>
      materialQuantities != null && materialQuantities!.isNotEmpty;

  @override
  String toString() {
    return 'NavigationData(materials: ${selectedMaterials?.length ?? 0}, '
        'quantities: ${materialQuantities?.length ?? 0}, '
        'zones: ${selectedZones?.length ?? 0}, '
        'projectData: ${projectData != null ? 'present' : 'null'})';
  }
}

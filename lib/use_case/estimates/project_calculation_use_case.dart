import '../../model/projects/project_card_model.dart';

class ProjectCalculationUseCase {
  /// Converte o tipo de projeto para tipo de zona
  String getZoneTypeFromProjectType(String projectType) {
    switch (projectType.toLowerCase()) {
      case 'interior':
        return 'interior';
      case 'exterior':
        return 'exterior';
      case 'both':
        return 'both';
      default:
        return 'interior';
    }
  }

  /// Calcula a área total de todas as zonas
  String calculateTotalArea(List<ProjectCardModel> zones) {
    if (zones.isEmpty) {
      return '631 sq ft'; // Valor padrão
    }

    final totalAreaValue = zones.fold(0.0, (sum, zone) {
      final areaStr = zone.floorAreaValue.replaceAll(' sq ft', '');
      return sum + (double.tryParse(areaStr) ?? 0.0);
    });

    return '${totalAreaValue.toInt()} sq ft';
  }

  /// Calcula o custo total dos materiais
  double calculateMaterialsCost(
    List<dynamic> materials,
    Map<dynamic, int> quantities,
  ) {
    return materials.fold(0.0, (sum, material) {
      final quantity = quantities[material] ?? 1;
      return sum + (material.price * quantity);
    });
  }

  /// Calcula o custo total do projeto
  double calculateTotalProjectCost(double materialsCost) {
    // Retorna apenas o custo dos materiais (removendo labor e supplies)
    return materialsCost;
  }

  /// Valida se os dados do projeto estão completos
  bool validateProjectData(Map<String, dynamic>? projectData) {
    if (projectData == null) return false;

    final requiredFields = ['projectName', 'clientId', 'projectType'];
    return requiredFields.every(
      (field) =>
          projectData.containsKey(field) &&
          projectData[field] != null &&
          projectData[field].toString().isNotEmpty,
    );
  }

  /// Formata as zonas para exibição
  List<String> formatZonesForDisplay(List<ProjectCardModel> zones) {
    return zones
        .map((zone) => '${zone.title} - ${zone.floorAreaValue}')
        .toList();
  }
}

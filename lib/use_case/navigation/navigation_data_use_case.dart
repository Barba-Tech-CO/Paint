import '../../domain/navigation_data.dart';
import '../../model/material_models/material_model.dart';
import '../../model/projects/project_card_model.dart';

class NavigationDataUseCase {
  /// Processa dados de navegação para OverviewZonesView
  /// Aceita diferentes formatos de dados e os converte para o formato padrão
  NavigationData processOverviewZonesData(dynamic extra) {
    if (extra == null) {
      return NavigationData.empty();
    }

    // Caso 1: Map<MaterialModel, int> (formato direto)
    if (extra is Map<MaterialModel, int>) {
      return NavigationData(
        selectedMaterials: extra.keys.toList(),
        materialQuantities: extra,
        selectedZones: null,
      );
    }

    // Caso 2: List<MaterialModel> (formato antigo)
    if (extra is List<MaterialModel>) {
      return NavigationData(
        selectedMaterials: extra,
        materialQuantities: null,
        selectedZones: null,
      );
    }

    // Caso 3: Map com diferentes estruturas
    if (extra is Map) {
      return _processMapData(extra);
    }

    // Caso desconhecido
    return NavigationData.empty();
  }

  /// Processa dados do tipo Map
  NavigationData _processMapData(Map extra) {
    // Extrair projectData se disponível
    final projectData = extra['projectData'] as Map<String, dynamic>?;

    // Novo formato: {materials: List<MaterialModel>, quantities: Map<String, int>, zones: List<ProjectCardModel>?}
    if (extra.containsKey('materials') && extra.containsKey('quantities')) {
      final materialsList = extra['materials'];
      final quantities = extra['quantities'];
      final zonesList = extra['zones'];

      final materials = _convertToMaterialList(materialsList);
      final quantitiesMap = _convertToQuantitiesMap(quantities);
      final zones = _convertToZonesList(zonesList);

      if (materials != null && quantitiesMap != null) {
        final materialQuantities = <MaterialModel, int>{};
        for (final material in materials) {
          final quantity = quantitiesMap[material.id.toString()] ?? 1;
          materialQuantities[material] = quantity;
        }

        final result = NavigationData(
          selectedMaterials: materials,
          materialQuantities: materialQuantities,
          selectedZones: zones, // Incluir zonas se disponíveis
          projectData: projectData,
        );

        return result;
      }
    }

    // Formato antigo: {materials: List<MaterialModel>, zones: List<ProjectCardModel>}
    if (extra.containsKey('materials') || extra.containsKey('zones')) {
      return NavigationData(
        selectedMaterials: extra['materials'] as List<MaterialModel>?,
        materialQuantities: null,
        selectedZones: extra['zones'] as List<ProjectCardModel>?,
        projectData: projectData,
      );
    }

    return NavigationData.empty();
  }

  List<MaterialModel>? _convertToMaterialList(dynamic materialsList) {
    if (materialsList is! List) return null;

    return materialsList.map((item) {
      if (item is Map<String, dynamic>) {
        return MaterialModel.fromJson(item);
      }
      return item as MaterialModel;
    }).toList();
  }

  Map<String, int>? _convertToQuantitiesMap(dynamic quantities) {
    if (quantities is! Map) return null;
    return Map<String, int>.from(quantities);
  }

  List<ProjectCardModel>? _convertToZonesList(dynamic zonesList) {
    if (zonesList == null) return null;

    if (zonesList is List) {
      try {
        return zonesList
            .map(
              (zone) => ProjectCardModel.fromJson(zone as Map<String, dynamic>),
            )
            .toList();
      } catch (e) {
        return null;
      }
    }

    return null;
  }
}

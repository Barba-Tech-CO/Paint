import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/navigation_data.dart';
import '../../model/material_models/material_model.dart';
import '../../model/projects/project_card_model.dart';

class NavigationUseCase {
  /// Navega para OverviewZonesView com dados processados
  void navigateToOverviewZones(
    BuildContext context, {
    List<MaterialModel>? materials,
    Map<MaterialModel, int>? quantities,
    List<ProjectCardModel>? zones,
    Map<String, dynamic>? projectData,
  }) {
    final extra = _buildNavigationExtra(
      materials: materials,
      quantities: quantities,
      zones: zones,
      projectData: projectData,
    );

    context.go('/overview-zones', extra: extra);
  }

  /// Navega para OverviewZonesView com dados já processados
  void navigateToOverviewZonesWithData(
    BuildContext context,
    NavigationData data, {
    Map<String, dynamic>? projectData,
  }) {
    final extra = _buildNavigationExtra(
      materials: data.selectedMaterials,
      quantities: data.materialQuantities,
      zones: data.selectedZones,
      projectData: projectData,
    );

    context.go('/overview-zones', extra: extra);
  }

  /// Navega para SelectMaterialView
  void navigateToSelectMaterial(
    BuildContext context, {
    Map<String, dynamic>? projectData,
  }) {
    context.go('/select-material', extra: projectData);
  }

  /// Navega para ZonesView
  void navigateToZones(
    BuildContext context, {
    Map<String, dynamic>? zoneData,
  }) {
    context.go('/zones', extra: zoneData);
  }

  /// Navega para CameraView
  void navigateToCamera(
    BuildContext context, {
    Map<String, dynamic>? projectData,
  }) {
    context.go('/camera', extra: projectData);
  }

  /// Navega para RoomPlanView
  void navigateToRoomPlan(
    BuildContext context, {
    required List<String> photos,
    Map<String, dynamic>? projectData,
  }) {
    final extra = {
      'photos': photos,
      'projectData': projectData,
    };
    context.go('/roomplan', extra: extra);
  }

  /// Navega para CreateProjectView
  void navigateToCreateProject(BuildContext context) {
    context.go('/create-project');
  }

  /// Navega para ContactsView
  void navigateToContacts(BuildContext context) {
    context.go('/contacts');
  }

  /// Navega para ProjectsView
  void navigateToProjects(BuildContext context) {
    context.go('/projects');
  }

  /// Navega para QuotesView
  void navigateToQuotes(BuildContext context) {
    context.go('/quotes');
  }

  /// Navega para HomeView
  void navigateToHome(BuildContext context) {
    context.go('/home');
  }

  /// Volta para a tela anterior
  void goBack(BuildContext context) {
    context.pop();
  }

  /// Constrói o extra para navegação baseado nos parâmetros fornecidos
  Map<String, dynamic> _buildNavigationExtra({
    List<MaterialModel>? materials,
    Map<MaterialModel, int>? quantities,
    List<ProjectCardModel>? zones,
    Map<String, dynamic>? projectData,
  }) {
    final extra = <String, dynamic>{};

    // Adicionar projectData se disponível
    if (projectData != null) {
      extra['projectData'] = projectData;
    }

    // Se temos materiais e quantidades, usar o novo formato
    if (materials != null && quantities != null) {
      extra['materials'] = materials.map((m) => m.toJson()).toList();
      extra['quantities'] = _convertQuantitiesToStringKeys(quantities);

      // Incluir zonas se disponíveis
      if (zones != null && zones.isNotEmpty) {
        extra['zones'] = zones.map((z) => z.toJson()).toList();
      }

      return extra;
    }

    // Se temos apenas materiais, usar formato simples
    if (materials != null) {
      extra['materials'] = materials.map((m) => m.toJson()).toList();
      return extra;
    }

    // Se temos zonas, usar formato com zonas
    if (zones != null) {
      extra['zones'] = zones.map((z) => z.toJson()).toList();
      return extra;
    }

    // Retornar dados do projeto se disponível
    return extra;
  }

  Map<String, int> _convertQuantitiesToStringKeys(
    Map<MaterialModel, int> quantities,
  ) {
    final result = <String, int>{};
    for (final entry in quantities.entries) {
      result[entry.key.id.toString()] = entry.value;
    }
    return result;
  }
}

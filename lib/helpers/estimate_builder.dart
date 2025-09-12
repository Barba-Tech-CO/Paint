import '../model/estimates/estimate_model.dart';
import '../model/estimates/estimate_status.dart';
import '../model/estimates/estimate_totals_model.dart';
import '../model/estimates/floor_dimensions_model.dart';
import '../model/estimates/material_item_model.dart';
import '../model/estimates/project_type.dart';
import '../model/estimates/surface_areas_model.dart';
import '../model/estimates/zone_data_model.dart';
import '../model/estimates/zone_model.dart';
import '../model/projects/project_card_model.dart';
import '../service/photo_service.dart';
import '../viewmodel/overview_zones_viewmodel.dart';

/// Helper class for building EstimateModel from UI data
class EstimateBuilder {
  final PhotoService _photoService;

  EstimateBuilder(this._photoService);

  /// Builds an EstimateModel from the collected UI data
  EstimateModel buildEstimateModel(OverviewZonesViewModel viewModel) {
    // Convert ProjectCardModel zones to ZoneModel
    final zones = viewModel.selectedZones.map((projectZone) {
      return _buildZoneModel(projectZone);
    }).toList();

    // Convert MaterialModel to MaterialItemModel
    final materials = viewModel.selectedMaterials.map((material) {
      return MaterialItemModel(
        id: material.id,
        unit: material.priceUnit,
        quantity: 1.0, // Default quantity
        unitPrice: material.price,
      );
    }).toList();

    // Create totals
    final totals = EstimateTotalsModel(
      materialsCost: viewModel.totalMaterialsCost,
      grandTotal: viewModel.totalProjectCost,
    );

    return EstimateModel(
      projectName:
          'Project ${DateTime.now().millisecondsSinceEpoch}', // Default name
      contactId: 'default-contact-id', // Should come from contact selection
      additionalNotes: '',
      projectType: ProjectType.residential, // Default type
      status: EstimateStatus.draft,
      paintableArea: _extractTotalArea(viewModel),
      zones: zones,
      materials: materials,
      totals: totals,
    );
  }

  /// Builds a ZoneModel from a ProjectCardModel
  ZoneModel _buildZoneModel(ProjectCardModel projectZone) {
    // Extract floor dimensions from project zone
    final floorDimensions = FloorDimensionsModel(
      length: 12.0, // Default values - should come from actual measurements
      width: 10.0,
      height: 8.0,
      unit: 'ft',
    );

    // Create surface areas - default values for now
    final surfaceAreas = SurfaceAreasModel(
      values: {
        'walls': 320.0,
        'ceiling': 120.0,
        'trim': 40.0,
      },
    );

    // Create zone data with photos from PhotoService
    final photoPaths = _photoService.getPhotosForZone(
      projectZone.id.toString(),
    );
    final zoneData = ZoneDataModel(
      floorDimensions: floorDimensions,
      surfaceAreas: surfaceAreas,
      photoPaths: photoPaths,
    );

    return ZoneModel(
      id: projectZone.id.toString(),
      name: projectZone.title,
      zoneType: _getZoneTypeFromProject(projectZone),
      data: [zoneData],
    );
  }

  /// Maps project type to zone type
  String _getZoneTypeFromProject(ProjectCardModel project) {
    if (project.title.toLowerCase().contains('interior')) return 'interior';
    if (project.title.toLowerCase().contains('exterior')) return 'exterior';
    return 'both'; // Default
  }

  /// Extracts total area from selected zones
  double _extractTotalArea(OverviewZonesViewModel viewModel) {
    if (viewModel.selectedZones.isNotEmpty) {
      return viewModel.selectedZones.fold(0.0, (sum, zone) {
        final areaStr = zone.floorAreaValue.replaceAll(' sq ft', '');
        return sum + (double.tryParse(areaStr) ?? 0.0);
      });
    }
    return 631.0; // Default area
  }
}

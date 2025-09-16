import 'package:flutter/foundation.dart';

import '../../domain/repository/estimate_repository.dart';
import '../../model/estimates/estimate_model.dart';
import '../../model/estimates/estimate_status.dart';
import '../../model/estimates/estimate_totals_model.dart';
import '../../model/estimates/floor_dimensions_model.dart';
import '../../model/estimates/material_item_model.dart';
import '../../model/estimates/surface_areas_model.dart';
import '../../model/estimates/zone_data_model.dart';
import '../../model/estimates/zone_model.dart';
import '../../model/projects/project_card_model.dart';
import '../../service/photo_service.dart';
import '../../utils/result/result.dart';
import '../../viewmodel/overview_zones_viewmodel.dart';

class EstimateCalculationViewModel extends ChangeNotifier {
  final IEstimateRepository _estimateRepository;
  final PhotoService _photoService;

  EstimateModel? _currentEstimate;
  bool _isCalculating = false;
  String? _error;
  double _totalCost = 0.0;
  double _totalArea = 0.0;

  EstimateCalculationViewModel(this._estimateRepository, this._photoService);

  // Getters
  EstimateModel? get currentEstimate => _currentEstimate;
  bool get isCalculating => _isCalculating;
  String? get error => _error;
  double get totalCost => _totalCost;
  double get totalArea => _totalArea;

  /// Seleciona elementos e calcula custos
  Future<bool> selectElementsAndCalculate(
    String estimateId,
    List<String> elementIds,
  ) async {
    _setCalculating(true);
    _clearError();

    try {
      final result = await _estimateRepository.selectElements(
        estimateId,
        elementIds,
      );

      if (result is Ok) {
        final data = result.asOk.value;
        // Extract relevant data from the Map<String, dynamic>
        _totalCost = (data['totalCost'] as num?)?.toDouble() ?? 0.0;
        _totalArea = (data['totalArea'] as num?)?.toDouble() ?? 0.0;
        notifyListeners();
        return true;
      } else if (result is Error) {
        _setError(result.asError.error.toString());
      }
      return false;
    } catch (e) {
      _setError('Error calculating estimate: $e');
      return false;
    } finally {
      _setCalculating(false);
    }
  }

  /// Atualiza os cálculos baseado no orçamento atual
  void _updateCalculations() {
    if (_currentEstimate == null) return;

    _totalCost = _currentEstimate!.totalCost ?? 0.0;
    _totalArea = _currentEstimate!.totalArea ?? 0.0;
  }

  /// Define o orçamento atual
  void setCurrentEstimate(EstimateModel estimate) {
    _currentEstimate = estimate;
    _updateCalculations();
    notifyListeners();
  }

  /// Limpa o orçamento atual
  void clearCurrentEstimate() {
    _currentEstimate = null;
    _totalCost = 0.0;
    _totalArea = 0.0;
    // Clear photos when clearing estimate
    _photoService.clearPhotos();
    notifyListeners();
  }

  /// Obtém o custo formatado
  String get formattedTotalCost {
    return '\$${_totalCost.toStringAsFixed(2)}';
  }

  /// Obtém a área formatada
  String get formattedTotalArea {
    return '${_totalArea.toStringAsFixed(2)} sqft';
  }

  /// Adiciona uma foto ao serviço
  Future<void> addPhoto(String photoPath) async {
    await _photoService.addPhoto(photoPath);
    notifyListeners();
  }

  /// Remove uma foto do serviço
  void removePhoto(String photoPath) {
    _photoService.removePhoto(photoPath);
    notifyListeners();
  }

  /// Obtém as fotos capturadas
  List<String> get capturedPhotos => _photoService.capturedPhotos;

  /// Verifica se há fotos disponíveis
  bool get hasPhotos => _photoService.hasPhotos;

  // Métodos privados para gerenciar estado
  void _setCalculating(bool calculating) {
    _isCalculating = calculating;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Migrated from EstimateBuilder
  /// Builds an EstimateModel from the collected UI data
  Future<EstimateModel> buildEstimateModel({
    required OverviewZonesViewModel viewModel,
    required String projectName,
    required String contactId,
    required String additionalNotes,
    required EstimateStatus status,
    required String zoneType, // From radio button in "New Project" screen
  }) async {
    // Initialize mock photos if no photos are available
    if (!_photoService.hasPhotos) {
      await _photoService.initializeMockPhotos();
    }
    // Convert ProjectCardModel zones to ZoneModel
    final zones = viewModel.selectedZones.map((projectZone) {
      return _buildZoneModel(projectZone, zoneType: zoneType);
    }).toList();

    // Convert MaterialModel to MaterialItemModel with user-provided quantities
    final materials = viewModel.selectedMaterials.map((material) {
      return MaterialItemModel(
        id: material.id,
        unit: material.priceUnit,
        quantity:
            1.0, // TODO: Use material.quantity when field is added to MaterialModel
        unitPrice: material.price,
      );
    }).toList();

    // Create totals
    final totals = EstimateTotalsModel(
      materialsCost: viewModel.totalMaterialsCost,
      grandTotal: viewModel.totalProjectCost,
    );

    return EstimateModel(
      projectName: projectName,
      contactId: contactId,
      additionalNotes: additionalNotes,
      status: status,
      paintableArea: _extractTotalArea(viewModel),
      zones: zones,
      materials: materials,
      totals: totals,
    );
  }

  /// Builds a ZoneModel from a ProjectCardModel
  ZoneModel _buildZoneModel(
    ProjectCardModel projectZone, {
    required String zoneType,
  }) {
    // Extract floor dimensions from project zone
    final floorDimensionsStr = projectZone.floorDimensionValue;
    final dimensionsParts = floorDimensionsStr.split(' x ');

    double width = 0.0;
    double length = 0.0;

    if (dimensionsParts.length == 2) {
      width = double.tryParse(dimensionsParts[0].trim()) ?? 0.0;
      length = double.tryParse(dimensionsParts[1].trim()) ?? 0.0;
    }

    final floorDimensions = FloorDimensionsModel(
      width: width,
      length: length,
    );

    // Extract areas from project zone
    final paintableAreaStr = projectZone.areaPaintable;
    final paintableArea = double.tryParse(paintableAreaStr) ?? 0.0;

    final ceilingAreaStr = projectZone.ceilingArea ?? '0';
    final ceilingArea = double.tryParse(ceilingAreaStr) ?? 0.0;

    final surfaceAreas = SurfaceAreasModel(
      values: {
        'walls': paintableArea,
        'ceiling': ceilingArea,
      },
    );

    // Extract photos using PhotoService
    final photoPaths =
        projectZone.roomPlanData?['photos'] as List<dynamic>? ?? [];
    final photos = photoPaths.map((photo) => photo.toString()).toList();

    // Add photos from PhotoService if available
    final servicePhotos = _photoService.getPhotosForZone(
      projectZone.id.toString(),
    );
    photos.addAll(servicePhotos);

    final zoneData = ZoneDataModel(
      floorDimensions: floorDimensions,
      surfaceAreas: surfaceAreas,
      photoPaths: photos,
    );

    return ZoneModel(
      id: projectZone.id.toString(),
      name: projectZone.title,
      zoneType: zoneType,
      data: [zoneData],
    );
  }

  /// Extracts total area from view model
  double _extractTotalArea(OverviewZonesViewModel viewModel) {
    double totalArea = 0.0;

    for (final zone in viewModel.selectedZones) {
      final areaStr = zone.areaPaintable;
      final area = double.tryParse(areaStr) ?? 0.0;
      totalArea += area;
    }

    return totalArea;
  }
}

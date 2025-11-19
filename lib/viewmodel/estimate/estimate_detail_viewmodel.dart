import 'package:flutter/foundation.dart';

import '../../model/estimates/estimate_detail_model.dart';
import '../../use_case/estimate/estimate_detail_use_case.dart';
import '../../domain/repository/material_repository.dart';
import '../../utils/result/result.dart';

class EstimateDetailViewModel extends ChangeNotifier {
  final EstimateDetailUseCase _estimateDetailUseCase;
  final IMaterialRepository _materialRepository;

  EstimateDetailViewModel(
    this._estimateDetailUseCase,
    this._materialRepository,
  );

  // State
  EstimateDetailModel? _estimateDetail;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  // Getters
  EstimateDetailModel? get estimateDetail => _estimateDetail;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;
  bool get hasError => _error != null;
  bool get hasData => _estimateDetail != null;

  /// Load estimate details by estimate ID
  Future<void> loadEstimateDetail(int estimateId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _estimateDetailUseCase.getEstimateDetail(estimateId);
      if (result is Ok) {
        _estimateDetail = result.asOk.value;
        _isInitialized = true;
        notifyListeners();
      } else {
        _setError(result.asError.error.toString());
      }
    } catch (e) {
      _setError('Error loading estimate details: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load estimate details by project ID
  Future<void> loadEstimateDetailByProjectId(int projectId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _estimateDetailUseCase.getEstimateDetailByProjectId(
        projectId,
      );
      if (result is Ok) {
        _estimateDetail = result.asOk.value;
        _isInitialized = true;
        notifyListeners();
      } else {
        _setError(result.asError.error.toString());
      }
    } catch (e) {
      _setError('Error loading estimate details: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load estimate for overview (convenience method)
  Future<void> loadEstimateForOverview(int projectId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _estimateDetailUseCase.getEstimateForOverview(
        projectId,
      );
      if (result is Ok) {
        _estimateDetail = result.asOk.value;
        _isInitialized = true;
        notifyListeners();
      } else {
        _setError(result.asError.error.toString());
      }
    } catch (e) {
      _setError('Error loading estimate for overview: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh estimate details
  Future<void> refresh() async {
    if (_estimateDetail != null) {
      final estimateId = _estimateDetail!.id;
      await loadEstimateDetail(estimateId);
    }
  }

  /// Clear all data
  void clear() {
    _estimateDetail = null;
    _isLoading = false;
    _error = null;
    _isInitialized = false;
    notifyListeners();
  }

  /// Get formatted total cost
  String getFormattedTotalCost() {
    if (_estimateDetail == null) return '\$0.00';

    // If total_cost is 0, use materials cost instead
    if (_estimateDetail!.totalCost == 0.0) {
      return getFormattedMaterialsCost();
    }

    return '\$${_estimateDetail!.totalCost.toStringAsFixed(2)}';
  }

  /// Get formatted materials cost
  String getFormattedMaterialsCost() {
    if (_estimateDetail == null) return '\$0.00';
    return '\$${_estimateDetail!.totals.materialsCost.toStringAsFixed(2)}';
  }

  /// Get formatted labor cost
  String getFormattedLaborCost() {
    if (_estimateDetail == null) return '\$0.00';
    return '\$${_estimateDetail!.totals.laborCost.toStringAsFixed(2)}';
  }

  /// Get total area
  double getTotalArea() {
    if (_estimateDetail == null) return 0.0;

    // Calculate total area from zones
    double totalArea = 0.0;
    for (final zone in _estimateDetail!.zones) {
      totalArea += zone.area;
    }

    // If no zones, try to get from materials calculation
    if (totalArea == 0.0) {
      totalArea = _estimateDetail!.materialsCalculation.totalArea;
    }

    return totalArea;
  }

  /// Get formatted total area
  String getFormattedTotalArea() {
    final area = getTotalArea();
    return '${area.toStringAsFixed(1)} sq ft';
  }

  /// Get zones count
  int getZonesCount() {
    if (_estimateDetail == null) return 0;
    return _estimateDetail!.zones.length;
  }

  /// Get materials count
  int getMaterialsCount() {
    if (_estimateDetail == null) return 0;
    return _estimateDetail!.materials.length;
  }

  /// Get project name
  String getProjectName() {
    if (_estimateDetail == null) return '';
    return _estimateDetail!.projectName;
  }

  /// Get client name
  String getClientName() {
    if (_estimateDetail == null) return '';
    return _estimateDetail!.clientName;
  }

  /// Get project type
  String getProjectType() {
    if (_estimateDetail == null) return '';
    return _estimateDetail!.projectType.name;
  }

  /// Get status
  String getStatus() {
    if (_estimateDetail == null) return '';
    return _estimateDetail!.status.name;
  }

  /// Get additional notes
  String getAdditionalNotes() {
    if (_estimateDetail == null) return '';
    return _estimateDetail!.additionalNotes;
  }

  /// Get wall condition
  String getWallCondition() {
    if (_estimateDetail == null) return '';
    return _estimateDetail!.wallCondition;
  }

  /// Check if has accent wall
  bool getHasAccentWall() {
    if (_estimateDetail == null) return false;
    return _estimateDetail!.hasAccentWall;
  }

  /// Get paint type (derived from materials)
  String getPaintType() {
    if (_estimateDetail == null || _estimateDetail!.materials.isEmpty) {
      return 'Not specified';
    }

    // Get the first paint material type
    final paintMaterials = _estimateDetail!.materials
        .where((material) => material.type == 'paint')
        .toList();

    if (paintMaterials.isNotEmpty) {
      return paintMaterials.first.product;
    }

    return 'Not specified';
  }

  /// Get formatted zones list
  List<String> getFormattedZones() {
    if (_estimateDetail == null) return [];
    return _estimateDetail!.zones.map((zone) => zone.name).toList();
  }

  /// Get material name by ID
  Future<String> getMaterialNameById(String materialId) async {
    try {
      final result = await _materialRepository.getMaterialById(materialId);
      if (result is Ok && result.asOk.value != null) {
        return result.asOk.value!.name;
      }
    } catch (e) {
      // Swallow error and return default below
    }
    return 'Unknown Material';
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
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
}

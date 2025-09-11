import 'dart:io';

import 'package:flutter/foundation.dart';

import '../model/estimates/estimate_create_request.dart';
import '../model/estimates/estimate_model.dart';
import '../model/estimates/estimate_totals.dart';
import '../model/estimates/floor_dimensions.dart';
import '../model/estimates/material_create_item.dart';
import '../model/estimates/surface/surface_areas.dart';
import '../model/estimates/zones/zone_create_model.dart';
import '../model/estimates/zones/zone_type.dart';
import '../use_case/estimates/estimate_creation_use_case.dart';
import '../utils/logger/app_logger.dart';
import '../utils/result/result.dart';

/// ViewModel for managing estimate creation state and business logic
class EstimateCreationViewModel extends ChangeNotifier {
  final EstimateCreationUseCase _estimateCreationUseCase;
  final AppLogger _logger;

  EstimateCreationViewModel(
    this._estimateCreationUseCase,
    this._logger,
  );

  // State management
  bool _isLoading = false;
  String? _error;
  EstimateModel? _createdEstimate;

  // Form data
  String _contactId = '';
  String _projectName = '';
  String _additionalNotes = '';
  final List<ZoneCreateModel> _zones = [];
  final List<MaterialCreateItem> _materials = [];
  EstimateTotals _totals = EstimateTotals(materialsCost: 0, grandTotal: 0);

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  EstimateModel? get createdEstimate => _createdEstimate;

  String get contactId => _contactId;
  String get projectName => _projectName;
  String get additionalNotes => _additionalNotes;
  List<ZoneCreateModel> get zones => List.unmodifiable(_zones);
  List<MaterialCreateItem> get materials => List.unmodifiable(_materials);
  EstimateTotals get totals => _totals;

  // Form state getters
  bool get hasValidBasicInfo =>
      _contactId.isNotEmpty && _projectName.trim().length >= 3;
  bool get hasZones => _zones.isNotEmpty;
  bool get hasMaterials => _materials.isNotEmpty;
  bool get isFormValid => hasValidBasicInfo && hasZones && hasMaterials;

  /// Sets the loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Sets error state
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Clears any existing error
  void clearError() {
    _setError(null);
  }

  /// Sets basic estimate information
  void setBasicInfo({
    required String contactId,
    required String projectName,
    String additionalNotes = '',
  }) {
    _contactId = contactId.trim();
    _projectName = projectName.trim();
    _additionalNotes = additionalNotes.trim();
    clearError();
    notifyListeners();
  }

  /// Adds a new zone to the estimate
  void addZone(ZoneCreateModel zone) {
    // Ensure only the first zone has zone_type
    final zoneToAdd = _zones.isEmpty
        ? zone
        : ZoneCreateModel(
            id: zone.id,
            name: zone.name,
            zoneType: null, // Clear zone type for subsequent zones
            floorDimensions: zone.floorDimensions,
            surfaceAreas: zone.surfaceAreas,
            photos: zone.photos,
          );

    _zones.add(zoneToAdd);
    clearError();
    notifyListeners();
  }

  /// Updates an existing zone
  void updateZone(int index, ZoneCreateModel zone) {
    if (index >= 0 && index < _zones.length) {
      // Preserve zone_type for first zone only
      final zoneToUpdate = index == 0
          ? zone
          : ZoneCreateModel(
              id: zone.id,
              name: zone.name,
              zoneType: null,
              floorDimensions: zone.floorDimensions,
              surfaceAreas: zone.surfaceAreas,
              photos: zone.photos,
            );

      _zones[index] = zoneToUpdate;
      clearError();
      notifyListeners();
    }
  }

  /// Removes a zone by index
  void removeZone(int index) {
    if (index >= 0 && index < _zones.length) {
      _zones.removeAt(index);

      // If we removed the first zone and there are others,
      // ensure the new first zone has a zone_type
      if (index == 0 && _zones.isNotEmpty && _zones.first.zoneType == null) {
        final firstZone = _zones.first;
        _zones[0] = ZoneCreateModel(
          id: firstZone.id,
          name: firstZone.name,
          zoneType: ZoneType.interior, // Default zone type
          floorDimensions: firstZone.floorDimensions,
          surfaceAreas: firstZone.surfaceAreas,
          photos: firstZone.photos,
        );
      }

      clearError();
      notifyListeners();
    }
  }

  /// Adds a material to the estimate
  void addMaterial(MaterialCreateItem material) {
    _materials.add(material);
    _calculateTotals();
    clearError();
    notifyListeners();
  }

  /// Updates an existing material
  void updateMaterial(int index, MaterialCreateItem material) {
    if (index >= 0 && index < _materials.length) {
      _materials[index] = material;
      _calculateTotals();
      clearError();
      notifyListeners();
    }
  }

  /// Removes a material by index
  void removeMaterial(int index) {
    if (index >= 0 && index < _materials.length) {
      _materials.removeAt(index);
      _calculateTotals();
      clearError();
      notifyListeners();
    }
  }

  /// Sets custom totals (overrides calculated totals)
  void setCustomTotals(EstimateTotals totals) {
    _totals = totals;
    clearError();
    notifyListeners();
  }

  /// Calculates totals based on materials
  void _calculateTotals() {
    final materialsCost = _materials.fold<num>(
      0,
      (sum, material) => sum + (material.quantity * material.unitPrice),
    );

    _totals = EstimateTotals(
      materialsCost: materialsCost,
      grandTotal: materialsCost, // Can be overridden by setCustomTotals
      laborCost: _totals.laborCost,
      additionalCosts: _totals.additionalCosts,
    );
  }

  /// Creates the estimate using the multipart upload
  Future<Result<void>> createEstimate() async {
    if (!isFormValid) {
      _setError('Please fill in all required fields');
      return Result.error(
        Exception('Please fill in all required fields'),
      );
    }

    _setLoading(true);
    _setError(null);

    try {
      final request = EstimateCreateRequest(
        contactId: _contactId,
        projectName: _projectName,
        additionalNotes: _additionalNotes.isNotEmpty ? _additionalNotes : null,
        zones: _zones,
        materials: _materials,
        totals: _totals,
      );

      final result = await _estimateCreationUseCase.createEstimateMultipart(
        request,
      );

      return result.when(
        ok: (estimate) {
          _createdEstimate = estimate;
          _setError(null);
          return Result.ok(null);
        },
        error: (error) {
          // Log technical error
          _logger.error('Estimate creation failed: $error');
          // Show user-friendly message
          _setError('Failed to create estimate. Please try again.');
          return Result.error(error);
        },
      );
    } catch (e) {
      // Log technical error
      _logger.error('Unexpected error in createEstimate: $e');
      // Show user-friendly message
      _setError('Unexpected error. Please try again.');
      return Result.error(
        Exception('Unexpected error'),
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Resets the form to initial state
  void resetForm() {
    _contactId = '';
    _projectName = '';
    _additionalNotes = '';
    _zones.clear();
    _materials.clear();
    _totals = EstimateTotals(materialsCost: 0, grandTotal: 0);
    _createdEstimate = null;
    _setError(null);
    notifyListeners();
  }

  /// Creates a sample zone for testing/demonstration
  ZoneCreateModel createSampleZone({
    required String id,
    required String name,
    ZoneType? zoneType,
    required List<File> photos,
  }) {
    return ZoneCreateModel(
      id: id,
      name: name,
      zoneType: zoneType,
      floorDimensions: FloorDimensions(
        length: 10,
        width: 12,
        height: 8,
        unit: 'ft',
      ),
      surfaceAreas: SurfaceAreas(
        walls: [],
        ceiling: [],
        trim: [],
      ),
      photos: photos,
    );
  }

  /// Creates a sample material for testing/demonstration
  MaterialCreateItem createSampleMaterial({
    required String id,
    required String name,
    required String unit,
    required num quantity,
    required num unitPrice,
  }) {
    return MaterialCreateItem(
      id: id,
      name: name,
      unit: unit,
      quantity: quantity,
      unitPrice: unitPrice,
    );
  }
}

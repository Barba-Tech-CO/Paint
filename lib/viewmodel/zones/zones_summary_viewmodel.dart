import 'package:flutter/foundation.dart';

import '../../model/projects/project_card_model.dart';
import '../../model/projects/projects_summary_model.dart';
import '../../utils/command/command.dart';
import '../../utils/result/result.dart';

enum ZonesSummaryState { initial, loading, loaded, error }

class ZonesSummaryViewModel extends ChangeNotifier {
  // Service seria injetado aqui quando estiver pronto
  // final ZonesService _zonesService;

  // State
  ZonesSummaryState _state = ZonesSummaryState.initial;
  ZonesSummaryState get state => _state;

  // Data
  ProjectsSummaryModel? _summary;
  ProjectsSummaryModel? get summary => _summary;

  List<ProjectCardModel> _zones = [];

  // Error
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Commands
  Command0<void>? _loadSummaryCommand;

  Command0<void> get loadSummaryCommand => _loadSummaryCommand!;

  // Computed properties
  bool get isLoading =>
      _state == ZonesSummaryState.initial ||
      _state == ZonesSummaryState.loading ||
      (_loadSummaryCommand?.running ?? false);
  bool get hasError =>
      _state == ZonesSummaryState.error || _errorMessage != null;
  bool get hasSummary => _summary != null;
  bool get isInitialized => _loadSummaryCommand != null;

  // Initialize
  void initialize() {
    if (!isInitialized) {
      _initializeCommands();
      loadSummary();
    }
  }

  void _initializeCommands() {
    _loadSummaryCommand = Command0(() async {
      return await _loadSummaryData();
    });
  }

  // Public methods
  Future<void> loadSummary() async {
    if (_loadSummaryCommand != null) {
      await _loadSummaryCommand!.execute();
    }
  }

  void updateZonesList(List<ProjectCardModel> zones) {
    _zones = List.from(zones);
    // Recalculate summary when zones list changes
    _calculateSummaryFromZones();
  }

  void refresh() {
    _clearError();
    loadSummary();
  }

  // Private methods
  Future<Result<void>> _loadSummaryData() async {
    try {
      _setState(ZonesSummaryState.loading);
      _clearError();

      // Calcula baseado nas zonas atuais
      _calculateSummaryFromZones();
      _setState(ZonesSummaryState.loaded);

      return Result.ok(null);
    } catch (e) {
      _setError('Erro ao carregar resumo: $e');
      _setState(ZonesSummaryState.error);
      return Result.error(Exception(e.toString()));
    }
  }

  void _calculateSummaryFromZones() {
    if (_zones.isEmpty) {
      _summary = ProjectsSummaryModel(
        avgDimensions: "0' x 0'",
        totalArea: "0 sq ft",
        totalPaintable: "0 sq ft",
      );
    } else {
      int count = _zones.length;
      double sumArea = 0;
      double sumPaintable = 0;
      double sumWidth = 0;
      double sumLength = 0;

      for (final z in _zones) {
        // Parse areas (should already be in sq ft from RoomPlan conversion)
        sumArea += _parseSqFt(z.floorAreaValue);
        sumPaintable += _parseSqFt(z.areaPaintable);
        
        // Parse dimensions (should already be in feet from RoomPlan conversion)
        final dims = _parseDimensions(z.floorDimensionValue);
        sumWidth += dims.$1;
        sumLength += dims.$2;
      }

      final avgWidth = count > 0 ? (sumWidth / count).round() : 0;
      final avgLength = count > 0 ? (sumLength / count).round() : 0;
      final totalAreaValue = sumArea.round();
      final totalPaintableValue = sumPaintable.round();

      _summary = ProjectsSummaryModel(
        avgDimensions: "$avgWidth' x $avgLength'",
        totalArea: "$totalAreaValue sq ft",
        totalPaintable: "$totalPaintableValue sq ft",
      );
    }

    notifyListeners();
  }

  // Helpers de parse
  double _parseSqFt(String value) {
    if (value.isEmpty) return 0.0;
    
    // Remove all non-numeric characters except decimal point
    final numStr = value.replaceAll(RegExp(r'[^0-9\.]'), '');
    return double.tryParse(numStr) ?? 0.0;
  }

  (double, double) _parseDimensions(String value) {
    if (value.isEmpty) return (0.0, 0.0);
    
    // Remove apostrophes and split by 'x'
    final cleaned = value.replaceAll("'", '').replaceAll('ft', '').trim();
    final parts = cleaned.split('x');
    
    if (parts.length >= 2) {
      final w = double.tryParse(parts[0].trim()) ?? 0.0;
      final l = double.tryParse(parts[1].trim()) ?? 0.0;
      return (w, l);
    }
    return (0.0, 0.0);
  }

  // State management methods
  void _setState(ZonesSummaryState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

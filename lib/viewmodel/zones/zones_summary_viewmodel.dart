import 'package:flutter/foundation.dart';

import '../../model/projects/project_card_model.dart';
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

      // Aqui seria a chamada para o service
      // final result = await _zonesService.getSummary();

      // Simulando dados de resumo - delay para mostrar loading
      await Future.delayed(const Duration(seconds: 2));

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
      // Calculate summary based on current zones
      final zonesCount = _zones.length;

      // For mock data, using simple calculations
      // In real app, this would parse actual dimension values
      final avgWidth = 12; // Mock average
      final avgHeight = 14; // Mock average
      final totalAreaValue = zonesCount * 168; // Mock calculation
      final totalPaintableValue = zonesCount * 420; // Mock calculation

      _summary = ProjectsSummaryModel(
        avgDimensions: "$avgWidth' x $avgHeight'",
        totalArea: "$totalAreaValue sq ft",
        totalPaintable: "$totalPaintableValue sq ft",
      );
    }

    notifyListeners();
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

import 'package:flutter/foundation.dart';

import '../../helpers/zones/zone_add_data.dart';
import '../../helpers/zones/zone_data_classes.dart';
import '../../model/projects/project_card_model.dart';
import '../../model/projects/projects_summary_model.dart';
import '../../utils/command/command.dart';
import '../../utils/result/result.dart';

enum ZonesState { initial, loading, loaded, error }

class ZonesCardViewmodel extends ChangeNotifier {
  // Service seria injetado aqui quando estiver pronto
  // final ZonesService _zonesService;

  // ZonesCardViewmodel(this._zonesService);

  // State
  ZonesState _state = ZonesState.initial;
  ZonesState get state => _state;

  // Data
  List<ProjectCardModel> _zones = [];
  List<ProjectCardModel> get zones => _zones;

  ProjectsSummaryModel? _summary;
  ProjectsSummaryModel? get summary => _summary;

  ProjectCardModel? _selectedZone;
  ProjectCardModel? get selectedZone => _selectedZone;

  // Error
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ZonesCardViewmodel();

  // Commands
  late final Command0<void> _loadZonesCommand;
  late final Command1<void, int> _deleteZoneCommand;
  late final Command1<void, ZoneRenameData> _renameZoneCommand;
  late final Command1<void, ZoneAddData> _addZoneCommand;
  late final Command0<void> _loadSummaryCommand;

  Command0<void> get loadZonesCommand => _loadZonesCommand;
  Command1<void, int> get deleteZoneCommand => _deleteZoneCommand;
  Command1<void, ZoneRenameData> get renameZoneCommand => _renameZoneCommand;
  Command1<void, ZoneAddData> get addZoneCommand => _addZoneCommand;
  Command0<void> get loadSummaryCommand => _loadSummaryCommand;

  // Computed properties
  bool get isLoading =>
      _state == ZonesState.initial ||
      _state == ZonesState.loading ||
      _loadZonesCommand.running ||
      _loadSummaryCommand.running;
  bool get hasError => _state == ZonesState.error || _errorMessage != null;
  bool get hasZones => _zones.isNotEmpty;
  int get zonesCount => _zones.length;

  // Initialize
  void initialize() {
    _initializeCommands();
    loadZones();
    loadSummary();
  }

  void _initializeCommands() {
    _loadZonesCommand = Command0(() async {
      return await _loadZonesData();
    });

    _deleteZoneCommand = Command1((int zoneId) async {
      return await _deleteZoneData(zoneId);
    });

    _renameZoneCommand = Command1((ZoneRenameData data) async {
      return await _renameZoneData(data.zoneId, data.newName);
    });

    _addZoneCommand = Command1((ZoneAddData data) async {
      return await _addZoneData(data);
    });

    _loadSummaryCommand = Command0(() async {
      return await _loadSummaryData();
    });
  }

  // Public methods
  Future<void> loadZones() async {
    await _loadZonesCommand.execute();
  }

  Future<void> deleteZone(int zoneId) async {
    await _deleteZoneCommand.execute(zoneId);
  }

  Future<void> renameZone(int zoneId, String newName) async {
    await _renameZoneCommand.execute(
      ZoneRenameData(zoneId: zoneId, newName: newName),
    );
  }

  Future<void> addZone({
    required String title,
    required String image,
    required String floorDimensionValue,
    required String floorAreaValue,
    required String areaPaintable,
    String? ceilingArea,
    String? trimLength,
    Map<String, dynamic>? roomPlanData,
  }) async {
    await _addZoneCommand.execute(
      ZoneAddData(
        title: title,
        image: image,
        floorDimensionValue: floorDimensionValue,
        floorAreaValue: floorAreaValue,
        areaPaintable: areaPaintable,
        ceilingArea: ceilingArea,
        trimLength: trimLength,
        roomPlanData: roomPlanData,
      ),
    );
  }

  Future<void> loadSummary() async {
    await _loadSummaryCommand.execute();
  }

  void selectZone(ProjectCardModel zone) {
    _selectedZone = zone;
    notifyListeners();
  }

  void clearSelection() {
    _selectedZone = null;
    notifyListeners();
  }

  void refresh() {
    _clearError();
    loadZones();
    loadSummary();
  }

  // Private data loading methods (preparados para quando o service estiver pronto)
  Future<Result<void>> _loadZonesData() async {
    try {
      _setState(ZonesState.loading);
      _clearError();

      // Não há API de zonas: iniciar vazio e aguardar adições do usuário
      _zones = [];
      _setState(ZonesState.loaded);

      return Result.ok(null);
    } catch (e) {
      _setError('Erro ao carregar zonas: $e');
      _setState(ZonesState.error);
      return Result.error(Exception(e.toString()));
    }
  }

  Future<Result<void>> _deleteZoneData(int zoneId) async {
    try {
      // Aqui seria a chamada para o service
      // final result = await _zonesService.deleteZone(zoneId);

      // Simulando exclusão
      await Future.delayed(const Duration(milliseconds: 300));

      _zones.removeWhere((zone) => zone.id == zoneId);

      // Se a zona selecionada foi excluída, limpar seleção
      if (_selectedZone?.id == zoneId) {
        _selectedZone = null;
      }

      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      _setError('Erro ao excluir zona: $e');
      return Result.error(Exception(e.toString()));
    }
  }

  Future<Result<void>> _renameZoneData(int zoneId, String newName) async {
    try {
      // Aqui seria a chamada para o service
      // final result = await _zonesService.renameZone(zoneId, newName);

      // Simulando renomeação
      await Future.delayed(const Duration(milliseconds: 300));

      final zoneIndex = _zones.indexWhere((zone) => zone.id == zoneId);
      if (zoneIndex != -1) {
        _zones[zoneIndex] = _zones[zoneIndex].copyWith(title: newName);

        // Atualizar zona selecionada se for a mesma
        if (_selectedZone?.id == zoneId) {
          _selectedZone = _zones[zoneIndex];
        }
      }

      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      _setError('Erro ao renomear zona: $e');
      return Result.error(Exception(e.toString()));
    }
  }

  Future<Result<void>> _addZoneData(ZoneAddData data) async {
    try {
      // Aqui seria a chamada para o service
      // final result = await _zonesService.addZone(data);

      // Simulando adição
      await Future.delayed(const Duration(milliseconds: 500));

      // Gerar novo ID (seria retornado pelo service)
      final newId = _zones.isNotEmpty
          ? _zones.map((z) => z.id).reduce((a, b) => a > b ? a : b) + 1
          : 1;

      final newZone = ProjectCardModel(
        id: newId,
        title: data.title,
        image: data.image,
        floorDimensionValue: data.floorDimensionValue,
        floorAreaValue: data.floorAreaValue,
        areaPaintable: data.areaPaintable,
        ceilingArea: data.ceilingArea,
        trimLength: data.trimLength,
        roomPlanData: data.roomPlanData,
      );

      _zones.add(newZone);

      // Atualizar resumo após adicionar zona
      await _loadSummaryData();

      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      _setError('Erro ao adicionar zona: $e');
      return Result.error(Exception(e.toString()));
    }
  }

  Future<Result<void>> _loadSummaryData() async {
    try {
      int count = _zones.length;
      double sumArea = 0;
      double sumPaintable = 0;
      double sumWidth = 0;
      double sumLength = 0;

      for (final z in _zones) {
        sumArea += _parseSqFt(z.floorAreaValue);
        sumPaintable += _parseSqFt(z.areaPaintable);
        final dims = _parseDimensions(z.floorDimensionValue);
        sumWidth += dims.$1;
        sumLength += dims.$2;
      }

      final avgWidth = count > 0 ? (sumWidth / count).round() : 0;
      final avgLength = count > 0 ? (sumLength / count).round() : 0;
      final totalAreaStr = '${sumArea.round()} sq ft';
      final totalPaintableStr = '${sumPaintable.round()} sq ft';

      _summary = ProjectsSummaryModel(
        avgDimensions: "$avgWidth' x $avgLength'",
        totalArea: totalAreaStr,
        totalPaintable: totalPaintableStr,
      );

      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      _setError('Erro ao carregar resumo: $e');
      return Result.error(Exception(e.toString()));
    }
  }

  // Helper methods
  ProjectCardModel? getZoneById(int id) {
    try {
      return _zones.firstWhere((zone) => zone.id == id);
    } catch (e) {
      return null;
    }
  }

  List<ProjectCardModel> getZonesByTitle(String title) {
    return _zones
        .where((zone) => zone.title.toLowerCase().contains(title.toLowerCase()))
        .toList();
  }

  // Helpers de parse
  double _parseSqFt(String value) {
    final numStr = value.replaceAll(RegExp(r'[^0-9\.]'), '');
    return double.tryParse(numStr) ?? 0;
  }

  (double, double) _parseDimensions(String value) {
    final cleaned = value.replaceAll("'", '');
    final parts = cleaned.split('x');
    if (parts.length >= 2) {
      final w = double.tryParse(parts[0].trim()) ?? 0;
      final l = double.tryParse(parts[1].trim()) ?? 0;
      return (w, l);
    }
    return (0, 0);
  }

  // State management methods
  void _setState(ZonesState state) {
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

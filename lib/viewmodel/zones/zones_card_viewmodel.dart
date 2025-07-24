import 'package:flutter/foundation.dart';
import '../../model/zones_card_model.dart';
import '../../utils/result/result.dart';
import '../../utils/command/command.dart';

enum ZonesState { initial, loading, loaded, error }

class ZonesCardViewmodel extends ChangeNotifier {
  // Service seria injetado aqui quando estiver pronto
  // final ZonesService _zonesService;

  // ZonesCardViewmodel(this._zonesService);

  // State
  ZonesState _state = ZonesState.initial;
  ZonesState get state => _state;

  // Data
  List<ZonesCardModel> _zones = [];
  List<ZonesCardModel> get zones => _zones;

  ZonesSummaryModel? _summary;
  ZonesSummaryModel? get summary => _summary;

  ZonesCardModel? _selectedZone;
  ZonesCardModel? get selectedZone => _selectedZone;

  // Error
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Commands
  late final Command0<void> _loadZonesCommand;
  late final Command1<void, int> _deleteZoneCommand;
  late final Command1<void, ZoneRenameData> _renameZoneCommand;
  late final Command0<void> _loadSummaryCommand;

  Command0<void> get loadZonesCommand => _loadZonesCommand;
  Command1<void, int> get deleteZoneCommand => _deleteZoneCommand;
  Command1<void, ZoneRenameData> get renameZoneCommand => _renameZoneCommand;
  Command0<void> get loadSummaryCommand => _loadSummaryCommand;

  // Computed properties
  bool get isLoading =>
      _state == ZonesState.loading || _loadZonesCommand.running;
  bool get hasError => _state == ZonesState.error || _errorMessage != null;
  bool get hasZones => _zones.isNotEmpty;
  int get zonesCount => _zones.length;

  // Initialize
  void initialize() {
    _initializeCommands();
    loadZones();
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

  Future<void> loadSummary() async {
    await _loadSummaryCommand.execute();
  }

  void selectZone(ZonesCardModel zone) {
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

      // Simulando dados enquanto não temos o service
      await Future.delayed(const Duration(milliseconds: 500));

      final mockZones = _generateMockZones();

      _zones = mockZones;
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

  Future<Result<void>> _loadSummaryData() async {
    try {
      // Aqui seria a chamada para o service
      // final result = await _zonesService.getSummary();

      // Simulando dados de resumo
      await Future.delayed(const Duration(milliseconds: 300));

      _summary = ZonesSummaryModel(
        avgDimensions: "12' x 14'",
        totalArea: "${_zones.length * 168} sq ft",
        totalPaintable: "${_zones.length * 420} sq ft",
      );

      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      _setError('Erro ao carregar resumo: $e');
      return Result.error(Exception(e.toString()));
    }
  }

  // Helper methods
  ZonesCardModel? getZoneById(int id) {
    try {
      return _zones.firstWhere((zone) => zone.id == id);
    } catch (e) {
      return null;
    }
  }

  List<ZonesCardModel> getZonesByTitle(String title) {
    return _zones
        .where((zone) => zone.title.toLowerCase().contains(title.toLowerCase()))
        .toList();
  }

  // Mock data generator (remover quando o service estiver pronto)
  List<ZonesCardModel> _generateMockZones() {
    return [
      ZonesCardModel(
        id: 1,
        title: "Living Room",
        image: "assets/images/living_room.jpg",
        floorDimensionValue: "14' x 16'",
        floorAreaValue: "224 sq ft",
        areaPaintable: "485 sq ft",
      ),
      ZonesCardModel(
        id: 2,
        title: "Kitchen",
        image: "assets/images/kitchen.jpg",
        floorDimensionValue: "10' x 12'",
        floorAreaValue: "120 sq ft",
        areaPaintable: "320 sq ft",
      ),
      ZonesCardModel(
        id: 3,
        title: "Bedroom",
        image: "assets/images/bedroom.jpg",
        floorDimensionValue: "12' x 14'",
        floorAreaValue: "168 sq ft",
        areaPaintable: "420 sq ft",
      ),
    ];
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

// Helper class for rename operation
class ZoneRenameData {
  final int zoneId;
  final String newName;

  ZoneRenameData({
    required this.zoneId,
    required this.newName,
  });
}

import 'package:flutter/foundation.dart';

import '../../helpers/zones/zone_add_data.dart';
import '../../model/projects/project_card_model.dart';
import '../../utils/command/command.dart';
import '../../utils/result/result.dart';

enum ZonesListState { initial, loading, loaded, error }

class ZonesListViewModel extends ChangeNotifier {
  // Service seria injetado aqui quando estiver pronto
  // final ZonesService _zonesService;

  // State
  ZonesListState _state = ZonesListState.initial;
  ZonesListState get state => _state;

  // Data
  List<ProjectCardModel> _zones = [];
  List<ProjectCardModel> get zones => _zones;

  ProjectCardModel? _selectedZone;
  ProjectCardModel? get selectedZone => _selectedZone;

  // Error
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ZonesListViewModel();

  // Commands
  Command0<void>? _loadZonesCommand;
  Command1<void, ZoneAddData>? _addZoneCommand;

  Command0<void> get loadZonesCommand => _loadZonesCommand!;
  Command1<void, ZoneAddData> get addZoneCommand => _addZoneCommand!;

  // Computed properties
  bool get isLoading =>
      _state == ZonesListState.initial ||
      _state == ZonesListState.loading ||
      (_loadZonesCommand?.running ?? false);
  bool get hasError => _state == ZonesListState.error || _errorMessage != null;
  bool get hasZones => _zones.isNotEmpty;
  int get zonesCount => _zones.length;
  bool get isInitialized =>
      _loadZonesCommand != null && _addZoneCommand != null;

  // Initialize
  void initialize() {
    if (!isInitialized) {
      _initializeCommands();
      loadZones();
    }
  }

  void _initializeCommands() {
    _loadZonesCommand = Command0(() async {
      return await _loadZonesData();
    });

    _addZoneCommand = Command1((ZoneAddData data) async {
      return await _addZoneData(data);
    });
  }

  // Public methods
  Future<void> loadZones() async {
    if (_loadZonesCommand != null) {
      await _loadZonesCommand!.execute();
    }
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
    if (_addZoneCommand != null) {
      await _addZoneCommand!.execute(
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

  // Method to update zone from external changes (like rename/delete)
  void updateZone(ProjectCardModel updatedZone) {
    final index = _zones.indexWhere((zone) => zone.id == updatedZone.id);
    if (index != -1) {
      _zones[index] = updatedZone;

      // Update selected zone if it's the same
      if (_selectedZone?.id == updatedZone.id) {
        _selectedZone = updatedZone;
      }

      notifyListeners();
    }
  }

  // Method to remove zone from external changes (like delete)
  void removeZone(int zoneId) {
    _zones.removeWhere((zone) => zone.id == zoneId);

    // Clear selection if the selected zone was removed
    if (_selectedZone?.id == zoneId) {
      _selectedZone = null;
    }

    notifyListeners();
  }

  // Private methods
  Future<Result<void>> _loadZonesData() async {
    try {
      _setState(ZonesListState.loading);
      _clearError();

      // Sem API de zonas: iniciar vazio e aguardar adições do usuário
      _zones = [];
      _setState(ZonesListState.loaded);

      return Result.ok(null);
    } catch (e) {
      _setError('Erro ao carregar zonas: $e');
      _setState(ZonesListState.error);
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
      notifyListeners();

      return Result.ok(null);
    } catch (e) {
      _setError('Erro ao adicionar zona: $e');
      return Result.error(Exception(e.toString()));
    }
  }

  // Mock generator removido: zonas serão criadas pelo usuário em runtime

  // State management methods
  void _setState(ZonesListState state) {
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

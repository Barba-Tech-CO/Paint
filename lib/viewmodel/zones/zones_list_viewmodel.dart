import 'package:flutter/foundation.dart';
import '../../model/zones_card_model.dart';
import '../../utils/result/result.dart';
import '../../utils/command/command.dart';
import '../../helpers/zones/zone_data_classes.dart';

enum ZonesListState { initial, loading, loaded, error }

class ZonesListViewModel extends ChangeNotifier {
  // Service seria injetado aqui quando estiver pronto
  // final ZonesService _zonesService;

  // State
  ZonesListState _state = ZonesListState.initial;
  ZonesListState get state => _state;

  // Data
  List<ZonesCardModel> _zones = [];
  List<ZonesCardModel> get zones => _zones;

  ZonesCardModel? _selectedZone;
  ZonesCardModel? get selectedZone => _selectedZone;

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
    String? image,
    String? floorDimensionValue,
    String? floorAreaValue,
    String? areaPaintable,
  }) async {
    if (_addZoneCommand != null) {
      await _addZoneCommand!.execute(
        ZoneAddData(
          title: title,
          image: image ?? "assets/images/kitchen.png",
          floorDimensionValue: floorDimensionValue ?? "10' x 10'",
          floorAreaValue: floorAreaValue ?? "100 sq ft",
          areaPaintable: areaPaintable ?? "280 sq ft",
        ),
      );
    }
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

  // Method to update zone from external changes (like rename/delete)
  void updateZone(ZonesCardModel updatedZone) {
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

      // Simulando dados enquanto não temos o service - 1 segundo para mostrar loading
      await Future.delayed(const Duration(seconds: 1));

      final mockZones = _generateMockZones();

      _zones = mockZones;
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

      final newZone = ZonesCardModel(
        id: newId,
        title: data.title,
        image: data.image,
        floorDimensionValue: data.floorDimensionValue,
        floorAreaValue: data.floorAreaValue,
        areaPaintable: data.areaPaintable,
      );

      _zones.add(newZone);
      notifyListeners();

      return Result.ok(null);
    } catch (e) {
      _setError('Erro ao adicionar zona: $e');
      return Result.error(Exception(e.toString()));
    }
  }

  // Mock data generator (remover quando o service estiver pronto)
  List<ZonesCardModel> _generateMockZones() {
    return [
      ZonesCardModel(
        id: 1,
        title: "Living Room",
        image: "assets/images/kitchen.png",
        floorDimensionValue: "14' x 16'",
        floorAreaValue: "224 sq ft",
        areaPaintable: "485 sq ft",
      ),
      ZonesCardModel(
        id: 2,
        title: "Kitchen",
        image: "assets/images/kitchen.png",
        floorDimensionValue: "10' x 12'",
        floorAreaValue: "120 sq ft",
        areaPaintable: "320 sq ft",
      ),
      ZonesCardModel(
        id: 3,
        title: "Bedroom",
        image: "assets/images/kitchen.png",
        floorDimensionValue: "12' x 14'",
        floorAreaValue: "168 sq ft",
        areaPaintable: "420 sq ft",
      ),
    ];
  }

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

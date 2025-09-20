import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../model/zones/zone_add_data_model.dart';
import '../../model/projects/project_card_model.dart';
import '../../service/i_zones_service.dart';
import '../../utils/command/command.dart';
import '../../utils/result/result.dart';
import '../../utils/unit_converter.dart';

enum ZonesListState { initial, loading, loaded, error }

class ZonesListViewModel extends ChangeNotifier {
  final IZonesService _zonesService;

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

  ZonesListViewModel(this._zonesService);

  // Commands
  Command0<void>? _loadZonesCommand;
  Command1<void, ZoneAddDataModel>? _addZoneCommand;

  Command0<void> get loadZonesCommand => _loadZonesCommand!;
  Command1<void, ZoneAddDataModel> get addZoneCommand => _addZoneCommand!;

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

    _addZoneCommand = Command1((ZoneAddDataModel data) async {
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
        ZoneAddDataModel(
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

  // Navigation methods
  void navigateToZoneDetails(BuildContext context, ProjectCardModel zone) {
    selectZone(zone);
    context.push('/zones-details', extra: zone);
  }

  void navigateToEditZone(BuildContext context, ProjectCardModel zone) {
    context.push('/edit-zone', extra: zone);
  }

  // Zone operations
  Future<void> renameZone(
    BuildContext context,
    ProjectCardModel zone,
    String newName,
  ) async {
    await _zonesService.renameZoneCommand.execute({
      'zoneId': zone.id,
      'newName': newName,
    });
    final result = _zonesService.renameZoneCommand.result;

    if (result != null && result.isSuccess) {
      updateZone(result.data);
    } else if (result != null && result.isError) {
      _errorMessage = 'Erro ao renomear zona: ${result.error}';
      notifyListeners();
    }
  }

  Future<void> deleteZone(BuildContext context, ProjectCardModel zone) async {
    await _zonesService.deleteZoneCommand.execute(zone.id);
    final result = _zonesService.deleteZoneCommand.result;

    if (result != null && result.isSuccess) {
      removeZone(zone.id);
    } else if (result != null && result.isError) {
      _errorMessage = 'Erro ao deletar zona: ${result.error}';
      notifyListeners();
    }
  }

  // Photo extraction utility
  List<String> extractPhotoPaths(ProjectCardModel zone) {
    return _zonesService.extractPhotoPaths(zone);
  }

  // Private methods
  Future<Result<void>> _loadZonesData() async {
    try {
      _setState(ZonesListState.loading);
      _clearError();

      // Carrega zonas usando o command do service
      await _zonesService.loadZonesCommand.execute();
      final result = _zonesService.loadZonesCommand.result;

      if (result != null && result.isSuccess) {
        _zones = result.data;
        _setState(ZonesListState.loaded);
        return Result.ok(null);
      } else if (result != null && result.isError) {
        _errorMessage = 'Erro ao carregar zonas: ${result.error}';
        _setState(ZonesListState.error);
        return Result.error(result.error);
      } else {
        _errorMessage = 'Erro desconhecido ao carregar zonas';
        _setState(ZonesListState.error);
        return Result.error(Exception('Unknown error'));
      }
    } catch (e) {
      _setError('Erro ao carregar zonas: $e');
      _setState(ZonesListState.error);
      return Result.error(Exception(e.toString()));
    }
  }

  Future<Result<void>> _addZoneData(ZoneAddDataModel data) async {
    try {
      // Adiciona zona usando o command do service
      await _zonesService.addZoneCommand.execute(data);
      final result = _zonesService.addZoneCommand.result;

      if (result != null && result.isSuccess) {
        // Check if zone already exists in local list to avoid duplicates - only by title
        final existingZone = _zones
            .where(
              (zone) => zone.title == result.data.title,
            )
            .firstOrNull;

        if (existingZone == null) {
          _zones.add(result.data);
        }

        notifyListeners();
        return Result.ok(null);
      } else if (result != null && result.isError) {
        _errorMessage = 'Erro ao adicionar zona: ${result.error}';
        notifyListeners();
        return Result.error(result.error);
      } else {
        _errorMessage = 'Erro desconhecido ao adicionar zona';
        notifyListeners();
        return Result.error(Exception('Unknown error'));
      }
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

  // Migrated from ProcessingHelper
  /// Simulates processing time between 3s to 5s
  static Future<void> simulateProcessing() async {
    final processingTime = Duration(
      milliseconds: 3000 + (DateTime.now().millisecondsSinceEpoch % 2000),
    );

    try {
      await Future.delayed(processingTime);
    } catch (e) {
      // Continue even if there's an error
    }
  }

  /// Creates zone data from room data - data is always available
  static Map<String, dynamic> createZoneDataFromRoomData({
    required List<String> capturedPhotos,
    required Map<String, dynamic> roomData,
    required Map<String, dynamic> projectData,
  }) {
    // Extract dimensions from RoomPlan data
    final dimensions = roomData['dimensions'] as Map<String, dynamic>?;
    final wallsData = roomData['walls'] as List<dynamic>?;

    // Extract floor dimensions from RoomPlan dimensions
    double? width = dimensions?['width']?.toDouble();
    double? length = dimensions?['length']?.toDouble();
    double? floorArea = dimensions?['floorArea']?.toDouble();

    String floorDimensionValue = '';
    String floorAreaValue = '';

    if (width != null && length != null && width > 0 && length > 0) {
      // Format dimensions showing only feet
      floorDimensionValue = UnitConverter.formatDimensionsInFeet(width, length);
      // Format area showing only square feet
      floorAreaValue = UnitConverter.formatAreaInSqFeetOnly(width * length);
    }

    // Calculate surface areas from walls
    double wallsArea = 0.0;
    if (wallsData != null) {
      for (final wall in wallsData) {
        final wallMap = wall as Map<String, dynamic>;
        final wallWidth = wallMap['width']?.toDouble() ?? 0.0;
        final wallHeight = wallMap['height']?.toDouble() ?? 0.0;
        final area = wallWidth * wallHeight;
        wallsArea += area;
      }
    }

    // Calculate ceiling area from dimensions
    double ceilingArea = floorArea ?? 0.0;

    return {
      'title': projectData['zoneName'],
      'image': capturedPhotos.isNotEmpty ? capturedPhotos.first : '',
      'floorDimensionValue': floorDimensionValue,
      'floorAreaValue': floorAreaValue,
      'areaPaintable': UnitConverter.formatAreaInSqFeetOnly(wallsArea),
      'ceilingArea': UnitConverter.formatAreaInSqFeetOnly(ceilingArea),
      'trimLength': '0',
      'roomPlanData': {
        'photos': capturedPhotos,
        'roomData': roomData,
        'projectData': projectData,
      },
    };
  }
}

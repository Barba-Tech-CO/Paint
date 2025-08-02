import 'package:flutter/foundation.dart';
import '../../model/zones_card_model.dart';
import '../../utils/result/result.dart';
import '../../utils/command/command.dart';
import '../../helpers/zones/zone_data_classes.dart';

class ZoneDetailViewModel extends ChangeNotifier {
  // Service seria injetado aqui quando estiver pronto
  // final ZonesService _zonesService;

  // Data
  ZonesCardModel? _currentZone;
  ZonesCardModel? get currentZone => _currentZone;

  // Error
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Internal state
  bool _disposed = false;

  ZoneDetailViewModel();

  // Commands
  Command1<void, int>? _deleteZoneCommand;
  Command1<void, ZoneRenameData>? _renameZoneCommand;

  Command1<void, int> get deleteZoneCommand => _deleteZoneCommand!;
  Command1<void, ZoneRenameData> get renameZoneCommand => _renameZoneCommand!;

  // Callbacks for notifying parent ViewModels about changes
  Function(int zoneId)? onZoneDeleted;
  Function(ZonesCardModel updatedZone)? onZoneUpdated;

  // Computed properties
  bool get hasZone => _currentZone != null;
  bool get hasError => _errorMessage != null;
  bool get isDeleting => _deleteZoneCommand?.running ?? false;
  bool get isRenaming => _renameZoneCommand?.running ?? false;
  bool get isBusy => isDeleting || isRenaming;
  bool get isInitialized =>
      _deleteZoneCommand != null && _renameZoneCommand != null;

  // Initialize
  void initialize() {
    if (!isInitialized) {
      _initializeCommands();
    }
  }

  void _initializeCommands() {
    _deleteZoneCommand = Command1((int zoneId) async {
      return await _deleteZoneData(zoneId);
    });

    _renameZoneCommand = Command1((ZoneRenameData data) async {
      return await _renameZoneData(data.zoneId, data.newName);
    });
  }

  // Public methods
  void setCurrentZone(ZonesCardModel? zone) {
    _currentZone = zone;
    _clearError();
    _safeNotifyListeners();
  }

  Future<void> deleteZone(int zoneId) async {
    if (_deleteZoneCommand != null) {
      await _deleteZoneCommand!.execute(zoneId);
    }
  }

  Future<void> renameZone(int zoneId, String newName) async {
    if (_renameZoneCommand != null) {
      await _renameZoneCommand!.execute(
        ZoneRenameData(zoneId: zoneId, newName: newName),
      );
    }
  }

  void clearCurrentZone() {
    _currentZone = null;
    _clearError();
    _safeNotifyListeners();
  }

  // Private methods
  Future<Result<void>> _deleteZoneData(int zoneId) async {
    try {
      // Aqui seria a chamada para o service
      // final result = await _zonesService.deleteZone(zoneId);

      // Simulando exclusão
      await Future.delayed(const Duration(milliseconds: 300));

      // Notify parent that zone was deleted
      onZoneDeleted?.call(zoneId);

      // Clear current zone if it was deleted
      if (_currentZone?.id == zoneId) {
        _currentZone = null;
      }

      _safeNotifyListeners();
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

      // Update current zone if it's the one being renamed
      if (_currentZone?.id == zoneId) {
        _currentZone = _currentZone!.copyWith(title: newName);

        // Notify parent about the update
        onZoneUpdated?.call(_currentZone!);
      }

      _safeNotifyListeners();
      return Result.ok(null);
    } catch (e) {
      _setError('Erro ao renomear zona: $e');
      return Result.error(Exception(e.toString()));
    }
  }

  // Helper methods
  void refresh() {
    _clearError();
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    onZoneDeleted = null;
    onZoneUpdated = null;
    super.dispose();
  }

  // State management methods
  void _setError(String message) {
    _errorMessage = message;
    _safeNotifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }
}

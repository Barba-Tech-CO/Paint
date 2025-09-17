import 'package:flutter/material.dart';

import '../../model/projects/project_card_model.dart';
import '../../model/zones/zone_rename_data_model.dart';
import '../../service/i_zones_service.dart';
import '../../utils/command/command.dart';
import '../../utils/result/result.dart';

class ZoneDetailViewModel extends ChangeNotifier {
  final IZonesService _zonesService;

  // Data
  ProjectCardModel? _currentZone;
  ProjectCardModel? get currentZone => _currentZone;

  // Error
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Internal state
  bool _disposed = false;

  ZoneDetailViewModel(this._zonesService);

  // Commands
  Command1<void, int>? _deleteZoneCommand;
  Command1<void, ZoneRenameDataModel>? _renameZoneCommand;

  Command1<void, int> get deleteZoneCommand => _deleteZoneCommand!;
  Command1<void, ZoneRenameDataModel> get renameZoneCommand =>
      _renameZoneCommand!;

  // Callbacks for notifying parent ViewModels about changes
  Function(int zoneId)? onZoneDeleted;
  Function(ProjectCardModel updatedZone)? onZoneUpdated;

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

    _renameZoneCommand = Command1((ZoneRenameDataModel data) async {
      return await _renameZoneData(data.zoneId, data.newName);
    });
  }

  // Public methods
  void setCurrentZone(ProjectCardModel? zone) {
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
        ZoneRenameDataModel(zoneId: zoneId, newName: newName),
      );
    }
  }

  Future<void> updateZoneDimensions(double width, double length) async {
    if (_currentZone != null) {
      await _zonesService.updateZoneDimensionsCommand.execute({
        'zoneId': _currentZone!.id,
        'width': width,
        'length': length,
      });

      final result = _zonesService.updateZoneDimensionsCommand.result;
      if (result != null && result.isSuccess) {
        _currentZone = result.data;
        onZoneUpdated?.call(result.data);
        _safeNotifyListeners();
      } else if (result != null && result.isError) {
        _errorMessage = 'Erro ao atualizar dimensões: ${result.error}';
        _safeNotifyListeners();
      }
    }
  }

  Future<void> updateZoneSurfaceAreas({
    double? walls,
    double? ceiling,
    double? trim,
  }) async {
    if (_currentZone != null) {
      await _zonesService.updateZoneSurfaceAreasCommand.execute({
        'zoneId': _currentZone!.id,
        'walls': walls,
        'ceiling': ceiling,
        'trim': trim,
      });

      final result = _zonesService.updateZoneSurfaceAreasCommand.result;
      if (result != null && result.isSuccess) {
        _currentZone = result.data;
        onZoneUpdated?.call(result.data);
        _safeNotifyListeners();
      } else if (result != null && result.isError) {
        _errorMessage = 'Erro ao atualizar áreas: ${result.error}';
        _safeNotifyListeners();
      }
    }
  }

  Future<void> addPhoto(String photoPath) async {
    if (_currentZone != null) {
      await _zonesService.addPhotosCommand.execute({
        'zoneId': _currentZone!.id,
        'photoPaths': [photoPath],
      });

      final result = _zonesService.addPhotosCommand.result;
      if (result != null && result.isSuccess) {
        _currentZone = result.data;
        onZoneUpdated?.call(result.data);
        _safeNotifyListeners();
      } else if (result != null && result.isError) {
        _errorMessage = 'Erro ao adicionar foto: ${result.error}';
        _safeNotifyListeners();
      }
    }
  }

  Future<void> deletePhoto(int index) async {
    if (_currentZone != null) {
      await _zonesService.removePhotoCommand.execute({
        'zoneId': _currentZone!.id,
        'photoIndex': index,
      });

      final result = _zonesService.removePhotoCommand.result;
      if (result != null && result.isSuccess) {
        _currentZone = result.data;
        onZoneUpdated?.call(result.data);
        _safeNotifyListeners();
      } else if (result != null && result.isError) {
        _errorMessage = 'Erro ao remover foto: ${result.error}';
        _safeNotifyListeners();
      }
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
      // Remove zona usando o command do service
      await _zonesService.deleteZoneCommand.execute(zoneId);
      final result = _zonesService.deleteZoneCommand.result;

      if (result != null && result.isSuccess) {
        // Notify parent that zone was deleted
        onZoneDeleted?.call(zoneId);

        // Clear current zone if it was deleted
        if (_currentZone?.id == zoneId) {
          _currentZone = null;
        }

        _safeNotifyListeners();
        return Result.ok(null);
      } else if (result != null && result.isError) {
        _errorMessage = 'Erro ao excluir zona: ${result.error}';
        _safeNotifyListeners();
        return Result.error(result.error);
      } else {
        _errorMessage = 'Erro desconhecido ao excluir zona';
        _safeNotifyListeners();
        return Result.error(Exception('Unknown error'));
      }
    } catch (e) {
      _setError('Erro ao excluir zona: $e');
      return Result.error(Exception(e.toString()));
    }
  }

  Future<Result<void>> _renameZoneData(int zoneId, String newName) async {
    try {
      // Renomeia zona usando o command do service
      await _zonesService.renameZoneCommand.execute({
        'zoneId': zoneId,
        'newName': newName,
      });
      final result = _zonesService.renameZoneCommand.result;

      if (result != null && result.isSuccess) {
        // Update current zone if it's the one being renamed
        if (_currentZone?.id == zoneId) {
          _currentZone = result.data;
          // Notify parent about the update
          onZoneUpdated?.call(result.data);
        }

        _safeNotifyListeners();
        return Result.ok(null);
      } else if (result != null && result.isError) {
        _errorMessage = 'Erro ao renomear zona: ${result.error}';
        _safeNotifyListeners();
        return Result.error(result.error);
      } else {
        _errorMessage = 'Erro desconhecido ao renomear zona';
        _safeNotifyListeners();
        return Result.error(Exception('Unknown error'));
      }
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

  // Migrated from ZonePhotosHelper
  /// Gets total item count for photo grid including add slot
  static int getTotalItemCount(List<String> photoUrls, {int maxPhotos = 9}) {
    if (photoUrls.length < maxPhotos) {
      return photoUrls.length + 1; // +1 para o slot de adicionar
    }
    return photoUrls.length; // Sem slot de adicionar quando atingir o máximo
  }

  /// Builds add photo slot widget
  static Widget buildAddPhotoSlot({
    VoidCallback? onAddPhoto,
    int currentPhotos = 0,
    int maxPhotos = 9,
  }) {
    return GestureDetector(
      onTap: onAddPhoto,
      child: Container(
        width: 104,
        height: 128,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            colors: [Color(0xFF007AFF), Color(0xFF0051D0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  /// Builds photo with delete button widget
  static Widget buildPhotoWithDeleteButton({
    required String photoUrl,
    required Future<void> Function()? onDelete,
    bool canDelete = true,
  }) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            photoUrl,
            fit: BoxFit.cover,
            width: 104,
            height: 128,
          ),
        ),
        if (canDelete)
          Positioned(
            top: 4,
            right: 8,
            child: GestureDetector(
              onTap: onDelete,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(
                  'assets/icons/delete.png',
                  width: 14,
                  height: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Helper methods for data transformation and presentation

  /// Safely parse dimension from floorDimensionValue string
  double? parseDimension(String dimensionValue, int index) {
    if (dimensionValue.isEmpty || dimensionValue == 'Unknown') {
      return null;
    }

    final parts = dimensionValue.split(' x ');
    if (parts.length <= index) {
      return null;
    }

    return double.tryParse(parts[index]);
  }

  /// Extract photo URLs from zone for presentation
  List<String> getPhotoUrls(ProjectCardModel zone) {
    // Se roomPlanData tem fotos, usa elas; senão usa a imagem principal
    if (zone.roomPlanData != null && zone.roomPlanData!['photos'] is List) {
      final photos = zone.roomPlanData!['photos'] as List;
      return photos.cast<String>();
    }
    // Fallback para a imagem principal se não houver fotos na lista
    return zone.image.isNotEmpty ? [zone.image] : [];
  }

  /// Update zone photos in the current zone
  void updateZonePhotos(List<String> photos) {
    if (_currentZone != null) {
      // Criar uma nova zona com as fotos atualizadas
      final updatedZone = _currentZone!.copyWith(
        roomPlanData: {
          ..._currentZone!.roomPlanData ?? {},
          'photos': photos,
        },
      );

      // Atualizar a zona no viewmodel
      setCurrentZone(updatedZone);
    }
  }
}

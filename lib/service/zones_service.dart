import '../helpers/zones/zone_add_data.dart';
import '../model/projects/project_card_model.dart';
import '../utils/command/command.dart';
import '../utils/result/result.dart';
import 'i_zones_service.dart';

class ZonesService implements IZonesService {
  final List<ProjectCardModel> _zones = [];

  // Commands
  Command0<List<ProjectCardModel>>? _loadZonesCommand;
  Command1<ProjectCardModel, ZoneAddData>? _addZoneCommand;
  Command1<ProjectCardModel, Map<String, dynamic>>? _updateZoneCommand;
  Command1<bool, int>? _deleteZoneCommand;
  Command1<ProjectCardModel, Map<String, dynamic>>? _renameZoneCommand;
  Command1<ProjectCardModel, Map<String, dynamic>>? _addPhotosCommand;
  Command1<ProjectCardModel, Map<String, dynamic>>? _removePhotoCommand;
  Command1<ProjectCardModel, Map<String, dynamic>>?
  _updateZoneDimensionsCommand;
  Command1<ProjectCardModel, Map<String, dynamic>>?
  _updateZoneSurfaceAreasCommand;

  ZonesService() {
    _initializeCommands();
  }

  // Command getters
  @override
  Command0<List<ProjectCardModel>> get loadZonesCommand =>
      _loadZonesCommand!;

  @override
  Command1<ProjectCardModel, ZoneAddData> get addZoneCommand =>
      _addZoneCommand!;

  @override
  Command1<ProjectCardModel, Map<String, dynamic>>
  get updateZoneCommand => _updateZoneCommand!;

  @override
  Command1<bool, int> get deleteZoneCommand => _deleteZoneCommand!;

  @override
  Command1<ProjectCardModel, Map<String, dynamic>>
  get renameZoneCommand => _renameZoneCommand!;

  @override
  Command1<ProjectCardModel, Map<String, dynamic>>
  get addPhotosCommand => _addPhotosCommand!;

  @override
  Command1<ProjectCardModel, Map<String, dynamic>>
  get removePhotoCommand => _removePhotoCommand!;

  @override
  Command1<ProjectCardModel, Map<String, dynamic>>
  get updateZoneDimensionsCommand => _updateZoneDimensionsCommand!;

  @override
  Command1<ProjectCardModel, Map<String, dynamic>>
  get updateZoneSurfaceAreasCommand => _updateZoneSurfaceAreasCommand!;

  void _initializeCommands() {
    _loadZonesCommand = Command0(() async {
      return Result.ok(_zones);
    });

    _addZoneCommand = Command1((ZoneAddData data) async {
      final result = await _addZoneData(data);
      if (result.isSuccess) {
        return Result.ok(result.data);
      } else {
        return Result.error(result.error);
      }
    });

    _updateZoneCommand = Command1((Map<String, dynamic> data) async {
      final result = await _updateZoneData(data);
      if (result.isSuccess) {
        return Result.ok(result.data);
      } else {
        return Result.error(result.error);
      }
    });

    _deleteZoneCommand = Command1((int zoneId) async {
      final result = await _deleteZoneData(zoneId);
      if (result.isSuccess) {
        return Result.ok(result.data);
      } else {
        return Result.error(result.error);
      }
    });

    _renameZoneCommand = Command1((Map<String, dynamic> data) async {
      final result = await _renameZoneData(data);
      if (result.isSuccess) {
        return Result.ok(result.data);
      } else {
        return Result.error(result.error);
      }
    });

    _addPhotosCommand = Command1((Map<String, dynamic> data) async {
      final result = await _addPhotosData(data);
      if (result.isSuccess) {
        return Result.ok(result.data);
      } else {
        return Result.error(result.error);
      }
    });

    _removePhotoCommand = Command1((Map<String, dynamic> data) async {
      final result = await _removePhotoData(data);
      if (result.isSuccess) {
        return Result.ok(result.data);
      } else {
        return Result.error(result.error);
      }
    });

    _updateZoneDimensionsCommand = Command1((Map<String, dynamic> data) async {
      final result = await _updateZoneDimensionsData(data);
      if (result.isSuccess) {
        return Result.ok(result.data);
      } else {
        return Result.error(result.error);
      }
    });

    _updateZoneSurfaceAreasCommand = Command1((
      Map<String, dynamic> data,
    ) async {
      final result = await _updateZoneSurfaceAreasData(data);
      if (result.isSuccess) {
        return Result.ok(result.data);
      } else {
        return Result.error(result.error);
      }
    });
  }

  @override
  List<ProjectCardModel> getZones() {
    return List.unmodifiable(_zones);
  }

  @override
  ProjectCardModel? getZone(int zoneId) {
    try {
      return _zones.firstWhere((zone) => zone.id == zoneId);
    } catch (e) {
      return null;
    }
  }

  @override
  List<String> extractPhotoPaths(ProjectCardModel zone) {
    // Try to get photos from roomPlanData first
    if (zone.roomPlanData != null) {
      final photos = zone.roomPlanData!['photos'] as List?;
      if (photos != null && photos.isNotEmpty) {
        return photos.cast<String>();
      }
    }

    // Fallback to single image if no photos array
    if (zone.image.isNotEmpty) {
      return [zone.image];
    }

    // Return empty list if no photos
    return [];
  }

  @override
  void clearZones() {
    _zones.clear();
  }

  @override
  int getNextId() {
    if (_zones.isEmpty) return 1;
    return _zones.map((z) => z.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  List<String> _getCurrentPhotos(ProjectCardModel zone) {
    if (zone.roomPlanData != null && zone.roomPlanData!['photos'] is List) {
      final photos = zone.roomPlanData!['photos'] as List;
      return List<String>.from(photos);
    }
    // Se não há fotos na lista, usa a imagem principal como primeira foto
    return zone.image.isNotEmpty ? [zone.image] : [];
  }

  // Private command implementations
  Future<Result<ProjectCardModel>> _addZoneData(ZoneAddData data) async {
    try {
      final newId = getNextId();
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
      return Result.ok(newZone);
    } catch (e) {
      return Result.error(Exception('Error adding zone: $e'));
    }
  }

  Future<Result<ProjectCardModel>> _updateZoneData(
    Map<String, dynamic> data,
  ) async {
    try {
      final zoneId = data['zoneId'] as int;
      final index = _zones.indexWhere((zone) => zone.id == zoneId);
      if (index == -1) {
        return Result.error(Exception('Zone not found'));
      }

      final currentZone = _zones[index];
      final updatedZone = currentZone.copyWith(
        title: data['title'] ?? currentZone.title,
        image: data['image'] ?? currentZone.image,
        floorDimensionValue:
            data['floorDimensionValue'] ?? currentZone.floorDimensionValue,
        floorAreaValue: data['floorAreaValue'] ?? currentZone.floorAreaValue,
        areaPaintable: data['areaPaintable'] ?? currentZone.areaPaintable,
        ceilingArea: data['ceilingArea'] ?? currentZone.ceilingArea,
        trimLength: data['trimLength'] ?? currentZone.trimLength,
        roomPlanData: data['roomPlanData'] ?? currentZone.roomPlanData,
      );

      _zones[index] = updatedZone;
      return Result.ok(updatedZone);
    } catch (e) {
      return Result.error(Exception('Error updating zone: $e'));
    }
  }

  Future<Result<bool>> _deleteZoneData(int zoneId) async {
    try {
      final initialLength = _zones.length;
      _zones.removeWhere((zone) => zone.id == zoneId);
      final success = _zones.length < initialLength;

      if (success) {
        return Result.ok(true);
      } else {
        return Result.error(Exception('Zone not found'));
      }
    } catch (e) {
      return Result.error(Exception('Error deleting zone: $e'));
    }
  }

  Future<Result<ProjectCardModel>> _renameZoneData(
    Map<String, dynamic> data,
  ) async {
    try {
      final zoneId = data['zoneId'] as int;
      final newName = data['newName'] as String;

      final index = _zones.indexWhere((zone) => zone.id == zoneId);
      if (index == -1) {
        return Result.error(Exception('Zone not found'));
      }

      final updatedZone = _zones[index].copyWith(title: newName);
      _zones[index] = updatedZone;
      return Result.ok(updatedZone);
    } catch (e) {
      return Result.error(Exception('Error renaming zone: $e'));
    }
  }

  Future<Result<ProjectCardModel>> _addPhotosData(
    Map<String, dynamic> data,
  ) async {
    try {
      final zoneId = data['zoneId'] as int;
      final photoPaths = data['photoPaths'] as List<String>;

      final index = _zones.indexWhere((zone) => zone.id == zoneId);
      if (index == -1) {
        return Result.error(Exception('Zone not found'));
      }

      final currentZone = _zones[index];
      final currentPhotos = _getCurrentPhotos(currentZone);
      currentPhotos.addAll(photoPaths);

      final updatedZone = currentZone.copyWith(
        roomPlanData: {
          ...currentZone.roomPlanData ?? {},
          'photos': currentPhotos,
        },
      );

      _zones[index] = updatedZone;
      return Result.ok(updatedZone);
    } catch (e) {
      return Result.error(Exception('Error adding photos: $e'));
    }
  }

  Future<Result<ProjectCardModel>> _removePhotoData(
    Map<String, dynamic> data,
  ) async {
    try {
      final zoneId = data['zoneId'] as int;
      final photoIndex = data['photoIndex'] as int;

      final index = _zones.indexWhere((zone) => zone.id == zoneId);
      if (index == -1) {
        return Result.error(Exception('Zone not found'));
      }

      final currentZone = _zones[index];
      final currentPhotos = _getCurrentPhotos(currentZone);

      if (photoIndex >= 0 && photoIndex < currentPhotos.length) {
        currentPhotos.removeAt(photoIndex);

        final updatedZone = currentZone.copyWith(
          roomPlanData: {
            ...currentZone.roomPlanData ?? {},
            'photos': currentPhotos,
          },
        );

        _zones[index] = updatedZone;
        return Result.ok(updatedZone);
      }

      return Result.error(Exception('Invalid photo index'));
    } catch (e) {
      return Result.error(Exception('Error removing photo: $e'));
    }
  }

  Future<Result<ProjectCardModel>> _updateZoneDimensionsData(
    Map<String, dynamic> data,
  ) async {
    try {
      final zoneId = data['zoneId'] as int;
      final width = data['width'] as double;
      final length = data['length'] as double;

      final index = _zones.indexWhere((zone) => zone.id == zoneId);
      if (index == -1) {
        return Result.error(Exception('Zone not found'));
      }

      final currentZone = _zones[index];
      final newFloorDimensionValue =
          '${width.toStringAsFixed(0)} x ${length.toStringAsFixed(0)}';
      final newFloorAreaValue = '${(width * length).toStringAsFixed(0)} sq ft';

      final updatedZone = currentZone.copyWith(
        floorDimensionValue: newFloorDimensionValue,
        floorAreaValue: newFloorAreaValue,
      );

      _zones[index] = updatedZone;
      return Result.ok(updatedZone);
    } catch (e) {
      return Result.error(Exception('Error updating zone dimensions: $e'));
    }
  }

  Future<Result<ProjectCardModel>> _updateZoneSurfaceAreasData(
    Map<String, dynamic> data,
  ) async {
    try {
      final zoneId = data['zoneId'] as int;
      final walls = data['walls'] as double?;
      final ceiling = data['ceiling'] as double?;
      final trim = data['trim'] as double?;

      final index = _zones.indexWhere((zone) => zone.id == zoneId);
      if (index == -1) {
        return Result.error(Exception('Zone not found'));
      }

      final currentZone = _zones[index];
      final updatedZone = currentZone.copyWith(
        areaPaintable: walls?.toStringAsFixed(0) ?? currentZone.areaPaintable,
        ceilingArea: ceiling?.toStringAsFixed(0) ?? currentZone.ceilingArea,
        trimLength: trim?.toStringAsFixed(0) ?? currentZone.trimLength,
      );

      _zones[index] = updatedZone;
      return Result.ok(updatedZone);
    } catch (e) {
      return Result.error(Exception('Error updating zone surface areas: $e'));
    }
  }
}

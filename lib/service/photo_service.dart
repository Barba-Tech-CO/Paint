import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Service to manage photos captured from camera
class PhotoService {
  static final PhotoService _instance = PhotoService._internal();
  factory PhotoService() => _instance;
  PhotoService._internal();

  // Zone-specific photo storage
  final Map<String, List<String>> _zonePhotos = {};

  List<String> get capturedPhotos {
    final allPhotos = <String>[];
    for (final photos in _zonePhotos.values) {
      allPhotos.addAll(photos);
    }
    return List.unmodifiable(allPhotos);
  }

  bool get hasPhotos => _zonePhotos.isNotEmpty;
  int get photoCount => capturedPhotos.length;

  /// Add a photo path to the captured photos list for a specific zone
  Future<void> addPhoto(String photoPath, {String? zoneId}) async {
    if (await File(photoPath).exists()) {
      final targetZoneId = zoneId ?? 'default';
      _zonePhotos.putIfAbsent(targetZoneId, () => []);
      _zonePhotos[targetZoneId]!.add(photoPath);
    }
  }

  /// Remove a photo from the captured photos list
  void removePhoto(String photoPath) {
    for (final photos in _zonePhotos.values) {
      photos.remove(photoPath);
    }
  }

  /// Clear all captured photos
  void clearPhotos() {
    _zonePhotos.clear();
  }

  /// Get photos for a specific zone
  List<String> getPhotosForZone(String zoneId) {
    return List.unmodifiable(_zonePhotos[zoneId] ?? []);
  }

  /// Generate temporary photo paths for testing
  Future<List<String>> generateMockPhotoPaths() async {
    final tempDir = await getTemporaryDirectory();
    final mockPhotos = <String>[];

    // Create 2-3 mock photo paths for testing
    for (int i = 1; i <= 3; i++) {
      final photoPath = '${tempDir.path}/mock_photo_$i.jpg';
      mockPhotos.add(photoPath);
    }

    return mockPhotos;
  }

  /// Initialize mock photos for testing
  Future<void> initializeMockPhotos({String? zoneId}) async {
    final targetZoneId = zoneId ?? 'default';
    _zonePhotos.putIfAbsent(targetZoneId, () => []);
    _zonePhotos[targetZoneId]!.clear();

    final mockPaths = await generateMockPhotoPaths();
    for (final path in mockPaths) {
      _zonePhotos[targetZoneId]!.add(path);
    }
  }

  /// Get all zone IDs that have photos
  List<String> get zoneIds => _zonePhotos.keys.toList();

  /// Get photo count for a specific zone
  int getPhotoCountForZone(String zoneId) {
    return _zonePhotos[zoneId]?.length ?? 0;
  }

  /// Clear photos for a specific zone
  void clearPhotosForZone(String zoneId) {
    _zonePhotos.remove(zoneId);
  }

  /// Check if a zone has photos
  bool hasPhotosForZone(String zoneId) {
    return _zonePhotos[zoneId]?.isNotEmpty ?? false;
  }
}

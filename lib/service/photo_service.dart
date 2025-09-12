import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Service to manage photos captured from camera
class PhotoService {
  static final PhotoService _instance = PhotoService._internal();
  factory PhotoService() => _instance;
  PhotoService._internal();

  // Temporary storage for captured photos
  final List<String> _capturedPhotos = [];

  List<String> get capturedPhotos => List.unmodifiable(_capturedPhotos);

  bool get hasPhotos => _capturedPhotos.isNotEmpty;
  int get photoCount => _capturedPhotos.length;

  /// Add a photo path to the captured photos list
  Future<void> addPhoto(String photoPath) async {
    if (await File(photoPath).exists()) {
      _capturedPhotos.add(photoPath);
    }
  }

  /// Remove a photo from the captured photos list
  void removePhoto(String photoPath) {
    _capturedPhotos.remove(photoPath);
  }

  /// Clear all captured photos
  void clearPhotos() {
    _capturedPhotos.clear();
  }

  /// Get photos for a specific zone
  /// For now, returns all captured photos since we don't have zone-specific storage yet
  List<String> getPhotosForZone(String zoneId) {
    // TODO: Implement zone-specific photo storage
    return List.unmodifiable(_capturedPhotos);
  }

  /// Generate temporary photo paths for testing
  /// TODO: Remove this when real camera is implemented
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
  /// TODO: Remove this when real camera is implemented
  Future<void> initializeMockPhotos() async {
    clearPhotos();
    final mockPaths = await generateMockPhotoPaths();
    for (final path in mockPaths) {
      _capturedPhotos.add(path);
    }
  }
}

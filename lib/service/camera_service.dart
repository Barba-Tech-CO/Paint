import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service for capturing photos using device camera
class CameraService {
  final ImagePicker _imagePicker = ImagePicker();

  /// Capture a single photo from camera
  Future<String?> capturePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // Good quality with reasonable file size
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        // Move the image to a permanent location
        return await _saveImageToPermanentLocation(image);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to capture photo: $e');
    }
  }

  /// Capture multiple photos from camera
  Future<List<String>> captureMultiplePhotos({int maxPhotos = 5}) async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (images.isEmpty) return [];

      final List<String> savedPaths = [];
      for (final image in images.take(maxPhotos)) {
        final savedPath = await _saveImageToPermanentLocation(image);
        if (savedPath != null) {
          savedPaths.add(savedPath);
        }
      }
      return savedPaths;
    } catch (e) {
      throw Exception('Failed to capture photos: $e');
    }
  }

  /// Save image to permanent location in app documents directory
  Future<String?> _saveImageToPermanentLocation(XFile image) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String photosDir = path.join(appDocDir.path, 'photos');

      // Create photos directory if it doesn't exist
      await Directory(photosDir).create(recursive: true);

      // Generate unique filename with timestamp
      final String fileName =
          'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String permanentPath = path.join(photosDir, fileName);

      // Copy the image to permanent location
      await image.saveTo(permanentPath);

      return permanentPath;
    } catch (e) {
      throw Exception('Failed to save image: $e');
    }
  }

  /// Check if camera is available on device
  Future<bool> isCameraAvailable() async {
    try {
      // Try to pick an image from camera to test availability
      final XFile? testImage = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 1,
        maxWidth: 1,
        maxHeight: 1,
      );
      return testImage != null;
    } catch (e) {
      return false;
    }
  }
}

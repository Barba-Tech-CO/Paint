import 'package:camera/camera.dart';

class CameraPhotoService {
  final List<XFile> _capturedPhotos = [];
  int _photoCount = 0;
  final int minPhotos;
  final int maxPhotos;
  final List<String> _existingPhotos;

  CameraPhotoService({
    this.minPhotos = 3,
    this.maxPhotos = 9,
    List<String> existingPhotos = const [],
  }) : _existingPhotos = List.from(existingPhotos) {
    _photoCount = _existingPhotos.length;
  }

  // Getters
  List<XFile> get capturedPhotos => List.unmodifiable(_capturedPhotos);
  List<XFile> get allPhotos {
    final allPhotos = <XFile>[];
    // Adicionar fotos existentes como XFile
    for (final photoPath in _existingPhotos) {
      allPhotos.add(XFile(photoPath));
    }
    // Adicionar fotos capturadas
    allPhotos.addAll(_capturedPhotos);
    return allPhotos;
  }

  int get photoCount => _photoCount;
  bool get isDoneEnabled => _photoCount >= minPhotos;
  bool get canTakeMorePhotos => _photoCount < maxPhotos;

  /// Take a photo using the camera controller
  Future<bool> takePhoto(CameraController? cameraController) async {
    if (cameraController == null || !cameraController.value.isInitialized) {
      return false;
    }

    if (!canTakeMorePhotos) {
      return false;
    }

    try {
      final XFile photo = await cameraController.takePicture();
      _capturedPhotos.add(photo);
      _photoCount++;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove a photo by index
  bool removePhoto(int index) {
    if (index >= 0 && index < _capturedPhotos.length) {
      _capturedPhotos.removeAt(index);
      _photoCount--;

      return true;
    }
    return false;
  }

  /// Remove last photo
  bool removeLastPhoto() {
    if (_capturedPhotos.isNotEmpty) {
      _capturedPhotos.removeLast();
      _photoCount--;

      return true;
    }
    return false;
  }

  /// Clear all photos
  void clearPhotos() {
    _capturedPhotos.clear();
    _photoCount = 0;
  }

  /// Get photo paths
  List<String> getPhotoPaths() {
    return _capturedPhotos.map((photo) => photo.path).toList();
  }

  /// Get instruction text based on current state
  String getInstructionText() {
    if (_photoCount == 0) {
      return 'Take between $minPhotos - $maxPhotos photos';
    } else if (_photoCount < minPhotos) {
      final remaining = minPhotos - _photoCount;
      return 'Take $remaining more photos (min $minPhotos)';
    } else if (_photoCount >= maxPhotos) {
      return 'Maximum photos reached';
    } else {
      return '$_photoCount/$maxPhotos Photos taken';
    }
  }

  /// Get all photos (existing + captured)
  List<String> getAllPhotoPaths() {
    final allPhotos = <String>[];
    allPhotos.addAll(_existingPhotos);
    allPhotos.addAll(_capturedPhotos.map((photo) => photo.path));
    return allPhotos;
  }
}

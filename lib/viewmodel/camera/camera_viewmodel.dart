import 'package:flutter/foundation.dart';

import '../../service/camera_dialog_service.dart';
import '../../service/camera_manager.dart';
import '../../service/camera_navigation_handler.dart';
import '../../service/camera_photo_service.dart';

class CameraViewModel extends ChangeNotifier {
  late CameraManager _cameraManager;
  late CameraPhotoService _photoService;
  late CameraNavigationHandler _navigationHandler;

  final Map<String, dynamic>? projectData;

  CameraViewModel({this.projectData});

  // Getters
  CameraManager get cameraManager => _cameraManager;
  CameraPhotoService get photoService => _photoService;
  CameraNavigationHandler get navigationHandler => _navigationHandler;
  bool get isInitialized => _cameraManager.isInitialized;
  bool get isDisposed => _disposed;

  // Internal state
  bool _disposed = false;

  /// Initialize camera system and services
  Future<void> initialize() async {
    _initializeServices();
    await _initializeCamera();
  }

  void _initializeServices() {
    _cameraManager = CameraManager();

    // Extrair fotos existentes dos dados do projeto
    final existingPhotos = <String>[];
    if (projectData != null) {
      final photos = projectData!['existingPhotos'] as List<dynamic>?;
      if (photos != null) {
        existingPhotos.addAll(photos.cast<String>());
      }
    }

    _photoService = CameraPhotoService(
      existingPhotos: existingPhotos,
      maxPhotos: projectData?['maxPhotos'] ?? 9,
    );

    // O navigationHandler será inicializado na view com o contexto correto
  }

  Future<void> _initializeCamera() async {
    final success = await _cameraManager.initialize();

    if (!_disposed) {
      if (!success) {
        // A view deve lidar com o diálogo de câmera indisponível
        notifyListeners();
      } else {
        notifyListeners();
      }
    }
  }

  /// Set navigation context (called from view)
  void setNavigationContext(dynamic context) {
    _navigationHandler = CameraNavigationHandler(
      context: context,
      photoService: _photoService,
      projectData: projectData,
    );
  }

  /// Toggle flash mode
  Future<void> toggleFlash() async {
    await _cameraManager.toggleFlash();
    if (!_disposed) {
      notifyListeners();
    }
  }

  /// Take a photo
  Future<bool> takePhoto() async {
    final success = await _photoService.takePhoto(
      _cameraManager.cameraController,
    );

    if (!_disposed) {
      if (success) {
        notifyListeners();
        return true;
      } else if (!_photoService.canTakeMorePhotos) {
        // A view deve lidar com o diálogo de limite de fotos
        notifyListeners();
        return false;
      }
    }
    return false;
  }

  /// Handle back button press
  void onBackPressed() {
    _navigationHandler.onBackPressed();
  }

  /// Handle done button press
  void onDonePressed() {
    _navigationHandler.onDonePressed();
  }

  /// Check if camera is unavailable and needs dialog
  bool get needsCameraUnavailableDialog => !_cameraManager.isInitialized;

  /// Check if photo limit dialog should be shown
  bool get needsPhotoLimitDialog =>
      !_photoService.canTakeMorePhotos && _photoService.photoCount > 0;

  /// Show camera unavailable dialog
  Future<void> showCameraUnavailableDialog(dynamic context) async {
    await CameraDialogService.showCameraUnavailableDialog(
      context,
      onGoBack: () => _navigationHandler.onBackPressed(),
    );
  }

  /// Show photo limit dialog
  Future<void> showPhotoLimitDialog(dynamic context) async {
    await CameraDialogService.showPhotoLimitDialog(
      context,
      maxPhotos: 9,
      onContinue: () => _navigationHandler.onDonePressed(),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _cameraManager.dispose();
    super.dispose();
  }
}

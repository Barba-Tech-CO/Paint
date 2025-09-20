import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../service/camera_dialog_service.dart';
import '../../service/camera_manager.dart';
import '../../service/camera_navigation_handler.dart';
import '../../service/camera_photo_service.dart';

class CameraViewModel extends ChangeNotifier {
  final CameraManager _cameraManager;
  final CameraPhotoService _photoService;
  final CameraNavigationHandler _navigationHandler;

  final Map<String, dynamic>? projectData;

  CameraViewModel({
    required CameraManager cameraManager,
    required CameraPhotoService photoService,
    required CameraNavigationHandler navigationHandler,
    this.projectData,
  }) : _cameraManager = cameraManager,
       _photoService = photoService,
       _navigationHandler = navigationHandler;

  // Getters
  CameraManager get cameraManager => _cameraManager;
  CameraPhotoService get photoService => _photoService;
  CameraNavigationHandler get navigationHandler => _navigationHandler;
  bool get isInitialized => _cameraManager.isInitialized;
  bool get isDisposed => _disposed;

  // Internal state
  bool _disposed = false;

  /// Initialize camera system
  Future<void> initialize() async {
    await _initializeCamera();
  }

  /// Set navigation context (called from view)
  void setNavigationContext(dynamic context) {
    // The navigation handler context is set during construction
    // This method is kept for compatibility but the context should be set during DI
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

  /// Toggle flash mode
  Future<void> toggleFlash() async {
    await _cameraManager.toggleFlash();
    if (!_disposed) {
      notifyListeners();
    }
  }

  /// Take a photo
  Future<bool> takePhoto() async {
    log('CameraViewModel: takePhoto called');
    log(
      'CameraViewModel: cameraController is null: ${_cameraManager.cameraController == null}',
    );
    log(
      'CameraViewModel: camera is initialized: ${_cameraManager.isInitialized}',
    );

    final success = await _photoService.takePhoto(
      _cameraManager.cameraController,
    );

    log('CameraViewModel: takePhoto result: $success');

    if (!_disposed) {
      if (success) {
        log('CameraViewModel: Photo taken successfully, notifying listeners');
        notifyListeners();
        return true;
      } else if (!_photoService.canTakeMorePhotos) {
        log('CameraViewModel: Cannot take more photos, showing dialog');
        // A view deve lidar com o diálogo de limite de fotos
        notifyListeners();
        return false;
      }
    }
    log('CameraViewModel: takePhoto failed or disposed');
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

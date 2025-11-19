import 'package:camera/camera.dart';

import 'camera_initialization_service.dart';

class CameraManager {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  final int _selectedCameraIndex = 0;
  FlashMode _flashMode = FlashMode.off;

  // Getters
  CameraController? get cameraController => _cameraController;
  List<CameraDescription>? get cameras => _cameras;
  bool get isInitialized => _isInitialized;
  FlashMode get flashMode => _flashMode;

  /// Initialize camera system
  Future<bool> initialize() async {
    try {
      // Check if service is already initialized
      if (!CameraInitializationService.isInitialized) {
        await CameraInitializationService.initialize();
      }

      // Check if we're on simulator or cameras are unavailable
      if (CameraInitializationService.isSimulator ||
          !CameraInitializationService.isCameraAvailable) {
        return false;
      }

      // Get cameras from the service
      _cameras = CameraInitializationService.cameras;

      if (_cameras != null && _cameras!.isNotEmpty) {
        return await _initializeCameraController();
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Initialize camera controller
  Future<bool> _initializeCameraController() async {
    try {
      if (_cameraController != null) {
        await _cameraController!.dispose();
      }

      if (_cameras == null || _cameras!.isEmpty) {
        return false;
      }

      _cameraController = CameraController(
        _cameras![_selectedCameraIndex],
        ResolutionPreset.max,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      _isInitialized = true;

      return true;
    } catch (e) {
      _isInitialized = false;
      return false;
    }
  }

  /// Toggle flash mode
  Future<void> toggleFlash() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      _flashMode = _flashMode == FlashMode.off ? FlashMode.auto : FlashMode.off;

      await _cameraController!.setFlashMode(_flashMode);
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _cameraController?.dispose();
    _cameraController = null;
    _isInitialized = false;
  }
}

import 'dart:io';
import 'package:camera/camera.dart';

/// Service for initializing camera functionality
class CameraInitializationService {
  static List<CameraDescription>? _availableCameras;
  static bool _isInitialized = false;
  static bool _isSimulator = false;

  /// Initialize camera service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Check if we're running on iOS simulator
    _isSimulator = _detectSimulator();

    if (_isSimulator) {
      _isInitialized = true;
      _availableCameras = [];
      return;
    }

    const maxRetries = 3;
    int attempt = 0;

    while (attempt < maxRetries && !_isInitialized) {
      attempt++;

      try {
        // Progressive delay: first attempt immediate, then longer delays
        if (attempt > 1) {
          final delayMs = attempt * 1500;
          await Future.delayed(
            Duration(milliseconds: delayMs),
          );
        }

        _availableCameras = await availableCameras();
        _isInitialized = true;

        return;
      } catch (e) {
        if (attempt >= maxRetries) {
          _isInitialized = true;
          _availableCameras = [];
        }
      }
    }
  }

  /// Detect if running on iOS simulator
  static bool _detectSimulator() {
    if (!Platform.isIOS) return false;

    try {
      // Check for common simulator characteristics
      final environment = Platform.environment;

      // Check for simulator-specific environment variables
      if (environment.containsKey('SIMULATOR_DEVICE_NAME') ||
          environment.containsKey('SIMULATOR_RUNTIME_VERSION') ||
          environment.containsKey('SIMULATOR_HOST_HOME')) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get available cameras
  static List<CameraDescription>? get cameras => _availableCameras;

  /// Check if camera is available
  static bool get isCameraAvailable => _availableCameras?.isNotEmpty ?? false;

  /// Check if service is initialized
  static bool get isInitialized => _isInitialized;

  /// Check if running on simulator
  static bool get isSimulator => _isSimulator;

  /// Reset initialization state (useful for testing)
  static void reset() {
    _isInitialized = false;
    _availableCameras = null;
    _isSimulator = false;
  }
}

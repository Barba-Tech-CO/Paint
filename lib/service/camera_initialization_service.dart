import 'dart:developer';
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
      log(
        'Running on iOS Simulator - camera not available, using image picker fallback',
      );
      _isInitialized = true;
      _availableCameras = [];
      return;
    }

    const maxRetries = 3;
    int attempt = 0;

    while (attempt < maxRetries && !_isInitialized) {
      attempt++;

      try {
        log('Initializing camera service... (attempt $attempt/$maxRetries)');

        // Progressive delay: first attempt immediate, then longer delays
        if (attempt > 1) {
          final delayMs = attempt * 1500; // 1.5s, 3s, 4.5s
          log('Waiting ${delayMs}ms before attempt $attempt');
          await Future.delayed(Duration(milliseconds: delayMs));
        }

        log('Calling availableCameras()...');
        _availableCameras = await availableCameras();
        _isInitialized = true;

        log(
          'Camera service initialized successfully. Found ${_availableCameras?.length ?? 0} cameras',
        );

        if (_availableCameras != null && _availableCameras!.isNotEmpty) {
          for (int i = 0; i < _availableCameras!.length; i++) {
            final camera = _availableCameras![i];
            log('Camera $i: ${camera.name} (${camera.lensDirection})');
          }
        } else {
          log('WARNING: No cameras found on device');
        }

        return; // Success, exit retry loop
      } catch (e) {
        log('Failed to initialize camera service (attempt $attempt): $e');

        if (attempt >= maxRetries) {
          log(
            'All camera initialization attempts failed. Using image picker fallback.',
          );
          _isInitialized =
              true; // Mark as initialized to prevent further attempts
          _availableCameras = [];
        } else {
          log('Retrying camera initialization...');
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

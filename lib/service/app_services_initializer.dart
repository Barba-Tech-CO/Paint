import 'dart:developer';

import '../config/dependency_injection.dart';
import 'camera_initialization_service.dart';
import 'http_service.dart';

class AppServicesInitializer {
  /// Initialize all app services during startup
  static Future<void> initializeAll() async {
    await Future.wait([
      _initializeAuthenticationServices(),
      _initializeCameraServices(),
    ]);
  }

  /// Initialize authentication services during app startup
  static Future<void> _initializeAuthenticationServices() async {
    try {
      final httpService = getIt<HttpService>();
      await httpService.initializeAuthToken();
    } catch (e) {
      // Log error but don't prevent app startup
      log('Warning: Failed to initialize authentication services: $e');
    }
  }

  /// Initialize camera services during app startup
  static Future<void> _initializeCameraServices() async {
    try {
      await CameraInitializationService.initialize();
    } catch (e) {
      // Log error but don't prevent app startup
      log('Warning: Failed to initialize camera services: $e');
      log('Camera features may have limited functionality');
    }
  }

  /// Initialize specific service by type
  static Future<void> initializeService(ServiceType serviceType) async {
    switch (serviceType) {
      case ServiceType.authentication:
        await _initializeAuthenticationServices();
        break;
      case ServiceType.camera:
        await _initializeCameraServices();
        break;
    }
  }

  /// Check if all critical services are initialized
  static bool areServicesReady() {
    try {
      // Check if critical services are available
      final cameraInitialized = CameraInitializationService.isInitialized;

      return cameraInitialized;
    } catch (e) {
      log('Error checking services readiness: $e');
      return false;
    }
  }
}

enum ServiceType {
  authentication,
  camera,
}

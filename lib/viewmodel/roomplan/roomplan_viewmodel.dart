import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roomplan_flutter/roomplan_flutter.dart';

import '../../widgets/dialogs/error_dialog.dart';
import '../../widgets/dialogs/incompatibility_dialog.dart';

class RoomPlanViewModel extends ChangeNotifier {
  RoomPlanScanner? _roomScanner;
  StreamSubscription<ScanResult?>? _scanSubscription;
  bool _isSupported = false;
  bool _isScanning = false;
  ScanResult? _scanResult;

  // Getters
  bool get isSupported => _isSupported;
  bool get isScanning => _isScanning;
  ScanResult? get scanResult => _scanResult;
  RoomPlanScanner? get roomScanner => _roomScanner;

  /// Check if RoomPlan is supported on this device
  Future<void> checkSupport() async {
    try {
      final supported = await RoomPlanScanner.isSupported();
      _isSupported = supported;
      notifyListeners();
    } catch (e) {
      log('RoomPlanViewModel: Error checking support: $e');
      _isSupported = false;
      notifyListeners();
    }
  }

  /// Start RoomPlan scanning
  Future<void> startScanning() async {
    if (!_isSupported) {
      log('RoomPlanViewModel: RoomPlan not supported on this device');
      return;
    }

    try {
      _isScanning = true;
      notifyListeners();

      _roomScanner = RoomPlanScanner();
      _scanSubscription = _roomScanner!.onScanResult.listen(
        (result) {
          _scanResult = result;
          notifyListeners();
        },
        onError: (error) {
          log('RoomPlanViewModel: Scan error: $error');
          _isScanning = false;
          notifyListeners();
        },
      );

      log('RoomPlanViewModel: RoomPlan scanning started');
    } catch (e) {
      log('RoomPlanViewModel: Error starting scan: $e');
      _isScanning = false;
      notifyListeners();
    }
  }

  /// Stop RoomPlan scanning
  Future<void> stopScanning() async {
    try {
      await _roomScanner?.stopScanning();
      _isScanning = false;
      notifyListeners();
      log('RoomPlanViewModel: RoomPlan scanning stopped');
    } catch (e) {
      log('RoomPlanViewModel: Error stopping scan: $e');
    }
  }

  /// Process scan result and prepare data for navigation
  Map<String, dynamic> processScanResult(
    ScanResult result,
    List<String> capturedPhotos,
    Map<String, dynamic>? projectData,
  ) {
    log('=== ROOMPLAN DATA PROCESSING ===');
    log(
      'RoomPlanViewModel: Starting data processing for navigation to processing screen',
    );

    // Prepara os dados da sala para enviar para a tela de processamento
    final roomData = {
      'title': projectData?['zoneName'],
      'zoneType': 'room',
      'walls': result.room.walls
          .map(
            (wall) => {
              'width': wall.width,
              'height': wall.height,
              'area': wall.width * wall.height,
              'condition': 'good', // Default condition, can be updated later
            },
          )
          .toList(),
      'doors': result.room.doors
          .map(
            (door) => {
              'width': door.width,
              'height': door.height,
              'area': door.width * door.height,
              'type': 'standard', // Default type
            },
          )
          .toList(),
      'windows': result.room.windows
          .map(
            (window) => {
              'width': window.width,
              'height': window.height,
              'area': window.width * window.height,
              'type': 'standard', // Default type
            },
          )
          .toList(),
      'objects': result.room.objects
          .map(
            (object) => {
              'category': object.category.name,
              'width': object.width,
              'height': object.height,
              'area': object.width * object.height,
            },
          )
          .toList(),
      'hasDimensions': result.room.dimensions != null,
      if (result.room.dimensions != null) ...{
        'dimensions': {
          'width': result.room.dimensions!.width,
          'length': result.room.dimensions!.length,
          'height': result.room.dimensions!.height,
          'floorArea': result.room.dimensions!.floorArea,
          'volume': result.room.dimensions!.volume,
        },
      },
      'metadata': {
        'scanDuration': result.metadata.scanDuration.inSeconds,
        'deviceModel': result.metadata.deviceModel,
        'hasLidar': result.metadata.hasLidar,
      },
    };

    // Log wall details
    final walls = roomData['walls'] as List;
    for (int i = 0; i < walls.length; i++) {
      final wall = walls[i] as Map<String, dynamic>;
      log(
        'RoomPlanViewModel: Wall $i processed - Width: ${wall['width']}m, Height: ${wall['height']}m, Area: ${wall['area']} sq m',
      );
    }

    // Log door details
    final doors = roomData['doors'] as List;
    for (int i = 0; i < doors.length; i++) {
      final door = doors[i] as Map<String, dynamic>;
      log(
        'RoomPlanViewModel: Door $i processed - Width: ${door['width']}m, Height: ${door['height']}m, Area: ${door['area']} sq m',
      );
    }

    // Log window details
    final windows = roomData['windows'] as List;
    for (int i = 0; i < windows.length; i++) {
      final window = windows[i] as Map<String, dynamic>;
      log(
        'RoomPlanViewModel: Window $i processed - Width: ${window['width']}m, Height: ${window['height']}m, Area: ${window['area']} sq m',
      );
    }

    // Log object details
    final objects = roomData['objects'] as List;
    for (int i = 0; i < objects.length; i++) {
      final object = objects[i] as Map<String, dynamic>;
      log(
        'RoomPlanViewModel: Object $i processed - Category: ${object['category']}, Width: ${object['width']}m, Height: ${object['height']}m, Area: ${object['area']} sq m',
      );
    }

    // Log dimensions if available
    if (roomData['hasDimensions'] == true) {
      final dimensions = roomData['dimensions'] as Map<String, dynamic>;
      log('RoomPlanViewModel: Processed dimensions:');
      log('RoomPlanViewModel: - Width: ${dimensions['width']}m');
      log('RoomPlanViewModel: - Length: ${dimensions['length']}m');
      log('RoomPlanViewModel: - Height: ${dimensions['height']}m');
      log('RoomPlanViewModel: - Floor area: ${dimensions['floorArea']} sq m');
      log('RoomPlanViewModel: - Volume: ${dimensions['volume']} cubic m');
    }

    // Log metadata
    final metadata = roomData['metadata'] as Map<String, dynamic>;
    log('RoomPlanViewModel: Processed metadata:');
    log(
      'RoomPlanViewModel: - Scan duration: ${metadata['scanDuration']} seconds',
    );
    log('RoomPlanViewModel: - Device model: ${metadata['deviceModel']}');
    log('RoomPlanViewModel: - Has LiDAR: ${metadata['hasLidar']}');

    log('RoomPlanViewModel: Captured photos count: ${capturedPhotos.length}');
    log('RoomPlanViewModel: Project data: $projectData');
    log(
      'RoomPlanViewModel: ClientId from projectData: ${projectData?['clientId']}',
    );
    log('RoomPlanViewModel: ProjectData keys: ${projectData?.keys.toList()}');
    log('=== END ROOMPLAN DATA PROCESSING ===');

    return roomData;
  }

  /// Navigate to processing screen with room data
  void navigateToProcessing(
    BuildContext context,
    Map<String, dynamic> roomData,
    List<String> capturedPhotos,
    Map<String, dynamic>? projectData,
  ) {
    context.go(
      '/processing',
      extra: {
        'photos': capturedPhotos,
        'roomData': roomData,
        'projectData': projectData,
      },
    );
  }

  /// Navigate to processing screen with photos only
  void navigateToProcessingWithPhotosOnly(
    BuildContext context,
    List<String> capturedPhotos,
    Map<String, dynamic>? projectData,
  ) {
    context.go(
      '/processing',
      extra: {
        'photos': capturedPhotos,
        'roomData': null, // No room data available
        'projectData': projectData,
      },
    );
  }

  /// Show incompatibility dialog
  Future<void> showIncompatibilityDialog(
    BuildContext context,
    VoidCallback onContinue,
  ) async {
    await IncompatibilityDialog.show(context).then((_) {
      onContinue();
    });
  }

  /// Show error dialog
  void showErrorDialog(BuildContext context, String message) {
    ErrorDialog.show(
      context,
      title: 'Error',
      message: message,
    );
  }

  /// Show world tracking error dialog
  void showWorldTrackingErrorDialog(
    BuildContext context,
    VoidCallback onContinue,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('World Tracking Failed'),
          content: const Text(
            'The room scanning failed due to world tracking issues. This can happen in low-light conditions or when there are not enough visual features in the room.\n\nWould you like to continue with photo capture only?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onContinue();
              },
              child: const Text('Continue with Photos'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Try Again'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _roomScanner?.dispose();
    super.dispose();
  }
}

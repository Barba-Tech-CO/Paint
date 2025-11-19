import 'dart:async';
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
      _isSupported = false;
      notifyListeners();
    }
  }

  /// Start RoomPlan scanning
  Future<void> startScanning() async {
    if (!_isSupported) {
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
          _isScanning = false;
          notifyListeners();
        },
      );

      // Start the actual native scanning
      final result = await _roomScanner!.startScanning();

      if (result != null) {
        _scanResult = result;
        _isScanning = false;
        notifyListeners();
      } else {
        _isScanning = false;
        notifyListeners();
      }
    } catch (e) {
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
    } catch (e) {
      // Handle error silently
    }
  }

  /// Process scan result and prepare data for navigation
  Map<String, dynamic> processScanResult(
    ScanResult result,
    List<String> capturedPhotos,
    Map<String, dynamic>? projectData,
  ) {
    // Calculate room dimensions from the scan result
    final roomDimensions = result.room.dimensions;
    final roomWidth = roomDimensions?.width ?? 0.0;
    final roomLength = roomDimensions?.length ?? 0.0;
    final roomHeight = roomDimensions?.height ?? 0.0;

    // If walls have width 0, distribute room dimensions among walls
    final walls = result.room.walls;
    final wallCount = walls.length;
    final averageWallWidth = wallCount > 0
        ? (roomWidth + roomLength) * 2 / wallCount
        : 0.0;

    // Prepara os dados da sala para enviar para a tela de processamento
    final roomData = {
      'title': projectData?['zoneName'],
      'zoneType': 'room',
      'walls': walls.asMap().entries.map(
        (entry) {
          final wall = entry.value;

          // Use actual wall width if available, otherwise use calculated average
          final wallWidth = wall.width > 0 ? wall.width : averageWallWidth;
          final wallHeight = wall.height > 0 ? wall.height : roomHeight;

          return {
            'width': wallWidth,
            'height': wallHeight,
            'area': wallWidth * wallHeight,
          };
        },
      ).toList(),
      'doors': result.room.doors
          .map(
            (door) => {
              'width': door.width > 0 ? door.width : 0.9,
              'height': door.height > 0
                  ? door.height
                  : 2.1, // Default door height
              'area':
                  (door.width > 0 ? door.width : 0.9) *
                  (door.height > 0 ? door.height : 2.1),
            },
          )
          .toList(),
      'windows': result.room.windows
          .map(
            (window) => {
              'width': window.width > 0
                  ? window.width
                  : 1.2, // Default window width
              'height': window.height > 0
                  ? window.height
                  : 1.0, // Default window height
              'area':
                  (window.width > 0 ? window.width : 1.2) *
                  (window.height > 0 ? window.height : 1.0),
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

    return roomData;
  }

  /// Navigate to processing screen with room data
  void navigateToProcessing(
    BuildContext context,
    Map<String, dynamic> roomData,
    List<String> capturedPhotos,
    Map<String, dynamic>? projectData,
  ) {
    // Calculate zone data from RoomPlan data
    final dimensions = roomData['dimensions'] as Map<String, dynamic>?;
    final floorArea = dimensions?['floorArea'] ?? 0.0;
    final ceilingArea = roomData['ceiling']?['area'] ?? 0.0;

    // Calculate paintable area (floor + walls - doors - windows)
    final walls = roomData['walls'] as List;
    final doors = roomData['doors'] as List;
    final windows = roomData['windows'] as List;

    double totalWallArea = 0.0;
    for (final wall in walls) {
      totalWallArea += (wall as Map<String, dynamic>)['area'] ?? 0.0;
    }

    double totalDoorArea = 0.0;
    for (final door in doors) {
      totalDoorArea += (door as Map<String, dynamic>)['area'] ?? 0.0;
    }

    double totalWindowArea = 0.0;
    for (final window in windows) {
      totalWindowArea += (window as Map<String, dynamic>)['area'] ?? 0.0;
    }

    final paintableArea =
        floorArea + totalWallArea - totalDoorArea - totalWindowArea;

    // Convert to imperial units
    final widthFeet = UnitConverter.metersToFeetConversion(
      dimensions?['width'] ?? 0.0,
    );
    final lengthFeet = UnitConverter.metersToFeetConversion(
      dimensions?['length'] ?? 0.0,
    );
    final floorAreaSqFt = UnitConverter.sqMetersToSqFeetConversion(floorArea);
    final paintableAreaSqFt = UnitConverter.sqMetersToSqFeetConversion(
      paintableArea,
    );
    final ceilingAreaSqFt = UnitConverter.sqMetersToSqFeetConversion(
      ceilingArea,
    );
    final trimLengthFeet = UnitConverter.metersToFeetConversion(
      totalWallArea / 2,
    );

    // Use first photo as zone image, or default
    final zoneImage = capturedPhotos.isNotEmpty ? capturedPhotos.first : '';

    // Store RoomPlan data (keep original metric data for reference)
    final roomPlanData = {
      'walls': roomData['walls'],
      'doors': roomData['doors'],
      'windows': roomData['windows'],
      'objects': roomData['objects'],
      'openings': roomData['openings'],
      'floor': roomData['floor'],
      'ceiling': roomData['ceiling'],
      'hasDimensions': roomData['hasDimensions'],
      'dimensions': roomData['dimensions'],
      'metadata': roomData['metadata'],
      'photos': capturedPhotos,
    };

    // Navigate directly to zones with the processed data
    final zoneData = {
      'title': projectData?['zoneName'] ?? 'New Zone',
      'zoneType': 'room',
      'projectName': projectData?['projectName'],
      'projectType': projectData?['projectType'],
      'clientId': projectData?['clientId'],
      'additionalNotes': projectData?['additionalNotes'],
      // Zone data for addZone method (in imperial units)
      'floorDimensionValue':
          '${widthFeet.toStringAsFixed(0)} ft x ${lengthFeet.toStringAsFixed(0)} ft',
      'floorAreaValue': '${floorAreaSqFt.toStringAsFixed(0)} sq ft',
      'areaPaintable': '${paintableAreaSqFt.toStringAsFixed(0)} sq ft',
      'image': zoneImage,
      'ceilingArea': ceilingAreaSqFt > 0
          ? '${ceilingAreaSqFt.toStringAsFixed(0)} sq ft'
          : null,
      'trimLength': '${trimLengthFeet.toStringAsFixed(0)} ft',
      'roomPlanData': roomPlanData,
    };

    context.go('/zones', extra: zoneData);
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

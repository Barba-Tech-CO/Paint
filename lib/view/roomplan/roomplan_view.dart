import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roomplan_flutter/roomplan_flutter.dart';

import '../../widgets/dialogs/error_dialog.dart';
import '../../widgets/dialogs/incompatibility_dialog.dart';

class RoomPlanView extends StatefulWidget {
  final List<String> capturedPhotos;
  final Map<String, dynamic>? projectData;

  const RoomPlanView({
    super.key,
    required this.capturedPhotos,
    this.projectData,
  });

  @override
  State<RoomPlanView> createState() => _RoomPlanViewState();
}

class _RoomPlanViewState extends State<RoomPlanView> {
  RoomPlanScanner? _roomScanner;
  StreamSubscription<ScanResult?>? _scanSubscription;
  bool _isSupported = false;
  bool _isScanning = false;
  ScanResult? _scanResult;

  @override
  void initState() {
    super.initState();
    _checkSupport();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _roomScanner?.dispose();
    super.dispose();
  }

  Future<void> _checkSupport() async {
    try {
      final supported = await RoomPlanScanner.isSupported();
      setState(() {
        _isSupported = supported;
      });

      if (supported) {
        _roomScanner = RoomPlanScanner();
        _scanSubscription = _roomScanner!.onScanResult.listen((result) {
          if (result != null) {
            setState(() {
              _scanResult = result;
            });

            // Detailed logging for real-time scan updates
            log('=== ROOMPLAN REAL-TIME SCAN UPDATE ===');
            log('RoomPlanView: Scan result received');
            log('RoomPlanView: Walls count: ${result.room.walls.length}');
            log('RoomPlanView: Doors count: ${result.room.doors.length}');
            log('RoomPlanView: Windows count: ${result.room.windows.length}');
            log('RoomPlanView: Objects count: ${result.room.objects.length}');
            log('RoomPlanView: Openings count: ${result.room.openings.length}');
            log('RoomPlanView: Has floor: ${result.room.floor != null}');
            log('RoomPlanView: Has ceiling: ${result.room.ceiling != null}');

            // Log room dimensions if available
            if (result.room.dimensions != null) {
              final dims = result.room.dimensions!;
              log(
                'RoomPlanView: Room dimensions - Width: ${dims.width}m, Length: ${dims.length}m, Height: ${dims.height}m',
              );
              log(
                'RoomPlanView: Floor area: ${dims.floorArea} sq m, Volume: ${dims.volume} cubic m',
              );
            } else {
              log('RoomPlanView: No room dimensions available');
            }

            // Log detailed wall information
            for (int i = 0; i < result.room.walls.length; i++) {
              final wall = result.room.walls[i];
              log(
                'RoomPlanView: Wall $i - UUID: ${wall.uuid}, Width: ${wall.width}m, Height: ${wall.height}m, Confidence: ${wall.confidence}',
              );
              log(
                'RoomPlanView: Wall $i - Position: x=${wall.position.x}, y=${wall.position.y}, z=${wall.position.z}',
              );
              log(
                'RoomPlanView: Wall $i - Openings count: ${wall.openings.length}',
              );
            }

            // Log detailed door information
            for (int i = 0; i < result.room.doors.length; i++) {
              final door = result.room.doors[i];
              log(
                'RoomPlanView: Door $i - UUID: ${door.uuid}, Type: ${door.type}, Width: ${door.width}m, Height: ${door.height}m',
              );
              log(
                'RoomPlanView: Door $i - Position: x=${door.position.x}, y=${door.position.y}, z=${door.position.z}',
              );
              log('RoomPlanView: Door $i - Confidence: ${door.confidence}');
            }

            // Log detailed window information
            for (int i = 0; i < result.room.windows.length; i++) {
              final window = result.room.windows[i];
              log(
                'RoomPlanView: Window $i - UUID: ${window.uuid}, Type: ${window.type}, Width: ${window.width}m, Height: ${window.height}m',
              );
              log(
                'RoomPlanView: Window $i - Position: x=${window.position.x}, y=${window.position.y}, z=${window.position.z}',
              );
              log('RoomPlanView: Window $i - Confidence: ${window.confidence}');
            }

            // Log detailed object information
            for (int i = 0; i < result.room.objects.length; i++) {
              final object = result.room.objects[i];
              log(
                'RoomPlanView: Object $i - UUID: ${object.uuid}, Category: ${object.category}, Width: ${object.width}m, Height: ${object.height}m, Length: ${object.length}m',
              );
              log(
                'RoomPlanView: Object $i - Position: x=${object.position.x}, y=${object.position.y}, z=${object.position.z}',
              );
              log('RoomPlanView: Object $i - Confidence: ${object.confidence}');
            }

            // Log metadata
            log(
              'RoomPlanView: Scan duration: ${result.metadata.scanDuration.inSeconds} seconds',
            );
            log('RoomPlanView: Device model: ${result.metadata.deviceModel}');
            log('RoomPlanView: Has LiDAR: ${result.metadata.hasLidar}');

            // Log confidence levels
            log(
              'RoomPlanView: Overall confidence: ${result.confidence.overall}',
            );
            log('=== END ROOMPLAN REAL-TIME SCAN UPDATE ===');
          }
        });

        // Automatically start scanning when device is compatible
        _startRoomPlan();
      } else {
        _showIncompatibilityDialog();
      }
    } catch (e) {
      log('RoomPlanView: Error checking support: $e');
      _showErrorDialog('Failed to check RoomPlan support: $e');
    }
  }

  Future<void> _startRoomPlan() async {
    if (!_isSupported || _roomScanner == null) {
      _showErrorDialog('RoomPlan not supported on this device');
      return;
    }

    setState(() {
      _isScanning = true;
      _scanResult = null;
    });

    try {
      // Start the room scanning session
      // This will open the native RoomPlan interface
      final result = await _roomScanner!.startScanning();

      if (result != null) {
        setState(() {
          _scanResult = result;
        });

        // Comprehensive logging for final scan result
        log('=== ROOMPLAN FINAL SCAN RESULT ===');
        log('RoomPlanView: RoomPlan completed successfully');
        log('RoomPlanView: Final result summary:');
        log('RoomPlanView: - Walls: ${result.room.walls.length}');
        log('RoomPlanView: - Doors: ${result.room.doors.length}');
        log('RoomPlanView: - Windows: ${result.room.windows.length}');
        log('RoomPlanView: - Objects: ${result.room.objects.length}');
        log('RoomPlanView: - Openings: ${result.room.openings.length}');
        log('RoomPlanView: - Has floor: ${result.room.floor != null}');
        log('RoomPlanView: - Has ceiling: ${result.room.ceiling != null}');

        if (result.room.dimensions != null) {
          final dims = result.room.dimensions!;
          log('RoomPlanView: Final room dimensions:');
          log('RoomPlanView: - Width: ${dims.width}m');
          log('RoomPlanView: - Length: ${dims.length}m');
          log('RoomPlanView: - Height: ${dims.height}m');
          log('RoomPlanView: - Floor area: ${dims.floorArea} sq m');
          log('RoomPlanView: - Volume: ${dims.volume} cubic m');
        }

        log('RoomPlanView: Scan metadata:');
        log(
          'RoomPlanView: - Duration: ${result.metadata.scanDuration.inSeconds} seconds',
        );
        log('RoomPlanView: - Device: ${result.metadata.deviceModel}');
        log('RoomPlanView: - LiDAR: ${result.metadata.hasLidar}');

        log('RoomPlanView: Confidence levels:');
        log('RoomPlanView: - Overall: ${result.confidence.overall}');
        log('=== END ROOMPLAN FINAL SCAN RESULT ===');

        _navigateToProcessing(result);
      } else {
        log('RoomPlanView: RoomPlan was cancelled');
      }
    } on RoomPlanPermissionsException {
      _showErrorDialog(
        'Camera permission denied. Please grant camera access in Settings.',
      );
    } on ScanCancelledException {
      log('RoomPlanView: RoomPlan was cancelled by user');
    } catch (e) {
      log('RoomPlanView: Error during RoomPlan: $e');
      _showErrorDialog('RoomPlan failed: $e');
    } finally {
      setState(() => _isScanning = false);
    }
  }

  void _showIncompatibilityDialog() {
    IncompatibilityDialog.show(context).then((_) {
      // Navigate to processing with photos only
      _navigateToProcessingWithPhotosOnly();
    });
  }

  void _showErrorDialog(String message) {
    ErrorDialog.show(
      context,
      title: 'Error',
      message: message,
    );
  }

  void _navigateToProcessing(ScanResult result) {
    log('=== ROOMPLAN DATA PROCESSING ===');
    log(
      'RoomPlanView: Starting data processing for navigation to processing screen',
    );

    // Prepara os dados da sala para enviar para a tela de processamento
    final roomData = {
      'title': widget.projectData?['zoneName'],
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

    // Log processed room data
    log('RoomPlanView: Processed room data:');
    log('RoomPlanView: - Title: ${roomData['title']}');
    log('RoomPlanView: - Zone type: ${roomData['zoneType']}');
    log('RoomPlanView: - Walls count: ${(roomData['walls'] as List).length}');
    log('RoomPlanView: - Doors count: ${(roomData['doors'] as List).length}');
    log(
      'RoomPlanView: - Windows count: ${(roomData['windows'] as List).length}',
    );
    log(
      'RoomPlanView: - Objects count: ${(roomData['objects'] as List).length}',
    );
    log('RoomPlanView: - Has dimensions: ${roomData['hasDimensions']}');

    // Log wall details
    final walls = roomData['walls'] as List;
    for (int i = 0; i < walls.length; i++) {
      final wall = walls[i] as Map<String, dynamic>;
      log(
        'RoomPlanView: Wall $i processed - Width: ${wall['width']}m, Height: ${wall['height']}m, Area: ${wall['area']} sq m',
      );
    }

    // Log door details
    final doors = roomData['doors'] as List;
    for (int i = 0; i < doors.length; i++) {
      final door = doors[i] as Map<String, dynamic>;
      log(
        'RoomPlanView: Door $i processed - Width: ${door['width']}m, Height: ${door['height']}m, Area: ${door['area']} sq m',
      );
    }

    // Log window details
    final windows = roomData['windows'] as List;
    for (int i = 0; i < windows.length; i++) {
      final window = windows[i] as Map<String, dynamic>;
      log(
        'RoomPlanView: Window $i processed - Width: ${window['width']}m, Height: ${window['height']}m, Area: ${window['area']} sq m',
      );
    }

    // Log object details
    final objects = roomData['objects'] as List;
    for (int i = 0; i < objects.length; i++) {
      final object = objects[i] as Map<String, dynamic>;
      log(
        'RoomPlanView: Object $i processed - Category: ${object['category']}, Width: ${object['width']}m, Height: ${object['height']}m, Area: ${object['area']} sq m',
      );
    }

    // Log dimensions if available
    if (roomData['hasDimensions'] == true) {
      final dimensions = roomData['dimensions'] as Map<String, dynamic>;
      log('RoomPlanView: Processed dimensions:');
      log('RoomPlanView: - Width: ${dimensions['width']}m');
      log('RoomPlanView: - Length: ${dimensions['length']}m');
      log('RoomPlanView: - Height: ${dimensions['height']}m');
      log('RoomPlanView: - Floor area: ${dimensions['floorArea']} sq m');
      log('RoomPlanView: - Volume: ${dimensions['volume']} cubic m');
    }

    // Log metadata
    final metadata = roomData['metadata'] as Map<String, dynamic>;
    log('RoomPlanView: Processed metadata:');
    log('RoomPlanView: - Scan duration: ${metadata['scanDuration']} seconds');
    log('RoomPlanView: - Device model: ${metadata['deviceModel']}');
    log('RoomPlanView: - Has LiDAR: ${metadata['hasLidar']}');

    log('RoomPlanView: Captured photos count: ${widget.capturedPhotos.length}');
    log('RoomPlanView: Project data: ${widget.projectData}');
    log('=== END ROOMPLAN DATA PROCESSING ===');

    // Navega para a tela de processamento
    context.pushNamed(
      'processing',
      extra: {
        'photos': widget.capturedPhotos,
        'roomData': roomData,
        'projectData': widget.projectData,
      },
    );
  }

  void _navigateToProcessingWithPhotosOnly() {
    // Navega para a tela de processamento apenas com fotos
    context.pushNamed(
      'processing',
      extra: {
        'photos': widget.capturedPhotos,
        'roomData': null, // No room data available
        'projectData': widget.projectData,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Se não é suportado, mostra apenas o dialog de incompatibilidade
    if (!_isSupported) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    // Se está escaneando, mostra interface mínima
    if (_isScanning) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
              SizedBox(height: 24),
              Text(
                'Starting Room Scan...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please wait while the scanner initializes',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Se tem resultado, mostra interface de sucesso
    if (_scanResult != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 24),
              const Text(
                'Room scan completed!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Walls: ${_scanResult!.room.walls.length} | Doors: ${_scanResult!.room.doors.length} | Windows: ${_scanResult!.room.windows.length}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              if (_scanResult!.room.dimensions != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Size: ${_scanResult!.room.dimensions!.width.toStringAsFixed(1)}m × ${_scanResult!.room.dimensions!.length.toStringAsFixed(1)}m',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _navigateToProcessing(_scanResult!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue to Processing',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Estado inicial - mostrando loading
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
            SizedBox(height: 24),
            Text(
              'Checking device compatibility...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

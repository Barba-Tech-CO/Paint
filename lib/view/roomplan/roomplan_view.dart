import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roomplan_flutter/roomplan_flutter.dart';

import '../../widgets/dialogs/app_dialogs.dart';

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
            log(
              'RoomPlanView: Real-time scan update - ${result.room.walls.length} walls',
            );
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
        log('RoomPlanView: RoomPlan completed successfully');
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
    AppDialogs.showIncompatibilityDialog(context).then((_) {
      // Navigate to processing with photos only
      _navigateToProcessingWithPhotosOnly();
    });
  }

  void _showErrorDialog(String message) {
    AppDialogs.showErrorDialog(
      context,
      title: 'Error',
      message: message,
    );
  }

  void _navigateToProcessing(ScanResult result) {
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

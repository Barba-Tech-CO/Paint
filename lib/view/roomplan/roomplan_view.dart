import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roomplan_flutter/roomplan_flutter.dart';

class RoomPlanView extends StatefulWidget {
  final List<String> capturedPhotos;

  const RoomPlanView({
    super.key,
    required this.capturedPhotos,
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
  String _scanStatus = 'Checking device compatibility...';

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
        _scanStatus = supported
            ? 'Ready to scan room'
            : 'RoomPlan not supported on this device';
      });

      if (supported) {
        _roomScanner = RoomPlanScanner();
        _scanSubscription = _roomScanner!.onScanResult.listen((result) {
          if (result != null) {
            setState(() {
              _scanResult = result;
              _scanStatus =
                  'Scanning... (${result.room.walls.length} walls detected)';
            });
            log(
              'RoomPlanView: Real-time scan update - ${result.room.walls.length} walls',
            );
          }
        });
      } else {
        _showErrorDialog(
          'RoomPlan is not supported on this device.\n\nRequires:\n• iOS 16.0 or later\n• Device with LiDAR sensor (iPhone 12 Pro+, iPad Pro)',
        );
      }
    } catch (e) {
      log('RoomPlanView: Error checking support: $e');
      setState(() {
        _scanStatus = 'Error checking device compatibility';
      });
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
      _scanStatus = 'Starting room scan...';
      _scanResult = null;
    });

    try {
      // Start the room scanning session
      // This will open the native RoomPlan interface
      final result = await _roomScanner!.startScanning();

      if (result != null) {
        setState(() {
          _scanResult = result;
          _scanStatus = 'Room scan completed successfully!';
        });
        log('RoomPlanView: RoomPlan completed successfully');
        _navigateToProcessing(result);
      } else {
        setState(() {
          _scanStatus = 'Room scan was cancelled by user';
        });
        log('RoomPlanView: RoomPlan was cancelled');
      }
    } on RoomPlanPermissionsException {
      setState(() {
        _scanStatus = 'Camera permission denied';
      });
      _showErrorDialog(
        'Camera permission denied. Please grant camera access in Settings.',
      );
    } on ScanCancelledException {
      setState(() {
        _scanStatus = 'Room scan was cancelled';
      });
      log('RoomPlanView: RoomPlan was cancelled by user');
    } catch (e) {
      setState(() {
        _scanStatus = 'Error during room scan';
      });
      log('RoomPlanView: Error during RoomPlan: $e');
      _showErrorDialog('RoomPlan failed: $e');
    } finally {
      setState(() => _isScanning = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToProcessing(ScanResult result) {
    // Prepara os dados da sala para enviar para a tela de processamento
    final roomData = {
      'walls': result.room.walls.length,
      'doors': result.room.doors.length,
      'windows': result.room.windows.length,
      'objects': result.room.objects.length,
      'hasDimensions': result.room.dimensions != null,
      if (result.room.dimensions != null) ...{
        'width': result.room.dimensions!.width,
        'length': result.room.dimensions!.length,
        'height': result.room.dimensions!.height,
        'floorArea': result.room.dimensions!.floorArea,
        'volume': result.room.dimensions!.volume,
      },
      'confidence': {
        'overall': result.confidence.overall,
        'wallAccuracy': result.confidence.wallAccuracy,
        'dimensionAccuracy': result.confidence.dimensionAccuracy,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Measurements'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Room Measurements',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _scanStatus,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Captured Photos: ${widget.capturedPhotos.length}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // RoomPlan Button
              ElevatedButton(
                onPressed: _isSupported && !_isScanning ? _startRoomPlan : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSupported ? Colors.blue : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isScanning
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Scanning Room...'),
                        ],
                      )
                    : _isSupported
                    ? const Text(
                        'Start Room Scan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const Text(
                        'RoomPlan Not Supported',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              // Back Button
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.grey),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back to Camera',
                  style: TextStyle(fontSize: 16),
                ),
              ),

              const Spacer(),

              // RoomPlan Result Info
              if (_scanResult != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Room scan completed!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Walls: ${_scanResult!.room.walls.length} | Doors: ${_scanResult!.room.doors.length} | Windows: ${_scanResult!.room.windows.length}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_scanResult!.room.dimensions != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Size: ${_scanResult!.room.dimensions!.width.toStringAsFixed(1)}m × ${_scanResult!.room.dimensions!.length.toStringAsFixed(1)}m',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

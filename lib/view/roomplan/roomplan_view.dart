import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:roomplan_flutter/roomplan_flutter.dart';

import '../../config/app_colors.dart';
import '../../model/projects/project_model.dart';
import '../widgets/buttons/paint_pro_button.dart';

class RoomPlanView extends StatefulWidget {
  final ProjectModel project;

  const RoomPlanView({super.key, required this.project});

  @override
  State<RoomPlanView> createState() => _RoomPlanViewState();
}

class _RoomPlanViewState extends State<RoomPlanView> {
  // final RoomPlanController _controller = RoomPlanController();
  // RoomPlanData? _roomData;
  bool _isScanning = false;
  bool _scanCompleted = false;
  Map<String, dynamic>? _roomMeasurements;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan Room - ${widget.project.projectName}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Status Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _scanCompleted ? Icons.check_circle : Icons.threed_rotation,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  _scanCompleted
                      ? 'Room Scan Complete!'
                      : _isScanning
                      ? 'Scanning Room...'
                      : 'Ready to Scan Room',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _scanCompleted
                      ? 'Room measurements captured successfully'
                      : 'Point your device around the room to capture measurements',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // RoomPlan Scanner Area
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildScannerContent(),
              ),
            ),
          ),

          // Room Measurements Display
          if (_roomMeasurements != null)
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: _buildMeasurementsDisplay(),
              ),
            ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (!_scanCompleted && !_isScanning)
                  PaintProButton(
                    text: 'Start Room Scan',
                    onPressed: _startRoomScan,
                    icon: const Icon(Icons.threed_rotation),
                  ),

                if (_isScanning)
                  PaintProButton(
                    text: 'Stop Scanning',
                    onPressed: _stopRoomScan,
                    backgroundColor: Colors.orange,
                    icon: const Icon(Icons.stop),
                  ),

                if (_scanCompleted)
                  Column(
                    children: [
                      PaintProButton(
                        text: 'Continue to Zones',
                        onPressed: _proceedToZones,
                        icon: const Icon(Icons.arrow_forward),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _rescanRoom,
                        child: Text(
                          'Rescan Room',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerContent() {
    if (_isScanning) {
      return Container(
        color: Colors.black87,
        child: Stack(
          children: [
            // Simulated camera feed
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[800]!,
                    Colors.grey[900]!,
                  ],
                ),
              ),
            ),
            // Scanning overlay
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Scanning Room...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Move your device slowly around the room',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Scanning grid overlay
            CustomPaint(
              painter: ScanningGridPainter(),
              size: Size.infinite,
            ),
          ],
        ),
      );
    } else if (_scanCompleted) {
      return Container(
        color: Colors.green[50],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green[600],
              ),
              const SizedBox(height: 16),
              Text(
                'Room Scan Complete!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Room measurements captured successfully',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green[600],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        color: Colors.grey[100],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.threed_rotation,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Ready to Scan Room',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap "Start Room Scan" to begin',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildMeasurementsDisplay() {
    final measurements = _roomMeasurements!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Room Measurements',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMeasurementItem(
              'Total Area',
              '${measurements['total_area']} sqft',
              Icons.square_foot,
            ),
            _buildMeasurementItem(
              'Wall Area',
              '${measurements['wall_area']} sqft',
              Icons.wallpaper,
            ),
            _buildMeasurementItem(
              'Height',
              '${measurements['height']} ft',
              Icons.height,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMeasurementItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _startRoomScan() {
    setState(() {
      _isScanning = true;
    });

    // Simulate RoomPlan scanning process
    // In real implementation, this would integrate with roomplan_flutter package
    // RoomPlanController would handle the actual scanning

    // Simulate scanning delay
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isScanning) {
        _stopRoomScan();
        _generateMockMeasurements();
      }
    });
  }

  void _stopRoomScan() {
    setState(() {
      _isScanning = false;
      _scanCompleted = true;
    });
  }

  void _rescanRoom() {
    setState(() {
      _scanCompleted = false;
      _roomMeasurements = null;
    });
  }

  void _generateMockMeasurements() {
    // Generate realistic mock measurements
    // In real implementation, this would come from RoomPlan
    setState(() {
      _roomMeasurements = {
        'total_area': 245.5,
        'wall_area': 380.2,
        'height': 9.5,
        'rooms': [
          {
            'name': 'Living Room',
            'floor_area': 245.5,
            'wall_area': 380.2,
            'ceiling_area': 245.5,
          },
        ],
      };
    });
  }

  void _proceedToZones() {
    if (_roomMeasurements != null) {
      // Pass project and room data to zones view
      context.push(
        '/zones',
        extra: {
          'project': widget.project,
          'roomData': _roomMeasurements,
        },
      );
    }
  }
}

// Custom painter for scanning grid overlay
class ScanningGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const gridSize = 30.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

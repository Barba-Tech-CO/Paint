import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_colors.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';

class ProcessingView extends StatefulWidget {
  final List<String> capturedPhotos;
  final Map<String, dynamic>? roomData;
  final Map<String, dynamic>? projectData;

  const ProcessingView({
    super.key,
    required this.capturedPhotos,
    this.roomData,
    this.projectData,
  });

  @override
  State<ProcessingView> createState() => _ProcessingViewState();
}

class _ProcessingViewState extends State<ProcessingView> {
  @override
  void initState() {
    super.initState();
    _startProcessing();
  }

  Future<void> _startProcessing() async {
    // Simula processamento entre 3s a 5s
    final processingTime = Duration(
      milliseconds: 3000 + (DateTime.now().millisecondsSinceEpoch % 2000),
    );

    await Future.delayed(processingTime);

    if (mounted) {
      _navigateToZones();
    }
  }

  void _navigateToZones() {
    // Cria dados da zona baseado no roomData ou dados padrão
    final zoneData = _createZoneDataFromRoomData();

    // Navega para a ZonesView com os dados da zona
    context.go('/zones', extra: zoneData);
  }

  Map<String, dynamic> _createZoneDataFromRoomData() {
    // Se temos dados da sala do RoomPlan, usa eles
    if (widget.roomData != null) {
      final roomData = widget.roomData!;
      final dimensions = roomData['dimensions'] as Map<String, dynamic>?;

      if (dimensions != null) {
        final width = dimensions['width'] as double?;
        final length = dimensions['length'] as double?;
        final floorArea = dimensions['floorArea'] as double?;

        // Calcula área pintável baseada nas dimensões reais de cada parede
        // Fórmula: (área das paredes individuais) - aberturas reais + teto
        double totalWallArea = 0.0;

        // Calcula área de cada parede individual detectada pelo RoomPlan
        final walls = roomData['walls'] as List<dynamic>? ?? [];
        for (final wall in walls) {
          final wallWidth = (wall['width'] as num?)?.toDouble() ?? 0.0;
          final wallHeight = (wall['height'] as num?)?.toDouble() ?? 0.0;
          totalWallArea += wallWidth * wallHeight;
        }

        // Se não há paredes detectadas, usa estimativa baseada nas dimensões da sala
        if (totalWallArea == 0.0 && width != null && length != null) {
          final height = dimensions['height'] as double? ?? 8.0;
          // 2 paredes de largura + 2 paredes de comprimento
          totalWallArea = (2 * width * height) + (2 * length * height);
        }

        // Área do teto
        final ceilingArea = width != null && length != null
            ? width * length
            : 0.0;

        // Calcula área real das aberturas (portas e janelas) detectadas pelo RoomPlan
        double realOpeningsArea = 0.0;

        // Soma área das portas detectadas
        final doors = roomData['doors'] as List<dynamic>? ?? [];
        for (final door in doors) {
          final doorWidth = (door['width'] as num?)?.toDouble() ?? 0.0;
          final doorHeight = (door['height'] as num?)?.toDouble() ?? 0.0;
          realOpeningsArea += doorWidth * doorHeight;
        }

        // Soma área das janelas detectadas
        final windows = roomData['windows'] as List<dynamic>? ?? [];
        for (final window in windows) {
          final windowWidth = (window['width'] as num?)?.toDouble() ?? 0.0;
          final windowHeight = (window['height'] as num?)?.toDouble() ?? 0.0;
          realOpeningsArea += windowWidth * windowHeight;
        }

        // Área pintável = paredes - aberturas reais + teto
        final paintableArea = width != null && length != null
            ? (totalWallArea - realOpeningsArea) + ceilingArea
            : null;

        return {
          'title': roomData['title'] ?? widget.projectData?['zoneName'],
          'zoneType': roomData['zoneType'] ?? 'room',
          'floorDimensionValue': width != null && length != null
              ? '${width.toStringAsFixed(0)}\' x ${length.toStringAsFixed(0)}\''
              : '',
          'floorAreaValue': floorArea != null
              ? '${floorArea.toStringAsFixed(0)} sq ft'
              : '',
          'areaPaintable': paintableArea != null
              ? '${paintableArea.toStringAsFixed(0)} sq ft'
              : '',
          'ceilingArea': ceilingArea > 0
              ? '${ceilingArea.toStringAsFixed(0)} sq ft'
              : null,
          'trimLength': _calculateTrimLength(walls, doors, windows),
          'image': widget.capturedPhotos.isNotEmpty
              ? widget.capturedPhotos.first
              : null,
          // Preserve detailed RoomPlan data for zone editing
          'roomPlanData': {
            'walls': walls,
            'doors': doors,
            'windows': windows,
            'objects': roomData['objects'] as List<dynamic>? ?? [],
            'metadata': roomData['metadata'],
          },
        };
      }
    }

    // Dados vazios se não houver roomData
    return {
      'title': widget.projectData?['zoneName'],
      'zoneType': 'room',
      'floorDimensionValue': '',
      'floorAreaValue': '',
      'areaPaintable': '',
      'ceilingArea': null,
      'image': widget.capturedPhotos.isNotEmpty
          ? widget.capturedPhotos.first
          : null,
      'roomPlanData': null,
    };
  }

  String _calculateTrimLength(
    List<dynamic> walls,
    List<dynamic> doors,
    List<dynamic> windows,
  ) {
    // Calcula o perímetro da sala baseado nas paredes detectadas
    double perimeter = 0.0;

    for (final wall in walls) {
      final wallWidth = (wall['width'] as num?)?.toDouble() ?? 0.0;
      perimeter += wallWidth;
    }

    // Se não há paredes detectadas, usa estimativa baseada nas dimensões
    if (perimeter == 0.0) {
      final dimensions =
          widget.roomData?['dimensions'] as Map<String, dynamic>?;
      if (dimensions != null) {
        final width = dimensions['width'] as double? ?? 0.0;
        final length = dimensions['length'] as double? ?? 0.0;
        if (width > 0 && length > 0) {
          perimeter = 2 * (width + length);
        }
      }
    }

    // Adiciona comprimento das aberturas (portas e janelas)
    double openingsLength = 0.0;

    for (final door in doors) {
      final doorWidth = (door['width'] as num?)?.toDouble() ?? 0.0;
      openingsLength += doorWidth;
    }

    for (final window in windows) {
      final windowWidth = (window['width'] as num?)?.toDouble() ?? 0.0;
      openingsLength += windowWidth;
    }

    // Trim length = perímetro - aberturas (assumindo que há trim ao redor das aberturas)
    final trimLength = perimeter - openingsLength;

    return trimLength > 0 ? '${trimLength.toStringAsFixed(0)} linear ft' : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaintProAppBar(
        title: 'Processing...',
        backgroundColor: AppColors.primary,
        textColor: AppColors.textOnPrimary,
        toolbarHeight: 80,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Loading Animation
              Column(
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Processing Photos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Calculating measurements...',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

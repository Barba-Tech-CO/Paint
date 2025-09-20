class ProcessingHelper {
  /// Simulates processing time between 3s to 5s
  static Future<void> simulateProcessing() async {
    final processingTime = Duration(
      milliseconds: 3000 + (DateTime.now().millisecondsSinceEpoch % 2000),
    );

    await Future.delayed(processingTime);
  }

  /// Creates zone data from room data or returns default data
  static Map<String, dynamic> createZoneDataFromRoomData({
    required List<String> capturedPhotos,
    Map<String, dynamic>? roomData,
    Map<String, dynamic>? projectData,
  }) {
    // If we have room data from RoomPlan, use it
    if (roomData != null) {
      final dimensions = roomData['dimensions'] as Map<String, dynamic>?;

      if (dimensions != null) {
        final width = dimensions['width'] as double?;
        final length = dimensions['length'] as double?;
        final floorArea = dimensions['floorArea'] as double?;

        // Calculate paintable area based on real dimensions of each wall
        // Formula: (individual wall areas) - real openings + ceiling
        double totalWallArea = 0.0;

        // Calculate area of each individual wall detected by RoomPlan
        final walls = roomData['walls'] as List<dynamic>? ?? [];

        for (int i = 0; i < walls.length; i++) {
          final wall = walls[i];
          final wallWidth = (wall['width'] as num?)?.toDouble() ?? 0.0;
          final wallHeight = (wall['height'] as num?)?.toDouble() ?? 0.0;
          final wallArea = wallWidth * wallHeight;
          totalWallArea += wallArea;
        }

        // If no walls detected, use estimate based on room dimensions
        if (totalWallArea == 0.0 && width != null && length != null) {
          final height = dimensions['height'] as double? ?? 8.0;
          // 2 width walls + 2 length walls
          totalWallArea = (2 * width * height) + (2 * length * height);
        }

        // Ceiling area
        final ceilingArea = width != null && length != null
            ? width * length
            : 0.0;

        // Calculate real area of openings (doors and windows) detected by RoomPlan
        double realOpeningsArea = 0.0;

        // Sum door areas
        final doors = roomData['doors'] as List<dynamic>? ?? [];
        for (int i = 0; i < doors.length; i++) {
          final door = doors[i];
          final doorWidth = (door['width'] as num?)?.toDouble() ?? 0.0;
          final doorHeight = (door['height'] as num?)?.toDouble() ?? 0.0;
          final doorArea = doorWidth * doorHeight;
          realOpeningsArea += doorArea;
        }

        // Sum window areas
        final windows = roomData['windows'] as List<dynamic>? ?? [];
        for (int i = 0; i < windows.length; i++) {
          final window = windows[i];
          final windowWidth = (window['width'] as num?)?.toDouble() ?? 0.0;
          final windowHeight = (window['height'] as num?)?.toDouble() ?? 0.0;
          final windowArea = windowWidth * windowHeight;
          realOpeningsArea += windowArea;
        }

        // Paintable area = walls - real openings + ceiling
        final paintableArea = width != null && length != null
            ? (totalWallArea - realOpeningsArea) + ceilingArea
            : null;

        final zoneData = {
          'title': roomData['title'] ?? projectData?['zoneName'],
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
          'trimLength': _calculateTrimLength(
            walls,
            doors,
            windows,
            roomData,
          ),
          'image': capturedPhotos.isNotEmpty ? capturedPhotos.first : null,
          // Preserve detailed RoomPlan data for zone editing
          'roomPlanData': {
            'walls': walls,
            'doors': doors,
            'windows': windows,
            'objects': roomData['objects'] as List<dynamic>? ?? [],
            'metadata': roomData['metadata'],
          },
        };

        return zoneData;
      }
    }

    // Empty data if no roomData
    final fallbackData = {
      'title': projectData?['zoneName'],
      'zoneType': 'room',
      'floorDimensionValue': '',
      'floorAreaValue': '',
      'areaPaintable': '',
      'ceilingArea': null,
      'image': capturedPhotos.isNotEmpty ? capturedPhotos.first : null,
      'roomPlanData': null,
    };

    return fallbackData;
  }

  /// Calculates trim length based on walls, doors, and windows
  static String _calculateTrimLength(
    List<dynamic> walls,
    List<dynamic> doors,
    List<dynamic> windows,
    Map<String, dynamic>? roomData,
  ) {
    // Calculate room perimeter based on detected walls
    double perimeter = 0.0;

    for (int i = 0; i < walls.length; i++) {
      final wall = walls[i];
      final wallWidth = (wall['width'] as num?)?.toDouble() ?? 0.0;
      perimeter += wallWidth;
    }

    // If no walls detected, use estimate based on dimensions
    if (perimeter == 0.0) {
      final dimensions = roomData?['dimensions'] as Map<String, dynamic>?;
      if (dimensions != null) {
        final width = dimensions['width'] as double? ?? 0.0;
        final length = dimensions['length'] as double? ?? 0.0;
        if (width > 0 && length > 0) {
          perimeter = 2 * (width + length);
        }
      }
    }

    // Add length of openings (doors and windows)
    double openingsLength = 0.0;

    for (int i = 0; i < doors.length; i++) {
      final door = doors[i];
      final doorWidth = (door['width'] as num?)?.toDouble() ?? 0.0;
      openingsLength += doorWidth;
    }

    for (int i = 0; i < windows.length; i++) {
      final window = windows[i];
      final windowWidth = (window['width'] as num?)?.toDouble() ?? 0.0;
      openingsLength += windowWidth;
    }

    // Trim length = perimeter - openings (assuming there's trim around openings)
    final trimLength = perimeter - openingsLength;

    final result = trimLength > 0
        ? '${trimLength.toStringAsFixed(0)} linear ft'
        : '';
    return result;
  }
}

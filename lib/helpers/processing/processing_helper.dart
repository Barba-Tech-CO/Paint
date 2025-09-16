import 'dart:developer';

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
    log('=== PROCESSING HELPER - ZONE DATA CREATION ===');
    log('ProcessingHelper: Starting zone data creation');
    log('ProcessingHelper: Captured photos count: ${capturedPhotos.length}');
    log('ProcessingHelper: Room data available: ${roomData != null}');
    log('ProcessingHelper: Project data available: ${projectData != null}');

    if (projectData != null) {
      log('ProcessingHelper: Project data: $projectData');
    }

    // If we have room data from RoomPlan, use it
    if (roomData != null) {
      log('ProcessingHelper: Processing RoomPlan data');
      log('ProcessingHelper: Room data keys: ${roomData.keys.toList()}');
      final dimensions = roomData['dimensions'] as Map<String, dynamic>?;
      log('ProcessingHelper: Dimensions available: ${dimensions != null}');

      if (dimensions != null) {
        final width = dimensions['width'] as double?;
        final length = dimensions['length'] as double?;
        final floorArea = dimensions['floorArea'] as double?;

        log('ProcessingHelper: Room dimensions:');
        log('ProcessingHelper: - Width: ${width}m');
        log('ProcessingHelper: - Length: ${length}m');
        log('ProcessingHelper: - Floor area: ${floorArea} sq m');

        // Calculate paintable area based on real dimensions of each wall
        // Formula: (individual wall areas) - real openings + ceiling
        double totalWallArea = 0.0;

        // Calculate area of each individual wall detected by RoomPlan
        final walls = roomData['walls'] as List<dynamic>? ?? [];
        log('ProcessingHelper: Processing ${walls.length} walls');

        for (int i = 0; i < walls.length; i++) {
          final wall = walls[i];
          final wallWidth = (wall['width'] as num?)?.toDouble() ?? 0.0;
          final wallHeight = (wall['height'] as num?)?.toDouble() ?? 0.0;
          final wallArea = wallWidth * wallHeight;
          totalWallArea += wallArea;
          log(
            'ProcessingHelper: Wall $i - Width: ${wallWidth}m, Height: ${wallHeight}m, Area: ${wallArea} sq m',
          );
        }

        log(
          'ProcessingHelper: Total wall area calculated: ${totalWallArea} sq m',
        );

        // If no walls detected, use estimate based on room dimensions
        if (totalWallArea == 0.0 && width != null && length != null) {
          final height = dimensions['height'] as double? ?? 8.0;
          // 2 width walls + 2 length walls
          totalWallArea = (2 * width * height) + (2 * length * height);
          log(
            'ProcessingHelper: No walls detected, using estimated wall area: ${totalWallArea} sq m',
          );
        }

        // Ceiling area
        final ceilingArea = width != null && length != null
            ? width * length
            : 0.0;
        log('ProcessingHelper: Ceiling area: ${ceilingArea} sq m');

        // Calculate real area of openings (doors and windows) detected by RoomPlan
        double realOpeningsArea = 0.0;

        // Sum door areas
        final doors = roomData['doors'] as List<dynamic>? ?? [];
        log('ProcessingHelper: Processing ${doors.length} doors');
        for (int i = 0; i < doors.length; i++) {
          final door = doors[i];
          final doorWidth = (door['width'] as num?)?.toDouble() ?? 0.0;
          final doorHeight = (door['height'] as num?)?.toDouble() ?? 0.0;
          final doorArea = doorWidth * doorHeight;
          realOpeningsArea += doorArea;
          log(
            'ProcessingHelper: Door $i - Width: ${doorWidth}m, Height: ${doorHeight}m, Area: ${doorArea} sq m',
          );
        }

        // Sum window areas
        final windows = roomData['windows'] as List<dynamic>? ?? [];
        log('ProcessingHelper: Processing ${windows.length} windows');
        for (int i = 0; i < windows.length; i++) {
          final window = windows[i];
          final windowWidth = (window['width'] as num?)?.toDouble() ?? 0.0;
          final windowHeight = (window['height'] as num?)?.toDouble() ?? 0.0;
          final windowArea = windowWidth * windowHeight;
          realOpeningsArea += windowArea;
          log(
            'ProcessingHelper: Window $i - Width: ${windowWidth}m, Height: ${windowHeight}m, Area: ${windowArea} sq m',
          );
        }

        log('ProcessingHelper: Total openings area: ${realOpeningsArea} sq m');

        // Paintable area = walls - real openings + ceiling
        final paintableArea = width != null && length != null
            ? (totalWallArea - realOpeningsArea) + ceilingArea
            : null;
        log(
          'ProcessingHelper: Calculated paintable area: ${paintableArea} sq m',
        );

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

        log('ProcessingHelper: Generated zone data:');
        log('ProcessingHelper: - Title: ${zoneData['title']}');
        log('ProcessingHelper: - Zone type: ${zoneData['zoneType']}');
        log(
          'ProcessingHelper: - Floor dimensions: ${zoneData['floorDimensionValue']}',
        );
        log('ProcessingHelper: - Floor area: ${zoneData['floorAreaValue']}');
        log('ProcessingHelper: - Paintable area: ${zoneData['areaPaintable']}');
        log('ProcessingHelper: - Ceiling area: ${zoneData['ceilingArea']}');
        log('ProcessingHelper: - Trim length: ${zoneData['trimLength']}');
        log('ProcessingHelper: - Image: ${zoneData['image']}');
        log(
          'ProcessingHelper: - RoomPlan data preserved: ${zoneData['roomPlanData'] != null}',
        );
        log('=== END PROCESSING HELPER - ZONE DATA CREATION ===');

        return zoneData;
      } else {
        log('ProcessingHelper: No dimensions available in room data');
      }
    } else {
      log('ProcessingHelper: No room data available, using fallback');
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

    log('ProcessingHelper: Using fallback zone data:');
    log('ProcessingHelper: - Title: ${fallbackData['title']}');
    log('ProcessingHelper: - Zone type: ${fallbackData['zoneType']}');
    log('ProcessingHelper: - Image: ${fallbackData['image']}');
    log('=== END PROCESSING HELPER - ZONE DATA CREATION ===');

    return fallbackData;
  }

  /// Calculates trim length based on walls, doors, and windows
  static String _calculateTrimLength(
    List<dynamic> walls,
    List<dynamic> doors,
    List<dynamic> windows,
    Map<String, dynamic>? roomData,
  ) {
    log('ProcessingHelper: Calculating trim length');
    log('ProcessingHelper: - Walls count: ${walls.length}');
    log('ProcessingHelper: - Doors count: ${doors.length}');
    log('ProcessingHelper: - Windows count: ${windows.length}');

    // Calculate room perimeter based on detected walls
    double perimeter = 0.0;

    for (int i = 0; i < walls.length; i++) {
      final wall = walls[i];
      final wallWidth = (wall['width'] as num?)?.toDouble() ?? 0.0;
      perimeter += wallWidth;
      log(
        'ProcessingHelper: Wall $i width: ${wallWidth}m, running perimeter: ${perimeter}m',
      );
    }

    // If no walls detected, use estimate based on dimensions
    if (perimeter == 0.0) {
      log('ProcessingHelper: No walls detected, using estimated perimeter');
      final dimensions = roomData?['dimensions'] as Map<String, dynamic>?;
      if (dimensions != null) {
        final width = dimensions['width'] as double? ?? 0.0;
        final length = dimensions['length'] as double? ?? 0.0;
        if (width > 0 && length > 0) {
          perimeter = 2 * (width + length);
          log(
            'ProcessingHelper: Estimated perimeter from dimensions: ${perimeter}m (${width}m x ${length}m)',
          );
        }
      }
    } else {
      log('ProcessingHelper: Calculated perimeter from walls: ${perimeter}m');
    }

    // Add length of openings (doors and windows)
    double openingsLength = 0.0;

    for (int i = 0; i < doors.length; i++) {
      final door = doors[i];
      final doorWidth = (door['width'] as num?)?.toDouble() ?? 0.0;
      openingsLength += doorWidth;
      log(
        'ProcessingHelper: Door $i width: ${doorWidth}m, running openings length: ${openingsLength}m',
      );
    }

    for (int i = 0; i < windows.length; i++) {
      final window = windows[i];
      final windowWidth = (window['width'] as num?)?.toDouble() ?? 0.0;
      openingsLength += windowWidth;
      log(
        'ProcessingHelper: Window $i width: ${windowWidth}m, running openings length: ${openingsLength}m',
      );
    }

    // Trim length = perimeter - openings (assuming there's trim around openings)
    final trimLength = perimeter - openingsLength;
    log(
      'ProcessingHelper: Final trim length calculation: ${perimeter}m - ${openingsLength}m = ${trimLength}m',
    );

    final result = trimLength > 0
        ? '${trimLength.toStringAsFixed(0)} linear ft'
        : '';
    log('ProcessingHelper: Trim length result: $result');
    return result;
  }
}

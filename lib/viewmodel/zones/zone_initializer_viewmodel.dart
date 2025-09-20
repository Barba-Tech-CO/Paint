import 'dart:developer';
import 'package:flutter/material.dart';

import '../../viewmodel/zones/zones_list_viewmodel.dart';

class ZoneInitializerViewModel {
  final ZonesListViewModel listViewModel;

  ZoneInitializerViewModel({required this.listViewModel});

  void initializeZone(Map<String, dynamic> zoneData) {
    // Check if zone already exists to avoid duplicates - only by title
    final existingZone = listViewModel.zones
        .where(
          (zone) => zone.title == zoneData['title'],
        )
        .firstOrNull;

    if (existingZone != null) {
      log(
        'ZoneInitializerViewModel: Zone "${zoneData['title']}" already exists, skipping',
      );
      return;
    }

    // Zone doesn't exist, add it directly through the ZonesListViewModel
    listViewModel.addZone(
      title: zoneData['title'],
      floorDimensionValue: zoneData['floorDimensionValue'],
      floorAreaValue: zoneData['floorAreaValue'],
      areaPaintable: zoneData['areaPaintable'],
      image: zoneData['image'],
      ceilingArea: zoneData['ceilingArea'],
      trimLength: zoneData['trimLength'],
      // Store additional RoomPlan data for zone editing
      roomPlanData: zoneData['roomPlanData'],
    );
  }

  void initializeZoneAfterBuild(
    BuildContext context,
    Map<String, dynamic> zoneData,
  ) {
    log(
      'ZoneInitializerViewModel: initializeZoneAfterBuild called for "${zoneData['title']}"',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        log(
          'ZoneInitializerViewModel: PostFrameCallback executing for "${zoneData['title']}"',
        );
        initializeZone(zoneData);
      } else {
        log(
          'ZoneInitializerViewModel: Context not mounted, skipping initialization',
        );
      }
    });
  }
}

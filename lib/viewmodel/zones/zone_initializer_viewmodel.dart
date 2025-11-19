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
      return;
    }

    listViewModel.addZone(
      title: zoneData['title'],
      floorDimensionValue: zoneData['floorDimensionValue'],
      floorAreaValue: zoneData['floorAreaValue'],
      areaPaintable: zoneData['areaPaintable'],
      image: zoneData['image'],
      ceilingArea: zoneData['ceilingArea'],
      trimLength: zoneData['trimLength'],
      roomPlanData: zoneData['roomPlanData'],
    );
  }

  void initializeZoneAfterBuild(
    BuildContext context,
    Map<String, dynamic> zoneData,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        initializeZone(zoneData);
      }
    });
  }
}

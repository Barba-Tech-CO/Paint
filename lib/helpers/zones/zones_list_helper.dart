import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/dependency_injection.dart';
import '../../viewmodel/zones/zone_detail_viewmodel.dart';
import '../../viewmodel/zones/zones_list_viewmodel.dart';

class ZonesListHelper {
  // Private constructor to prevent instantiation
  ZonesListHelper._();

  /// Handle zone tap navigation
  static void onZoneTap(
    BuildContext context,
    dynamic zone,
    ZonesListViewModel listViewModel,
  ) {
    listViewModel.selectZone(zone);
    context.push('/zones-details', extra: zone);
  }

  /// Handle zone edit navigation
  static void onZoneEdit(BuildContext context, dynamic zone) {
    context.push('/edit-zone', extra: zone);
  }

  /// Handle zone rename
  static void onZoneRename(
    BuildContext context,
    dynamic zone,
    String newName,
    ZonesListViewModel listViewModel,
  ) {
    final detailViewModel = getIt<ZoneDetailViewModel>();
    detailViewModel.setCurrentZone(zone);

    detailViewModel.onZoneUpdated = (updatedZone) {
      listViewModel.updateZone(updatedZone);
    };

    detailViewModel.renameZone(zone.id, newName);
  }

  /// Handle zone delete
  static void onZoneDelete(
    BuildContext context,
    dynamic zone,
    ZonesListViewModel listViewModel,
  ) {
    final detailViewModel = getIt<ZoneDetailViewModel>();
    detailViewModel.setCurrentZone(zone);

    detailViewModel.onZoneDeleted = (deletedZoneId) {
      listViewModel.removeZone(deletedZoneId);
    };

    detailViewModel.deleteZone(zone.id);
  }

  /// Extract photo paths from zone data
  static List<String> extractPhotoPaths(dynamic zone) {
    // Try to get photos from roomPlanData first
    if (zone.roomPlanData != null) {
      final photos = zone.roomPlanData['photos'] as List?;
      if (photos != null && photos.isNotEmpty) {
        return photos.cast<String>();
      }
    }

    // Fallback to single image if no photos array
    if (zone.image != null && zone.image.isNotEmpty) {
      return [zone.image];
    }

    // Return empty list if no photos
    return [];
  }
}

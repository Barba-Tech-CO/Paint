import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/dependency_injection.dart';
import '../../viewmodel/zones/zone_detail_viewmodel.dart';
import '../../viewmodel/zones/zones_list_viewmodel.dart';
import '../cards/zones_card.dart';

class ZonesListWidget extends StatelessWidget {
  final ZonesListViewModel listViewModel;

  const ZonesListWidget({
    super.key,
    required this.listViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            ...listViewModel.zones.asMap().entries.map(
              (entry) {
                final zone = entry.value;
                return Column(
                  children: [
                    ZonesCard(
                      title: zone.title,
                      image: zone.image,
                      valueDimension: zone.floorDimensionValue,
                      valueArea: zone.floorAreaValue,
                      valuePaintable: zone.areaPaintable,
                      onTap: () => _onZoneTap(context, zone),
                      onEdit: () => _onZoneEdit(context, zone),
                      onRename: (newName) =>
                          _onZoneRename(context, zone, newName),
                      onDelete: () => _onZoneDelete(context, zone),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _onZoneTap(BuildContext context, dynamic zone) {
    listViewModel.selectZone(zone);
    context.push('/zones-details', extra: zone);
  }

  void _onZoneEdit(BuildContext context, dynamic zone) {
    context.push('/edit-zone', extra: zone);
  }

  void _onZoneRename(BuildContext context, dynamic zone, String newName) {
    final detailViewModel = getIt<ZoneDetailViewModel>();
    detailViewModel.setCurrentZone(zone);

    detailViewModel.onZoneUpdated = (updatedZone) {
      listViewModel.updateZone(updatedZone);
    };

    detailViewModel.renameZone(zone.id, newName);
  }

  void _onZoneDelete(BuildContext context, dynamic zone) {
    final detailViewModel = getIt<ZoneDetailViewModel>();
    detailViewModel.setCurrentZone(zone);

    detailViewModel.onZoneDeleted = (deletedZoneId) {
      listViewModel.removeZone(deletedZoneId);
    };

    detailViewModel.deleteZone(zone.id);
  }
}

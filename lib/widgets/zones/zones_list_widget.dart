import 'package:flutter/material.dart';

import '../../helpers/zones/zones_list_helper.dart';
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
                      photoPaths: ZonesListHelper.extractPhotoPaths(zone),
                      valueDimension: zone.floorDimensionValue,
                      valueArea: zone.floorAreaValue,
                      valuePaintable: zone.areaPaintable,
                      onTap: () => ZonesListHelper.onZoneTap(
                        context,
                        zone,
                        listViewModel,
                      ),
                      onEdit: () => ZonesListHelper.onZoneEdit(context, zone),
                      onRename: (newName) => ZonesListHelper.onZoneRename(
                        context,
                        zone,
                        newName,
                        listViewModel,
                      ),
                      onDelete: () => ZonesListHelper.onZoneDelete(
                        context,
                        zone,
                        listViewModel,
                      ),
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
}

import 'package:flutter/material.dart';

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
                      photoPaths: listViewModel.extractPhotoPaths(zone),
                      valueDimension: zone.floorDimensionValue,
                      valueArea: zone.floorAreaValue,
                      valuePaintable: zone.areaPaintable,
                      onTap: () =>
                          listViewModel.navigateToZoneDetails(context, zone),
                      onEdit: () =>
                          listViewModel.navigateToEditZone(context, zone),
                      onRename: (newName) => listViewModel.renameZone(
                        context,
                        zone,
                        newName,
                      ),
                      onDelete: () => listViewModel.deleteZone(
                        context,
                        zone,
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

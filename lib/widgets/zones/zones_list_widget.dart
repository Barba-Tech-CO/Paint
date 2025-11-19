import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
            SizedBox(height: 16.h),
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
                    SizedBox(height: 16.h),
                  ],
                );
              },
            ),
            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }
}

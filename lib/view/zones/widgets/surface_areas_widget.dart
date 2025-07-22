import 'package:flutter/material.dart';
import 'package:paintpro/view/zones/widgets/surface_row_widget.dart';
import 'package:paintpro/view/widgets/cards/input_card_widget.dart';

class SurfaceAreasWidget extends StatelessWidget {
  final Map<String, dynamic> surfaceData;

  const SurfaceAreasWidget({
    super.key,
    required this.surfaceData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: InputCardWidget(
        title: 'Surface Areas',
        padding: EdgeInsets.zero,
        widget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SurfaceRowWidget(
              label: 'Walls',
              value: '${surfaceData['walls']} sq ft',
            ),
            SurfaceRowWidget(
              label: 'Ceiling',
              value: '${surfaceData['ceiling']} sq ft',
            ),
            SurfaceRowWidget(
              label: 'Trim',
              value: '${surfaceData['trim']} linear ft',
            ),
            const Divider(),
            SurfaceRowWidget(
              label: 'Total Paintable',
              value: '${surfaceData['totalPaintable']} sq ft',
              isBold: true,
              valueColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

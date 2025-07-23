import 'package:flutter/material.dart';
import 'package:paintpro/view/widgets/buttons/paint_pro_button.dart';
import 'package:paintpro/view/zones/widgets/zones_card.dart';
import 'package:paintpro/view/zones/widgets/zones_summary_card.dart';

class ZonesResultsWidget extends StatelessWidget {
  final Map<String, dynamic> results;

  const ZonesResultsWidget({
    super.key,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            ZonesCard(
              title: 'Kitchen',
              image: "assets/images/kitchen.png",
              valueDimension: '14 x 16',
              valueArea: '224 sq ft',
              valuePaintable: '631 sq ft',
            ),
            const SizedBox(height: 16),
            ZonesCard(
              title: 'Kitchen',
              image: "assets/images/kitchen.png",
              valueDimension: '14 x 16',
              valueArea: '224 sq ft',
              valuePaintable: '631 sq ft',
            ),
            const SizedBox(height: 16),
            ZonesCard(
              title: 'Kitchen',
              image: "assets/images/kitchen.png",
              valueDimension: '14 x 16',
              valueArea: '224 sq ft',
              valuePaintable: '631 sq ft',
            ),
            const SizedBox(height: 16),
            ZonesSummaryCard(
              avgDimensions: '14 x 16',
              totalArea: '752 sq ft',
              totalPaintable: '2031 sq ft',
              onAdd: () {
                // ação ao clicar no botão +
              },
            ),
            const SizedBox(height: 32),
            PaintProButton(
              text: "Next",
              onPressed: () {
                // ação ao clicar no botão Next
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:paintpro/view/widgets/buttons/paint_pro_button.dart';
import 'package:paintpro/view/zones/widgets/zones_card.dart';
import 'package:paintpro/view/zones/widgets/zones_summary_card.dart';

class ZonesResultsWidget extends StatefulWidget {
  final Map<String, dynamic> results;

  const ZonesResultsWidget({
    super.key,
    required this.results,
  });

  @override
  State<ZonesResultsWidget> createState() => _ZonesResultsWidgetState();
}

class _ZonesResultsWidgetState extends State<ZonesResultsWidget> {
  List<Map<String, String>> _zones = [
    {
      'title': 'Kitchen',
      'image': 'assets/images/kitchen.png',
      'valueDimension': '14 x 16',
      'valueArea': '224 sq ft',
      'valuePaintable': '631 sq ft',
    },
    {
      'title': 'Bathroom',
      'image': 'assets/images/kitchen.png',
      'valueDimension': '8 x 10',
      'valueArea': '80 sq ft',
      'valuePaintable': '200 sq ft',
    },
    {
      'title': 'Living Room',
      'image': 'assets/images/kitchen.png',
      'valueDimension': '12 x 15',
      'valueArea': '180 sq ft',
      'valuePaintable': '450 sq ft',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            ..._zones.asMap().entries.map((entry) {
              final i = entry.key;
              final zone = entry.value;
              return Column(
                children: [
                  ZonesCard(
                    title: zone['title']!,
                    image: zone['image']!,
                    valueDimension: zone['valueDimension']!,
                    valueArea: zone['valueArea']!,
                    valuePaintable: zone['valuePaintable']!,
                    onRename: (newName) {
                      setState(() {
                        _zones[i]['title'] = newName;
                      });
                    },
                    onDelete: () {
                      setState(() {
                        _zones.removeAt(i);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),
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

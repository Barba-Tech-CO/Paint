import 'package:flutter/material.dart';
import 'package:paintpro/view/zones/widgets/zones_card.dart';

class MeasurementResultsWidget extends StatelessWidget {
  final Map<String, dynamic> results;

  const MeasurementResultsWidget({
    super.key,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ZonesCard(
            title: 'Kitchen',
            image: "assets/images/kitchen.png",
            valueDimension: '14 x 16',
            valueArea: '224 sq ft',
            valuePaintable: '631 sq ft',
          ),
        ],
      ),
    );
  }
}

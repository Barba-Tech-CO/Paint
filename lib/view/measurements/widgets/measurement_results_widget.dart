import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paintpro/view/measurements/widgets/surface_row_widget.dart';
import 'package:paintpro/view/widgets/cards/input_card_widget.dart';
import 'package:paintpro/view/widgets/cards/stats_card_widget.dart';

class MeasurementResultsWidget extends StatelessWidget {
  final Map<String, dynamic> results;

  const MeasurementResultsWidget({
    super.key,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cabeçalho verde
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              // Ícone de check
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(5),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 24,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Measurements Complete!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              Text(
                'Accuracy: ${results['accuracy']}%',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),

        // Conteúdo e botões mais próximos
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              spacing: 12,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: StatsCardWidget(
                        title: results['floorDimensions'] ?? '-',
                        description: 'Floor Dimensions',
                        titleFontSize: 18,
                        descriptionFontSize: 12,
                        height: 80,
                        borderRadius: 12,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: StatsCardWidget(
                        title: '${results['floorArea']} sq ft',
                        description: 'Floor Area',
                        titleFontSize: 18,
                        descriptionFontSize: 12,
                        height: 80,
                        borderRadius: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox.shrink(),

                // Card Surface Areas usando InputCardWidget
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: InputCardWidget(
                    title: 'Surface Areas',
                    padding: EdgeInsets.zero,
                    widget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SurfaceRowWidget(
                          label: 'Walls',
                          value: '${results['walls']} sq ft',
                        ),
                        SurfaceRowWidget(
                          label: 'Ceiling',
                          value: '${results['ceiling']} sq ft',
                        ),
                        SurfaceRowWidget(
                          label: 'Trim',
                          value: '${results['trim']} linear ft',
                        ),
                        const Divider(),
                        SurfaceRowWidget(
                          label: 'Total Paintable',
                          value: '${results['totalPaintable']} sq ft',
                          isBold: true,
                          valueColor: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),

                // Botões mais próximos do conteúdo
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Adjust'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            context.push('/room-configuration');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Accept'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

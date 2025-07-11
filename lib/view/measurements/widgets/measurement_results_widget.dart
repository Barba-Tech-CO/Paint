import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paintpro/view/measurements/widgets/surface_row_widget.dart';
import 'package:paintpro/view/widgets/cards/input_card_widget.dart';
import 'package:paintpro/view/widgets/buttons/primary_button_widget.dart';

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
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: Colors.green[400],
                  borderRadius: BorderRadius.circular(32),
                ),
                padding: const EdgeInsets.all(5),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 32,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                spacing: 12,
                children: [
                  InputCardWidget(
                    title: 'Room Overview',
                    widget: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.15),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '14 X 16',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Floor Dimensions',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '224 sq ft',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Floor Area',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
                          child: PrimaryButtonWidget(
                            text: 'Adjust',
                            onPressed: () =>
                                context.push('/room-configuration'),
                            backgroundColor: Colors.grey[300],
                            textStyle: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: PrimaryButtonWidget(
                            text: 'Accept',
                            onPressed: () =>
                                context.push('/room-configuration'),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

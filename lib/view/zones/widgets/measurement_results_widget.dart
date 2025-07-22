import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paintpro/view/zones/widgets/measurement_header_widget.dart';
import 'package:paintpro/view/zones/widgets/room_overview_widget.dart';
import 'package:paintpro/view/zones/widgets/surface_areas_widget.dart';
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
        // TODO(gabri): Ver se esse dado vai bater com a api
        MeasurementHeaderWidget(
          accuracy: results['accuracy'] ?? 95,
        ),

        // Conteúdo principal
        Flexible(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                spacing: 12,
                children: [
                  // Room Overview separado
                  RoomOverviewWidget(
                    floorDimensions:
                        '${results['width']} X ${results['height']}',
                    floorArea: '${results['floorArea']} sq ft',
                  ),

                  const SizedBox.shrink(),

                  // Surface Areas separado
                  SurfaceAreasWidget(
                    surfaceData: results,
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

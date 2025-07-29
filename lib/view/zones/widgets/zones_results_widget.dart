import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paintpro/view/widgets/buttons/paint_pro_button.dart';
import 'package:paintpro/view/zones/widgets/zones_card.dart';
import 'package:paintpro/view/zones/widgets/zones_summary_card.dart';
import 'package:paintpro/view/zones/widgets/add_zone_dialog.dart';
import 'package:paintpro/viewmodel/zones/zones_card_viewmodel.dart';

class ZonesResultsWidget extends StatelessWidget {
  final Map<String, dynamic> results;

  const ZonesResultsWidget({
    super.key,
    required this.results,
  });

  void _showAddZoneDialog(BuildContext context, ZonesCardViewmodel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AddZoneDialog(
        onAdd:
            ({
              required String title,
              required String zoneType,
              String? floorDimensionValue,
              String? floorAreaValue,
              String? areaPaintable,
            }) {
              Navigator.of(context).pop();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                viewModel.addZone(
                  title: title, // Remove a formatação com categoria
                  floorDimensionValue: floorDimensionValue ?? "12' x 14'",
                  floorAreaValue: floorAreaValue ?? "168 sq ft",
                  areaPaintable: areaPaintable ?? "420 sq ft",
                );
              });
            },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ZonesCardViewmodel>(
      builder: (context, viewModel, child) {
        // Se ainda está carregando, retorna apenas o loading
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (viewModel.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Erro: ${viewModel.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.refresh(),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                ...viewModel.zones.asMap().entries.map((entry) {
                  final zone = entry.value;
                  return Column(
                    children: [
                      ZonesCard(
                        title: zone.title,
                        image: zone.image,
                        valueDimension: zone.floorDimensionValue,
                        valueArea: zone.floorAreaValue,
                        valuePaintable: zone.areaPaintable,
                        onRename: (newName) {
                          viewModel.renameZone(zone.id, newName);
                        },
                        onDelete: () {
                          viewModel.deleteZone(zone.id);
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }),
                if (viewModel.summary != null)
                  ZonesSummaryCard(
                    avgDimensions: viewModel.summary!.avgDimensions,
                    totalArea: viewModel.summary!.totalArea,
                    totalPaintable: viewModel.summary!.totalPaintable,
                    onAdd: () => _showAddZoneDialog(
                      context,
                      viewModel,
                    ), // Usar nossa função local
                  ),
                const SizedBox(height: 32),
                PaintProButton(
                  text: "Next",
                  onPressed: () {
                    // TODO: Implementar navegação para próxima tela
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Navegação para próxima tela em desenvolvimento',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

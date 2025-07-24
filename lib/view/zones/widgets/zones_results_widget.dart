import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paintpro/view/widgets/buttons/paint_pro_button.dart';
import 'package:paintpro/view/zones/widgets/zones_card.dart';
import 'package:paintpro/view/zones/widgets/zones_summary_card.dart';
import 'package:paintpro/viewmodel/zones/zones_card_viewmodel.dart';

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
                    onAdd: () {
                      // TODO: Implementar adição de nova zona
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Funcionalidade de adicionar zona em desenvolvimento',
                          ),
                        ),
                      );
                    },
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

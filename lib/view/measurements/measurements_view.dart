import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paintpro/viewmodel/measurements/measurements_viewmodel.dart';
import 'package:paintpro/view/measurements/widgets/loading_widget.dart';
import 'package:paintpro/view/widgets/cards/input_card_widget.dart';
import 'package:provider/provider.dart';

class MeasurementsView extends StatelessWidget {
  const MeasurementsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MeasurementsViewModel(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.pop(),
          ),
          title: const Text('Measurements'),
        ),
        body: Consumer<MeasurementsViewModel>(
          builder: (context, viewModel, child) {
            return viewModel.isLoading
                ? const LoadingWidget()
                : _buildResultsScreen(context, viewModel);
          },
        ),
      ),
    );
  }

  Widget _buildResultsScreen(
    BuildContext context,
    MeasurementsViewModel viewModel,
  ) {
    final results = viewModel.measurementResults;

    return Container(
      color: Colors.grey.shade100,
      child: Column(
        children: [
          // Cabeçalho verde
          Container(
            width: double.infinity,
            color: Colors.green.shade50,
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

          // Lista de resultados
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Card Room Overview usando InputCardWidget
                InputCardWidget(
                  title: 'Room Overview',
                  padding: EdgeInsets.zero,
                  widget: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${results['floorDimensions']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Floor Dimensions',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${results['floorArea']} sq ft',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Floor Area',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Card Surface Areas usando InputCardWidget
                InputCardWidget(
                  title: 'Surface Areas',
                  padding: EdgeInsets.zero,
                  widget: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Valores de área
                      _buildSurfaceRow(
                        'Walls',
                        '${results['walls']} sq ft',
                      ),
                      _buildSurfaceRow(
                        'Ceiling',
                        '${results['ceiling']} sq ft',
                      ),
                      _buildSurfaceRow(
                        'Trim',
                        '${results['trim']} linear ft',
                      ),
                      const Divider(),
                      _buildSurfaceRow(
                        'Total Paintable',
                        '${results['totalPaintable']} sq ft',
                        isBold: true,
                        valueColor: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Botões no rodapé
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Botão Adjust
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Reiniciar as medições
                      viewModel.resetMeasurements();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Adjust'),
                  ),
                ),

                const SizedBox(width: 16),

                // Botão Accept
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navegar para próxima etapa
                      context.go('/paint-selection');
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
    );
  }

  // Helper para criar linhas de informação de superfície
  Widget _buildSurfaceRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

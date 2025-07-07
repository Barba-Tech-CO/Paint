import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paintpro/view/widgets/appbars/paint_pro_app_bar.dart';
import 'package:paintpro/viewmodel/measurements/measurements_viewmodel.dart';
import 'package:paintpro/view/measurements/widgets/loading_widget.dart';
import 'package:paintpro/view/widgets/cards/input_card_widget.dart';
import 'package:paintpro/view/widgets/cards/stats_card_widget.dart';
import 'package:provider/provider.dart';

class MeasurementsView extends StatelessWidget {
  const MeasurementsView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cancelar medição?'),
            content: const Text(
              'Se cancelar, os dados preenchidos serão perdidos. Deseja voltar para o início do projeto?',
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(false),
                child: const Text('Ficar'),
              ),
              TextButton(
                onPressed: () => context.pop(true),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        );
        if (shouldLeave == true) {
          context.go('/new-project');
        }
      },
      child: ChangeNotifierProvider(
        create: (context) => MeasurementsViewModel(),
        child: Scaffold(
          body: Consumer<MeasurementsViewModel>(
            builder: (context, viewModel, child) {
              return viewModel.isLoading
                  ? const LoadingWidget()
                  : _buildResultsScreen(context, viewModel);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResultsScreen(
    BuildContext context,
    MeasurementsViewModel viewModel,
  ) {
    final results = viewModel.measurementResults;

    return Scaffold(
      appBar: PaintProAppBar(title: 'Measurements'),
      body: Column(
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
      ),
    );
  }

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

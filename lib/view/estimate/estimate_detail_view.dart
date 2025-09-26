import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/dependency_injection.dart';
import '../../viewmodel/estimate/estimate_detail_viewmodel.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';
import '../../widgets/cards/project_summary_card_widget.dart';
import '../../widgets/summary/material_item_row_widget.dart';
import '../../widgets/summary/project_cost_summary_widget.dart';
import '../../widgets/summary/room_overview_row_widget.dart';
import '../../widgets/summary/summary_info_row_widget.dart';
import '../../widgets/summary/summary_total_row_widget.dart';

class EstimateDetailView extends StatefulWidget {
  final int projectId;

  const EstimateDetailView({
    super.key,
    required this.projectId,
  });

  @override
  State<EstimateDetailView> createState() => _EstimateDetailViewState();
}

class _EstimateDetailViewState extends State<EstimateDetailView> {
  late EstimateDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<EstimateDetailViewModel>();
    _loadEstimateDetail();
  }

  Future<void> _loadEstimateDetail() async {
    await _viewModel.loadEstimateForOverview(widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaintProAppBar(
        title: 'Estimate Details',
        leading: GestureDetector(
          onTap: () {
            if (context.mounted) {
              context.pop();
            }
          },
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: const Icon(Icons.arrow_back_ios),
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, child) {
          if (_viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_viewModel.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _viewModel.error ?? 'Failed to load project details',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _loadEstimateDetail(),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            );
          }

          if (!_viewModel.hasData) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No data',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No project details available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Project Summary Card
                  ProjectSummaryCardWidget(
                    title: 'Project Summary',
                    children: [
                      SummaryInfoRowWidget(
                        label: 'Total Area',
                        value: _viewModel.getFormattedTotalArea(),
                      ),
                      // Widget customizado para exibir as zonas
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Zones:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ..._viewModel.getFormattedZones().map(
                              (zone) => Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  top: 2,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      zone,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SummaryInfoRowWidget(
                        label: 'Paint Type',
                        value: _viewModel.getPaintType(),
                      ),
                    ],
                  ),

                  // Materials Card - dinâmico baseado nos materiais selecionados
                  ProjectSummaryCardWidget(
                    title: 'Materials',
                    children: [
                      // Listar os materiais selecionados
                      if (_viewModel.estimateDetail!.materials.isNotEmpty)
                        ..._viewModel.estimateDetail!.materials.map(
                          (material) {
                            return FutureBuilder<String>(
                              future: _viewModel.getMaterialNameById(
                                material.id,
                              ),
                              builder: (context, snapshot) {
                                final isDone = snapshot.connectionState == ConnectionState.done;
                                final materialName = snapshot.data ?? (isDone ? 'Unknown Material' : 'Loading…');
                                return MaterialItemRowWidget(
                                  title: materialName,
                                  subtitle:
                                      '${material.unit} (Qty: ${material.quantity.toInt()})',
                                  price:
                                      '\$${material.totalPrice.toStringAsFixed(2)}',
                                );
                              },
                            );
                          },
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'No materials selected',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      SummaryTotalRowWidget(
                        label: 'Materials Total:',
                        value: _viewModel.getFormattedMaterialsCost(),
                      ),
                    ],
                  ),

                  // Room Overview Card
                  ProjectSummaryCardWidget(
                    title: 'Metrics Overview',
                    children: [
                      if (_viewModel.estimateDetail!.zones.isNotEmpty)
                        ..._viewModel.estimateDetail!.zones.map(
                          (zone) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Título da zona
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    zone.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                // Medidas da zona
                                RoomOverviewRowWidget(
                                  leftTitle:
                                      '${zone.area.toStringAsFixed(1)} sq ft',
                                  leftSubtitle: 'Floor Area',
                                  rightTitle: zone.type
                                      .replaceAll('_', ' ')
                                      .toUpperCase(),
                                  rightSubtitle: 'Type',
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'No zones selected',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Total Project Cost Card
                  ProjectSummaryCardWidget(
                    children: [
                      ProjectCostSummaryWidget(
                        title: 'Total Project Cost',
                        cost: _viewModel.getFormattedTotalCost(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../model/models.dart';
import '../../viewmodel/viewmodels.dart';
import '../widgets/widgets.dart';

class OverviewZonesView extends StatefulWidget {
  final List<MaterialModel>? selectedMaterials;

  const OverviewZonesView({super.key, this.selectedMaterials});

  @override
  State<OverviewZonesView> createState() => _OverviewZonesViewState();
}

class _OverviewZonesViewState extends State<OverviewZonesView> {
  late OverviewZonesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = OverviewZonesViewModel();

    // Se materiais foram passados, configurá-los no ViewModel
    if (widget.selectedMaterials != null &&
        widget.selectedMaterials!.isNotEmpty) {
      _viewModel.setSelectedMaterials(widget.selectedMaterials!);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaintProAppBar(
        title: 'Measurements',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, child) {
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
                        value: _viewModel.totalArea,
                      ),
                      SummaryInfoRowWidget(
                        label: 'Rooms',
                        value: _viewModel.rooms,
                      ),
                      SummaryInfoRowWidget(
                        label: 'Paint Type',
                        value: _viewModel.paintType,
                      ),
                    ],
                  ),

                  // Materials Card - dinâmico baseado nos materiais selecionados
                  ProjectSummaryCardWidget(
                    title: 'Materials',
                    children: [
                      // Listar os materiais selecionados
                      ..._viewModel.selectedMaterials.map(
                        (material) => MaterialItemRowWidget(
                          title: material.name,
                          subtitle: '${material.code} - ${material.priceUnit}',
                          price: '\$${material.price.toStringAsFixed(2)}',
                        ),
                      ),

                      // Custos adicionais (mão de obra, suprimentos)
                      const MaterialItemRowWidget(
                        title: 'Labor Cost',
                        subtitle: '9 hours x \$45/hr',
                        price: '\$405.00',
                      ),
                      const MaterialItemRowWidget(
                        title: 'Supplies',
                        subtitle: 'Brushes, rollers, drop cloths',
                        price: '\$45.00',
                      ),

                      SummaryTotalRowWidget(
                        label: 'Materials Total:',
                        value:
                            '\$${_viewModel.totalMaterialsCost.toStringAsFixed(2)}',
                      ),
                    ],
                  ),

                  // Room Overview Card
                  ProjectSummaryCardWidget(
                    title: 'Metrics Overview',
                    children: [
                      RoomOverviewRowWidget(
                        leftTitle: _viewModel.floorDimensions,
                        leftSubtitle: 'Floor Dimensions',
                        rightTitle: _viewModel.floorArea,
                        rightSubtitle: 'Floor Area',
                      ),
                    ],
                  ),

                  // Total Project Cost Card
                  ProjectSummaryCardWidget(
                    children: [
                      ProjectCostSummaryWidget(
                        title: 'Total Project Cost',
                        cost:
                            '\$${_viewModel.totalProjectCost.toStringAsFixed(2)}',
                        timeline: 'Timeline: 2-3 days',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                    child: Row(
                      children: [
                        Flexible(
                          child: PaintProButton(
                            text: 'Adjust',
                            borderRadius: 16,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(width: 32),
                        Flexible(
                          child: PaintProButton(
                            text: 'Send Quote',
                            borderRadius: 16,
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            onPressed: () => context.go('/home'),
                          ),
                        ),
                      ],
                    ),
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

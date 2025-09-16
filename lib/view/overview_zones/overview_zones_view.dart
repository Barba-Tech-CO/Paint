import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/dependency_injection.dart';
import '../../helpers/estimate_builder.dart';
import '../../helpers/loading_helper.dart';
import '../../model/material_models/material_model.dart';
import '../../model/projects/project_card_model.dart';
import '../../viewmodel/estimate/estimate_upload_viewmodel.dart';
import '../../viewmodel/overview_zones_viewmodel.dart';
import '../../viewmodel/zones/zones_list_viewmodel.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';
import '../../widgets/buttons/paint_pro_button.dart';
import '../../widgets/cards/project_summary_card_widget.dart';
import '../../widgets/summary/material_item_row_widget.dart';
import '../../widgets/summary/project_cost_summary_widget.dart';
import '../../widgets/summary/room_overview_row_widget.dart';
import '../../widgets/summary/summary_info_row_widget.dart';
import '../../widgets/summary/summary_total_row_widget.dart';

class OverviewZonesView extends StatefulWidget {
  final List<MaterialModel>? selectedMaterials;
  final List<ProjectCardModel>? selectedZones;

  const OverviewZonesView({
    super.key,
    this.selectedMaterials,
    this.selectedZones,
  });

  @override
  State<OverviewZonesView> createState() => _OverviewZonesViewState();
}

class _OverviewZonesViewState extends State<OverviewZonesView> {
  late OverviewZonesViewModel _viewModel;
  late ZonesListViewModel _zonesListViewModel;
  late EstimateUploadViewModel _estimateUploadViewModel;
  late EstimateBuilder _estimateBuilder;

  @override
  void initState() {
    super.initState();
    _viewModel = OverviewZonesViewModel();
    _zonesListViewModel = getIt<ZonesListViewModel>();
    _estimateUploadViewModel = getIt<EstimateUploadViewModel>();
    _estimateBuilder = getIt<EstimateBuilder>();

    // Inicializar o ZonesListViewModel
    _zonesListViewModel.initialize();

    // Adicionar listener para o EstimateUploadViewModel
    _estimateUploadViewModel.addListener(_onEstimateUploadStateChanged);

    // Se materiais foram passados, configurá-los no ViewModel
    if (widget.selectedMaterials != null &&
        widget.selectedMaterials!.isNotEmpty) {
      _viewModel.setSelectedMaterials(widget.selectedMaterials!);
    }

    // Se zonas foram passadas, configurá-las no ViewModel
    if (widget.selectedZones != null && widget.selectedZones!.isNotEmpty) {
      _viewModel.setSelectedZones(widget.selectedZones!);
    } else {
      // Se não há zonas passadas, usar as zonas reais do ZonesListViewModel
      _loadRealZones();
    }
  }

  void _loadRealZones() {
    // Adicionar listener para quando as zonas forem carregadas
    _zonesListViewModel.addListener(_onZonesLoaded);

    // Se já existem zonas carregadas, usá-las imediatamente
    if (_zonesListViewModel.zones.isNotEmpty) {
      _viewModel.setSelectedZones(_zonesListViewModel.zones);
    } else {
      // Se não há zonas carregadas ainda, aguardar um pouco e tentar novamente
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_zonesListViewModel.zones.isNotEmpty) {
          _viewModel.setSelectedZones(_zonesListViewModel.zones);
        }
      });
    }
  }

  void _onZonesLoaded() {
    if (_zonesListViewModel.zones.isNotEmpty &&
        _viewModel.selectedZones.isEmpty) {
      _viewModel.setSelectedZones(_zonesListViewModel.zones);
    }
  }

  @override
  void dispose() {
    _zonesListViewModel.removeListener(_onZonesLoaded);
    _estimateUploadViewModel.removeListener(_onEstimateUploadStateChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onEstimateUploadStateChanged() {
    if (mounted) {
      setState(() {});

      // Handle success state
      if (_estimateUploadViewModel.state == EstimateUploadState.success) {
        LoadingHelper.navigateToQuoteLoading(context);
      }

      // Handle error state
      if (_estimateUploadViewModel.state == EstimateUploadState.error) {
        _showErrorDialog(
          _estimateUploadViewModel.errorMessage ?? 'Unknown error occurred',
        );
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
                            // Debug: Verificar se há zonas
                            if (_viewModel.selectedZones.isEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'No zones selected',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  Text(
                                    'ViewModel zones: ${_viewModel.zonesCount}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.red[400],
                                    ),
                                  ),
                                  Text(
                                    'Real zones available: ${_zonesListViewModel.zones.length}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue[400],
                                    ),
                                  ),
                                ],
                              )
                            else
                              ..._viewModel.formattedZones.map(
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
                            text: _estimateUploadViewModel.isUploading
                                ? 'Sending...'
                                : 'Send Quote',
                            borderRadius: 16,
                            padding: EdgeInsets.zero,
                            backgroundColor:
                                _estimateUploadViewModel.isUploading
                                ? Colors.grey
                                : Colors.blue,
                            foregroundColor: Colors.white,
                            onPressed: _estimateUploadViewModel.isUploading
                                ? null
                                : () async {
                                    // Build EstimateModel from collected data
                                    final estimateModel = _estimateBuilder
                                        .buildEstimateModel(_viewModel);

                                    // Upload estimate using the ViewModel
                                    await _estimateUploadViewModel.upload(
                                      estimateModel,
                                    );
                                  },
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

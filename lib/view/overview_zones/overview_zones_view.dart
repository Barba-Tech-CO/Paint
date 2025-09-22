import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/dependency_injection.dart';
import '../../domain/project_entity.dart';
import '../../model/estimates/estimate_status.dart';
import '../../model/material_models/material_model.dart';
import '../../model/projects/project_card_model.dart';
import '../../viewmodel/estimate/estimate_calculation_viewmodel.dart';
import '../../viewmodel/estimate/estimate_upload_viewmodel.dart';
import '../../viewmodel/overview_zones_viewmodel.dart';
import '../../viewmodel/zones/zones_list_viewmodel.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';
import '../../widgets/buttons/paint_pro_button.dart';
import '../../widgets/cards/project_summary_card_widget.dart';
import '../../widgets/loading/loading_navigation_widget.dart';
import '../../widgets/summary/material_item_row_widget.dart';
import '../../widgets/summary/project_cost_summary_widget.dart';
import '../../widgets/summary/room_overview_row_widget.dart';
import '../../widgets/summary/summary_info_row_widget.dart';
import '../../widgets/summary/summary_total_row_widget.dart';

class OverviewZonesView extends StatefulWidget {
  final List<MaterialModel>? selectedMaterials;
  final Map<MaterialModel, int>? materialQuantities;
  final List<ProjectCardModel>? selectedZones;
  final Map<String, dynamic>? projectData;

  const OverviewZonesView({
    super.key,
    this.selectedMaterials,
    this.materialQuantities,
    this.selectedZones,
    this.projectData,
  });

  @override
  State<OverviewZonesView> createState() => _OverviewZonesViewState();
}

class _OverviewZonesViewState extends State<OverviewZonesView> {
  late OverviewZonesViewModel _viewModel;
  late ZonesListViewModel _zonesListViewModel;
  late EstimateUploadViewModel _estimateUploadViewModel;
  late EstimateCalculationViewModel _estimateCalculationViewModel;

  // Project data from create_project_view
  ProjectEntity? _projectEntity;

  @override
  void initState() {
    super.initState();
    _viewModel = OverviewZonesViewModel();
    _zonesListViewModel = getIt<ZonesListViewModel>();
    _estimateUploadViewModel = getIt<EstimateUploadViewModel>();
    _estimateCalculationViewModel = getIt<EstimateCalculationViewModel>();

    // Inicializar o ZonesListViewModel
    _zonesListViewModel.initialize();

    // Adicionar listener para o EstimateUploadViewModel
    _estimateUploadViewModel.addListener(_onEstimateUploadStateChanged);

    // Extrair dados do projeto se fornecidos
    if (widget.projectData != null) {
      _projectEntity = ProjectEntity.fromMap(widget.projectData!);
    }

    // Se materiais foram passados, configurá-los no ViewModel
    if (widget.selectedMaterials != null &&
        widget.selectedMaterials!.isNotEmpty) {
      _viewModel.setSelectedMaterials(widget.selectedMaterials!);

      // Se quantidades foram passadas, configurá-las também
      if (widget.materialQuantities != null) {
        _viewModel.setMaterialQuantities(widget.materialQuantities!);
      }
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
        LoadingNavigationWidget.navigateToQuoteLoading(context);
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
                      if (_viewModel.selectedMaterials.isNotEmpty)
                        ..._viewModel.selectedMaterials.map(
                          (material) {
                            final quantity = _viewModel.getQuantity(material);
                            final totalPrice = material.price * quantity;
                            return MaterialItemRowWidget(
                              title: material.name,
                              subtitle:
                                  '${material.code} - ${material.priceUnit} (Qty: ${quantity.toInt()})',
                              price: '\$${totalPrice.toStringAsFixed(2)}',
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
                        value:
                            '\$${_viewModel.totalMaterialsCost.toStringAsFixed(2)}',
                      ),
                    ],
                  ),

                  // Room Overview Card
                  ProjectSummaryCardWidget(
                    title: 'Metrics Overview',
                    children: [
                      if (_viewModel.selectedZones.isNotEmpty)
                        ..._viewModel.selectedZones.map(
                          (zone) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Título da zona
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    zone.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                // Medidas da zona
                                RoomOverviewRowWidget(
                                  leftTitle: zone.floorDimensionValue,
                                  leftSubtitle: 'Floor Dimensions',
                                  rightTitle: zone.floorAreaValue,
                                  rightSubtitle: 'Floor Area',
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
                        cost:
                            '\$${_viewModel.totalProjectCost.toStringAsFixed(2)}',
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
                            backgroundColor: Colors.black,
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
                                : 'Send Estimate',
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
                                    try {
                                      // Build EstimateModel from collected data
                                      final estimateModel =
                                          await _estimateCalculationViewModel
                                              .buildEstimateModel(
                                                viewModel: _viewModel,
                                                projectName:
                                                    _projectEntity
                                                        ?.projectName ??
                                                    '',
                                                contactId:
                                                    _projectEntity?.contactId ??
                                                    '',
                                                additionalNotes:
                                                    _projectEntity
                                                        ?.additionalNotes ??
                                                    '',
                                                status: EstimateStatus.draft,
                                                zoneType:
                                                    _projectEntity?.zoneType ??
                                                    'interior',
                                              );

                                      // Upload estimate using the ViewModel
                                      await _estimateUploadViewModel.upload(
                                        estimateModel,
                                      );
                                    } catch (e) {
                                      // Handle error silently or show user-friendly message
                                    }
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
            width: 48.w,
            height: 48.h,
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
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Error',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _viewModel.error ?? 'Failed to load project details',
                    style: TextStyle(
                      fontSize: 16.sp,
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
            return Center(
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
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No project details available',
                    style: TextStyle(
                      fontSize: 16.sp,
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
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Zones:',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            ..._viewModel.getFormattedZones().map(
                              (zone) => Padding(
                                padding: EdgeInsets.only(
                                  left: 8.w,
                                  top: 2.h,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4.w,
                                      height: 4.h,
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      zone,
                                      style: TextStyle(
                                        fontSize: 14.sp,
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
                                final isDone =
                                    snapshot.connectionState ==
                                    ConnectionState.done;
                                final materialName =
                                    snapshot.data ??
                                    (isDone ? 'Unknown Material' : 'Loading…');
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
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: Text(
                            'No materials selected',
                            style: TextStyle(
                              fontSize: 14.sp,
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
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Título da zona
                                Padding(
                                  padding: EdgeInsets.only(bottom: 8.h),
                                  child: Text(
                                    zone.name,
                                    style: TextStyle(
                                      fontSize: 16.sp,
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
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: Text(
                            'No zones selected',
                            style: TextStyle(
                              fontSize: 14.sp,
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

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../config/dependency_injection.dart';
import '../../../viewmodel/zones/zone_detail_viewmodel.dart';
import '../../../viewmodel/zones/zones_list_viewmodel.dart';
import '../../../viewmodel/zones/zones_summary_viewmodel.dart';
import '../../widgets/buttons/paint_pro_button.dart';
import '../../widgets/cards/zones_card.dart';
import 'add_zone_dialog.dart';
import 'zones_summary_card.dart';

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
  late final ZonesListViewModel _listViewModel;
  late final ZonesSummaryViewModel _summaryViewModel;

  @override
  void initState() {
    super.initState();
    _listViewModel = getIt<ZonesListViewModel>();
    _summaryViewModel = getIt<ZonesSummaryViewModel>();

    // Initialize ViewModels
    _listViewModel.initialize();
    _summaryViewModel.initialize();

    // Setup listener to update summary when zones list changes
    _listViewModel.addListener(_updateSummary);
  }

  @override
  void dispose() {
    _listViewModel.removeListener(_updateSummary);
    super.dispose();
  }

  void _updateSummary() {
    _summaryViewModel.updateZonesList(_listViewModel.zones);
  }

  void _showAddZoneDialog(BuildContext context, ZonesListViewModel viewModel) {
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
              context.pop();

              // Adicionar a zona ao ViewModel
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  viewModel.addZone(
                    title: title,
                    floorDimensionValue: floorDimensionValue ?? "12' x 14'",
                    floorAreaValue: floorAreaValue ?? "168 sq ft",
                    areaPaintable: areaPaintable ?? "420 sq ft",
                  );

                  // Navegar para a tela da câmera
                  context.go('/camera');
                }
              });
            },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ZonesListViewModel>.value(value: _listViewModel),
        ChangeNotifierProvider<ZonesSummaryViewModel>.value(
          value: _summaryViewModel,
        ),
      ],
      child: Consumer2<ZonesListViewModel, ZonesSummaryViewModel>(
        builder: (context, listViewModel, summaryViewModel, child) {
          // Se ainda está carregando, retorna apenas o loading
          if (listViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (listViewModel.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Erro: ${listViewModel.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => listViewModel.refresh(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Área scrollável com as zonas
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        ...listViewModel.zones.asMap().entries.map((entry) {
                          final zone = entry.value;
                          return Column(
                            children: [
                              ZonesCard(
                                title: zone.title,
                                image: zone.image,
                                valueDimension: zone.floorDimensionValue,
                                valueArea: zone.floorAreaValue,
                                valuePaintable: zone.areaPaintable,
                                onTap: () {
                                  // Select zone when tapping
                                  listViewModel.selectZone(zone);
                                  context.push('/zones-details', extra: zone);
                                },
                                onEdit: () {
                                  // Navigate to edit zone page
                                  context.push('/edit-zone', extra: zone);
                                },
                                onRename: (newName) {
                                  // Use the ZoneDetailViewModel to maintain consistency
                                  final detailViewModel =
                                      getIt<ZoneDetailViewModel>();
                                  detailViewModel.setCurrentZone(zone);

                                  // Setup callback to update list when rename completes
                                  detailViewModel.onZoneUpdated =
                                      (updatedZone) {
                                        listViewModel.updateZone(updatedZone);
                                      };

                                  detailViewModel.renameZone(zone.id, newName);
                                },
                                onDelete: () {
                                  // Use the ZoneDetailViewModel to maintain consistency
                                  final detailViewModel =
                                      getIt<ZoneDetailViewModel>();
                                  detailViewModel.setCurrentZone(zone);

                                  // Setup callback to update list when delete completes
                                  detailViewModel.onZoneDeleted =
                                      (deletedZoneId) {
                                        listViewModel.removeZone(deletedZoneId);
                                      };

                                  detailViewModel.deleteZone(zone.id);
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }),
                        const SizedBox(
                          height: 80,
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    if (summaryViewModel.summary != null)
                      ZonesSummaryCard(
                        avgDimensions: summaryViewModel.summary!.avgDimensions,
                        totalArea: summaryViewModel.summary!.totalArea,
                        totalPaintable:
                            summaryViewModel.summary!.totalPaintable,
                        onAdd: () => _showAddZoneDialog(
                          context,
                          listViewModel,
                        ),
                      ),
                    const SizedBox(height: 32),
                    PaintProButton(
                      text: "Next",
                      onPressed: () => context.push('/select-material'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

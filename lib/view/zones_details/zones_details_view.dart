import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paintpro/config/dependency_injection.dart';
import 'package:paintpro/config/app_colors.dart';
import 'package:paintpro/view/widgets/widgets.dart';
import 'package:paintpro/model/zones_card_model.dart';
import 'package:paintpro/view/widgets/buttons/paint_pro_delete_button.dart';
import 'package:paintpro/view/zones_details/widgets/rename_zone_dialog.dart';
import 'package:paintpro/viewmodel/zones/zones_viewmodels.dart';

class ZonesDetailsView extends StatefulWidget {
  final ZonesCardModel? zone;
  const ZonesDetailsView({super.key, this.zone});

  @override
  State<ZonesDetailsView> createState() => _ZonesDetailsViewState();
}

class _ZonesDetailsViewState extends State<ZonesDetailsView> {
  late final ZoneDetailViewModel _detailViewModel;
  late final ZonesListViewModel _listViewModel;

  @override
  void initState() {
    super.initState();
    _detailViewModel = getIt<ZoneDetailViewModel>();
    _listViewModel = getIt<ZonesListViewModel>();

    // Initialize ViewModels only once (safe for multiple calls)
    _detailViewModel.initialize();
    _listViewModel.initialize();

    // Set current zone
    if (widget.zone != null) {
      _detailViewModel.setCurrentZone(widget.zone!);
    }

    // Setup callbacks for communication with list ViewModel
    _setupViewModelCallbacks();
  }

  @override
  void dispose() {
    // Clear callbacks to prevent memory leaks
    _detailViewModel.onZoneDeleted = null;
    _detailViewModel.onZoneUpdated = null;
    super.dispose();
  }

  void _setupViewModelCallbacks() {
    // When zone is deleted, remove from list and navigate back
    _detailViewModel.onZoneDeleted = (int zoneId) {
      if (mounted) {
        _listViewModel.removeZone(zoneId);
        // Use WidgetsBinding to ensure safe context usage
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.pop();
          }
        });
      }
    };

    // When zone is updated, update in list
    _detailViewModel.onZoneUpdated = (ZonesCardModel updatedZone) {
      if (mounted) {
        _listViewModel.updateZone(updatedZone);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _detailViewModel,
      builder: (context, _) {
        if (_detailViewModel.currentZone == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: Text('Zone was not found.')),
          );
        }
        return _ZonesDetailsContent(viewModel: _detailViewModel);
      },
    );
  }
}

class _ZonesDetailsContent extends StatelessWidget {
  final ZoneDetailViewModel viewModel;
  const _ZonesDetailsContent({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, child) {
        final zone = viewModel.currentZone!;
        final photoUrls = [zone.image];

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: PaintProAppBar(
            title: zone.title,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => context.pop(),
            ),
            actions: [
              PaintProDeleteButton(viewModel: viewModel),
            ],
          ),
          body: Stack(
            children: [
              // Conteúdo rolável
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Room',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          RoomOverviewRowWidget(
                            leftTitle: zone.floorDimensionValue,
                            leftSubtitle: 'Floor Dimensions',
                            rightTitle: zone.floorAreaValue,
                            rightSubtitle: 'Floor Area',
                            titleColor: const Color(0xFF1A73E8),
                            subtitleColor: Colors.black54,
                            titleFontSize: 20,
                            subtitleFontSize: 13,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SurfaceAreasWidget(
                        surfaceData: {
                          'Walls': zone.areaPaintable,
                          if (zone.ceilingArea != null)
                            'Ceiling': zone.ceilingArea!,
                          if (zone.trimLength != null) 'Trim': zone.trimLength!,
                        },
                        totalPaintableLabel: 'Total Paintable',
                        totalPaintableValue: zone.areaPaintable,
                      ),
                      const SizedBox(height: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Photos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                ),
                            itemCount: photoUrls.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final url = photoUrls[index];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  url,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      // Espaço adicional para não sobrepor os botões
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              // Botões fixos na parte inferior
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: Row(
                  children: [
                    Flexible(
                      child: PaintProButton(
                        text: 'Edit',
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                        onPressed: viewModel.isRenaming
                            ? null
                            : () => RenameZoneDialog.show(context, viewModel),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Flexible(
                      child: PaintProButton(
                        text: 'OK',
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

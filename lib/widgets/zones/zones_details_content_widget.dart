import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_colors.dart';
import '../../config/dependency_injection.dart';
import '../../utils/logger/app_logger.dart';
import '../../viewmodel/zones/zone_detail_viewmodel.dart';
import '../appbars/paint_pro_app_bar.dart';
import '../buttons/paint_pro_button.dart';
import '../buttons/paint_pro_delete_button.dart';
import '../cards/surface_areas_widget.dart';
import '../dialogs/app_dialogs.dart';
import '../summary/room_overview_row_widget.dart';

class ZonesDetailsContentWidget extends StatelessWidget {
  final ZoneDetailViewModel viewModel;

  const ZonesDetailsContentWidget({
    super.key,
    required this.viewModel,
  });

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
              PaintProDeleteButton(
                viewModel: viewModel,
                logger: getIt<AppLogger>(),
              ),
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
                            : () =>
                                  AppDialogs.showRenameZoneDialogWithViewModel(
                                    context,
                                    viewModel: viewModel,
                                  ),
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

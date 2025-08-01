import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paintpro/config/dependency_injection.dart';
import 'package:paintpro/view/widgets/buttons/paint_pro_button.dart';
import 'package:paintpro/config/app_colors.dart';
import 'package:paintpro/view/widgets/widgets.dart';
import 'package:paintpro/model/zones_card_model.dart';
import 'package:paintpro/viewmodel/zones/zones_viewmodels.dart';

class ZonesDetails extends StatefulWidget {
  final ZonesCardModel? zone;
  const ZonesDetails({super.key, this.zone});

  @override
  State<ZonesDetails> createState() => _ZonesDetailsState();
}

class _ZonesDetailsState extends State<ZonesDetails> {
  late final ZoneDetailViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = getIt<ZoneDetailViewModel>();
    viewModel.setZone(widget.zone!);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        if (viewModel.zone == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: Text('Zone was not found.')),
          );
        }
        return _ZonesDetailsContent(viewModel: viewModel);
      },
    );
  }
}

class _ZonesDetailsContent extends StatelessWidget {
  final ZoneDetailViewModel viewModel;
  const _ZonesDetailsContent({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final zone = viewModel.zone!;
    final photoUrls = [zone.image];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, zone),
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
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 24),
                Flexible(
                  child: PaintProButton(
                    text: 'Rename',
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ZonesCardModel zone) {
    return PaintProAppBar(
      title: zone.title,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => context.pop(),
      ),
      actions: [
        _DeleteZoneButton(viewModel: viewModel),
      ],
    );
  }
}

class _DeleteZoneButton extends StatelessWidget {
  final ZoneDetailViewModel viewModel;
  const _DeleteZoneButton({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Zone'),
            content: const Text(
              'Are you sure you want to delete this Zone?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes, go delete'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await viewModel.deleteZone();
          if (context.mounted) {
            context.pop();
          }
        }
      },
      icon: const Icon(Icons.delete_outline_rounded),
    );
  }
}

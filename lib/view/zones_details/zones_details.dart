import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:paintpro/config/app_colors.dart';
import 'package:paintpro/view/widgets/widgets.dart';
import 'package:paintpro/model/zones_card_model.dart';
import 'package:paintpro/viewmodel/zones/zones_viewmodels.dart';

class ZonesDetails extends StatelessWidget {
  final ZonesCardModel? zone;
  const ZonesDetails({super.key, this.zone});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ZoneDetailViewModel>(
      create: (_) => ZoneDetailViewModel(zone),
      child: Builder(
        builder: (context) {
          return Consumer<ZoneDetailViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isLoading) {
                return const Scaffold(
                  backgroundColor: AppColors.background,
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (viewModel.zone == null) {
                return const Scaffold(
                  backgroundColor: AppColors.background,
                  body: Center(child: Text('Zona não encontrada.')),
                );
              }
              return const _ZonesDetailsContent();
            },
          );
        },
      ),
    );
  }
}

class _ZonesDetailsContent extends StatelessWidget {
  const _ZonesDetailsContent();

  @override
  Widget build(BuildContext context) {
    final zone = context.watch<ZoneDetailViewModel>().zone!;
    final photoUrls = [zone.image];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, zone),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 16.0,
          ),
          child: Column(
            children: [
              _buildRoomSection(zone),
              const SizedBox(height: 24),
              _buildSurfaceAreasSection(zone),
              const SizedBox(height: 24),
              _buildPhotosSection(photoUrls),
            ],
          ),
        ),
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
        _DeleteZoneButton(),
        _RenameZoneButton(),
      ],
    );
  }

  Widget _buildRoomSection(ZonesCardModel zone) {
    return Column(
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
    );
  }

  Widget _buildSurfaceAreasSection(ZonesCardModel zone) {
    return SurfaceAreasWidget(
      surfaceData: {
        'Walls': zone.areaPaintable,
      },
      totalPaintableLabel: 'Total Paintable',
      totalPaintableValue: zone.areaPaintable,
    );
  }

  Widget _buildPhotosSection(List<String> photoUrls) {
    return Column(
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
        GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final url in photoUrls)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _DeleteZoneButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Apagar zona'),
            content: const Text(
              'Tem certeza que deseja apagar esta zona?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Apagar'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await context.read<ZoneDetailViewModel>().deleteZone();
          if (context.mounted) {
            context.pop();
          }
        }
      },
      icon: const Icon(Icons.delete_outline_rounded),
    );
  }
}

class _RenameZoneButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final zone = context.read<ZoneDetailViewModel>().zone!;
        final controller = TextEditingController(text: zone.title);

        final newName = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Renomear zona'),
            content: TextField(
              decoration: const InputDecoration(
                hintText: 'Novo nome',
              ),
              controller: controller,
              onSubmitted: (value) => Navigator.of(context).pop(value),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(controller.text),
                child: const Text('Salvar'),
              ),
            ],
          ),
        );

        controller.dispose();

        if (newName != null && newName.trim().isNotEmpty) {
          await context.read<ZoneDetailViewModel>().renameZone(newName.trim());
        }
      },
      icon: const Icon(Icons.edit),
    );
  }
}

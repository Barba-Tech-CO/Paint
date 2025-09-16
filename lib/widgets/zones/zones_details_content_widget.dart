import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_colors.dart';
import '../../config/dependency_injection.dart';
import '../../model/projects/project_card_model.dart';
import '../../utils/logger/app_logger.dart';
import '../../viewmodel/zones/zone_detail_viewmodel.dart';
import '../appbars/paint_pro_app_bar.dart';
import '../buttons/paint_pro_button.dart';
import '../buttons/paint_pro_delete_button.dart';
import '../dialogs/delete_photo_dialog.dart';
import '../dialogs/rename_zone_dialog.dart';
import 'floor_dimension_widget.dart';
import 'surface_area_display_widget.dart';
import 'zone_photos_widget.dart';

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
        // Verificar se a zona ainda existe antes de renderizar
        if (viewModel.currentZone == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final zone = viewModel.currentZone!;
        final photoUrls = _getPhotoUrls(zone);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: PaintProAppBar(
            title: zone.title,
            leadingWidth: 120,
            leading: InkWell(
              onTap: () => context.pop(),
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.textOnPrimary,
                      size: 24,
                    ),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
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
                            'Room Metrics',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FloorDimensionWidget(
                            width: double.tryParse(
                              zone.floorDimensionValue.split(' x ')[0],
                            ),
                            length: double.tryParse(
                              zone.floorDimensionValue.split(' x ')[1],
                            ),
                            onDimensionChanged: (width, length) {
                              viewModel.updateZoneDimensions(width, length);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SurfaceAreaDisplayWidget(
                        walls: double.tryParse(zone.areaPaintable),
                        ceiling: zone.ceilingArea != null
                            ? double.tryParse(zone.ceilingArea!)
                            : null,
                        trim: zone.trimLength != null
                            ? double.tryParse(zone.trimLength!)
                            : null,
                        onWallsChanged: (walls) {
                          viewModel.updateZoneSurfaceAreas(walls: walls);
                        },
                        onCeilingChanged: (ceiling) {
                          viewModel.updateZoneSurfaceAreas(ceiling: ceiling);
                        },
                        onTrimChanged: (trim) {
                          viewModel.updateZoneSurfaceAreas(trim: trim);
                        },
                      ),
                      const SizedBox(height: 64),
                      ZonePhotosWidget(
                        photoUrls: photoUrls,
                        onAddPhoto: () => _addPhoto(context),
                        onDeletePhoto: (index) async =>
                            await _deletePhoto(context, index),
                        minPhotos: 3,
                        maxPhotos: 9,
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 170,
                      child: PaintProButton(
                        text: 'Edit',
                        backgroundColor: AppColors.gray16,
                        foregroundColor: Colors.black,
                        onPressed: viewModel.isRenaming
                            ? null
                            : () => _showRenameZoneDialog(context),
                      ),
                    ),
                    SizedBox(
                      width: 170,
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

  List<String> _getPhotoUrls(ProjectCardModel zone) {
    // Se roomPlanData tem fotos, usa elas; senão usa a imagem principal
    if (zone.roomPlanData != null && zone.roomPlanData!['photos'] is List) {
      final photos = zone.roomPlanData!['photos'] as List;
      return photos.cast<String>();
    }
    // Fallback para a imagem principal se não houver fotos na lista
    return zone.image.isNotEmpty ? [zone.image] : [];
  }

  Future<void> _addPhoto(BuildContext context) async {
    try {
      final currentPhotos = _getPhotoUrls(viewModel.currentZone!).length;
      final maxPhotos = 9;

      // Verificar se ainda pode adicionar fotos
      if (currentPhotos >= maxPhotos) {
        return; // Não fazer nada se já atingiu o máximo
      }

      // Navegar diretamente para a câmera com as fotos existentes
      final projectData = {
        'zoneId': viewModel.currentZone!.id,
        'existingPhotos': _getPhotoUrls(viewModel.currentZone!),
        'currentPhotoCount': currentPhotos,
        'maxPhotos': maxPhotos,
      };

      final result = await context.push('/camera', extra: projectData);

      // Se a câmera retornou fotos, atualizar a zona
      if (result is List<String> && result.isNotEmpty) {
        _updateZonePhotos(result);
      }
    } catch (e) {
      // Mostrar erro se necessário
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding photo: $e')),
        );
      }
    }
  }

  Future<void> _deletePhoto(BuildContext context, int index) async {
    final bool? shouldDelete = await DeletePhotoDialog.show(context);
    if (shouldDelete == true) {
      viewModel.deletePhoto(index);
    }
  }

  Future<void> _showRenameZoneDialog(BuildContext context) async {
    final zone = viewModel.currentZone;
    if (zone == null) return;

    final newName = await RenameZoneDialog.show(
      context,
      initialName: zone.title,
    );

    if (newName != null &&
        newName.isNotEmpty &&
        newName != zone.title &&
        context.mounted) {
      await viewModel.renameZone(zone.id, newName);
    }
  }

  void _updateZonePhotos(List<String> photos) {
    if (viewModel.currentZone != null) {
      // Criar uma nova zona com as fotos atualizadas
      final updatedZone = viewModel.currentZone!.copyWith(
        roomPlanData: {
          ...viewModel.currentZone!.roomPlanData ?? {},
          'photos': photos,
        },
      );

      // Atualizar a zona no viewmodel
      viewModel.setCurrentZone(updatedZone);
    }
  }
}

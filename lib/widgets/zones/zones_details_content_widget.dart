import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_colors.dart';
import '../../config/dependency_injection.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/unit_converter.dart' as app_unit_converter;
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
        final photoUrls = viewModel.getPhotoUrls(zone);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: PaintProAppBar(
            title: zone.title,
            leadingWidth: 120.w,
            leading: GestureDetector(
              onTap: () {
                if (context.mounted) {
                  context.pop();
                }
              },
              child: Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.textOnPrimary,
                      size: 24.sp,
                    ),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 18.sp,
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Room Metrics',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          FloorDimensionWidget(
                            width: viewModel.hasRoomPlanData
                                ? app_unit_converter
                                      .UnitConverter.metersToFeetConversion(
                                    (viewModel.getRoomPlanDimensions()?['width']
                                            as double?) ??
                                        0.0,
                                  )
                                : viewModel.parseDimension(
                                        zone.floorDimensionValue,
                                        0,
                                      ) ??
                                      0.0,
                            length: viewModel.hasRoomPlanData
                                ? app_unit_converter
                                      .UnitConverter.metersToFeetConversion(
                                    (viewModel.getRoomPlanDimensions()?['length']
                                            as double?) ??
                                        0.0,
                                  )
                                : viewModel.parseDimension(
                                        zone.floorDimensionValue,
                                        1,
                                      ) ??
                                      0.0,
                            onDimensionChanged: (width, length) {
                              viewModel.updateZoneDimensions(width, length);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      SurfaceAreaDisplayWidget(
                        walls: viewModel.hasRoomPlanData
                            ? app_unit_converter
                                  .UnitConverter.sqMetersToSqFeetConversion(
                                _calculateTotalWallArea(
                                  viewModel.getRoomPlanWalls(),
                                ),
                              )
                            : double.tryParse(zone.areaPaintable) ?? 0.0,
                        ceiling: viewModel.hasRoomPlanData
                            ? app_unit_converter
                                  .UnitConverter.sqMetersToSqFeetConversion(
                                (viewModel.getRoomPlanDimensions()?['floorArea']
                                        as double?) ??
                                    0.0,
                              )
                            : zone.ceilingArea != null
                            ? double.tryParse(zone.ceilingArea!) ?? 0.0
                            : null,
                        trim: viewModel.hasRoomPlanData
                            ? app_unit_converter
                                  .UnitConverter.metersToFeetConversion(
                                _calculateTrimLength(
                                  viewModel.getRoomPlanWalls(),
                                ),
                              )
                            : zone.trimLength != null
                            ? double.tryParse(zone.trimLength!) ?? 0.0
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
                      SizedBox(height: 64.h),
                      ZonePhotosWidget(
                        photoUrls: photoUrls,
                        onAddPhoto: () => _addPhoto(context),
                        onDeletePhoto: (index) async =>
                            await _deletePhoto(context, index),
                        minPhotos: 3,
                        maxPhotos: 9,
                      ),
                      // Espaço adicional para não sobrepor os botões
                      SizedBox(height: 100.h),
                    ],
                  ),
                ),
              ),

              // Botões fixos na parte inferior
              Positioned(
                left: 24.w,
                right: 24.w,
                bottom: 24.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 170.w,
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
                      width: 170.w,
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

  Future<void> _addPhoto(BuildContext context) async {
    try {
      final currentPhotos = viewModel
          .getPhotoUrls(viewModel.currentZone!)
          .length;
      final maxPhotos = 9;

      // Verificar se ainda pode adicionar fotos
      if (currentPhotos >= maxPhotos) {
        return; // Não fazer nada se já atingiu o máximo
      }

      // Navegar diretamente para a câmera com as fotos existentes
      final projectData = {
        'zoneId': viewModel.currentZone!.id,
        'existingPhotos': viewModel.getPhotoUrls(viewModel.currentZone!),
        'currentPhotoCount': currentPhotos,
        'maxPhotos': maxPhotos,
      };

      final result = await context.push('/camera', extra: projectData);

      // Se a câmera retornou fotos, atualizar a zona
      if (result is List<String> && result.isNotEmpty) {
        viewModel.updateZonePhotos(result);
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

  /// Calculate total wall area from RoomPlan walls data
  double _calculateTotalWallArea(List<Map<String, dynamic>> walls) {
    double totalArea = 0.0;
    for (final wall in walls) {
      totalArea += (wall['area'] as double?) ?? 0.0;
    }
    return totalArea;
  }

  /// Calculate trim length from RoomPlan walls data
  double _calculateTrimLength(List<Map<String, dynamic>> walls) {
    double totalLength = 0.0;
    for (final wall in walls) {
      totalLength += (wall['width'] as double?) ?? 0.0;
    }
    return totalLength / 2; // Approximate trim length
  }
}

import 'dart:io';
import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../utils/responsive/responsive_helper.dart';
import '../dialogs/delete_zone_dialog.dart';
import '../dialogs/rename_zone_dialog.dart';

class ZonesCard extends StatelessWidget {
  final String title;
  final List<String> photoPaths;
  final String valueDimension;
  final String valueArea;
  final String valuePaintable;
  final double? height;
  final double? width;
  final double? imageHeight;
  final double? imageWidth;
  final VoidCallback? onTap;
  final void Function(String newName)? onRename;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const ZonesCard({
    super.key,
    required this.title,
    required this.photoPaths,
    required this.valueDimension,
    required this.valueArea,
    required this.valuePaintable,
    this.height = 104,
    this.width = 364,
    this.imageHeight = 80,
    this.imageWidth = 120,
    this.onTap,
    this.onRename,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    // Get responsive dimensions
    final dimensions = ResponsiveHelper.getZonesCardDimensions(context);
    final textStyles = ResponsiveHelper.getZonesCardTextStyles(context);
    final imageDimensions = ResponsiveHelper.getImageDimensions(
      baseImageSize: dimensions.imageSize,
      customWidth: imageWidth,
      customHeight: imageHeight,
    );

    // Use custom width if provided, otherwise use responsive width
    final cardWidth = width ?? dimensions.cardWidth;

    // Get first photo path
    final firstPhotoPath = photoPaths.first;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: cardWidth,
        constraints: BoxConstraints(
          minHeight: height!,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Conteúdo principal
            Padding(
              padding: EdgeInsets.all(dimensions.padding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(firstPhotoPath),
                      fit: BoxFit.cover,
                      width: imageDimensions.width,
                      height: imageDimensions.height,
                    ),
                  ),
                  SizedBox(width: dimensions.spacing * 3),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: textStyles.titleStyle,
                        ),
                        SizedBox(height: dimensions.spacing),
                        Text(
                          'Floor Dimensions . $valueDimension',
                          style: textStyles.bodyStyle,
                        ),
                        SizedBox(height: dimensions.spacing / 2),
                        Text(
                          'Floor Area . $valueArea',
                          style: textStyles.bodyStyle,
                        ),
                        SizedBox(height: dimensions.spacing / 2),
                        Text(
                          'Paintable . $valuePaintable',
                          style: textStyles.bodyStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // IconButton no canto superior direito
            Positioned(
              top: 0,
              right: 0,
              child: PopupMenuButton(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                tooltip: '',
                icon: Icon(Icons.more_vert, color: Colors.grey[700]),
                onSelected: (value) async {
                  if (value == 'rename') {
                    final newName = await RenameZoneDialog.show(
                      context,
                      initialName: title,
                    );
                    if (newName != null && newName.trim().isNotEmpty) {
                      onRename?.call(newName.trim());
                    }
                  } else if (value == 'edit') {
                    onEdit?.call();
                  } else if (value == 'delete') {
                    final confirm = await DeleteZoneDialog.show(
                      context,
                      zoneName: title,
                    );
                    if (confirm == true) {
                      onDelete?.call();
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Rename'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

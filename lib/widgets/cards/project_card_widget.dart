import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../utils/responsive/responsive_helper.dart';
import '../dialogs/delete_quote_dialog.dart';
import '../dialogs/rename_quote_dialog.dart';

class ProjectCardWidget extends StatelessWidget {
  final String projectName;
  final String personName;
  final int zonesCount;
  final String createdDate;
  final String image;
  final double? height;
  final double? width;
  final double? imageHeight;
  final double? imageWidth;
  final VoidCallback? onTap;
  final void Function(String newName)? onRename;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const ProjectCardWidget({
    super.key,
    required this.projectName,
    required this.personName,
    required this.zonesCount,
    required this.createdDate,
    required this.image,
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
    final dimensions = ResponsiveHelper.getProjectCardDimensions(context);
    final textStyles = ResponsiveHelper.getProjectCardTextStyles(context);
    final imageDimensions = ResponsiveHelper.getImageDimensions(
      baseImageSize: dimensions.imageSize,
      customWidth: imageWidth,
      customHeight: imageHeight,
    );

    // Use custom width if provided, otherwise use responsive width
    final cardWidth = width ?? dimensions.cardWidth;

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
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,
                      width: imageDimensions.width,
                      height: imageDimensions.height,
                    ),
                  ),
                  SizedBox(width: dimensions.spacing * 3),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          personName,
                          style: textStyles.bodyStyle,
                        ),
                        Text(
                          projectName,
                          style: textStyles.titleStyle,
                        ),
                        SizedBox(height: dimensions.spacing),
                        Row(
                          children: [
                            Text(
                              '$zonesCount Zones',
                              style: textStyles.bodyStyle,
                            ),
                            SizedBox(width: dimensions.spacing * 2),
                            Text(
                              '• Created $createdDate',
                              style: textStyles.bodyStyle?.copyWith(
                                color: Colors.grey[500],
                                fontSize: textStyles.bodyStyle?.fontSize != null
                                    ? textStyles.bodyStyle!.fontSize! - 1
                                    : null,
                              ),
                            ),
                          ],
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
                icon: Icon(Icons.more_vert, color: Colors.grey[700]),
                onSelected: (value) async {
                  if (value == 'rename') {
                    final newName = await RenameQuoteDialog.show(
                      context,
                      initialName: projectName,
                    );
                    if (newName != null && newName.trim().isNotEmpty) {
                      onRename?.call(newName.trim());
                    }
                  } else if (value == 'delete') {
                    final confirm = await DeleteQuoteDialog.show(
                      context,
                      quoteName: projectName,
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
                        Text('Rename Project'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete),
                        SizedBox(width: 8),
                        Text('Delete Project'),
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

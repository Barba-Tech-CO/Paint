import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../dialogs/app_dialogs.dart';

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
    // Obter dimensões da tela
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Definir valores responsivos baseados no tamanho da tela
    double cardWidth;
    double imageSize;
    double fontSize;
    double padding;
    double spacing;

    // Breakpoints para diferentes tamanhos de tela
    if (screenWidth < 360) {
      // Tela pequena (celular pequeno)
      cardWidth = width ?? screenWidth * 0.9;
      imageSize = 80;
      fontSize = 13;
      padding = 8;
      spacing = 2;
    } else if (screenWidth < 600) {
      // Tela média (celular normal)
      cardWidth = width ?? 364;
      imageSize = 100;
      fontSize = 14;
      padding = 12;
      spacing = 4;
    } else {
      // Tela grande (tablet/desktop)
      cardWidth = width ?? 380;
      imageSize = 120;
      fontSize = 16;
      padding = 16;
      spacing = 6;
    }

    // Ajustar altura da imagem proporcionalmente
    final actualImageWidth = imageWidth ?? imageSize;
    final actualImageHeight = imageHeight ?? (imageSize * 0.75);

    // Criar estilos de texto responsivos
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: fontSize + 2,
    );

    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Colors.grey[700],
      fontSize: fontSize,
    );

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
              padding: EdgeInsets.all(padding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,
                      width: actualImageWidth,
                      height: actualImageHeight,
                    ),
                  ),
                  SizedBox(width: spacing * 3),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          personName,
                          style: bodyStyle,
                        ),
                        Text(
                          projectName,
                          style: titleStyle,
                        ),
                        SizedBox(height: spacing),
                        Row(
                          children: [
                            Text(
                              '$zonesCount Zones',
                              style: bodyStyle,
                            ),
                            SizedBox(width: spacing * 2),
                            Text(
                              '• Created $createdDate',
                              style: bodyStyle?.copyWith(
                                color: Colors.grey[500],
                                fontSize: fontSize - 1,
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
                    final newName = await AppDialogs.showRenameQuoteDialog(
                      context,
                      initialName: projectName,
                    );
                    if (newName != null && newName.trim().isNotEmpty) {
                      onRename?.call(newName.trim());
                    }
                  } else if (value == 'delete') {
                    final confirm = await AppDialogs.showDeleteQuoteDialog(
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

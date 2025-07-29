import 'package:flutter/material.dart';
import 'package:paintpro/config/app_colors.dart';

class ZonesCard extends StatelessWidget {
  final String title;

  // TODO(gabriel): verificar sobre a imagem
  final String image;

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

  const ZonesCard({
    super.key,
    required this.title,
    required this.image,
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

    return Container(
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: titleStyle,
                      ),
                      SizedBox(height: spacing),
                      Text(
                        'Floor Dimensions . $valueDimension',
                        style: bodyStyle,
                      ),
                      SizedBox(height: spacing / 2),
                      Text(
                        'Floor Area . $valueArea',
                        style: bodyStyle,
                      ),
                      SizedBox(height: spacing / 2),
                      Text(
                        'Paintable . $valuePaintable',
                        style: bodyStyle,
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
                  final newName = await showDialog<String>(
                    context: context,
                    builder: (context) => _RenameZoneDialog(initialName: title),
                  );
                  if (newName != null && newName.trim().isNotEmpty) {
                    onRename?.call(newName.trim());
                  }
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => _DeleteZoneDialog(zoneName: title),
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
    );
  }
}

class _RenameZoneDialog extends StatefulWidget {
  final String initialName;

  const _RenameZoneDialog({required this.initialName});

  @override
  State<_RenameZoneDialog> createState() => _RenameZoneDialogState();
}

class _RenameZoneDialogState extends State<_RenameZoneDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename Zone'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(labelText: 'Zone Name'),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _DeleteZoneDialog extends StatelessWidget {
  final String zoneName;

  const _DeleteZoneDialog({required this.zoneName});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Zone'),
      content: Text('Are you sure you want to delete "$zoneName"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

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
            child: IconButton(
              iconSize: screenWidth < 360 ? 20 : 24,
              icon: const Icon(Icons.more_vert),
              color: Colors.grey[700],
              onPressed: onTap,
            ),
          ),
        ],
      ),
    );
  }
}

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
    return Container(
      width: width,
      constraints: const BoxConstraints(
        minHeight: 120,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Conteúdo principal
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                    width: imageWidth,
                    height: imageHeight,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Floor Dimensions . $valueDimension',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Floor Area . $valueArea',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Paintable . $valuePaintable',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
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
              iconSize: 24,
              icon: const Icon(Icons.more_vert),
              color: Colors.black,
              onPressed: onTap,
            ),
          ),
        ],
      ),
    );
  }
}

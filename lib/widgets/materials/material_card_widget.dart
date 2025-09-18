import 'package:flutter/material.dart';
import '../../model/material_models/material_model.dart';
import '../../config/app_colors.dart';
import 'build_chip_widget.dart';

class MaterialCardWidget extends StatelessWidget {
  final MaterialModel material;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const MaterialCardWidget({
    super.key,
    required this.material,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com seleção e código
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Código do material
                  Text(
                    material.code,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray100,
                    ),
                  ),
                  Text(
                    '\$${material.price.toStringAsFixed(2)}/${material.priceUnit}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Nome do material
              Text(
                material.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Informações do material
              Row(
                children: [
                  // Tipo
                  BuildChipWidget(
                    text: material.type.displayName,
                    textColor: AppColors.gray100,
                  ),
                  Text(
                    '.',
                    style: TextStyle(
                      color: AppColors.gray100,
                    ),
                  ),
                  // Qualidade
                  BuildChipWidget(
                    text: material.quality.displayName,
                    textColor: AppColors.gray100,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

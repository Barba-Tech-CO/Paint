import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/material_models/material_model.dart';
import '../../config/app_colors.dart';
import 'build_chip_widget.dart';
import 'quantity_selector_widget.dart';

class MaterialCardWidget extends StatelessWidget {
  final MaterialModel material;
  final bool isSelected;
  final int quantity;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onQuantityDecrease;
  final VoidCallback? onQuantityIncrease;

  const MaterialCardWidget({
    super.key,
    required this.material,
    this.isSelected = false,
    this.quantity = 1,
    this.onTap,
    this.onLongPress,
    this.onQuantityDecrease,
    this.onQuantityIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : 2,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: isSelected ? 2.w : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
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
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray100,
                    ),
                  ),
                  Text(
                    '\$${material.price.toStringAsFixed(2)}/${material.priceUnit}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Nome do material
              Text(
                material.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),

              // Informações do material
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tipo e Qualidade
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

                  // Quantity Selector (only show when selected)
                  if (isSelected)
                    QuantitySelectorWidget(
                      quantity: quantity,
                      onDecrease: onQuantityDecrease ?? () {},
                      onIncrease: onQuantityIncrease ?? () {},
                      enabled: isSelected,
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

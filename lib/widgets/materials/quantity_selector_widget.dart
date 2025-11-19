import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class QuantitySelectorWidget extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final bool enabled;

  const QuantitySelectorWidget({
    super.key,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // Garantir que a quantidade nunca seja menor que 1
    final validQuantity = quantity < 1 ? 1 : quantity;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Minus button
        GestureDetector(
          onTap: enabled && validQuantity > 1 ? onDecrease : null,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: enabled && validQuantity > 1
                  ? AppColors.primary
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.remove,
              color: enabled && validQuantity > 1
                  ? Colors.white
                  : Colors.grey[600],
              size: 18,
            ),
          ),
        ),

        // Quantity display
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            validQuantity.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: enabled ? Colors.black87 : Colors.grey[600],
            ),
          ),
        ),

        // Plus button
        GestureDetector(
          onTap: enabled ? onIncrease : null,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: enabled ? AppColors.primary : Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.add,
              color: enabled ? Colors.white : Colors.grey[600],
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}

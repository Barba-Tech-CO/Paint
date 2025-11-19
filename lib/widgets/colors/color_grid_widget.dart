import 'package:flutter/material.dart';
import 'color_card_widget.dart';

class ColorGridWidget extends StatelessWidget {
  final String brand;
  final List<Map<String, dynamic>> colors;
  final Function(Map<String, dynamic>)? onColorTap;

  const ColorGridWidget({
    super.key,
    required this.brand,
    required this.colors,

    this.onColorTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Notes",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              return ColorCardWidget(
                name: color['name'] ?? '',
                code: color['code'] ?? '',
                price: color['price'] ?? '',
                color: color['color'],
                onTap: () => onColorTap?.call(color),
              );
            },
          ),
        ],
      ),
    );
  }
}

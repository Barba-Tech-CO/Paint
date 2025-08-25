import 'package:flutter/material.dart';

import '../../widgets/buttons/paint_pro_button.dart';

class TryAgainWidget extends StatelessWidget {
  final VoidCallback onPressed;
  const TryAgainWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          SizedBox(height: 16),
          Text(
            'Error to load quotes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Check your connection and try again',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 16),
          PaintProButton(
            text: 'Try Again',
            minimumSize: Size(130, 42),
            borderRadius: 16,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

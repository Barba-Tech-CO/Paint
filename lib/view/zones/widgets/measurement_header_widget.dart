import 'package:flutter/material.dart';

class MeasurementHeaderWidget extends StatelessWidget {
  final double accuracy;

  const MeasurementHeaderWidget({
    super.key,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          // Ícone de check
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.green[400],
              borderRadius: BorderRadius.circular(32),
            ),
            padding: const EdgeInsets.all(5),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 32,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Measurements Complete!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          Text(
            'Accuracy: $accuracy%',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

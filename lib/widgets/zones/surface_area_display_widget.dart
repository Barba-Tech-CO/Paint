import 'package:flutter/material.dart';
import '../form_field/paint_pro_area_field.dart';

class SurfaceAreaDisplayWidget extends StatefulWidget {
  final double? walls;
  final double? ceiling;
  final double? trim;
  final ValueChanged<double?>? onWallsChanged;
  final ValueChanged<double?>? onCeilingChanged;
  final ValueChanged<double?>? onTrimChanged;

  const SurfaceAreaDisplayWidget({
    super.key,
    this.walls,
    this.ceiling,
    this.trim,
    this.onWallsChanged,
    this.onCeilingChanged,
    this.onTrimChanged,
  });

  @override
  State<SurfaceAreaDisplayWidget> createState() =>
      _SurfaceAreaDisplayWidgetState();
}

class _SurfaceAreaDisplayWidgetState extends State<SurfaceAreaDisplayWidget> {
  late TextEditingController _wallsController;
  late TextEditingController _ceilingController;
  late TextEditingController _trimController;

  @override
  void initState() {
    super.initState();
    _wallsController = TextEditingController(
      text: widget.walls?.toStringAsFixed(0) ?? '',
    );
    _ceilingController = TextEditingController(
      text: widget.ceiling?.toStringAsFixed(0) ?? '',
    );
    _trimController = TextEditingController(
      text: widget.trim?.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _wallsController.dispose();
    _ceilingController.dispose();
    _trimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Surface Areas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // Walls
        PaintProAreaField(
          label: 'Walls:',
          controller: _wallsController,
          unit: 'sq ft',
          onChanged: (value) {
            final doubleValue = double.tryParse(value ?? '');
            widget.onWallsChanged?.call(doubleValue);
            setState(() {}); // Atualiza o Total Paintable
          },
        ),
        const SizedBox(height: 16),

        // Ceiling
        PaintProAreaField(
          label: 'Ceiling:',
          controller: _ceilingController,
          unit: 'sq ft',
          onChanged: (value) {
            final doubleValue = double.tryParse(value ?? '');
            widget.onCeilingChanged?.call(doubleValue);
            setState(() {}); // Atualiza o Total Paintable
          },
        ),
        const SizedBox(height: 16),

        // Trim
        PaintProAreaField(
          label: 'Trim:',
          controller: _trimController,
          unit: 'linear ft',
          onChanged: (value) {
            final doubleValue = double.tryParse(value ?? '');
            widget.onTrimChanged?.call(doubleValue);
          },
        ),
        const SizedBox(height: 24),

        // Total Paintable
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Paintable',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              '${_calculateTotalPaintable().toStringAsFixed(0)} sq ft',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _calculateTotalPaintable() {
    double total = 0;
    final wallsValue = double.tryParse(_wallsController.text);
    final ceilingValue = double.tryParse(_ceilingController.text);

    if (wallsValue != null) total += wallsValue;
    if (ceilingValue != null) total += ceilingValue;
    return total;
  }
}

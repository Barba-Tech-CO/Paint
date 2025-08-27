import 'package:flutter/material.dart';

class PaintProSearchField extends StatefulWidget {
  final TextEditingController controller;

  const PaintProSearchField({
    super.key,
    required this.controller,
  });

  @override
  State<PaintProSearchField> createState() => _PaintProSearchFieldState();
}

class _PaintProSearchFieldState extends State<PaintProSearchField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _buildClearButton(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget? _buildClearButton() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: widget.controller,
      builder: (context, value, child) {
        if (value.text.isEmpty) {
          return const SizedBox.shrink();
        }

        return IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            widget.controller.clear();
          },
        );
      },
    );
  }
}

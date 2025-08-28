import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';

class PaintProSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final void Function(String)? onChanged;
  final void Function()? onClear;

  const PaintProSearchField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onClear,
  });

  @override
  State<PaintProSearchField> createState() => _PaintProSearchFieldState();
}

class _PaintProSearchFieldState extends State<PaintProSearchField> {
  late TextEditingController _controller;
  bool _isControllerLocal = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _isControllerLocal = true;
    }

    if (widget.onChanged != null) {
      _controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    if (widget.onChanged != null) {
      _controller.removeListener(_onTextChanged);
    }
    if (_isControllerLocal) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    if (widget.onChanged != null) {
      widget.onChanged!(_controller.text);
    }
  }

  void _clearText() {
    _controller.clear();
    if (widget.onClear != null) {
      widget.onClear!();
    }
    if (widget.onChanged != null) {
      widget.onChanged!('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: widget.hintText ?? 'Search',
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.buttonPrimary,
        ),
        suffixIcon: _buildClearButton(),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE0E0E0), // Cinza claro
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE0E0E0), // Cinza claro
            width: 1.0,
          ),
        ),
      ),
    );
  }

  Widget? _buildClearButton() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, child) {
        if (value.text.isEmpty) {
          return const SizedBox.shrink();
        }

        return IconButton(
          icon: const Icon(Icons.clear),
          onPressed: _clearText,
        );
      },
    );
  }
}

// decoration: InputDecoration(
//           hintText: 'Search',
//           prefixIcon: const Icon(Icons.search),
//           suffixIcon: _buildClearButton(),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),
//           filled: true,
//           fillColor: Colors.grey[100],
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 12,
//           ),
//         ),

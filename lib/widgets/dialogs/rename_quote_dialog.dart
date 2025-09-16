import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_colors.dart';

/// Dialog for renaming quotes with proper TextEditingController lifecycle management
class RenameQuoteDialog extends StatefulWidget {
  final String initialName;

  const RenameQuoteDialog({
    super.key,
    required this.initialName,
  });

  /// Show the rename quote dialog
  static Future<String?> show(
    BuildContext context, {
    required String initialName,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => RenameQuoteDialog(initialName: initialName),
    );
  }

  @override
  State<RenameQuoteDialog> createState() => _RenameQuoteDialogState();
}

class _RenameQuoteDialogState extends State<RenameQuoteDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename Quote'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(labelText: 'Quote Name'),
        autofocus: true,
      ),
      actions: [
        ElevatedButton(
          onPressed: () => context.pop(_controller.text.trim()),
          child: Text(
            'Save',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

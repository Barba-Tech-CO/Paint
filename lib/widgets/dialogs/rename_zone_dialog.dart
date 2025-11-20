import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_colors.dart';

/// Dialog for renaming zones with proper TextEditingController lifecycle management
class RenameZoneDialog extends StatefulWidget {
  final String initialName;

  const RenameZoneDialog({
    super.key,
    required this.initialName,
  });

  /// Show the rename zone dialog
  static Future<String?> show(
    BuildContext context, {
    required String initialName,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => RenameZoneDialog(initialName: initialName),
    );
  }

  @override
  State<RenameZoneDialog> createState() => _RenameZoneDialogState();
}

class _RenameZoneDialogState extends State<RenameZoneDialog> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

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

  void _handleSubmit() {
    if (_formKey.currentState?.validate() == true) {
      final newName = _controller.text.trim();
      context.pop(newName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename Zone'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Zone Name',
            hintText: 'Enter new zone name',
          ),
          autofocus: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Zone name cannot be empty';
            }
            return null;
          },
          onFieldSubmitted: (_) => _handleSubmit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _handleSubmit,
          child: Text(
            'Rename',
            style: TextStyle(
              color: AppColors.gray100,
              fontSize: 16.sp,
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
              fontSize: 16.sp,
            ),
          ),
        ),
      ],
    );
  }
}

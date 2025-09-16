import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_colors.dart';

/// Dialog for adding new zones with proper TextEditingController lifecycle management
class AddZoneDialog extends StatefulWidget {
  final Function({
    required String title,
    required String zoneType,
  })
  onAdd;

  const AddZoneDialog({
    super.key,
    required this.onAdd,
  });

  /// Show the add zone dialog
  static Future<void> show(
    BuildContext context, {
    required Function({
      required String title,
      required String zoneType,
    })
    onAdd,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AddZoneDialog(onAdd: onAdd),
    );
  }

  @override
  State<AddZoneDialog> createState() => _AddZoneDialogState();
}

class _AddZoneDialogState extends State<AddZoneDialog> {
  late TextEditingController _titleController;
  final _formKey = GlobalKey<FormState>();
  String _selectedZoneType = 'room';

  final List<String> _zoneTypes = [
    'room',
    'bathroom',
    'kitchen',
    'bedroom',
    'living room',
    'dining room',
    'office',
    'basement',
    'attic',
    'garage',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() == true) {
      widget.onAdd(
        title: _titleController.text.trim(),
        zoneType: _selectedZoneType,
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Zone'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Zone Name',
                hintText: 'Enter zone name',
              ),
              autofocus: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Zone name is required';
                }
                return null;
              },
              onFieldSubmitted: (_) => _handleSubmit(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedZoneType,
              decoration: const InputDecoration(
                labelText: 'Zone Type',
              ),
              items: _zoneTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedZoneType = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _handleSubmit,
          child: Text(
            'Add Zone',
            style: TextStyle(
              color: AppColors.gray100,
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
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

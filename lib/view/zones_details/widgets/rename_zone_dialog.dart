import 'package:flutter/material.dart';
import 'package:paintpro/viewmodel/zones/zones_viewmodels.dart';

class RenameZoneDialog extends StatefulWidget {
  final ZoneDetailViewModel viewModel;

  const RenameZoneDialog({
    super.key,
    required this.viewModel,
  });

  @override
  State<RenameZoneDialog> createState() => _RenameZoneDialogState();

  static Future<void> show(
    BuildContext context,
    ZoneDetailViewModel viewModel,
  ) async {
    final zone = viewModel.currentZone;
    if (zone == null) return;

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => RenameZoneDialog(viewModel: viewModel),
    );

    if (newName != null &&
        newName.isNotEmpty &&
        newName != zone.title &&
        context.mounted) {
      await viewModel.renameZone(zone.id, newName);
    }
  }
}

class _RenameZoneDialogState extends State<RenameZoneDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final zone = widget.viewModel.currentZone;
    _controller = TextEditingController(
      text: zone?.title ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() == true) {
      final newName = _controller.text.trim();
      Navigator.of(context).pop(newName);
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _handleSubmit,
          child: const Text('Rename'),
        ),
      ],
    );
  }
}

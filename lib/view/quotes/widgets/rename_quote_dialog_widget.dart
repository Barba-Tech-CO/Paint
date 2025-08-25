import 'package:flutter/material.dart';

class RenameQuoteDialog extends StatefulWidget {
  final String initialName;

  const RenameQuoteDialog({
    super.key,
    required this.initialName,
  });

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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

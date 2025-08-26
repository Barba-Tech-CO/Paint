import 'package:flutter/material.dart';

class DeleteDialog extends StatelessWidget {
  final String quoteName;

  const DeleteDialog({
    super.key,
    required this.quoteName,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Quote'),
      content: Text('Are you sure you want to delete "$quoteName"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

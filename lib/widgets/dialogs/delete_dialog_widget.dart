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
      title: const Text(
        'Delete Quote',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black),
          children: [
            const TextSpan(text: 'Are you sure you want to delete '),
            TextSpan(
              text: '"$quoteName"',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(
              text:
                  '?\n\nThis action will permanently delete all related data, including extracted materials.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            'Cancel',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: const Text(
            'Delete',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

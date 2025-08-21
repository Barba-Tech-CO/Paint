import 'package:flutter/material.dart';
import 'widgets.dart';

class QuoteCardWidget extends StatelessWidget {
  final String id;
  final String titulo;
  final DateTime dateUpload;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Function(String)? onRename;
  final VoidCallback? onDelete;

  const QuoteCardWidget({
    super.key,
    required this.id,
    required this.titulo,
    required this.dateUpload,
    this.width = 336,
    this.height = 84,
    this.onTap,
    this.onRename,
    this.onDelete,
  });

  String _formatDateTime(DateTime dateTime) {
    // Formato: "Uploaded at 07/14/2025 - 10:30 AM"
    String day = dateTime.day.toString().padLeft(2, '0');
    String month = dateTime.month.toString().padLeft(2, '0');
    String year = dateTime.year.toString(); // Ano completo

    int hour = dateTime.hour;
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String period = hour >= 12 ? 'PM' : 'AM';

    // Converter para formato 12 horas
    if (hour > 12) {
      hour = hour - 12;
    } else if (hour == 0) {
      hour = 12;
    }

    return "Uploaded at $month/$day/$year - $hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16,
      ),
      width: width,
      constraints: BoxConstraints(
        minHeight: height ?? 84,
        minWidth: width ?? 336,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 1.5,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Image(
                height: 60,
                width: 60,
                image: AssetImage('assets/images/icon_pdf.png'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quote #$id',
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      _formatDateTime(dateUpload),
                      style: TextStyle(
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
            ],
          ),
          Positioned(
            top: -8,
            right: -8,
            child: PopupMenuButton(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              icon: Icon(Icons.more_vert, size: 20, color: Colors.grey[700]),
              onSelected: (value) async {
                if (value == 'rename') {
                  final newName = await showDialog<String>(
                    context: context,
                    builder: (context) =>
                        RenameQuoteDialog(initialName: titulo),
                  );
                  if (newName != null && newName.trim().isNotEmpty) {
                    onRename?.call(newName.trim());
                  }
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => DeleteQuoteDialog(quoteName: titulo),
                  );
                  if (confirm == true) {
                    onDelete?.call();
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'rename',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Rename'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';

class QuoteCardWidget extends StatelessWidget {
  final String id;
  final String titulo;
  final DateTime dateUpload;
  final String? status;
  final int? materialsExtracted;
  final String? errorMessage;
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
    this.status,
    this.materialsExtracted,
    this.errorMessage,
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

  Color _getStatusColor() {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'failed':
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDisplay() {
    if (status == null) return 'Unknown';
    return status!.toUpperCase();
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
                    Row(
                      children: [
                        Text(
                          'Quote #$id',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(width: 8),
                        if (status != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor().withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getStatusColor(),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _getStatusDisplay(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      _formatDateTime(dateUpload),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (materialsExtracted != null && materialsExtracted! > 0)
                      Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          '$materialsExtracted materials extracted',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (errorMessage != null && errorMessage!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'Error: $errorMessage',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
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
              icon: Icon(
                Icons.more_vert,
                size: 20,
                color: Colors.grey[700],
              ),
              onSelected: (value) async {
                if (value == 'rename') {
                  final newName = await showDialog<String>(
                    context: context,
                    builder: (context) => RenameDialog(initialName: titulo),
                  );
                  if (newName != null && newName.trim().isNotEmpty) {
                    onRename?.call(newName.trim());
                  }
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => DeleteDialog(quoteName: titulo),
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
                      Icon(
                        Icons.edit,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text('Rename'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete,
                        size: 18,
                        color: Colors.red,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
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

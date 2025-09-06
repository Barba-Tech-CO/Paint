import 'package:flutter/material.dart';
import '../../../helpers/date_helper.dart';
import '../../../helpers/status_helper.dart';
import '../../widgets/widgets.dart';

class QuoteCardWidget extends StatefulWidget {
  final String id;
  final String titulo;
  final DateTime dateUpload;
  final String? status;
  final String? errorMessage;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Function(String)? onRename;
  final VoidCallback? onDelete;
  final bool isDeleting;

  const QuoteCardWidget({
    super.key,
    required this.id,
    required this.titulo,
    required this.dateUpload,
    this.status,
    this.errorMessage,
    this.width = 336,
    this.height = 84,
    this.onTap,
    this.onRename,
    this.onDelete,
    this.isDeleting = false,
  });

  @override
  State<QuoteCardWidget> createState() => _QuoteCardWidgetState();
}

class _QuoteCardWidgetState extends State<QuoteCardWidget> {
  bool _showTemporaryStatus = false;
  String? _previousStatus;

  @override
  void initState() {
    super.initState();
    _previousStatus = widget.status;
  }

  @override
  void didUpdateWidget(QuoteCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if status changed to completed using helper
    if (StatusHelper.hasStatusChangedToCompleted(
      currentStatus: widget.status,
      previousStatus: _previousStatus,
    )) {
      _showTemporaryStatus = true;
      // Hide the temporary status after 3 seconds
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted) {
          setState(() {
            _showTemporaryStatus = false;
          });
        }
      });
    }

    _previousStatus = widget.status;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Don't allow delete if already deleting
        if (widget.isDeleting) return;

        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => DeleteDialog(quoteName: widget.titulo),
        );
        if (confirm == true) {
          widget.onDelete?.call();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        width: widget.width,
        constraints: BoxConstraints(
          minHeight: widget.height ?? 84,
          minWidth: widget.width ?? 336,
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
                            'Quote #${widget.id}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(width: 8),
                          if (StatusHelper.shouldShowStatus(
                            currentStatus: widget.status,
                            previousStatus: _previousStatus,
                            showTemporaryStatus: _showTemporaryStatus,
                          ))
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: StatusHelper.getStatusColor(
                                  widget.status,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: StatusHelper.getStatusColor(
                                    widget.status,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                StatusHelper.getStatusDisplay(widget.status),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: StatusHelper.getStatusColor(
                                    widget.status,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.titulo,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        DateHelper.formatUploadDateTime(widget.dateUpload),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.errorMessage != null &&
                          widget.errorMessage!.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'Error: ${widget.errorMessage}',
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
                      builder: (context) =>
                          RenameDialog(initialName: widget.titulo),
                    );
                    if (newName != null && newName.trim().isNotEmpty) {
                      widget.onRename?.call(newName.trim());
                    }
                  } else if (value == 'delete') {
                    // Don't allow delete if already deleting
                    if (widget.isDeleting) return;

                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) =>
                          DeleteDialog(quoteName: widget.titulo),
                    );
                    if (confirm == true) {
                      widget.onDelete?.call();
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
                  PopupMenuItem(
                    value: 'delete',
                    enabled: !widget.isDeleting,
                    child: Row(
                      children: [
                        if (widget.isDeleting)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.red,
                              ),
                            ),
                          )
                        else
                          Icon(
                            Icons.delete,
                            size: 18,
                            color: Colors.red,
                          ),
                        SizedBox(width: 8),
                        Text(
                          widget.isDeleting ? 'Deleting...' : 'Delete',
                          style: TextStyle(
                            color: widget.isDeleting ? Colors.grey : Colors.red,
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
      ),
    );
  }
}

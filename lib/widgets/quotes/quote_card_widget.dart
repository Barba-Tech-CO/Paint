import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/date_utils.dart' as app_date_utils;
import '../../utils/status_utils.dart';
import '../dialogs/delete_quote_dialog.dart';
import '../dialogs/rename_quote_dialog.dart';

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
    this.width,
    this.height,
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
    if (StatusUtils.hasStatusChangedToCompleted(
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

        final confirm = await DeleteQuoteDialog.show(
          context,
          quoteName: widget.titulo,
        );
        if (confirm == true) {
          widget.onDelete?.call();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 12.h,
          horizontal: 16.w,
        ),
        width: widget.width ?? 336.w,
        constraints: BoxConstraints(
          minHeight: widget.height ?? 84.h,
          minWidth: widget.width ?? 336.w,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 1.5.r,
              offset: Offset(1.w, 2.h),
            ),
          ],
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Image(
                  height: 60.h,
                  width: 60.w,
                  image: AssetImage('assets/images/icon_pdf.png'),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Quote #${widget.id}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(width: 8.w),
                          if (StatusUtils.shouldShowStatus(
                            currentStatus: widget.status,
                            previousStatus: _previousStatus,
                            showTemporaryStatus: _showTemporaryStatus,
                          ))
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: StatusUtils.getStatusColor(
                                  widget.status,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: StatusUtils.getStatusColor(
                                    widget.status,
                                  ),
                                  width: 1.w,
                                ),
                              ),
                              child: Text(
                                StatusUtils.getStatusDisplay(widget.status),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: StatusUtils.getStatusColor(
                                    widget.status,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        widget.titulo,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        app_date_utils.DateUtils.formatUploadDateTime(
                          widget.dateUpload,
                        ),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.errorMessage != null &&
                          widget.errorMessage!.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            'Error: ${widget.errorMessage}',
                            style: TextStyle(
                              fontSize: 11.sp,
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
                SizedBox(width: 8.w),
              ],
            ),
            Positioned(
              top: -8.h,
              right: -8.w,
              child: PopupMenuButton(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                tooltip: '',
                icon: Icon(
                  Icons.more_vert,
                  size: 20.sp,
                  color: Colors.grey[700],
                ),
                onSelected: (value) async {
                  if (value == 'rename') {
                    final newName = await RenameQuoteDialog.show(
                      context,
                      initialName: widget.titulo,
                    );
                    if (newName != null && newName.trim().isNotEmpty) {
                      widget.onRename?.call(newName.trim());
                    }
                  } else if (value == 'delete') {
                    // Don't allow delete if already deleting
                    if (widget.isDeleting) return;

                    final confirm = await DeleteQuoteDialog.show(
                      context,
                      quoteName: widget.titulo,
                    );
                    if (confirm == true) {
                      widget.onDelete?.call();
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit,
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
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
                            width: 16.w,
                            height: 16.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.w,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.red,
                              ),
                            ),
                          )
                        else
                          Icon(
                            Icons.delete,
                            size: 18.sp,
                            color: Colors.red,
                          ),
                        SizedBox(width: 8.w),
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

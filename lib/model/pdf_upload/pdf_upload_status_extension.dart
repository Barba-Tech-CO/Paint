import 'dart:developer';

import 'pdf_upload_status.dart';

extension PdfUploadStatusExtension on PdfUploadStatus {
  static PdfUploadStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return PdfUploadStatus.pending;
      case 'processing':
        return PdfUploadStatus.processing;
      case 'completed':
        return PdfUploadStatus.completed;
      case 'failed':
        return PdfUploadStatus.failed;
      case 'error':
        return PdfUploadStatus.error;
      default:
        // Log the unknown status and return pending as default
        log(
          'WARNING: Unknown PdfUploadStatus: $value, using pending as default',
        );
        return PdfUploadStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case PdfUploadStatus.pending:
        return 'Pending';
      case PdfUploadStatus.processing:
        return 'Processing';
      case PdfUploadStatus.completed:
        return 'Completed';
      case PdfUploadStatus.failed:
        return 'Failed';
      case PdfUploadStatus.error:
        return 'Error'; // Adicionando display name para erro
    }
  }
}

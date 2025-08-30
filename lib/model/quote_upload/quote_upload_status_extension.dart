import 'dart:developer';

import 'quote_upload_status.dart';

extension QuoteUploadStatusExtension on QuoteUploadStatus {
  static QuoteUploadStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return QuoteUploadStatus.pending;
      case 'processing':
        return QuoteUploadStatus.processing;
      case 'completed':
        return QuoteUploadStatus.completed;
      case 'failed':
        return QuoteUploadStatus.failed;
      case 'error':
        return QuoteUploadStatus.error;
      default:
        // Log the unknown status and return pending as default
        log(
          'WARNING: Unknown QuoteUploadStatus: $value, using pending as default',
        );
        return QuoteUploadStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case QuoteUploadStatus.pending:
        return 'Pending';
      case QuoteUploadStatus.processing:
        return 'Processing';
      case QuoteUploadStatus.completed:
        return 'Completed';
      case QuoteUploadStatus.failed:
        return 'Failed';
      case QuoteUploadStatus.error:
        return 'Error'; // Adicionando display name para erro
    }
  }
}

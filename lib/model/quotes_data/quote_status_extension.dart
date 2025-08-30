import 'dart:developer';

import 'quote_status.dart';

extension QuoteStatusExtension on QuoteStatus {
  static QuoteStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return QuoteStatus.pending;
      case 'processing':
        return QuoteStatus.processing;
      case 'completed':
        return QuoteStatus.completed;
      case 'failed':
        return QuoteStatus.failed;
      case 'error':
        return QuoteStatus.error;
      default:
        // Log the unknown status and return pending as default
        log(
          'WARNING: Unknown QuoteStatus: $value, using pending as default',
        );
        return QuoteStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case QuoteStatus.pending:
        return 'Pending';
      case QuoteStatus.processing:
        return 'Processing';
      case QuoteStatus.completed:
        return 'Completed';
      case QuoteStatus.failed:
        return 'Failed';
      case QuoteStatus.error:
        return 'Error'; // Adicionando display name para erro
    }
  }
}

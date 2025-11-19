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
        throw Exception('Unknown QuoteStatus: $value');
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
        return 'Error';
    }
  }
}

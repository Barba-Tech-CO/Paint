import 'pdf_upload_status.dart';

extension PdfUploadStatusExtension on PdfUploadStatus {
  static PdfUploadStatus fromString(String value) {
    switch (value) {
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
        throw ArgumentError('Unknown PdfUploadStatus: $value');
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

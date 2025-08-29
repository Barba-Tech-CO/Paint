import '../pdf_upload/pdf_upload_model.dart';
import '../pdf_upload/pdf_upload_status.dart';
import '../pdf_upload/pdf_upload_status_extension.dart';

class QuotesModel {
  final String id;
  final String titulo;
  final DateTime dateUpload;
  final PdfUploadStatus? status;
  final int? materialsExtracted;
  final String? errorMessage;
  final String? r2Url;
  final String? filePath;

  QuotesModel({
    required this.id,
    required this.titulo,
    required this.dateUpload,
    this.status,
    this.materialsExtracted,
    this.errorMessage,
    this.r2Url,
    this.filePath,
  });

  /// Factory constructor para criar QuotesModel a partir de PdfUploadModel
  factory QuotesModel.fromPdfUpload(PdfUploadModel pdfUpload) {
    return QuotesModel(
      id: pdfUpload.id.toString(),
      titulo: pdfUpload.displayName ?? pdfUpload.originalName,
      dateUpload: pdfUpload.createdAt,
      status: pdfUpload.status,
      materialsExtracted: pdfUpload.materialsExtracted,
      errorMessage: pdfUpload.errorMessage,
      r2Url: pdfUpload.r2Url,
      filePath: pdfUpload.filePath,
    );
  }

  /// Factory constructor para criar QuotesModel a partir de JSON
  factory QuotesModel.fromJson(Map<String, dynamic> json) {
    return QuotesModel(
      id: json['id']?.toString() ?? '',
      titulo: json['display_name'] ?? json['original_name'] ?? '',
      dateUpload: DateTime.parse(json['created_at'] as String),
      status: json['status'] != null
          ? PdfUploadStatusExtension.fromString(json['status'] as String)
          : null,
      materialsExtracted: json['materials_extracted'] as int?,
      errorMessage: json['error_message'] as String?,
      r2Url: json['r2_url'] as String?,
      filePath: json['file_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'dateUpload': dateUpload.toIso8601String(),
      'status': status?.value,
      'materials_extracted': materialsExtracted,
      'error_message': errorMessage,
      'r2_url': r2Url,
      'file_path': filePath,
    };
  }

  QuotesModel copyWith({
    String? id,
    String? titulo,
    DateTime? dateUpload,
    PdfUploadStatus? status,
    int? materialsExtracted,
    String? errorMessage,
    String? r2Url,
    String? filePath,
  }) {
    return QuotesModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      dateUpload: dateUpload ?? this.dateUpload,
      status: status ?? this.status,
      materialsExtracted: materialsExtracted ?? this.materialsExtracted,
      errorMessage: errorMessage ?? this.errorMessage,
      r2Url: r2Url ?? this.r2Url,
      filePath: filePath ?? this.filePath,
    );
  }

  /// Getters para facilitar o uso na UI
  bool get isPending => status == PdfUploadStatus.pending;
  bool get isProcessing => status == PdfUploadStatus.processing;
  bool get isCompleted => status == PdfUploadStatus.completed;
  bool get isFailed => status == PdfUploadStatus.failed;
  bool get isError => status == PdfUploadStatus.error;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  bool get hasMaterials =>
      materialsExtracted != null && materialsExtracted! > 0;

  /// Status display para UI
  String get statusDisplay {
    if (status == null) return 'Unknown';
    return status!.displayName;
  }

  /// Status color para UI
  String get statusColor {
    switch (status) {
      case PdfUploadStatus.pending:
        return 'orange';
      case PdfUploadStatus.processing:
        return 'blue';
      case PdfUploadStatus.completed:
        return 'green';
      case PdfUploadStatus.failed:
      case PdfUploadStatus.error:
        return 'red';
      default:
        return 'grey';
    }
  }
}

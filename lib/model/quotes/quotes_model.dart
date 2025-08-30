import '../quotes_data/quote_model.dart';
import '../quotes_data/quote_status.dart';
import '../quotes_data/quote_status_extension.dart';

class QuotesModel {
  final String id;
  final String titulo;
  final DateTime dateUpload;
  final QuoteStatus? status;
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

  /// Factory constructor para criar QuotesModel a partir de QuoteModel
  factory QuotesModel.fromQuote(QuoteModel quote) {
    return QuotesModel(
      id: quote.id.toString(),
      titulo: quote.displayName ?? quote.originalName,
      dateUpload: quote.createdAt,
      status: quote.status,
      materialsExtracted: quote.materialsExtracted,
      errorMessage: quote.errorMessage,
      r2Url: quote.r2Url,
      filePath: quote.filePath,
    );
  }

  /// Factory constructor para criar QuotesModel a partir de JSON
  factory QuotesModel.fromJson(Map<String, dynamic> json) {
    return QuotesModel(
      id: json['id']?.toString() ?? '',
      titulo: json['display_name'] ?? json['original_name'] ?? '',
      dateUpload: DateTime.parse(json['created_at'] as String),
      status: json['status'] != null
          ? QuoteStatusExtension.fromString(json['status'] as String)
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
    QuoteStatus? status,
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
  bool get isPending => status == QuoteStatus.pending;
  bool get isProcessing => status == QuoteStatus.processing;
  bool get isCompleted => status == QuoteStatus.completed;
  bool get isFailed => status == QuoteStatus.failed;
  bool get isError => status == QuoteStatus.error;
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
      case QuoteStatus.pending:
        return 'orange';
      case QuoteStatus.processing:
        return 'blue';
      case QuoteStatus.completed:
        return 'green';
      case QuoteStatus.failed:
      case QuoteStatus.error:
        return 'red';
      default:
        return 'grey';
    }
  }
}

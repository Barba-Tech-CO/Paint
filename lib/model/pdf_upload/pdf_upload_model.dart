class PdfUploadModel {
  final int id;
  final int? userId;
  final String originalName;
  final String? displayName;
  final String? filePath; // Tornando opcional
  final String? r2Url;
  final String? fileHash; // Tornando opcional
  final PdfUploadStatus status;
  final int materialsExtracted;
  final Map<String, dynamic>? extractionMetadata;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  PdfUploadModel({
    required this.id,
    this.userId,
    required this.originalName,
    this.displayName,
    this.filePath, // Tornando opcional
    this.r2Url,
    this.fileHash, // Tornando opcional
    required this.status,
    required this.materialsExtracted,
    this.extractionMetadata,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PdfUploadModel.fromJson(Map<String, dynamic> json) {
    return PdfUploadModel(
      id: json['id'] as int,
      userId: json['user_id'] as int?, // Opcional
      originalName: json['original_name'] as String,
      displayName: json['display_name'] as String?,
      filePath: json['file_path'] as String? ?? '', // Valor padrão se ausente
      r2Url: json['r2_url'] as String?,
      fileHash: json['file_hash'] as String? ?? '', // Valor padrão se ausente
      status: PdfUploadStatusExtension.fromString(json['status'] as String),
      materialsExtracted:
          json['materials_extracted'] as int? ?? 0, // Valor padrão se nulo
      extractionMetadata: json['extraction_metadata'] as Map<String, dynamic>?,
      errorMessage: json['error_message'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'original_name': originalName,
      'display_name': displayName,
      'file_path': filePath,
      'r2_url': r2Url,
      'file_hash': fileHash,
      'status': status.value,
      'materials_extracted': materialsExtracted,
      'extraction_metadata': extractionMetadata,
      'error_message': errorMessage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PdfUploadModel copyWith({
    int? id,
    int? userId,
    String? originalName,
    String? displayName,
    String? filePath,
    String? r2Url,
    String? fileHash,
    PdfUploadStatus? status,
    int? materialsExtracted,
    Map<String, dynamic>? extractionMetadata,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PdfUploadModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      originalName: originalName ?? this.originalName,
      displayName: displayName ?? this.displayName,
      filePath: filePath ?? this.filePath,
      r2Url: r2Url ?? this.r2Url,
      fileHash: fileHash ?? this.fileHash,
      status: status ?? this.status,
      materialsExtracted: materialsExtracted ?? this.materialsExtracted,
      extractionMetadata: extractionMetadata ?? this.extractionMetadata,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == PdfUploadStatus.pending;
  bool get isProcessing => status == PdfUploadStatus.processing;
  bool get isCompleted => status == PdfUploadStatus.completed;
  bool get isFailed => status == PdfUploadStatus.failed;
  bool get isError => status == PdfUploadStatus.error;
}

enum PdfUploadStatus {
  pending('pending'),
  processing('processing'),
  completed('completed'),
  failed('failed'),
  error('error'); // Adicionando status de erro

  const PdfUploadStatus(this.value);
  final String value;
}

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
        return PdfUploadStatus.error; // Adicionando caso para erro
      default:
        throw ArgumentError('Invalid PdfUploadStatus: $value');
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

class PdfUploadResponse {
  final bool success;
  final PdfUploadModel upload;
  final String message;
  final String? r2Url;
  final int? size;

  PdfUploadResponse({
    required this.success,
    required this.upload,
    required this.message,
    this.r2Url,
    this.size,
  });

  factory PdfUploadResponse.fromJson(Map<String, dynamic> json) {
    return PdfUploadResponse(
      success: json['success'] as bool,
      upload: PdfUploadModel.fromJson(
        json['data']['upload'] as Map<String, dynamic>,
      ),
      message: json['data']['message'] as String,
      r2Url: json['data']['r2_url'] as String?,
      size: json['data']['size'] as int?,
    );
  }
}

class PdfUploadListResponse {
  final bool success;
  final List<PdfUploadModel> uploads;
  final PaginationInfo pagination;

  PdfUploadListResponse({
    required this.success,
    required this.uploads,
    required this.pagination,
  });

  factory PdfUploadListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return PdfUploadListResponse(
      success: json['success'] as bool,
      uploads: (data['uploads'] as List<dynamic>)
          .map((item) => PdfUploadModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: PaginationInfo.fromJson(
        data['pagination'] as Map<String, dynamic>,
      ),
    );
  }
}

class PaginationInfo {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final int? from;
  final int? to;

  PaginationInfo({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    this.from,
    this.to,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      total: json['total'] as int,
      perPage: json['per_page'] as int,
      currentPage: json['current_page'] as int,
      lastPage: json['last_page'] as int,
      from: json['from'] as int?,
      to: json['to'] as int?,
    );
  }
}

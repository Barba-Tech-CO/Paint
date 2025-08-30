import 'dart:developer';
import 'quote_upload_status.dart';
import 'quote_upload_status_extension.dart';

class QuoteUploadModel {
  final int id;
  final int userId;
  final String originalName;
  final String? displayName;
  final String filePath;
  final String? r2Url;
  final String fileHash;
  final QuoteUploadStatus status;
  final int materialsExtracted;
  final Map<String, dynamic>? extractionMetadata;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuoteUploadModel({
    required this.id,
    required this.userId,
    required this.originalName,
    this.displayName,
    required this.filePath,
    this.r2Url,
    required this.fileHash,
    required this.status,
    required this.materialsExtracted,
    this.extractionMetadata,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuoteUploadModel.fromJson(Map<String, dynamic> json) {
    log('DEBUG: QuoteUploadModel.fromJson - json: $json');

    // Verificar campos obrigatórios
    if (json['id'] == null) {
      log('DEBUG: QuoteUploadModel.fromJson - Missing required field: id');
      throw Exception('Missing required field: id');
    }

    if (json['original_name'] == null) {
      log(
        'DEBUG: QuoteUploadModel.fromJson - Missing required field: original_name',
      );
      throw Exception('Missing required field: original_name');
    }

    if (json['status'] == null) {
      log('DEBUG: QuoteUploadModel.fromJson - Missing required field: status');
      throw Exception('Missing required field: status');
    }

    if (json['created_at'] == null) {
      log(
        'DEBUG: QuoteUploadModel.fromJson - Missing required field: created_at',
      );
      throw Exception('Missing required field: created_at');
    }

    if (json['updated_at'] == null) {
      log(
        'DEBUG: QuoteUploadModel.fromJson - Missing required field: updated_at',
      );
      throw Exception('Missing required field: updated_at');
    }

    return QuoteUploadModel(
      id: json['id'] as int,
      userId: json['user_id'] as int? ?? 1, // Usar valor padrão se ausente
      originalName: json['original_name'] as String,
      displayName: json['display_name'] as String?,
      filePath:
          json['file_path'] as String? ?? '', // Usar valor padrão se ausente
      r2Url: json['r2_url'] as String?,
      fileHash:
          json['file_hash'] as String? ?? '', // Usar valor padrão se ausente
      status: QuoteUploadStatusExtension.fromString(json['status'] as String),
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

  QuoteUploadModel copyWith({
    int? id,
    int? userId,
    String? originalName,
    String? displayName,
    String? filePath,
    String? r2Url,
    String? fileHash,
    QuoteUploadStatus? status,
    int? materialsExtracted,
    Map<String, dynamic>? extractionMetadata,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuoteUploadModel(
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

  bool get isPending => status == QuoteUploadStatus.pending;
  bool get isProcessing => status == QuoteUploadStatus.processing;
  bool get isCompleted => status == QuoteUploadStatus.completed;
  bool get isFailed => status == QuoteUploadStatus.failed;
  bool get isError => status == QuoteUploadStatus.error;
}

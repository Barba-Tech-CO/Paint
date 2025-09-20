import 'dart:developer';
import 'quote_status.dart';
import 'quote_status_extension.dart';

class QuoteModel {
  final int id;
  final int? userId;
  final String originalName;
  final String? displayName;
  final String filePath;
  final String? r2Url;
  final String? fileHash;
  final QuoteStatus status;
  final int materialsExtracted;
  final Map<String, dynamic>? extractionMetadata;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuoteModel({
    required this.id,
    this.userId,
    required this.originalName,
    this.displayName,
    required this.filePath,
    this.r2Url,
    this.fileHash,
    required this.status,
    required this.materialsExtracted,
    this.extractionMetadata,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Parse DateTime from string, always converting to device local timezone
  static DateTime _parseDateTime(String dateString) {
    try {
      // Parse the date string
      final parsed = DateTime.parse(dateString);

      // Always convert to local timezone of the device
      final localDateTime = parsed.toLocal();

      return localDateTime;
    } catch (e) {
      // Fallback to current local time if parsing fails
      return DateTime.now();
    }
  }

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    // Verificar campos obrigatórios
    if (json['id'] == null) {
      throw Exception('Missing required field: id');
    }

    if (json['original_name'] == null) {
      throw Exception('Missing required field: original_name');
    }

    if (json['status'] == null) {
      throw Exception('Missing required field: status');
    }

    if (json['created_at'] == null) {
      log(
        'DEBUG: PdfUploadModel.fromJson - Missing required field: created_at',
      );
      throw Exception('Missing required field: created_at');
    }

    if (json['updated_at'] == null) {
      log(
        'DEBUG: PdfUploadModel.fromJson - Missing required field: updated_at',
      );
      throw Exception('Missing required field: updated_at');
    }

    // Validate required fields
    if (json['file_path'] == null) {
      throw Exception('Missing required field: file_path');
    }

    return QuoteModel(
      id: json['id'] as int,
      userId: json['user_id'] as int?,
      originalName: json['original_name'] as String,
      displayName: json['display_name'] as String?,
      filePath: json['file_path'] as String,
      r2Url: json['r2_url'] as String?,
      fileHash: json['file_hash'] as String?,
      status: QuoteStatusExtension.fromString(json['status'] as String),
      materialsExtracted: json['materials_extracted'] as int? ?? 0,
      extractionMetadata: json['extraction_metadata'] as Map<String, dynamic>?,
      errorMessage: json['error_message'] as String?,
      createdAt: _parseDateTime(json['created_at'] as String),
      updatedAt: _parseDateTime(json['updated_at'] as String),
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

  QuoteModel copyWith({
    int? id,
    int? userId,
    String? originalName,
    String? displayName,
    String? filePath,
    String? r2Url,
    String? fileHash,
    QuoteStatus? status,
    int? materialsExtracted,
    Map<String, dynamic>? extractionMetadata,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuoteModel(
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

  bool get isPending => status == QuoteStatus.pending;
  bool get isProcessing => status == QuoteStatus.processing;
  bool get isCompleted => status == QuoteStatus.completed;
  bool get isFailed => status == QuoteStatus.failed;
  bool get isError => status == QuoteStatus.error;
}

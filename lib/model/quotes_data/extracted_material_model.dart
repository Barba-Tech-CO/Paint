import 'pdf_upload_info_model.dart';

class ExtractedMaterialModel {
  final int id;
  final int pdfUploadId;
  final int userId;
  final String brand;
  final String description;
  final String type;
  final String unit;
  final double unitPrice;
  final String? finish;
  final String? qualityGrade;
  final String? category;
  final Map<String, dynamic>? specifications;
  final int lineNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PdfUploadInfo? pdfUpload;

  ExtractedMaterialModel({
    required this.id,
    required this.pdfUploadId,
    required this.userId,
    required this.brand,
    required this.description,
    required this.type,
    required this.unit,
    required this.unitPrice,
    this.finish,
    this.qualityGrade,
    this.category,
    this.specifications,
    required this.lineNumber,
    required this.createdAt,
    required this.updatedAt,
    this.pdfUpload,
  });

  factory ExtractedMaterialModel.fromJson(Map<String, dynamic> json) {
    return ExtractedMaterialModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      pdfUploadId: json['pdf_upload_id'] is int
          ? json['pdf_upload_id'] as int
          : int.parse(json['pdf_upload_id'].toString()),
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.parse(json['user_id'].toString()),
      brand: json['brand'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      unit: json['unit'] as String,
      unitPrice: json['unit_price'] is num
          ? (json['unit_price'] as num).toDouble()
          : double.parse(json['unit_price'].toString()),
      finish: json['finish'] as String?,
      qualityGrade: json['quality_grade'] as String?,
      category: json['category'] as String?,
      specifications: json['specifications'] is Map<String, dynamic>
          ? json['specifications'] as Map<String, dynamic>
          : json['specifications'] is List
          ? null
          : json['specifications'] as Map<String, dynamic>?,
      lineNumber: json['line_number'] is int
          ? json['line_number'] as int
          : int.parse(json['line_number'].toString()),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      pdfUpload: json['pdf_upload'] != null
          ? PdfUploadInfo.fromJson(json['pdf_upload'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pdf_upload_id': pdfUploadId,
      'user_id': userId,
      'brand': brand,
      'description': description,
      'type': type,
      'unit': unit,
      'unit_price': unitPrice,
      'finish': finish,
      'quality_grade': qualityGrade,
      'category': category,
      'specifications': specifications,
      'line_number': lineNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'pdf_upload': pdfUpload?.toJson(),
    };
  }

  ExtractedMaterialModel copyWith({
    int? id,
    int? pdfUploadId,
    int? userId,
    String? brand,
    String? description,
    String? type,
    String? unit,
    double? unitPrice,
    String? finish,
    String? qualityGrade,
    String? category,
    Map<String, dynamic>? specifications,
    int? lineNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    PdfUploadInfo? pdfUpload,
  }) {
    return ExtractedMaterialModel(
      id: id ?? this.id,
      pdfUploadId: pdfUploadId ?? this.pdfUploadId,
      userId: userId ?? this.userId,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      type: type ?? this.type,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      finish: finish ?? this.finish,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      category: category ?? this.category,
      specifications: specifications ?? this.specifications,
      lineNumber: lineNumber ?? this.lineNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pdfUpload: pdfUpload ?? this.pdfUpload,
    );
  }

  String get formattedPrice => '\$${unitPrice.toStringAsFixed(2)}';

  String get displayName => '$brand - $description';

  String get fullDescription {
    final parts = <String>[description];
    if (finish != null) parts.add(finish!);
    if (qualityGrade != null) parts.add(qualityGrade!);
    return parts.join(' - ');
  }
}

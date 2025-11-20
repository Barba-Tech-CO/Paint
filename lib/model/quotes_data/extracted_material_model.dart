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
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      final s = v.toString();
      return int.tryParse(s) ?? 0;
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      final s = v.toString();
      return double.tryParse(s) ?? 0.0;
    }

    String parseString(dynamic v) => v == null ? '' : v.toString();

    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
      if (v is DateTime) return v;
      if (v is String) {
        try {
          return DateTime.parse(v);
        } catch (_) {
          return DateTime.fromMillisecondsSinceEpoch(0);
        }
      }
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    final pdfUploadRaw = json['pdf_upload'];
    final pdfUpload = pdfUploadRaw is Map<String, dynamic>
        ? PdfUploadInfo.fromJson(pdfUploadRaw)
        : null;

    final specsRaw = json['specifications'];
    final specifications = specsRaw is Map<String, dynamic>
        ? specsRaw
        : (specsRaw is List ? null : specsRaw as Map<String, dynamic>?);

    return ExtractedMaterialModel(
      id: parseInt(json['id']),
      pdfUploadId: parseInt(json['pdf_upload_id']),
      userId: parseInt(json['user_id']),
      brand: parseString(json['brand']),
      description: parseString(json['description']),
      type: parseString(json['type']),
      unit: parseString(json['unit']),
      unitPrice: parseDouble(json['unit_price']),
      finish: json['finish'] == null ? null : parseString(json['finish']),
      qualityGrade: json['quality_grade'] == null
          ? null
          : parseString(json['quality_grade']),
      category: json['category'] == null ? null : parseString(json['category']),
      specifications: specifications,
      lineNumber: parseInt(json['line_number']),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      pdfUpload: pdfUpload,
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

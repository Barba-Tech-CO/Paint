import 'pdf_upload_model.dart';

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

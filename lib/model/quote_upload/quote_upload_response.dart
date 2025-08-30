import 'quote_upload_model.dart';

class QuoteUploadResponse {
  final bool success;
  final QuoteUploadModel upload;
  final String message;
  final String? r2Url;
  final int? size;

  QuoteUploadResponse({
    required this.success,
    required this.upload,
    required this.message,
    this.r2Url,
    this.size,
  });

  factory QuoteUploadResponse.fromJson(Map<String, dynamic> json) {
    return QuoteUploadResponse(
      success: json['success'] as bool,
      upload: QuoteUploadModel.fromJson(
        json['data']['upload'] as Map<String, dynamic>,
      ),
      message: json['data']['message'] as String,
      r2Url: json['data']['r2_url'] as String?,
      size: json['data']['size'] as int?,
    );
  }
}

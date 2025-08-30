import 'quote_model.dart';

class QuoteResponse {
  final bool success;
  final QuoteModel quote;
  final String message;
  final String? r2Url;
  final int? size;

  QuoteResponse({
    required this.success,
    required this.quote,
    required this.message,
    this.r2Url,
    this.size,
  });

  factory QuoteResponse.fromJson(Map<String, dynamic> json) {
    return QuoteResponse(
      success: json['success'] as bool,
      quote: QuoteModel.fromJson(
        json['data']['upload'] as Map<String, dynamic>,
      ),
      message: json['data']['message'] as String,
      r2Url: json['data']['r2_url'] as String?,
      size: json['data']['size'] as int?,
    );
  }
}

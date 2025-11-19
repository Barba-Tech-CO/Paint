import 'quote_model.dart';

class QuoteResponse {
  final bool success;
  final QuoteModel quote;
  final String message;
  final String? url;
  final int? size;

  QuoteResponse({
    required this.success,
    required this.quote,
    required this.message,
    this.url,
    this.size,
  });

  factory QuoteResponse.fromJson(Map<String, dynamic> json) {
    // Validate required fields
    if (json['success'] == null) {
      throw Exception('Missing required field: success');
    }

    if (json['message'] == null) {
      throw Exception('Missing required field: message');
    }

    final data = json['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Missing required field: data');
    }

    if (data['upload'] == null) {
      throw Exception('Missing required field: data.upload');
    }

    return QuoteResponse(
      success: json['success'] as bool,
      quote: QuoteModel.fromJson(
        data['upload'] as Map<String, dynamic>,
      ),
      message: json['message'] as String,
      url: data['url'] as String?,
      size: data['size'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': {
        'upload': quote.toJson(),
        'url': url,
        'size': size,
      },
    };
  }
}

import 'estimate_model.dart';

class EstimateResponse {
  final bool success;
  final String? message;
  final EstimateModel? data;

  EstimateResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory EstimateResponse.fromJson(Map<String, dynamic> json) {
    return EstimateResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? EstimateModel.fromJson(json['data']) : null,
    );
  }
}

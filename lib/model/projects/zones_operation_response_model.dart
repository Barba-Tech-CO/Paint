import 'project_card_model.dart';

class ZonesOperationResponse {
  final bool success;
  final String message;
  final ProjectCardModel? data;

  ZonesOperationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ZonesOperationResponse.fromJson(Map<String, dynamic> json) {
    return ZonesOperationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ProjectCardModel.fromJson(json['data'])
          : null,
    );
  }
}

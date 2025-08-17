import 'zones_card_model.dart';

class ZonesListResponse {
  final bool success;
  final List<ZonesCardModel> data;
  final String? message;

  ZonesListResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory ZonesListResponse.fromJson(Map<String, dynamic> json) {
    return ZonesListResponse(
      success: json['success'] ?? false,
      data:
          (json['data'] as List<dynamic>?)
              ?.map(
                (item) => ZonesCardModel.fromJson(item),
              )
              .toList() ??
          [],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((item) => item.toJson()).toList(),
      'message': message,
    };
  }
}

import 'ghl_profile_data.dart';

class GhlProfileResponse {
  final bool success;
  final GhlProfileData? data;
  final String? message;

  GhlProfileResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory GhlProfileResponse.fromJson(Map<String, dynamic> json) {
    return GhlProfileResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? GhlProfileData.fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}
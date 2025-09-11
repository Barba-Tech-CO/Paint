import 'dashboard_data.dart';

class DashboardResponse {
  final bool success;
  final DashboardData? data;

  DashboardResponse({
    required this.success,
    this.data,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? DashboardData.fromJson(json['data']) : null,
    );
  }
}

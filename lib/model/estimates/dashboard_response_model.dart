import 'dashboard_data_model.dart';

class DashboardResponseModel {
  final bool success;
  final DashboardDataModel data;
  final String? message;

  const DashboardResponseModel({
    required this.success,
    required this.data,
    this.message,
  });

  factory DashboardResponseModel.fromJson(Map<String, dynamic> json) {
    return DashboardResponseModel(
      success: json['success'] ?? false,
      data: DashboardDataModel.fromJson(json['data'] ?? {}),
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
      'message': message,
    };
  }
}

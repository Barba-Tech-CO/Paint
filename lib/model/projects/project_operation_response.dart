import 'project_model.dart';

class ProjectOperationResponse {
  final bool success;
  final String message;
  final ProjectModel? data;

  ProjectOperationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ProjectOperationResponse.fromJson(Map<String, dynamic> json) {
    return ProjectOperationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ProjectModel.fromJson(json['data']) : null,
    );
  }
}

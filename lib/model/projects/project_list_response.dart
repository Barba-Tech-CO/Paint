import 'project_model.dart';

class ProjectListResponse {
  final bool success;
  final List<ProjectModel> data;
  final String? message;

  ProjectListResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory ProjectListResponse.fromJson(Map<String, dynamic> json) {
    return ProjectListResponse(
      success: json['success'] ?? false,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => ProjectModel.fromJson(item))
              .toList() ??
          [],
      message: json['message'],
    );
  }
}

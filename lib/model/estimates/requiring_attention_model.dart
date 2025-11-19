import '../../utils/json_parser_helper.dart';

class RequiringAttentionModel {
  final int id;
  final String clientName;
  final String projectName;
  final String status;
  final DateTime createdAt;
  final double totalCost;

  const RequiringAttentionModel({
    required this.id,
    required this.clientName,
    required this.projectName,
    required this.status,
    required this.createdAt,
    required this.totalCost,
  });

  factory RequiringAttentionModel.fromJson(Map<String, dynamic> json) {
    return RequiringAttentionModel(
      id: json['id'] ?? 0,
      clientName: json['client_name'] ?? '',
      projectName: json['project_name'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      totalCost: parseDouble(json['total_cost']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_name': clientName,
      'project_name': projectName,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'total_cost': totalCost,
    };
  }
}

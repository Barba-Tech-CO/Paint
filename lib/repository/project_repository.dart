import '../model/projects/project_model.dart';
import '../utils/result/result.dart';

abstract class ProjectRepository {
  /// Lista todos os projetos
  Future<Result<List<ProjectModel>>> getProjects({
    int? limit,
    int? offset,
    String? status,
    String? clientName,
    String? projectType,
    String? search,
  });

  /// Obtém um projeto específico por ID
  Future<Result<ProjectModel>> getProject(String id);

  /// Cria um novo projeto
  Future<Result<ProjectModel>> createProject({
    required String projectName,
    required String clientName,
    required String projectType,
    required String contact,
    String? additionalNotes,
    String? wallCondition,
    bool? hasAccentWall,
    String? extraNotes,
    Map<String, dynamic>? materialsCalculation,
    double? totalCost,
    bool? complete,
    List<String>? photos,
    List<Map<String, dynamic>>? paintElements,
    Map<String, dynamic>? roomMeasurements,
  });

  /// Atualiza um projeto existente
  Future<Result<ProjectModel>> updateProject({
    required String id,
    String? projectName,
    String? clientName,
    String? projectType,
    String? contact,
    String? additionalNotes,
    String? wallCondition,
    bool? hasAccentWall,
    String? extraNotes,
    Map<String, dynamic>? materialsCalculation,
    double? totalCost,
    bool? complete,
    List<String>? photos,
    List<Map<String, dynamic>>? paintElements,
    Map<String, dynamic>? roomMeasurements,
  });

  /// Remove um projeto
  Future<Result<bool>> deleteProject(String id);

  /// Obtém estatísticas do dashboard
  Future<Result<Map<String, dynamic>>> getDashboardData();
}

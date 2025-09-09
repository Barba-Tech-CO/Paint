import '../../model/projects/project_model.dart';
import '../../repository/project_repository.dart';
import '../../utils/result/result.dart';

class ProjectOperationsUseCase {
  final ProjectRepository _projectRepository;

  ProjectOperationsUseCase(this._projectRepository);

  /// Obtém lista de projetos com filtros opcionais
  Future<Result<List<ProjectModel>>> getProjects({
    int? limit,
    int? offset,
    String? status,
    String? clientName,
    String? projectType,
    String? search,
  }) async {
    return await _projectRepository.getProjects(
      limit: limit,
      offset: offset,
      status: status,
      clientName: clientName,
      projectType: projectType,
      search: search,
    );
  }

  /// Obtém um projeto específico
  Future<Result<ProjectModel>> getProject(String id) async {
    if (id.isEmpty) {
      return Result.error(Exception('Project ID cannot be empty'));
    }
    return await _projectRepository.getProject(id);
  }

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
  }) async {
    // Validação básica dos campos obrigatórios
    if (projectName.trim().isEmpty) {
      return Result.error(Exception('Project name cannot be empty'));
    }

    if (clientName.trim().isEmpty) {
      return Result.error(Exception('Client name cannot be empty'));
    }

    if (contact.trim().isEmpty) {
      return Result.error(Exception('Contact cannot be empty'));
    }

    if (!['interior', 'exterior', 'both'].contains(projectType)) {
      return Result.error(
        Exception('Project type must be interior, exterior, or both'),
      );
    }

    return await _projectRepository.createProject(
      projectName: projectName,
      clientName: clientName,
      projectType: projectType,
      contact: contact,
      additionalNotes: additionalNotes,
      wallCondition: wallCondition,
      hasAccentWall: hasAccentWall,
      extraNotes: extraNotes,
      materialsCalculation: materialsCalculation,
      totalCost: totalCost,
      complete: complete,
      photos: photos,
      paintElements: paintElements,
      roomMeasurements: roomMeasurements,
    );
  }

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
  }) async {
    if (id.isEmpty) {
      return Result.error(Exception('Project ID cannot be empty'));
    }

    // Validação dos campos se fornecidos
    if (projectName != null && projectName.trim().isEmpty) {
      return Result.error(Exception('Project name cannot be empty'));
    }

    if (clientName != null && clientName.trim().isEmpty) {
      return Result.error(Exception('Client name cannot be empty'));
    }

    if (contact != null && contact.trim().isEmpty) {
      return Result.error(Exception('Contact cannot be empty'));
    }

    if (projectType != null &&
        !['interior', 'exterior', 'both'].contains(projectType)) {
      return Result.error(
        Exception('Project type must be interior, exterior, or both'),
      );
    }

    return await _projectRepository.updateProject(
      id: id,
      projectName: projectName,
      clientName: clientName,
      projectType: projectType,
      contact: contact,
      additionalNotes: additionalNotes,
      wallCondition: wallCondition,
      hasAccentWall: hasAccentWall,
      extraNotes: extraNotes,
      materialsCalculation: materialsCalculation,
      totalCost: totalCost,
      complete: complete,
      photos: photos,
      paintElements: paintElements,
      roomMeasurements: roomMeasurements,
    );
  }

  /// Remove um projeto
  Future<Result<bool>> deleteProject(String id) async {
    if (id.isEmpty) {
      return Result.error(Exception('Project ID cannot be empty'));
    }
    return await _projectRepository.deleteProject(id);
  }

  /// Obtém dados do dashboard
  Future<Result<Map<String, dynamic>>> getDashboardData() async {
    return await _projectRepository.getDashboardData();
  }
}

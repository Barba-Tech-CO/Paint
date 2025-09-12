import 'package:flutter/foundation.dart';

import '../../domain/repository/estimate_repository.dart';
import '../../model/estimates/estimate_model.dart';
import '../../model/projects/project_model.dart';
import '../../utils/command/command.dart';
import '../../utils/result/result.dart';

enum ProjectsState { initial, loading, loaded, error }

// Data classes for operations
class RenameProjectData {
  final String projectId;
  final String newName;

  RenameProjectData({
    required this.projectId,
    required this.newName,
  });
}

class ProjectsViewModel extends ChangeNotifier {
  final IEstimateRepository _estimateRepository;

  // State
  ProjectsState _state = ProjectsState.initial;
  ProjectsState get state => _state;

  // Data
  List<ProjectModel> _projects = [];
  List<ProjectModel> get projects => _projects;

  set projects(List<ProjectModel> value) {
    _projects = value;
    _filteredProjects = List.from(value);
    // Use Future.microtask to defer notification
    Future.microtask(() {
      notifyListeners();
    });
  }

  List<ProjectModel> _filteredProjects = [];
  List<ProjectModel> get filteredProjects => _filteredProjects;

  set filteredProjects(List<ProjectModel> value) {
    _filteredProjects = value;
    // Use Future.microtask to defer notification
    Future.microtask(() {
      notifyListeners();
    });
  }

  ProjectModel? _selectedProject;
  ProjectModel? get selectedProject => _selectedProject;

  set selectedProject(ProjectModel? value) {
    _selectedProject = value;
    // Use Future.microtask to defer notification
    Future.microtask(() {
      notifyListeners();
    });
  }

  // Search
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  set searchQuery(String value) {
    if (_searchQuery != value) {
      _searchQuery = value;
      // Use Future.microtask to defer the filtering and notification
      Future.microtask(() {
        _filterProjectsByQuery(value);
        notifyListeners();
      });
    }
  }

  // Error
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  set errorMessage(String? value) {
    _errorMessage = value;
    // Use Future.microtask to defer notification
    Future.microtask(() {
      notifyListeners();
    });
  }

  ProjectsViewModel(this._estimateRepository);

  // Commands
  Command0<void>? _loadProjectsCommand;
  Command1<void, ProjectModel>? _addProjectCommand;
  Command1<void, ProjectModel>? _updateProjectCommand;
  Command1<void, String>? _deleteProjectCommand;
  Command1<void, String>? _searchProjectsCommand;
  Command1<void, RenameProjectData>? _renameProjectCommand;

  Command0<void> get loadProjectsCommand => _loadProjectsCommand!;
  Command1<void, ProjectModel> get addProjectCommand => _addProjectCommand!;
  Command1<void, ProjectModel> get updateProjectCommand =>
      _updateProjectCommand!;
  Command1<void, String> get deleteProjectCommand => _deleteProjectCommand!;
  Command1<void, String> get searchProjectsCommand => _searchProjectsCommand!;
  Command1<void, RenameProjectData> get renameProjectCommand =>
      _renameProjectCommand!;

  // Computed properties
  bool get isLoading =>
      _state == ProjectsState.initial ||
      _state == ProjectsState.loading ||
      (_loadProjectsCommand?.running ?? false);
  bool get hasError => _state == ProjectsState.error || _errorMessage != null;
  bool get hasProjects => _projects.isNotEmpty;
  bool get hasFilteredProjects => _filteredProjects.isNotEmpty;
  int get projectsCount => _projects.length;
  int get filteredProjectsCount => _filteredProjects.length;
  bool get isSearching => _searchQuery.isNotEmpty;
  bool get isInitialized => _loadProjectsCommand != null;

  // Initialize
  void initialize() {
    if (!isInitialized) {
      _initializeCommands();
      loadProjects();
    }
  }

  void _initializeCommands() {
    _loadProjectsCommand = Command0(() async {
      return await _loadProjectsData();
    });

    _addProjectCommand = Command1((ProjectModel project) async {
      return await _addProjectData(project);
    });

    _updateProjectCommand = Command1((ProjectModel project) async {
      return await _updateProjectData(project);
    });

    _deleteProjectCommand = Command1((String projectId) async {
      return await _deleteProjectData(projectId);
    });

    _searchProjectsCommand = Command1((String query) async {
      return await _searchProjectsData(query);
    });

    _renameProjectCommand = Command1((RenameProjectData data) async {
      return await _renameProjectData(data.projectId, data.newName);
    });
  }

  // Public methods
  Future<void> loadProjects() async {
    if (_loadProjectsCommand != null) {
      await _loadProjectsCommand!.execute();
    }
  }

  Future<void> addProject(ProjectModel project) async {
    if (_addProjectCommand != null) {
      await _addProjectCommand!.execute(project);
    }
  }

  Future<void> updateProject(ProjectModel project) async {
    if (_updateProjectCommand != null) {
      await _updateProjectCommand!.execute(project);
    }
  }

  Future<void> deleteProject(String projectId) async {
    if (_deleteProjectCommand != null) {
      await _deleteProjectCommand!.execute(projectId);
    }
  }

  Future<void> renameProject(String projectId, String newName) async {
    if (_renameProjectCommand != null) {
      await _renameProjectCommand!.execute(
        RenameProjectData(projectId: projectId, newName: newName),
      );
    }
  }

  Future<void> searchProjects(String query) async {
    _searchQuery = query;
    if (_searchProjectsCommand != null) {
      await _searchProjectsCommand!.execute(query);
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredProjects = List.from(_projects);
    // Use Future.microtask to defer notification
    Future.microtask(() {
      notifyListeners();
    });
  }

  void selectProject(ProjectModel? project) {
    _selectedProject = project;
    // Use Future.microtask to defer notification
    Future.microtask(() {
      notifyListeners();
    });
  }

  // Private helper methods
  void _filterProjectsByQuery(String query) {
    if (query.isEmpty) {
      _filteredProjects = List.from(_projects);
    } else {
      final searchLower = query.toLowerCase();
      _filteredProjects = _projects.where((project) {
        final projectName = project.projectName.toLowerCase();
        final personName = project.personName.toLowerCase();

        return projectName.contains(searchLower) ||
            personName.contains(searchLower);
      }).toList();
    }
  }

  // Additional helper methods
  void addProjectToList(ProjectModel project) {
    _projects.add(project);
    _filterProjectsByQuery(_searchQuery);
    // Use Future.microtask to defer notification
    Future.microtask(() {
      notifyListeners();
    });
  }

  void updateProjectInList(ProjectModel updatedProject) {
    final index = _projects.indexWhere((p) => p.id == updatedProject.id);
    if (index != -1) {
      _projects[index] = updatedProject;
      _filterProjectsByQuery(_searchQuery);
      // Use Future.microtask to defer notification
      Future.microtask(() {
        notifyListeners();
      });
    }
  }

  void removeProjectFromList(String projectId) {
    _projects.removeWhere((p) => p.id.toString() == projectId);
    _filterProjectsByQuery(_searchQuery);
    // Use Future.microtask to defer notification
    Future.microtask(() {
      notifyListeners();
    });
  }

  ProjectModel? getProjectById(String id) {
    try {
      return _projects.firstWhere((project) => project.id.toString() == id);
    } catch (e) {
      return null;
    }
  }

  // Private methods - Carregar via Estimates API
  Future<Result<void>> _loadProjectsData() async {
    try {
      _state = ProjectsState.loading;
      _errorMessage = null;
      notifyListeners();

      final result = await _estimateRepository.getEstimates(limit: 50, offset: 0);
      if (result is Ok<List<EstimateModel>>) {
        final estimates = result.asOk.value;
        _projects = estimates.map(_mapEstimateToProject).toList();
        _filteredProjects = List.from(_projects);
        _state = ProjectsState.loaded;
        notifyListeners();
        return Result.ok(null);
      } else {
        _state = ProjectsState.error;
        _errorMessage = 'Erro ao carregar projetos: \\${result.asError.error}';
        notifyListeners();
        return Result.error(Exception(_errorMessage));
      }
    } catch (e) {
      _state = ProjectsState.error;
      _errorMessage = 'Erro ao carregar projetos: ${e.toString()}';
      notifyListeners();
      return Result.error(Exception(_errorMessage));
    }
  }

  ProjectModel _mapEstimateToProject(EstimateModel e) {
    final created = e.createdAt != null
        ? '${e.createdAt!.day.toString().padLeft(2, '0')}/${e.createdAt!.month.toString().padLeft(2, '0')}/${e.createdAt!.year % 100}'
        : '';
    final image = (e.photos != null && e.photos!.isNotEmpty)
        ? e.photos!.first
        : 'assets/images/kitchen.png';
    return ProjectModel(
      id: int.tryParse(e.id ?? '') ?? e.hashCode,
      projectName: e.projectName ?? 'Estimate',
      personName: e.clientName ?? '',
      zonesCount: e.zones?.length ?? 0,
      createdDate: created,
      image: image,
    );
  }

  Future<Result<void>> _addProjectData(ProjectModel project) async {
    try {
      // TODO: Implementar quando o ProjectOperationsUseCase estiver pronto
      // final result = await _projectUseCase.createProject(
      //   projectName: project.projectName,
      //   personName: project.personName,
      //   zonesCount: project.zonesCount,
      //   createdDate: project.createdDate,
      //   image: project.image,
      // );

      // Mock implementation
      await Future.delayed(const Duration(milliseconds: 300));
      final newProject = ProjectModel(
        id: DateTime.now().millisecondsSinceEpoch,
        projectName: project.projectName,
        personName: project.personName,
        zonesCount: project.zonesCount,
        createdDate: project.createdDate,
        image: project.image,
      );

      _projects.add(newProject);
      _filteredProjects = List.from(_projects);
      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      _errorMessage = 'Erro ao adicionar projeto: ${e.toString()}';
      notifyListeners();
      return Result.error(Exception(_errorMessage));
    }
  }

  Future<Result<void>> _updateProjectData(ProjectModel project) async {
    try {
      // TODO: Implementar quando o ProjectOperationsUseCase estiver pronto
      // final result = await _projectUseCase.updateProject(
      //   project.id.toString(),
      //   projectName: project.projectName,
      //   personName: project.personName,
      //   zonesCount: project.zonesCount,
      //   createdDate: project.createdDate,
      //   image: project.image,
      // );

      // Mock implementation
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        _projects[index] = project;
        _filteredProjects = List.from(_projects);
        notifyListeners();
      }
      return Result.ok(null);
    } catch (e) {
      _errorMessage = 'Erro ao atualizar projeto: ${e.toString()}';
      notifyListeners();
      return Result.error(Exception(_errorMessage));
    }
  }

  Future<Result<void>> _deleteProjectData(String projectId) async {
    try {
      // TODO: Implementar quando o ProjectOperationsUseCase estiver pronto
      // final result = await _projectUseCase.deleteProject(projectId);

      // Mock implementation
      await Future.delayed(const Duration(milliseconds: 300));
      _projects.removeWhere((p) => p.id.toString() == projectId);
      _filteredProjects = List.from(_projects);
      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      _errorMessage = 'Erro ao deletar projeto: ${e.toString()}';
      notifyListeners();
      return Result.error(Exception(_errorMessage));
    }
  }

  Future<Result<void>> _renameProjectData(
    String projectId,
    String newName,
  ) async {
    try {
      // TODO: Implementar quando o ProjectOperationsUseCase estiver pronto
      // final result = await _projectUseCase.renameProject(projectId, newName);

      // Mock implementation
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _projects.indexWhere((p) => p.id.toString() == projectId);
      if (index != -1) {
        final updatedProject = _projects[index].copyWith(projectName: newName);
        _projects[index] = updatedProject;
        _filteredProjects = List.from(_projects);
        notifyListeners();
      }
      return Result.ok(null);
    } catch (e) {
      _errorMessage = 'Erro ao renomear projeto: ${e.toString()}';
      notifyListeners();
      return Result.error(Exception(_errorMessage));
    }
  }

  Future<Result<void>> _searchProjectsData(String query) async {
    try {
      if (query.isEmpty) {
        _filteredProjects = List.from(_projects);
        notifyListeners();
        return Result.ok(null);
      }

      // TODO: Implementar quando o ProjectOperationsUseCase estiver pronto
      // final result = await _projectUseCase.searchProjects(query);

      // Mock implementation - filtrar localmente
      _filterProjectsByQuery(query);
      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      _errorMessage = 'Erro ao buscar projetos: ${e.toString()}';
      notifyListeners();
      return Result.error(Exception(_errorMessage));
    }
  }

  // Mock generator removido: projetos agora vêm da API de Estimates
}

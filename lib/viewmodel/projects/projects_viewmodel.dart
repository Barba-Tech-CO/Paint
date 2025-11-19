import 'package:flutter/foundation.dart';

import '../../model/projects/project_model.dart';
import '../../model/projects/projects_state.dart';
import '../../model/projects/rename_project_data.dart';
import '../../use_case/projects/project_operations_use_case.dart';
import '../../utils/command/command.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class ProjectsViewModel extends ChangeNotifier {
  final ProjectOperationsUseCase _projectOperationsUseCase;
  final AppLogger _logger;

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

  ProjectsViewModel(this._projectOperationsUseCase, this._logger);

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

  // Private methods - Load via UseCase
  Future<Result<void>> _loadProjectsData() async {
    try {
      _state = ProjectsState.loading;
      _errorMessage = null;
      notifyListeners();

      final result = await _projectOperationsUseCase.loadProjects();
      if (result is Ok<List<ProjectModel>>) {
        _projects = result.asOk.value;
        _filteredProjects = List.from(_projects);
        _state = ProjectsState.loaded;
        
        notifyListeners();
        return Result.ok(null);
      } else {
        _state = ProjectsState.error;
        _errorMessage = 'Unable to load projects. Please try again.';
        _logger.error(
          'ProjectsViewModel: Error loading projects: ${result.asError.error}',
          result.asError.error,
        );
        notifyListeners();
        return Result.error(
          Exception(_errorMessage),
        );
      }
    } catch (e) {
      _state = ProjectsState.error;
      _errorMessage = 'Unable to load projects. Please try again.';
      _logger.error('ProjectsViewModel: Exception loading projects: $e', e);
      notifyListeners();
      return Result.error(
        Exception(_errorMessage),
      );
    }
  }

  Future<Result<void>> _addProjectData(ProjectModel project) async {
    try {
      final result = await _projectOperationsUseCase.createProject(project);
      if (result is Ok<ProjectModel>) {
        final newProject = result.asOk.value;
        _projects.add(newProject);
        _filteredProjects = List.from(_projects);
        notifyListeners();
        return Result.ok(null);
      } else {
        _errorMessage = 'Unable to create project. Please try again.';
        _logger.error(
          'Error creating project: ${result.asError.error}',
          result.asError.error,
        );
        notifyListeners();
        return Result.error(
          Exception(_errorMessage),
        );
      }
    } catch (e) {
      _errorMessage = 'Unable to create project. Please try again.';
      _logger.error('Error creating project: $e', e);
      notifyListeners();
      return Result.error(
        Exception(_errorMessage),
      );
    }
  }

  Future<Result<void>> _updateProjectData(ProjectModel project) async {
    try {
      final result = await _projectOperationsUseCase.updateProject(project);
      if (result is Ok<ProjectModel>) {
        final updatedProject = result.asOk.value;
        final index = _projects.indexWhere((p) => p.id == project.id);
        if (index != -1) {
          _projects[index] = updatedProject;
          _filteredProjects = List.from(_projects);
          notifyListeners();
        }
        return Result.ok(null);
      } else {
        _errorMessage = 'Unable to update project. Please try again.';
        _logger.error(
          'Error updating project: ${result.asError.error}',
          result.asError.error,
        );
        notifyListeners();
        return Result.error(
          Exception(_errorMessage),
        );
      }
    } catch (e) {
      _errorMessage = 'Unable to update project. Please try again.';
      _logger.error('Error updating project: $e', e);
      notifyListeners();
      return Result.error(
        Exception(_errorMessage),
      );
    }
  }

  Future<Result<void>> _deleteProjectData(String projectId) async {
    try {
      final result = await _projectOperationsUseCase.deleteProject(projectId);
      if (result is Ok<bool>) {
        _projects.removeWhere((p) => p.id.toString() == projectId);
        _filteredProjects = List.from(_projects);
        notifyListeners();
        return Result.ok(null);
      } else {
        _errorMessage = 'Unable to delete project. Please try again.';
        _logger.error(
          'Error deleting project: ${result.asError.error}',
          result.asError.error,
        );
        notifyListeners();
        return Result.error(
          Exception(_errorMessage),
        );
      }
    } catch (e) {
      _errorMessage = 'Unable to delete project. Please try again.';
      _logger.error('Error deleting project: $e', e);
      notifyListeners();
      return Result.error(
        Exception(_errorMessage),
      );
    }
  }

  Future<Result<void>> _renameProjectData(
    String projectId,
    String newName,
  ) async {
    try {
      final result = await _projectOperationsUseCase.renameProject(
        projectId,
        newName,
      );
      if (result is Ok<ProjectModel>) {
        final updatedProject = result.asOk.value;
        final index = _projects.indexWhere((p) => p.id.toString() == projectId);
        if (index != -1) {
          _projects[index] = updatedProject;
          _filteredProjects = List.from(_projects);
          notifyListeners();
        }
        return Result.ok(null);
      } else {
        _errorMessage = 'Unable to rename project. Please try again.';
        _logger.error(
          'Error renaming project: ${result.asError.error}',
          result.asError.error,
        );
        notifyListeners();
        return Result.error(
          Exception(_errorMessage),
        );
      }
    } catch (e) {
      _errorMessage = 'Unable to rename project. Please try again.';
      _logger.error('Error renaming project: $e', e);
      notifyListeners();
      return Result.error(
        Exception(_errorMessage),
      );
    }
  }

  Future<Result<void>> _searchProjectsData(String query) async {
    try {
      if (query.isEmpty) {
        _filteredProjects = List.from(_projects);
        notifyListeners();
        return Result.ok(null);
      }

      // Filter projects locally since the API doesn't have search functionality
      // This is more efficient than making API calls for each search
      _filterProjectsByQuery(query);
      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      _errorMessage = 'Unable to search projects. Please try again.';
      _logger.error('Error searching projects: $e', e);
      notifyListeners();
      return Result.error(
        Exception(_errorMessage),
      );
    }
  }
}

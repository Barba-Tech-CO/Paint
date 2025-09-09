import 'package:flutter/foundation.dart';

import '../../model/projects/project_model.dart';
import '../../use_case/projects/project_operations_use_case.dart';
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
  final ProjectOperationsUseCase _projectUseCase;

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

  ProjectsViewModel(this._projectUseCase);

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
      return await _renameProjectData(data);
    });
  }

  // Public methods
  void loadProjects() {
    if (_loadProjectsCommand != null && !_loadProjectsCommand!.running) {
      _loadProjectsCommand!.execute();
    }
  }

  void addProject(ProjectModel project) {
    if (_addProjectCommand != null && !_addProjectCommand!.running) {
      _addProjectCommand!.execute(project);
    }
  }

  void updateProject(ProjectModel project) {
    if (_updateProjectCommand != null && !_updateProjectCommand!.running) {
      _updateProjectCommand!.execute(project);
    }
  }

  void deleteProject(String projectId) {
    if (_deleteProjectCommand != null && !_deleteProjectCommand!.running) {
      _deleteProjectCommand!.execute(projectId);
    }
  }

  void searchProjects(String query) {
    searchQuery = query;
    if (_searchProjectsCommand != null && !_searchProjectsCommand!.running) {
      _searchProjectsCommand!.execute(query);
    }
  }

  void renameProject(String projectId, String newName) {
    final renameData = RenameProjectData(
      projectId: projectId,
      newName: newName,
    );
    if (_renameProjectCommand != null && !_renameProjectCommand!.running) {
      _renameProjectCommand!.execute(renameData);
    }
  }

  void clearSearch() {
    searchQuery = '';
    _filteredProjects = List.from(_projects);
    notifyListeners();
  }

  void selectProject(ProjectModel? project) {
    selectedProject = project;
  }

  void clearError() {
    errorMessage = null;
  }

  void _filterProjectsByQuery(String query) {
    if (query.isEmpty) {
      _filteredProjects = List.from(_projects);
    } else {
      final lowerQuery = query.toLowerCase();
      _filteredProjects = _projects.where((project) {
        return project.projectName.toLowerCase().contains(lowerQuery) ||
            project.personName.toLowerCase().contains(lowerQuery);
      }).toList();
    }
  }

  // Private data methods
  Future<Result<void>> _loadProjectsData() async {
    try {
      _state = ProjectsState.loading;
      _errorMessage = null;
      notifyListeners();

      final result = await _projectUseCase.getProjects();
      if (result is Ok) {
        final projectsList = result.asOk.value;
        _projects = projectsList;
        _filteredProjects = List.from(_projects);
        _state = ProjectsState.loaded;
        notifyListeners();
        return Result.ok(null);
      } else {
        _state = ProjectsState.error;
        _errorMessage = 'Erro ao carregar projetos: ${result.asError.error}';
        notifyListeners();
        return Result.error(Exception(_errorMessage));
      }
    } catch (e) {
      _state = ProjectsState.error;
      _errorMessage = 'Erro ao buscar projetos: ${e.toString()}';
      notifyListeners();
      return Result.error(Exception(_errorMessage));
    }
  }

  Future<Result<void>> _addProjectData(ProjectModel project) async {
    try {
      final result = await _projectUseCase.createProject(
        projectName: project.projectName,
        clientName: project.personName,
        projectType: 'interior', // Default value, should be passed as parameter
        contact:
            'contact_${project.personName.toLowerCase().replaceAll(' ', '_')}',
        materialsCalculation: {
          'gallons_needed': 2.0,
          'cans_needed': 2,
          'unit': 'gallon',
        },
        totalCost: 250.0,
        complete: false,
      );

      if (result is Ok) {
        final newProject = result.asOk.value;
        _projects.add(newProject);
        _filteredProjects = List.from(_projects);
        notifyListeners();
        return Result.ok(null);
      } else {
        _errorMessage = 'Erro ao adicionar projeto: ${result.asError.error}';
        notifyListeners();
        return Result.error(Exception(_errorMessage));
      }
    } catch (e) {
      _errorMessage = 'Erro ao adicionar projeto: ${e.toString()}';
      notifyListeners();
      return Result.error(Exception(_errorMessage));
    }
  }

  Future<Result<void>> _updateProjectData(ProjectModel project) async {
    try {
      final result = await _projectUseCase.updateProject(
        id: project.id.toString(),
        projectName: project.projectName,
        clientName: project.personName,
      );

      if (result is Ok) {
        final updatedProject = result.asOk.value;
        final index = _projects.indexWhere((p) => p.id == project.id);
        if (index >= 0) {
          _projects[index] = updatedProject;
          _filteredProjects = List.from(_projects);
          notifyListeners();
        }
        return Result.ok(null);
      } else {
        _errorMessage = 'Erro ao atualizar projeto: ${result.asError.error}';
        notifyListeners();
        return Result.error(Exception(_errorMessage));
      }
    } catch (e) {
      _errorMessage = 'Erro ao atualizar projeto: ${e.toString()}';
      notifyListeners();
      return Result.error(Exception(_errorMessage));
    }
  }

  Future<Result<void>> _deleteProjectData(String projectId) async {
    try {
      final result = await _projectUseCase.deleteProject(projectId);

      if (result is Ok) {
        _projects.removeWhere((p) => p.id.toString() == projectId);
        _filteredProjects = List.from(_projects);
        notifyListeners();
        return Result.ok(null);
      } else {
        _errorMessage = 'Erro ao deletar projeto: ${result.asError.error}';
        notifyListeners();
        return Result.error(Exception(_errorMessage));
      }
    } catch (e) {
      _errorMessage = 'Erro ao deletar projeto: ${e.toString()}';
      notifyListeners();
      return Result.error(Exception(_errorMessage));
    }
  }

  Future<Result<void>> _searchProjectsData(String query) async {
    try {
      final result = await _projectUseCase.getProjects(search: query);
      if (result is Ok) {
        final projectsList = result.asOk.value;
        _filteredProjects = projectsList;
        notifyListeners();
        return Result.ok(null);
      } else {
        _errorMessage = 'Erro ao buscar projetos: ${result.asError.error}';
        notifyListeners();
        return Result.error(Exception(_errorMessage));
      }
    } catch (e) {
      _errorMessage = 'Erro ao buscar projetos: ${e.toString()}';
      notifyListeners();
      return Result.error(Exception(_errorMessage));
    }
  }

  Future<Result<void>> _renameProjectData(RenameProjectData renameData) async {
    try {
      final result = await _projectUseCase.updateProject(
        id: renameData.projectId,
        projectName: renameData.newName,
      );

      if (result is Ok) {
        final updatedProject = result.asOk.value;
        final index = _projects.indexWhere(
          (p) => p.id.toString() == renameData.projectId,
        );
        if (index >= 0) {
          _projects[index] = updatedProject;
          _filteredProjects = List.from(_projects);
          notifyListeners();
        }
        return Result.ok(null);
      } else {
        _errorMessage = 'Erro ao renomear projeto: ${result.asError.error}';
        notifyListeners();
        return Result.error(Exception(_errorMessage));
      }
    } catch (e) {
      _errorMessage = 'Erro ao renomear projeto: ${e.toString()}';
      notifyListeners();
      return Result.error(Exception(_errorMessage));
    }
  }
}

import 'package:flutter/foundation.dart';

import '../../model/models.dart';
import '../../utils/command/command.dart';
import '../../utils/result/result.dart';

enum ProjectsState { initial, loading, loaded, error }

class ProjectsViewModel extends ChangeNotifier {
  // NOTE: ProjectOperationsUseCase será injetado aqui quando estiver pronto
  // final ProjectOperationsUseCase _projectUseCase;

  // State
  ProjectsState _state = ProjectsState.initial;
  ProjectsState get state => _state;

  // Data
  List<ProjectCardModel> _projects = [];
  List<ProjectCardModel> get projects => _projects;

  set projects(List<ProjectCardModel> value) {
    _projects = value;
    _filteredProjects = List.from(value);
    // Use Future.microtask to defer notification
    Future.microtask(() {
      notifyListeners();
    });
  }

  List<ProjectCardModel> _filteredProjects = [];
  List<ProjectCardModel> get filteredProjects => _filteredProjects;

  set filteredProjects(List<ProjectCardModel> value) {
    _filteredProjects = value;
    // Use Future.microtask to defer notification
    Future.microtask(() {
      notifyListeners();
    });
  }

  ProjectCardModel? _selectedProject;
  ProjectCardModel? get selectedProject => _selectedProject;

  set selectedProject(ProjectCardModel? value) {
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

  ProjectsViewModel();
  // ProjectsViewModel(this._projectUseCase); // Uncomment quando o use case estiver pronto

  // Commands
  Command0<void>? _loadProjectsCommand;
  Command1<void, ProjectCardModel>? _addProjectCommand;
  Command1<void, ProjectCardModel>? _updateProjectCommand;
  Command1<void, String>? _deleteProjectCommand;
  Command1<void, String>? _searchProjectsCommand;

  Command0<void> get loadProjectsCommand => _loadProjectsCommand!;
  Command1<void, ProjectCardModel> get addProjectCommand => _addProjectCommand!;
  Command1<void, ProjectCardModel> get updateProjectCommand =>
      _updateProjectCommand!;
  Command1<void, String> get deleteProjectCommand => _deleteProjectCommand!;
  Command1<void, String> get searchProjectsCommand => _searchProjectsCommand!;

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

    _addProjectCommand = Command1((ProjectCardModel project) async {
      return await _addProjectData(project);
    });

    _updateProjectCommand = Command1((ProjectCardModel project) async {
      return await _updateProjectData(project);
    });

    _deleteProjectCommand = Command1((String projectId) async {
      return await _deleteProjectData(projectId);
    });

    _searchProjectsCommand = Command1((String query) async {
      return await _searchProjectsData(query);
    });
  }

  // Public methods
  Future<void> loadProjects() async {
    if (_loadProjectsCommand != null) {
      await _loadProjectsCommand!.execute();
    }
  }

  Future<void> addProject(ProjectCardModel project) async {
    if (_addProjectCommand != null) {
      await _addProjectCommand!.execute(project);
    }
  }

  Future<void> updateProject(ProjectCardModel project) async {
    if (_updateProjectCommand != null) {
      await _updateProjectCommand!.execute(project);
    }
  }

  Future<void> deleteProject(String projectId) async {
    if (_deleteProjectCommand != null) {
      await _deleteProjectCommand!.execute(projectId);
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

  void selectProject(ProjectCardModel? project) {
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
        final title = project.title.toLowerCase();
        final areaPaintable = project.areaPaintable.toLowerCase();
        final floorAreaValue = project.floorAreaValue.toLowerCase();

        return title.contains(searchLower) ||
            areaPaintable.contains(searchLower) ||
            floorAreaValue.contains(searchLower);
      }).toList();
    }
  }

  // Additional helper methods
  void addProjectToList(ProjectCardModel project) {
    _projects.add(project);
    _filterProjectsByQuery(_searchQuery);
    // Use Future.microtask to defer notification
    Future.microtask(() {
      notifyListeners();
    });
  }

  void updateProjectInList(ProjectCardModel updatedProject) {
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

  ProjectCardModel? getProjectById(String id) {
    try {
      return _projects.firstWhere((project) => project.id.toString() == id);
    } catch (e) {
      return null;
    }
  }

  // Private methods - Mock data até o Repository ser implementado
  Future<Result<void>> _loadProjectsData() async {
    try {
      _state = ProjectsState.loading;
      _errorMessage = null;
      notifyListeners();

      // Simular chamada de API - substituir pela implementação real do use case
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data - substituir pela resposta real do repository
      final mockProjects = _generateMockProjects();
      _projects = mockProjects;
      _filteredProjects = List.from(_projects);
      _state = ProjectsState.loaded;
      notifyListeners();
      return Result.ok(null);

      // TODO: Implementar quando o ProjectOperationsUseCase estiver pronto
      // final result = await _projectUseCase.getProjects();
      // if (result is Ok) {
      //   final response = result.asOk.value;
      //   _projects = response.projects;
      //   _filteredProjects = List.from(_projects);
      //   _state = ProjectsState.loaded;
      //   notifyListeners();
      //   return Result.ok(null);
      // } else {
      //   _state = ProjectsState.error;
      //   _errorMessage = 'Erro ao carregar projetos: ${result.asError.error}';
      //   notifyListeners();
      //   return Result.error(Exception(_errorMessage));
      // }
    } catch (e) {
      _state = ProjectsState.error;
      _errorMessage = 'Erro ao carregar projetos: ${e.toString()}';
      notifyListeners();
      return Result.error(Exception(_errorMessage));
    }
  }

  Future<Result<void>> _addProjectData(ProjectCardModel project) async {
    try {
      // TODO: Implementar quando o ProjectOperationsUseCase estiver pronto
      // final result = await _projectUseCase.createProject(
      //   title: project.title,
      //   image: project.image,
      //   floorDimensionValue: project.floorDimensionValue,
      //   floorAreaValue: project.floorAreaValue,
      //   areaPaintable: project.areaPaintable,
      //   ceilingArea: project.ceilingArea,
      //   trimLength: project.trimLength,
      // );

      // Mock implementation
      await Future.delayed(const Duration(milliseconds: 300));
      final newProject = ProjectCardModel(
        id: DateTime.now().millisecondsSinceEpoch,
        title: project.title,
        image: project.image,
        floorDimensionValue: project.floorDimensionValue,
        floorAreaValue: project.floorAreaValue,
        areaPaintable: project.areaPaintable,
        ceilingArea: project.ceilingArea,
        trimLength: project.trimLength,
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

  Future<Result<void>> _updateProjectData(ProjectCardModel project) async {
    try {
      // TODO: Implementar quando o ProjectOperationsUseCase estiver pronto
      // final result = await _projectUseCase.updateProject(
      //   project.id.toString(),
      //   title: project.title,
      //   image: project.image,
      //   floorDimensionValue: project.floorDimensionValue,
      //   floorAreaValue: project.floorAreaValue,
      //   areaPaintable: project.areaPaintable,
      //   ceilingArea: project.ceilingArea,
      //   trimLength: project.trimLength,
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

  // TODO(gabriel): Implementar quando o repository estiver pronto
  // Mock data generator - remover quando o repository estiver pronto
  List<ProjectCardModel> _generateMockProjects() {
    return [
      ProjectCardModel(
        id: 1,
        title: "Casa Silva",
        image: "assets/images/kitchen.png",
        floorDimensionValue: "14' x 16'",
        floorAreaValue: "224 sq ft",
        areaPaintable: "485 sq ft",
        ceilingArea: "224 sq ft",
        trimLength: "60 linear ft",
      ),
      ProjectCardModel(
        id: 2,
        title: "Apartamento Santos",
        image: "assets/images/kitchen.png",
        floorDimensionValue: "10' x 12'",
        floorAreaValue: "120 sq ft",
        areaPaintable: "320 sq ft",
        ceilingArea: "120 sq ft",
        trimLength: "44 linear ft",
      ),
      ProjectCardModel(
        id: 3,
        title: "Escritório Tech",
        image: "assets/images/kitchen.png",
        floorDimensionValue: "12' x 14'",
        floorAreaValue: "168 sq ft",
        areaPaintable: "420 sq ft",
        ceilingArea: "168 sq ft",
        trimLength: "52 linear ft",
      ),
      ProjectCardModel(
        id: 4,
        title: "Loja Comercial",
        image: "assets/images/kitchen.png",
        floorDimensionValue: "20' x 8'",
        floorAreaValue: "160 sq ft",
        areaPaintable: "380 sq ft",
        ceilingArea: "160 sq ft",
        trimLength: "56 linear ft",
      ),
    ];
  }
}

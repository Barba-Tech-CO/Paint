import 'package:flutter/foundation.dart';
import '../../domain/entities/projects_state.dart';
import '../../domain/usecases/load_projects_usecase.dart';

class ProjectsViewmodel extends ChangeNotifier {
  ProjectsState _state = const ProjectsState(viewState: ProjectsViewState.loading);
  final LoadProjectsUsecase _loadProjectsUsecase;

  ProjectsViewmodel({
    LoadProjectsUsecase? loadProjectsUsecase,
  }) : _loadProjectsUsecase = loadProjectsUsecase ?? LoadProjectsUsecase();

  ProjectsState get state => _state;

  void _updateState(ProjectsState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> loadProjects() async {
    try {
      _updateState(_state.copyWith(viewState: ProjectsViewState.loading));

      final projects = await _loadProjectsUsecase.execute();

      if (projects.isEmpty) {
        _updateState(_state.copyWith(
          viewState: ProjectsViewState.empty,
          projects: projects,
        ));
      } else {
        _updateState(_state.copyWith(
          viewState: ProjectsViewState.loaded,
          projects: projects,
        ));
      }
    } catch (e) {
      _updateState(_state.copyWith(
        viewState: ProjectsViewState.error,
        errorMessage: 'Failed to load projects: ${e.toString()}',
      ));
    }
  }

  Future<void> refresh() async {
    await loadProjects();
  }
}
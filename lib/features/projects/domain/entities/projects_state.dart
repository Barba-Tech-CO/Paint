import 'project.dart';

enum ProjectsViewState {
  loading,
  loaded,
  empty,
  error,
}

class ProjectsState {
  final ProjectsViewState viewState;
  final List<Project> projects;
  final String? errorMessage;

  const ProjectsState({
    required this.viewState,
    this.projects = const [],
    this.errorMessage,
  });

  ProjectsState copyWith({
    ProjectsViewState? viewState,
    List<Project>? projects,
    String? errorMessage,
  }) {
    return ProjectsState(
      viewState: viewState ?? this.viewState,
      projects: projects ?? this.projects,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
import 'project_form.dart';

enum CreateProjectViewState {
  editing,
  validating,
  valid,
  invalid,
  saving,
  saved,
  error,
}

class CreateProjectState {
  final CreateProjectViewState viewState;
  final ProjectForm form;
  final String? errorMessage;

  const CreateProjectState({
    required this.viewState,
    required this.form,
    this.errorMessage,
  });

  CreateProjectState copyWith({
    CreateProjectViewState? viewState,
    ProjectForm? form,
    String? errorMessage,
  }) {
    return CreateProjectState(
      viewState: viewState ?? this.viewState,
      form: form ?? this.form,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
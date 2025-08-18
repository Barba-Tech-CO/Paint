import 'package:flutter/foundation.dart';
import '../../domain/entities/create_project_state.dart';
import '../../domain/entities/project_form.dart';
import '../../domain/usecases/validate_project_form_usecase.dart';
import '../../domain/usecases/save_project_usecase.dart';

class CreateProjectViewmodel extends ChangeNotifier {
  CreateProjectState _state = const CreateProjectState(
    viewState: CreateProjectViewState.editing,
    form: ProjectForm(
      clientName: '',
      projectName: '',
      projectType: ProjectType.interior,
    ),
  );

  final ValidateProjectFormUsecase _validateProjectFormUsecase;
  final SaveProjectUsecase _saveProjectUsecase;

  CreateProjectViewmodel({
    ValidateProjectFormUsecase? validateProjectFormUsecase,
    SaveProjectUsecase? saveProjectUsecase,
  }) : _validateProjectFormUsecase = validateProjectFormUsecase ?? ValidateProjectFormUsecase(),
        _saveProjectUsecase = saveProjectUsecase ?? SaveProjectUsecase();

  CreateProjectState get state => _state;
  ProjectForm get form => _state.form;
  bool get isFormValid => _validateProjectFormUsecase.execute(_state.form);

  void _updateState(CreateProjectState newState) {
    _state = newState;
    notifyListeners();
  }

  void updateClientName(String clientName) {
    final updatedForm = _state.form.copyWith(clientName: clientName);
    _updateState(_state.copyWith(form: updatedForm));
    _validateForm();
  }

  void updateProjectName(String projectName) {
    final updatedForm = _state.form.copyWith(projectName: projectName);
    _updateState(_state.copyWith(form: updatedForm));
    _validateForm();
  }

  void updateProjectType(ProjectType projectType) {
    final updatedForm = _state.form.copyWith(projectType: projectType);
    _updateState(_state.copyWith(form: updatedForm));
  }

  void updateAdditionalNotes(String notes) {
    final updatedForm = _state.form.copyWith(additionalNotes: notes);
    _updateState(_state.copyWith(form: updatedForm));
  }

  void _validateForm() {
    final isValid = _validateProjectFormUsecase.execute(_state.form);
    final newViewState = isValid ? CreateProjectViewState.valid : CreateProjectViewState.invalid;
    _updateState(_state.copyWith(viewState: newViewState));
  }

  Future<bool> saveProject() async {
    if (!isFormValid) {
      final errors = _validateProjectFormUsecase.getValidationErrors(_state.form);
      _updateState(_state.copyWith(
        viewState: CreateProjectViewState.error,
        errorMessage: errors.join(', '),
      ));
      return false;
    }

    try {
      _updateState(_state.copyWith(viewState: CreateProjectViewState.saving));
      await _saveProjectUsecase.execute(_state.form);
      _updateState(_state.copyWith(viewState: CreateProjectViewState.saved));
      return true;
    } catch (e) {
      _updateState(_state.copyWith(
        viewState: CreateProjectViewState.error,
        errorMessage: 'Failed to save project: ${e.toString()}',
      ));
      return false;
    }
  }

  void clearError() {
    if (_state.viewState == CreateProjectViewState.error) {
      _updateState(_state.copyWith(
        viewState: CreateProjectViewState.editing,
        errorMessage: null,
      ));
    }
  }
}
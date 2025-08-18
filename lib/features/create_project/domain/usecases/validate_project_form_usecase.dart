import '../entities/project_form.dart';

class ValidateProjectFormUsecase {
  bool execute(ProjectForm form) {
    return form.isValid;
  }

  List<String> getValidationErrors(ProjectForm form) {
    final errors = <String>[];

    if (form.clientName.trim().isEmpty) {
      errors.add('Client name is required');
    }

    if (form.projectName.trim().isEmpty) {
      errors.add('Project name is required');
    }

    return errors;
  }
}
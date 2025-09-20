import 'package:flutter/foundation.dart';

import '../../model/estimates/estimate_model.dart';
import '../../use_case/estimates/estimate_upload_use_case.dart';
import '../../utils/command/command.dart';
import '../../utils/result/result.dart';

enum EstimateUploadState {
  initial,
  editing,
  reviewing,
  uploading,
  success,
  error,
}

class EstimateUploadViewModel extends ChangeNotifier {
  final EstimateUploadUseCase _useCase;

  EstimateUploadState _state = EstimateUploadState.initial;
  String? _errorMessage;
  EstimateModel? _uploaded;

  late final Command1<void, EstimateModel> _uploadCommand;

  EstimateUploadViewModel(this._useCase) {
    _initCommands();
  }

  // Getters
  EstimateUploadState get state => _state;
  String? get errorMessage => _errorMessage;
  EstimateModel? get uploadedEstimate => _uploaded;
  Command1<void, EstimateModel> get uploadCommand => _uploadCommand;

  // Computed
  bool get isUploading =>
      _state == EstimateUploadState.uploading || _uploadCommand.running;
  bool get hasError =>
      _state == EstimateUploadState.error && _errorMessage != null;

  void _initCommands() {
    _uploadCommand = Command1((EstimateModel estimate) async {
      _setState(EstimateUploadState.uploading);
      _clearError();

      try {
        final result = await _useCase.upload(estimate);
        return result.when(
          ok: (model) {
            _uploaded = model;
            _setState(EstimateUploadState.success);
            return Result.ok(null);
          },
          error: (e) {
            _setError(e.toString());
            _setState(EstimateUploadState.error);
            return Result.error(e);
          },
        );
      } catch (e) {
        _setError('Unexpected error: $e');
        _setState(EstimateUploadState.error);
        return Result.error(Exception(e.toString()));
      }
    });
  }

  // Public API
  Future<void> upload(EstimateModel estimate) async {
    await _uploadCommand.execute(estimate);
  }

  void setEditing() => _setState(EstimateUploadState.editing);
  void setReviewing() => _setState(EstimateUploadState.reviewing);
  void reset() {
    _uploaded = null;
    _clearError();
    _setState(EstimateUploadState.initial);
  }

  // State helpers
  void _setState(EstimateUploadState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

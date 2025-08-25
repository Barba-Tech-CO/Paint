import 'package:flutter/foundation.dart';
import '../../utils/result/result.dart';
import '../../domain/repository/estimate_repository.dart';

class EstimateUploadViewModel extends ChangeNotifier {
  final IEstimateRepository _estimateRepository;

  final List<String> _selectedPhotos = [];
  bool _isUploading = false;
  String? _error;
  double _uploadProgress = 0.0;

  EstimateUploadViewModel(this._estimateRepository);

  // Getters
  List<String> get selectedPhotos => _selectedPhotos;
  bool get isUploading => _isUploading;
  String? get error => _error;
  double get uploadProgress => _uploadProgress;
  bool get hasPhotos => _selectedPhotos.isNotEmpty;

  /// Adiciona fotos à lista
  void addPhotos(List<String> photoPaths) {
    _selectedPhotos.addAll(photoPaths);
    notifyListeners();
  }

  /// Remove uma foto da lista
  void removePhoto(int index) {
    if (index >= 0 && index < _selectedPhotos.length) {
      _selectedPhotos.removeAt(index);
      notifyListeners();
    }
  }

  /// Remove todas as fotos
  void clearPhotos() {
    _selectedPhotos.clear();
    notifyListeners();
  }

  /// Faz upload das fotos para um orçamento
  Future<bool> uploadPhotos(String estimateId) async {
    if (_selectedPhotos.isEmpty) {
      _setError('No photos selected');
      return false;
    }

    _setUploading(true);
    _clearError();
    _setUploadProgress(0.0);

    try {
      final result = await _estimateRepository.uploadPhotos(
        estimateId,
        _selectedPhotos,
      );

      if (result is Ok) {
        _setUploadProgress(1.0);
        notifyListeners();
        return true;
      } else if (result is Error) {
        _setError(result.asError.error.toString());
      }
      return false;
    } catch (e) {
      _setError('Error uploading photos: $e');
      return false;
    } finally {
      _setUploading(false);
    }
  }

  /// Simula progresso de upload (para UI)
  void updateUploadProgress(double progress) {
    _setUploadProgress(progress);
  }

  // Métodos privados para gerenciar estado
  void _setUploading(bool uploading) {
    _isUploading = uploading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _setUploadProgress(double progress) {
    _uploadProgress = progress;
    notifyListeners();
  }
}

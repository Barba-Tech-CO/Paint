import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodel/zones/zones_list_viewmodel.dart';

class ProcessingViewModel extends ChangeNotifier {
  bool _isProcessing = false;
  String? _error;
  double _progress = 0.0;

  // Getters
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  double get progress => _progress;

  /// Start processing with photos and room data
  Future<void> startProcessing({
    required List<String> capturedPhotos,
    Map<String, dynamic>? roomData,
    Map<String, dynamic>? projectData,
  }) async {
    try {
      _setProcessing(true);
      _clearError();
      _setProgress(0.0);

      log('ProcessingViewModel: Starting processing...');
      log('ProcessingViewModel: Photos count: ${capturedPhotos.length}');
      log('ProcessingViewModel: Room data available: ${roomData != null}');
      log('ProcessingViewModel: Project data: $projectData');

      // Simulate processing with progress updates
      await _simulateProcessing();

      log('ProcessingViewModel: Processing completed, navigating to zones...');
    } catch (e) {
      log('ProcessingViewModel: Error during processing: $e');
      _setError('Processing failed: $e');
    } finally {
      _setProcessing(false);
    }
  }

  /// Simulate processing with progress updates
  Future<void> _simulateProcessing() async {
    const totalSteps = 10;

    for (int i = 0; i < totalSteps; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      _setProgress((i + 1) / totalSteps);

      log('ProcessingViewModel: Processing step ${i + 1}/$totalSteps');
    }

    // Call the static method from ZonesListViewModel
    await ZonesListViewModel.simulateProcessing();
  }

  /// Navigate to zones screen
  void navigateToZones(BuildContext context) {
    context.go('/zones');
  }

  // Private methods for state management
  void _setProcessing(bool processing) {
    _isProcessing = processing;
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

  void _setProgress(double progress) {
    _progress = progress;
    notifyListeners();
  }
}

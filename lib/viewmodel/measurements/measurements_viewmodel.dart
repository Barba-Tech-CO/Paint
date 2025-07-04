import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class MeasurementsViewModel extends ChangeNotifier {
  int _randomNumber = 0;
  Timer? _timer;
  final _random = Random();
  bool _isLoading = true;
  String? _error;

  // Dados simulados - em produção viriam de um processamento real
  final Map<String, dynamic> _measurementResults = {
    'accuracy': 95.8,
    'floorDimensions': '14\' x 16\'',
    'floorArea': 224,
    'walls': 485,
    'ceiling': 224,
    'trim': 60,
    'totalPaintable': 631,
  };

  // Getters
  int get randomNumber => _randomNumber;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get measurementResults => _measurementResults;

  MeasurementsViewModel() {
    startRandomCalculation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> startRandomCalculation() async {
    _setLoading(true);
    _clearError();

    final random = Random();
    final secondsToWait = random.nextInt(4) + 2;

    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      _randomNumber = _random.nextInt(100);
      notifyListeners();
    });

    await Future.delayed(Duration(seconds: secondsToWait), () {
      if (_timer?.isActive == true) {
        _timer?.cancel();
        _setLoading(false);
      }
    });
  }

  // Reset measurements
  void resetMeasurements() {
    startRandomCalculation();
  }

  // Métodos de gerenciamento de estado
  void _setLoading(bool loading) {
    _isLoading = loading;
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
}

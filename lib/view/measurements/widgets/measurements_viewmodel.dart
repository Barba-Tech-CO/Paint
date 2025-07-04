import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class MeasurementsViewModel extends ChangeNotifier {
  int _randomNumber = 0;
  Timer? _timer;
  final _random = Random();
  bool _isLoading = true;

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
    final random = Random();
    // Tempo de espera aleatório entre 2 e 5 segundos
    final secondsToWait = random.nextInt(4) + 2;

    // Atualiza o número aleatório a cada 200ms
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      _randomNumber = _random.nextInt(100); // Gera um número entre 0 e 99
      notifyListeners();
    });

    await Future.delayed(Duration(seconds: secondsToWait), () {
      _timer?.cancel();
      _isLoading = false; // Muda para tela de resultados
      notifyListeners();
    });
  }

  void resetMeasurements() {
    _isLoading = true;
    notifyListeners();
    startRandomCalculation();
  }
}

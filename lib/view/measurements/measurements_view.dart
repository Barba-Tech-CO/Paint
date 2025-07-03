import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MeasurementsView extends StatefulWidget {
  const MeasurementsView({super.key});

  @override
  State<MeasurementsView> createState() => _MeasurementsViewState();
}

class _MeasurementsViewState extends State<MeasurementsView> {
  int _randomNumber = 0;
  Timer? _timer;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _startRandomCalculation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startRandomCalculation() async {
    final random = Random();
    // Tempo de espera aleatório entre 2 e 5 segundos
    final secondsToWait = random.nextInt(4) + 2;

    // Atualiza o número aleatório a cada 200ms
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      setState(() {
        _randomNumber = _random.nextInt(100); // Gera um número entre 0 e 99
      });
    });

    await Future.delayed(Duration(seconds: secondsToWait), () {
      if (mounted) {
        _timer?.cancel();
        // Navega para a tela de resultados (que você criará)
        context.go('/measurement-results');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Calculando: $_randomNumber',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

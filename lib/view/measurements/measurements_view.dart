import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paintpro/config/app_colors.dart';
import 'package:paintpro/view/widgets/cards/input_card_widget.dart';

class MeasurementsView extends StatefulWidget {
  const MeasurementsView({super.key});

  @override
  State<MeasurementsView> createState() => _MeasurementsViewState();
}

class _MeasurementsViewState extends State<MeasurementsView> {
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
        setState(() {
          _isLoading = false; // Muda para tela de resultados
        });
      }
    });
  }

  Widget _buildLoadingScreen() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ícone de engrenagem
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(Icons.settings, size: 30),
                  ),
                  const SizedBox(height: 20),

                  // Texto de processamento
                  const Text(
                    'Processing Photos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Calculating measurements...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Barra de progresso
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: LinearProgressIndicator(
                      value: _randomNumber / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsScreen() {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        children: [
          // Cabeçalho verde
          Container(
            width: double.infinity,
            color: Colors.green.shade50,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                // Ícone de check
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(5),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 24,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Measurements Complete!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                Text(
                  'Accuracy: ${_measurementResults['accuracy']}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          // Lista de resultados
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Card Room Overview usando InputCardWidget
                InputCardWidget(
                  title: 'Room Overview',
                  padding: EdgeInsets.zero,
                  widget: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${_measurementResults['floorDimensions']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Floor Dimensions',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${_measurementResults['floorArea']} sq ft',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Floor Area',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Card Surface Areas usando InputCardWidget
                InputCardWidget(
                  title: 'Surface Areas',
                  padding: EdgeInsets.zero,
                  widget: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Valores de área
                      _buildSurfaceRow(
                        'Walls',
                        '${_measurementResults['walls']} sq ft',
                      ),
                      _buildSurfaceRow(
                        'Ceiling',
                        '${_measurementResults['ceiling']} sq ft',
                      ),
                      _buildSurfaceRow(
                        'Trim',
                        '${_measurementResults['trim']} linear ft',
                      ),
                      const Divider(),
                      _buildSurfaceRow(
                        'Total Paintable',
                        '${_measurementResults['totalPaintable']} sq ft',
                        isBold: true,
                        valueColor: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Botões no rodapé
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Botão Adjust
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Em produção: lógica para editar medições
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Adjust'),
                  ),
                ),

                const SizedBox(width: 16),

                // Botão Accept
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navegar para próxima etapa
                      context.go('/paint-selection');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper para criar linhas de informação de superfície
  Widget _buildSurfaceRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: const Text('Measurements'),
      ),
      body: _isLoading ? _buildLoadingScreen() : _buildResultsScreen(),
    );
  }
}

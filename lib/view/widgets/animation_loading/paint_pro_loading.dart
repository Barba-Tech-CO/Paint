import 'dart:math' as math;
import 'package:flutter/material.dart';

class PaintProLoading extends StatelessWidget {
  final AnimationController controller;
  final double size;
  final double strokeWidth;
  final Color primaryColor;

  const PaintProLoading({
    super.key,
    required this.controller,
    this.size = 80,
    this.strokeWidth = 6,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Transform.rotate(
            // Animação de rotação contínua
            angle: controller.value * 2 * math.pi,
            child: _buildGradientCircle(),
          );
        },
      ),
    );
  }

  Widget _buildGradientCircle() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Gradiente circular que cria o efeito de "arco"
        gradient: SweepGradient(
          colors: [
            // Começamos com transparente para criar o "corte" no círculo
            Colors.transparent,
            Colors.transparent,
            // Transição gradual para a cor principal
            primaryColor.withValues(alpha: 0.3),
            primaryColor,
          ],
          // Controla a distribuição das cores
          stops: const [0.0, 0.25, 0.75, 1.0],
          // Configurações para posicionar corretamente o gradiente
          startAngle: 0,
          endAngle: math.pi * 2,
          // Rotaciona o gradiente para o ponto inicial correto
          transform: GradientRotation(-math.pi / 2),
        ),
      ),
      // Círculo branco interno
      child: Padding(
        padding: EdgeInsets.all(strokeWidth),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

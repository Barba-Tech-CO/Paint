import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paintpro/viewmodel/measurements/measurements_viewmodel.dart';
import 'package:paintpro/config/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({super.key});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _dotsController;

  @override
  void initState() {
    super.initState();
    // Controlador para rotação do loading
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat();

    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1500), // Velocidade ajustada
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MeasurementsViewModel>();

    // Animação de onda para os pontos
    final wormDots = List.generate(3, (i) {
      return AnimatedBuilder(
        animation: _dotsController,
        builder: (context, child) {
          // Maior separação de fase para movimento sequencial claro
          final phase =
              i * (2 * math.pi / 3); // Separação de 1/3 do ciclo total

          // Limitamos o movimento a um intervalo específico para cada ponto
          double animValue = 0;
          final cyclePos =
              (_dotsController.value * 3) % 3; // Posição no ciclo de 3

          // Cada ponto só se move quando é sua vez
          if (cyclePos >= i && cyclePos < i + 1) {
            // Movimento suave em seu próprio intervalo
            animValue = math.sin((cyclePos - i) * math.pi);
          }

          // Amplitude menor para movimento mais sutil
          final yOffset = animValue * 4.0;

          return Container(
            width: 8, // Largura fixa um pouco menor
            alignment: Alignment.center,
            child: Transform.translate(
              offset: Offset(0, -yOffset),
              child: Text(
                '.',
                style: GoogleFonts.albertSans(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
          );
        },
      );
    });
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 90,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(64),
              bottomRight: Radius.circular(64),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Processing',
                style: GoogleFonts.albertSans(
                  color: AppColors.textOnPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 4),
              ...wormDots,
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Processing Photos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Calculating measurements...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            // Loading circular customizado estilo Figma
            SizedBox(
              width: 80,
              height: 80,
              child: AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: -_rotationController.value * 2 * math.pi,
                    child: ArcLoadingIndicator(
                      size: 80,
                      strokeWidth: 6,
                      colors: [
                        AppColors.primary, // azul sólido (início)
                        const Color.fromARGB(
                          255,
                          185,
                          212,
                          248,
                        ), // azul claro (meio)
                        Colors.white, // branco (fim)
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArcLoadingIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final List<Color> colors;

  const ArcLoadingIndicator({
    super.key,
    this.size = 80,
    this.strokeWidth = 4,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CircularProgressPainter(
          strokeWidth: strokeWidth,
          primaryColor: colors[0], // Azul forte
          secondaryColor: colors[2], // Branco/transparente
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double strokeWidth;
  final Color primaryColor;
  final Color secondaryColor;

  _CircularProgressPainter({
    required this.strokeWidth,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Parâmetros do arco
    final startAngle =
        -math.pi / 4; // Ajustado para posicionar o azul onde as setas apontam
    final sweepAngle = 5 * math.pi / 4; // ~225 graus (3/4 do círculo)

    // Gradiente linear para o arco, seguindo a direção do arco
    final gradient = LinearGradient(
      colors: [
        secondaryColor, // Começa com branco/transparente
        primaryColor.withOpacity(0.5), // Meio com azul médio
        primaryColor, // Termina com azul forte
      ],
      stops: const [0.0, 0.7, 1.0],
    );

    // Rect para posicionar o gradiente
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Paint para o arco com gradiente
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(rect);

    // Desenha o arco
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

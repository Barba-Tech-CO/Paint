import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/app_colors.dart';
import '../../../widgets/animation_loading/paint_pro_loading.dart';

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
    final wormDots = List.generate(3, (i) {
      return AnimatedBuilder(
        animation: _dotsController,
        builder: (context, child) {
          double animValue = 0;
          final cyclePos =
              (_dotsController.value * 3) % 3; // Posição no ciclo de 3

          if (cyclePos >= i && cyclePos < i + 1) {
            animValue = math.sin((cyclePos - i) * math.pi);
          }

          final yOffset = animValue * 4.0;

          return Container(
            width: 8,
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
            PaintProLoading(
              controller: _rotationController,
              size: 120,
              strokeWidth: 8,
              primaryColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

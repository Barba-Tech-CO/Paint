import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_colors.dart';
import '../animation_loading/paint_pro_loading.dart';

class LoadingWidget extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final String? description;
  final Duration? duration;
  final VoidCallback? onComplete;
  final String? navigateToOnComplete;

  const LoadingWidget({
    super.key,
    this.title,
    this.subtitle,
    this.description,
    this.duration,
    this.onComplete,
    this.navigateToOnComplete,
  });

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

    // Executa ação apenas se parâmetros específicos forem fornecidos
    // Isso mantém compatibilidade com uso como widget de estado interno
    if (widget.onComplete != null || widget.navigateToOnComplete != null) {
      final delay = widget.duration ?? const Duration(seconds: 3);
      Future.delayed(delay, () {
        if (mounted) {
          if (widget.onComplete != null) {
            widget.onComplete!();
          } else if (widget.navigateToOnComplete != null) {
            context.go(widget.navigateToOnComplete!);
          }
        }
      });
    }
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
            width: 8.w,
            alignment: Alignment.center,
            child: Transform.translate(
              offset: Offset(0, -yOffset),
              child: Text(
                '.',
                style: GoogleFonts.albertSans(
                  fontSize: 28.sp,
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
        preferredSize: Size.fromHeight(90.h),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 80.h,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(64.r),
              bottomRight: Radius.circular(64.r),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title ?? 'Processing',
                style: GoogleFonts.albertSans(
                  color: AppColors.textOnPrimary,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(width: 4.w),
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
            Text(
              widget.subtitle ?? 'Processing Photos',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              widget.description ?? 'Calculating measurements...',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 32.h),
            PaintProLoading(
              controller: _rotationController,
              size: 120.w,
              strokeWidth: 8.w,
              primaryColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

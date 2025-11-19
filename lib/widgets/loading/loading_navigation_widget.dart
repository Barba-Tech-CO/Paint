// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Widget class para facilitar a navegação para diferentes tipos de loading
class LoadingNavigationWidget {
  /// Navega para loading de envio de quote
  static void navigateToQuoteLoading(BuildContext context) {
    context.go(
      '/loading',
      extra: {
        'title': 'Sending Quote',
        'subtitle': 'Estimate sent successfully!',
        'description': 'Saving project data...',
        'duration': const Duration(seconds: 3),
        'navigateToOnComplete': '/home',
      },
    );
  }

  /// Navega para loading de processamento de fotos
  static void navigateToPhotoProcessing(
    BuildContext context, {
    VoidCallback? onComplete,
    String? navigateToOnComplete,
  }) {
    final extra = <String, dynamic>{
      'title': 'Processing',
      'subtitle': 'Processing Photos',
      'description': 'Calculating measurements...',
      'duration': const Duration(seconds: 4),
    };

    if (navigateToOnComplete != null) {
      extra['navigateToOnComplete'] = navigateToOnComplete;
    }

    context.go('/loading', extra: extra);
  }

  /// Navega para loading genérico personalizado
  static void navigateToCustomLoading(
    BuildContext context, {
    String? title,
    String? subtitle,
    String? description,
    Duration? duration,
    String? navigateToOnComplete,
  }) {
    context.go(
      '/loading',
      extra: {
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'duration': duration,
        'navigateToOnComplete': navigateToOnComplete,
      },
    );
  }

  /// Navega para loading que executa um callback ao finalizar
  static void navigateToLoadingWithCallback(
    BuildContext context, {
    String? title,
    String? subtitle,
    String? description,
    Duration? duration,
    required VoidCallback onComplete,
  }) {
    // Para callbacks, seria melhor usar um showDialog ou outra abordagem
    // pois GoRouter não suporta passar functions facilmente
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                title ?? 'Processing...',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(subtitle),
              ],
            ],
          ),
        ),
      ),
    );

    Future.delayed(duration ?? const Duration(seconds: 2), () {
      if (context.canPop()) {
        context.pop();
      }
      onComplete();
    });
  }
}

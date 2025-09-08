import 'package:flutter/material.dart';

class StatusHelper {
  /// Verifica se deve mostrar o status baseado na lógica de status temporário
  static bool shouldShowStatus({
    required String? currentStatus,
    required String? previousStatus,
    required bool showTemporaryStatus,
  }) {
    // Mostra status se não for completed, ou se for completed e estamos mostrando status temporário
    return currentStatus != null &&
        (currentStatus.toLowerCase() != 'completed' || showTemporaryStatus);
  }

  /// Verifica se o status mudou para completed
  static bool hasStatusChangedToCompleted({
    required String? currentStatus,
    required String? previousStatus,
  }) {
    return currentStatus?.toLowerCase() == 'completed' &&
        previousStatus?.toLowerCase() != 'completed';
  }

  /// Obtém a cor do status
  static Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'failed':
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Obtém o texto de exibição do status
  static String getStatusDisplay(String? status) {
    if (status == null) return 'Unknown';
    return status.toUpperCase();
  }
}

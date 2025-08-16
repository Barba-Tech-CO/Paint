import 'package:flutter/foundation.dart';
import '../service/logger_service.dart';

/// ViewModel base que implementa o padrão MVVM do Flutter
/// Fornece funcionalidades comuns como logging e gerenciamento de estado
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  BaseViewModel() {
    LoggerService.info('${runtimeType.toString()} initialized');
  }

  /// Indica se o ViewModel está carregando dados
  bool get isLoading => _isLoading;

  /// Mensagem de erro atual
  String? get errorMessage => _errorMessage;

  /// Define o estado de carregamento
  void setLoading(bool loading) {
    _isLoading = loading;
    LoggerService.debug(
      '${runtimeType.toString()} state: ${loading ? 'Loading' : 'Idle'}',
    );
    notifyListeners();
  }

  /// Define uma mensagem de erro
  void setError(String? error) {
    _errorMessage = error;
    if (error != null) {
      LoggerService.error('${runtimeType.toString()}.setError', error);
    }
    notifyListeners();
  }

  /// Limpa a mensagem de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Executa uma operação com tratamento de erro e logging
  Future<T?> executeOperation<T>(
    Future<T> Function() operation, {
    String? operationName,
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) {
        setLoading(true);
      }

      final startTime = DateTime.now();
      final result = await operation();
      final duration = DateTime.now().difference(startTime);

      if (operationName != null) {
        LoggerService.info(
          'Performance: $operationName took ${duration.inMilliseconds}ms',
        );
      }

      clearError();
      return result;
    } catch (error, stackTrace) {
      final errorMessage =
          'Erro na operação: ${operationName ?? 'desconhecida'}';
      setError(errorMessage);
      LoggerService.error(
        '${runtimeType.toString()}.${operationName ?? 'executeOperation'}',
        error,
        stackTrace,
      );
      return null;
    } finally {
      if (showLoading) {
        setLoading(false);
      }
    }
  }

  /// Log de operação de negócio
  void logBusinessOperation(String operation, {Map<String, dynamic>? data}) {
    final message = data != null ? '$operation - Data: $data' : operation;
    LoggerService.info('Business Operation: $message');
  }

  /// Log de navegação
  void logNavigation(
    String from,
    String to, {
    Map<String, dynamic>? parameters,
  }) {
    final message = parameters != null ? '$from -> $to - Parameters: $parameters' : '$from -> $to';
    LoggerService.info('Navigation: $message');
  }

  /// Log de debug
  void logDebug(String message) {
    LoggerService.debug(message);
  }

  /// Log de informação
  void logInfo(String message) {
    LoggerService.info(message);
  }

  /// Log de warning
  void logWarning(String message) {
    LoggerService.warning(message);
  }

  /// Log de erro
  void logError(String message, [dynamic error, StackTrace? stackTrace]) {
    LoggerService.error(message, error, stackTrace);
  }

  @override
  void dispose() {
    LoggerService.info('${runtimeType.toString()} disposed');
    super.dispose();
  }
}

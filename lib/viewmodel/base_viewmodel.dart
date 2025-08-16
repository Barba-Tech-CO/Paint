import 'package:flutter/foundation.dart';
import '../service/logger_service.dart';

/// ViewModel base que implementa o padrão MVVM do Flutter
/// Fornece funcionalidades comuns como logging e gerenciamento de estado
abstract class BaseViewModel extends ChangeNotifier {
  final LoggerService _logger;
  bool _isLoading = false;
  String? _errorMessage;

  BaseViewModel(this._logger) {
    _logger.logServiceInitialization(runtimeType.toString());
  }

  /// Indica se o ViewModel está carregando dados
  bool get isLoading => _isLoading;

  /// Mensagem de erro atual
  String? get errorMessage => _errorMessage;

  /// Define o estado de carregamento
  void setLoading(bool loading) {
    _isLoading = loading;
    _logger.logViewModelState(
      runtimeType.toString(),
      loading ? 'Loading' : 'Idle',
    );
    notifyListeners();
  }

  /// Define uma mensagem de erro
  void setError(String? error) {
    _errorMessage = error;
    if (error != null) {
      _logger.logViewModelError(runtimeType.toString(), 'setError', error);
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
        _logger.logPerformance(operationName, duration);
      }

      clearError();
      return result;
    } catch (error, stackTrace) {
      final errorMessage =
          'Erro na operação: ${operationName ?? 'desconhecida'}';
      setError(errorMessage);
      _logger.logViewModelError(
        runtimeType.toString(),
        operationName ?? 'executeOperation',
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
    _logger.logBusinessOperation(operation, data: data);
  }

  /// Log de navegação
  void logNavigation(
    String from,
    String to, {
    Map<String, dynamic>? parameters,
  }) {
    _logger.logNavigation(from, to, parameters: parameters);
  }

  /// Log de debug
  void logDebug(String message) {
    _logger.debug(message);
  }

  /// Log de informação
  void logInfo(String message) {
    _logger.info(message);
  }

  /// Log de warning
  void logWarning(String message) {
    _logger.warning(message);
  }

  /// Log de erro
  void logError(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.error(message, error, stackTrace);
  }

  @override
  void dispose() {
    _logger.info('${runtimeType.toString()} disposed');
    super.dispose();
  }
}

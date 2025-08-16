import '../utils/logger/app_logger.dart';
import '../utils/logger/logger_app_logger_impl.dart';

class LoggerService {
  final AppLogger _logger;
  static LoggerService? _instance;

  LoggerService(this._logger);

  static LoggerService get instance {
    _instance ??= LoggerService(LoggerAppLoggerImpl());
    return _instance!;
  }

  void _debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.debug(message, error, stackTrace);
  }

  void _info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.info(message, error, stackTrace);
  }

  void _warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.warning(message, error, stackTrace);
  }

  void _error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.error(message, error, stackTrace);
  }

  void _fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.fatal(message, error, stackTrace);
  }

  void logBusinessOperation(String operation, {Map<String, dynamic>? data}) {
    final logMessage = 'Business Operation: $operation';
    if (data != null) {
      _logger.info('$logMessage - Data: $data');
    } else {
      _logger.info(logMessage);
    }
  }

  void logNavigation(
    String from,
    String to, {
    Map<String, dynamic>? parameters,
  }) {
    final logMessage = 'Navigation: $from -> $to';
    if (parameters != null) {
      _logger.info('$logMessage - Parameters: $parameters');
    } else {
      _logger.info(logMessage);
    }
  }

  void logApiCall(
    String endpoint,
    String method, {
    Map<String, dynamic>? requestData,
    dynamic responseData,
    int? statusCode,
  }) {
    final logMessage = 'API Call: $method $endpoint';
    final details = <String, dynamic>{
      if (requestData != null) 'request': requestData,
      if (responseData != null) 'response': responseData,
      if (statusCode != null) 'statusCode': statusCode,
    };

    if (details.isNotEmpty) {
      _logger.info('$logMessage - Details: $details');
    } else {
      _logger.info(logMessage);
    }
  }

  void logPerformance(String operation, Duration duration) {
    _logger.info('Performance: $operation took ${duration.inMilliseconds}ms');
  }

  void logViewModelState(String viewModelName, String state) {
    _logger.debug('ViewModel State: $viewModelName -> $state');
  }

  void logViewModelError(
    String viewModelName,
    String operation,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    _logger.error(
      'ViewModel Error: $viewModelName.$operation',
      error,
      stackTrace,
    );
  }

  void logServiceInitialization(String serviceName) {
    _logger.info('Service Initialized: $serviceName');
  }

  void logServiceError(
    String serviceName,
    String operation,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    _logger.error('Service Error: $serviceName.$operation', error, stackTrace);
  }

  // Métodos estáticos para uso simples
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    instance._debug(message, error, stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    instance._info(message, error, stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    instance._warning(message, error, stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    instance._error(message, error, stackTrace);
  }

  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    instance._fatal(message, error, stackTrace);
  }
}

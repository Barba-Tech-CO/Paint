import '../utils/logger/app_logger.dart';

class LoggerService {
  final AppLogger _logger;

  LoggerService(this._logger);

  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.debug(message, error, stackTrace);
  }

  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.info(message, error, stackTrace);
  }

  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.warning(message, error, stackTrace);
  }

  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.error(message, error, stackTrace);
  }

  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
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
}

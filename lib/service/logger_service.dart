import 'dart:developer';

class LoggerService {
  static LoggerService? _instance;

  LoggerService();

  static void initialize() {
    _instance = LoggerService();
  }

  static LoggerService get instance {
    _instance ??= LoggerService();
    return _instance!;
  }

  void _debug(String message, [dynamic error, StackTrace? stackTrace]) {
    log('[DEBUG] $message');
    if (error != null) log('Error: $error');
    if (stackTrace != null) log('StackTrace: $stackTrace');
  }

  void _info(String message, [dynamic error, StackTrace? stackTrace]) {
    log('[INFO] $message');
    if (error != null) log('Error: $error');
    if (stackTrace != null) log('StackTrace: $stackTrace');
  }

  void _warning(String message, [dynamic error, StackTrace? stackTrace]) {
    log('[WARNING] $message');
    if (error != null) log('Error: $error');
    if (stackTrace != null) log('StackTrace: $stackTrace');
  }

  void _error(String message, [dynamic error, StackTrace? stackTrace]) {
    log('[ERROR] $message');
    if (error != null) log('Error: $error');
    if (stackTrace != null) log('StackTrace: $stackTrace');
  }

  void _fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    log('[FATAL] $message');
    if (error != null) log('Error: $error');
    if (stackTrace != null) log('StackTrace: $stackTrace');
  }

  void logBusinessOperation(String operation, {Map<String, dynamic>? data}) {
    final logMessage = 'Business Operation: $operation';
    if (data != null) {
      _info('$logMessage - Data: $data');
    } else {
      _info(logMessage);
    }
  }

  void logNavigation(
    String from,
    String to, {
    Map<String, dynamic>? parameters,
  }) {
    final logMessage = 'Navigation: $from -> $to';
    if (parameters != null) {
      _info('$logMessage - Parameters: $parameters');
    } else {
      _info(logMessage);
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
      _info('$logMessage - Details: $details');
    } else {
      _info(logMessage);
    }
  }

  void logPerformance(String operation, Duration duration) {
    _info('Performance: $operation took ${duration.inMilliseconds}ms');
  }

  void logViewModelState(String viewModelName, String state) {
    _debug('ViewModel State: $viewModelName -> $state');
  }

  void logViewModelError(
    String viewModelName,
    String operation,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    _error(
      'ViewModel Error: $viewModelName.$operation',
      error,
      stackTrace,
    );
  }

  void logServiceInitialization(String serviceName) {
    _info('Service Initialized: $serviceName');
  }

  void logServiceError(
    String serviceName,
    String operation,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    _error('Service Error: $serviceName.$operation', error, stackTrace);
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

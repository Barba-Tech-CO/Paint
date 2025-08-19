import 'package:logger/logger.dart';

import 'app_logger.dart';

class LoggerAppLoggerImpl implements AppLogger {
  final logger = Logger();
  var messages = <String>[];

  @override
  void append(message) {
    messages.add(message);
  }

  @override
  void closeAppend() {
    info(messages.join('\n'));
    messages = [];
  }

  @override
  void debug(message, [error, StackTrace? stackTrace]) =>
      logger.d(message, error: error, stackTrace: stackTrace);

  @override
  void error(message, [error, StackTrace? stackTrace]) =>
      logger.e(message, error: error, stackTrace: stackTrace);

  @override
  void info(message, [error, StackTrace? stackTrace]) =>
      logger.i(message, error: error, stackTrace: stackTrace);

  @override
  void warning(message, [error, StackTrace? stackTrace]) =>
      logger.w(message, error: error, stackTrace: stackTrace);

  @override
  void fatal(message, [error, StackTrace? stackTrace]) =>
      logger.f(message, error: error, stackTrace: stackTrace);

  @override
  void logBusinessOperation(String operation, {Map<String, dynamic>? data}) {
    final logMessage = 'Business Operation: $operation';
    if (data != null) {
      info('$logMessage - Data: $data');
    } else {
      info(logMessage);
    }
  }

  @override
  void logNavigation(
    String from,
    String to, {
    Map<String, dynamic>? parameters,
  }) {
    final logMessage = 'Navigation: $from -> $to';
    if (parameters != null) {
      info('$logMessage - Parameters: $parameters');
    } else {
      info(logMessage);
    }
  }

  @override
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
      info('$logMessage - Details: $details');
    } else {
      info(logMessage);
    }
  }

  @override
  void logPerformance(String operation, Duration duration) {
    info('Performance: $operation took ${duration.inMilliseconds}ms');
  }

  @override
  void logViewModelState(String viewModelName, String state) {
    debug('ViewModel State: $viewModelName -> $state');
  }

  @override
  void logViewModelError(
    String viewModelName,
    String operation,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    this.error(
      'ViewModel Error: $viewModelName.$operation',
      error,
      stackTrace,
    );
  }

  @override
  void logServiceInitialization(String serviceName) {
    info('Service Initialized: $serviceName');
  }

  @override
  void logServiceError(
    String serviceName,
    String operation,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    this.error('Service Error: $serviceName.$operation', error, stackTrace);
  }
}

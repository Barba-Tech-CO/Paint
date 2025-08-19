abstract class AppLogger {
  void debug(dynamic message, [dynamic error, StackTrace? stackTrace]);
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]);
  void warning(dynamic message, [dynamic error, StackTrace? stackTrace]);
  void info(dynamic message, [dynamic error, StackTrace? stackTrace]);
  void append(dynamic message);
  void closeAppend();
  void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]);

  // Business operation logging
  void logBusinessOperation(String operation, {Map<String, dynamic>? data});

  // Navigation logging
  void logNavigation(
    String from,
    String to, {
    Map<String, dynamic>? parameters,
  });

  // API call logging
  void logApiCall(
    String endpoint,
    String method, {
    Map<String, dynamic>? requestData,
    dynamic responseData,
    int? statusCode,
  });

  // Performance logging
  void logPerformance(String operation, Duration duration);

  // ViewModel state logging
  void logViewModelState(String viewModelName, String state);

  // ViewModel error logging
  void logViewModelError(
    String viewModelName,
    String operation,
    dynamic error, [
    StackTrace? stackTrace,
  ]);

  // Service initialization logging
  void logServiceInitialization(String serviceName);

  // Service error logging
  void logServiceError(
    String serviceName,
    String operation,
    dynamic error, [
    StackTrace? stackTrace,
  ]);
}

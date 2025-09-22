/// Helper class to transform technical errors into user-friendly messages
class ErrorUtils {
  /// Converts technical errors into user-friendly messages
  /// while logging detailed error information to console
  static String getUserFriendlyMessage(dynamic error) {
    if (error == null) {
      return 'An unexpected error occurred. Please try again.';
    }

    final errorString = error.toString().toLowerCase();

    // Database constraint errors
    if (errorString.contains('not null constraint failed')) {
      if (errorString.contains('location_id')) {
        return 'Unable to save contact. Please check your connection and try again.';
      }
      if (errorString.contains('ghl_id')) {
        return 'Contact ID is missing. Please try again.';
      }
      return 'Required information is missing. Please check all required fields and try again.';
    }

    // Database errors
    if (errorString.contains('databaseexception')) {
      return 'Unable to save contact. Please check your connection and try again.';
    }

    if (errorString.contains('sqfliteexception')) {
      return 'Unable to access contact data. Please restart the app and try again.';
    }

    // Network errors
    if (errorString.contains('socketexception') ||
        errorString.contains('handshakeexception') ||
        errorString.contains('connection refused')) {
      return 'Unable to connect to server. Please check your internet connection and try again.';
    }

    if (errorString.contains('timeoutexception')) {
      return 'Request timed out. Please check your connection and try again.';
    }

    // HTTP errors
    if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return 'Your session has expired. Please log in again.';
    }

    if (errorString.contains('403') || errorString.contains('forbidden')) {
      return 'You do not have permission to perform this action.';
    }

    if (errorString.contains('404') || errorString.contains('not found')) {
      return 'The requested information could not be found.';
    }

    if (errorString.contains('422') || errorString.contains('validation')) {
      return 'Please check your information and try again.';
    }

    if (errorString.contains('500') ||
        errorString.contains('internal server error')) {
      return 'Server error occurred. Please try again later.';
    }

    if (errorString.contains('503') ||
        errorString.contains('service unavailable')) {
      return 'Service is temporarily unavailable. Please try again later.';
    }

    // Format errors
    if (errorString.contains('formatexception') ||
        errorString.contains('invalid format')) {
      return 'Invalid data format. Please check your information and try again.';
    }

    // JSON parsing errors
    if (errorString.contains('type') &&
        errorString.contains('is not a subtype')) {
      return 'Data format error. Please try again.';
    }

    // Generic fallback
    return 'An unexpected error occurred. Please try again.';
  }
}

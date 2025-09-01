class AuthServiceException implements Exception {
  final String message;
  final AuthServiceErrorType errorType;
  final String? technicalDetails;

  const AuthServiceException({
    required this.message,
    required this.errorType,
    this.technicalDetails,
  });

  @override
  String toString() => message;
}

enum AuthServiceErrorType {
  serviceUnavailable,
  networkError,
  invalidCredentials,
  unknown,
}
/// Utility class for sanitizing authentication tokens
class TokenSanitizer {
  /// Sanitizes a token by removing whitespace, newlines, and wrapping quotes
  /// Returns null if the token is invalid or empty
  static String? sanitizeToken(String? rawToken) {
    if (rawToken == null || rawToken.trim().isEmpty) {
      return null;
    }

    // Trim whitespace and newlines
    String sanitized = rawToken.trim();

    // Remove wrapping quotes if present (both single and double)
    if ((sanitized.startsWith('"') && sanitized.endsWith('"')) ||
        (sanitized.startsWith("'") && sanitized.endsWith("'"))) {
      sanitized = sanitized.substring(1, sanitized.length - 1);
    }

    // Remove the word "Bearer" if present (tokens should be raw)
    if (sanitized.toLowerCase().startsWith('bearer ')) {
      sanitized = sanitized.substring(7);
    }

    // Final trim after all transformations
    sanitized = sanitized.trim();

    // Validate token format (basic JWT-like pattern or API token)
    if (sanitized.isEmpty ||
        !RegExp(
          r'^[A-Za-z0-9\-_\.]+(\|[A-Za-z0-9\-_\.]+)?$',
        ).hasMatch(sanitized)) {
      return null;
    }

    return sanitized;
  }

  /// Checks if a token appears to be valid format
  static bool isValidTokenFormat(String? token) {
    if (token == null || token.trim().isEmpty) {
      return false;
    }

    // Basic validation for JWT or Laravel Sanctum token format
    return RegExp(
      r'^[A-Za-z0-9\-_\.]+(\|[A-Za-z0-9\-_\.]+)?$',
    ).hasMatch(token.trim());
  }
}

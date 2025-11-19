/// Password validation utilities that match backend requirements
class PasswordValidator {
  /// Validates password according to backend requirements:
  /// - At least 8 characters
  /// - Contains uppercase letters
  /// - Contains lowercase letters
  /// - Contains numbers
  /// - Contains symbols/special characters
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!_hasUpperCase(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!_hasLowerCase(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!_hasDigit(value)) {
      return 'Password must contain at least one number';
    }

    if (!_hasSpecialChar(value)) {
      return 'Password must contain at least one special character (!@#\$%^&*(),.?":{}|<>)';
    }

    return null;
  }

  static bool _hasUpperCase(String value) {
    return value.contains(RegExp(r'[A-Z]'));
  }

  static bool _hasLowerCase(String value) {
    return value.contains(RegExp(r'[a-z]'));
  }

  static bool _hasDigit(String value) {
    return value.contains(RegExp(r'[0-9]'));
  }

  static bool _hasSpecialChar(String value) {
    return value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  /// Returns a user-friendly message explaining password requirements
  static String getRequirementsMessage() {
    return 'Password must:\n'
        '• Be at least 8 characters\n'
        '• Contain uppercase and lowercase letters\n'
        '• Contain at least one number\n'
        '• Contain at least one special character';
  }

  /// Checks if password meets all requirements without returning error message
  static bool isValid(String password) {
    return validate(password) == null;
  }
}

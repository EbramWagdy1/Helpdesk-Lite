class AppRegex {
  static bool isEmailValid(String email) {
    final trimmed = email.trim();
    if (trimmed.contains('..') || trimmed.startsWith('.') || trimmed.contains(' ')) return false;
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(trimmed);
  }

  static bool isPasswordValid(String password) {
    return RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{6,}$').hasMatch(password);
  }

  static bool isPhoneNumberValid(String phoneNumber) {
    return RegExp(r'^(\+?20|0)?(10|11|12|15)[0-9]{8}$').hasMatch(phoneNumber.trim());
  }

  static bool hasLowerCase(String password) {
    return RegExp('^(?=.*[a-z])').hasMatch(password);
  }

  static bool hasUpperCase(String password) {
    return RegExp('^(?=.*[A-Z])').hasMatch(password);
  }

  static bool hasNumber(String password) {
    return RegExp('^(?=.*?[0-9])').hasMatch(password);
  }

  static bool hasSpecialCharacter(String password) {
    return RegExp(r'^(?=.*?[#?!@$%^&*-])').hasMatch(password);
  }

  static bool hasMinLength(String password) {
    return RegExp('^(?=.{8,})').hasMatch(password);
  }
}

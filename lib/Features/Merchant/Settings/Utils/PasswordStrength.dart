enum PasswordStrengthLevel { empty, weak, medium, strong }

class PasswordStrength {
  PasswordStrength._();

  static bool hasMinLength(String value) => value.length >= 8;
  static bool hasUppercase(String value) => RegExp(r'[A-Z]').hasMatch(value);
  static bool hasLowercase(String value) => RegExp(r'[a-z]').hasMatch(value);
  static bool hasNumber(String value) => RegExp(r'[0-9]').hasMatch(value);
  static bool hasSpecialChar(String value) => RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\/;`~]').hasMatch(value);

  static List<bool> checklist(String value) => [
        hasMinLength(value),
        hasUppercase(value),
        hasLowercase(value),
        hasNumber(value),
        hasSpecialChar(value),
      ];

  static PasswordStrengthLevel level(String value) {
    if (value.isEmpty) return PasswordStrengthLevel.empty;

    final passed = checklist(value).where((v) => v).length;

    if (passed <= 2) return PasswordStrengthLevel.weak;
    if (passed <= 4) return PasswordStrengthLevel.medium;
    return PasswordStrengthLevel.strong;
  }

  static bool isStrongEnough(String value) {
    return hasMinLength(value) && hasUppercase(value) && hasNumber(value);
  }

  static String? validate(String value) {
    if (value.isEmpty) return "password_required";
    if (!hasMinLength(value)) return "password_too_short";
    if (!hasUppercase(value)) return "password_needs_uppercase";
    if (!hasNumber(value)) return "password_needs_number";
    return null;
  }
}
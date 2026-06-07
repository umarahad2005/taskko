/// Form validation + password strength (SRS FR-3.1, FR-5.2; §8 constraints).
abstract final class Validators {
  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  static String? name(String value) {
    if (value.trim().isEmpty) return 'Please enter your name';
    return null;
  }

  static String? email(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Please enter your email';
    if (!_email.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String value, {int min = 6}) {
    if (value.isEmpty) return 'Please enter a password';
    if (value.length < min) return 'At least $min characters';
    return null;
  }
}

enum PasswordStrength { weak, fair, strong }

extension PasswordStrengthX on String {
  /// Heuristic strength from length + character variety.
  PasswordStrength get passwordStrength {
    var score = 0;
    if (length >= 6) score++;
    if (length >= 10) score++;
    if (contains(RegExp(r'[A-Z]')) && contains(RegExp(r'[a-z]'))) score++;
    if (contains(RegExp(r'[0-9]'))) score++;
    if (contains(RegExp(r'[^A-Za-z0-9]'))) score++;
    if (score >= 4) return PasswordStrength.strong;
    if (score >= 2) return PasswordStrength.fair;
    return PasswordStrength.weak;
  }
}

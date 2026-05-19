class PhoneFormatter {
  PhoneFormatter._();

  static String toE164(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '+91$digits';
    }
    if (digits.startsWith('91') && digits.length == 12) {
      return '+$digits';
    }
    if (input.startsWith('+')) {
      return input;
    }
    return '+$digits';
  }

  static bool isValidIndianPhone(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return RegExp(r'^[6-9]\d{9}$').hasMatch(digits);
    }
    if (digits.length == 12 && digits.startsWith('91')) {
      return RegExp(r'^91[6-9]\d{9}$').hasMatch(digits);
    }
    return false;
  }
}

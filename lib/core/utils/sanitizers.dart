import 'package:flutter/services.dart';

String sanitizeName(String input) {
  final trimmed = input.trim();
  return trimmed.replaceAll(RegExp(r'\s+'), ' ');
}

String sanitizeEmail(String input) {
  return input.trim().toLowerCase();
}

String sanitizePassword(String input) {
  return input.trim();
}

String digitsOnly(String input) {
  return input.replaceAll(RegExp(r'\D'), '');
}

String sanitizeCpf(String input) {
  return digitsOnly(input);
}

String sanitizePhone(String input) {
  return digitsOnly(input);
}

String sanitizeUf(String input) {
  return input.trim().toUpperCase();
}

String sanitizeText(String input) {
  final trimmed = input.trim();
  return trimmed.replaceAll(RegExp(r'\s+'), ' ');
}

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}

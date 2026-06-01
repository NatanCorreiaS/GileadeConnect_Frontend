import 'package:flutter_test/flutter_test.dart';
import 'package:gileade_frontend/core/utils/sanitizers.dart';

void main() {
  test('sanitizeName remove espacos duplicados', () {
    expect(sanitizeName('  Maria   Silva  '), 'Maria Silva');
  });

  test('sanitizeEmail normaliza para minusculo', () {
    expect(sanitizeEmail(' TESTE@EMAIL.COM '), 'teste@email.com');
  });

  test('digitsOnly remove caracteres nao numericos', () {
    expect(digitsOnly('123.456-789'), '123456789');
  });

  test('sanitizeCpf remove caracteres nao numericos', () {
    expect(sanitizeCpf('123.456.789-01'), '12345678901');
  });

  test('sanitizeUf normaliza para maiusculo', () {
    expect(sanitizeUf('sp'), 'SP');
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:gileade_frontend/core/utils/validators.dart';

void main() {
  test('isValidEmail valida formato', () {
    expect(isValidEmail('usuario@email.com'), true);
    expect(isValidEmail('usuario@'), false);
  });

  test('validatePassword exige tamanho minimo', () {
    expect(validatePassword('123'), isNotNull);
    expect(validatePassword('123456'), isNull);
  });

  test('validateCpf exige 11 digitos', () {
    expect(validateCpf('123.456.789-01'), isNull);
    expect(validateCpf('123'), isNotNull);
  });

  test('validateIdade exige inteiro positivo', () {
    expect(validateIdade('0'), isNotNull);
    expect(validateIdade('30'), isNull);
  });

  test('validateCelular exige tamanho minimo', () {
    expect(validateCelular('11999990000'), isNull);
    expect(validateCelular('123'), isNotNull);
  });
}

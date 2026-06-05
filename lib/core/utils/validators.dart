import 'sanitizers.dart';

bool isValidEmail(String value) {
  final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  return regex.hasMatch(value);
}

String? requiredField(String? value, String mensagem) {
  if (value == null || value.trim().isEmpty) {
    return mensagem;
  }
  return null;
}

String? validateEmail(String? value) {
  final required = requiredField(value, 'Informe um e-mail.');
  if (required != null) {
    return required;
  }
  if (!isValidEmail(value!.trim())) {
    return 'E-mail invalido.';
  }
  return null;
}

String? validatePassword(String? value) {
  final required = requiredField(value, 'Informe uma senha.');
  if (required != null) {
    return required;
  }
  if (value!.trim().length < 6) {
    return 'Senha deve ter no minimo 6 caracteres.';
  }
  return null;
}

String? validateCpf(String? value) {
  final required = requiredField(value, 'Informe o CPF.');
  if (required != null) {
    return required;
  }
  final cpf = sanitizeCpf(value!);
  if (cpf.length != 11) {
    return 'CPF invalido.';
  }
  return null;
}

String? validateIdade(String? value) {
  final required = requiredField(value, 'Informe a idade.');
  if (required != null) {
    return required;
  }
  final idade = int.tryParse(value!.trim());
  if (idade == null || idade <= 0) {
    return 'Idade invalida.';
  }
  return null;
}

String? validateCelular(String? value) {
  final required = requiredField(value, 'Informe o celular.');
  if (required != null) {
    return required;
  }
  final digits = sanitizePhone(value!);
  if (digits.length < 10) {
    return 'Celular invalido.';
  }
  return null;
}

String? validateNome(String? value) {
  final required = requiredField(value, 'Campo obrigatorio.');
  if (required != null) {
    return required;
  }
  if (value!.trim().length < 2) {
    return 'Muito curto.';
  }
  return null;
}

String? validateUf(String? value) {
  final required = requiredField(value, 'UF e obrigatoria.');
  if (required != null) {
    return required;
  }
  if (value!.trim().length != 2) {
    return 'UF deve ter 2 letras.';
  }
  if (!RegExp(r'^[A-Z]{2}$').hasMatch(value.trim().toUpperCase())) {
    return 'UF invalida.';
  }
  return null;
}

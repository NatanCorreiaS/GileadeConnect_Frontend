import 'dart:convert';

import 'package:crypto/crypto.dart';

String hashSenha(String value) {
  return sha256.convert(utf8.encode(value)).toString();
}

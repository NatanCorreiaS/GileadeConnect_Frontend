import 'dart:convert';

import '../models/login_response.dart';
import 'api_client.dart';

class AuthService {
  AuthService(this._client);

  final ApiClient _client;

  Future<LoginResponse> login({
    required String cpf,
    required String senha,
  }) async {
    final response = await _client.postJson(
      '/api/v1/auth/login',
      {'cpf': cpf, 'senha': senha},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Falha no login. Codigo: ${response.statusCode}');
    }

    return LoginResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> logout() async {
    final response = await _client.postJson('/api/v1/auth/logout', {});

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Falha no logout. Codigo: ${response.statusCode}');
    }
  }
}

import 'api_client.dart';

class AuthService {
  AuthService(this._client);

  final ApiClient _client;

  Future<void> login({required String email, required String senhaHash}) async {
    final response = await _client.postJson(
      '/api/v1/auth/login',
      {
        'email': email,
        'senha': senhaHash,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Falha no login. Codigo: ${response.statusCode}');
    }
  }
}

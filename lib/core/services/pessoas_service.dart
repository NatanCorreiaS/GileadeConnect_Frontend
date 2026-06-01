import '../models/pessoa_create_request.dart';
import 'api_client.dart';

class PessoasService {
  PessoasService(this._client);

  final ApiClient _client;

  Future<void> criarPessoa(PessoaCreateRequest request) async {
    final response = await _client.postJson(
      '/api/v1/pessoas',
      request.toJson(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Falha ao cadastrar. Codigo: ${response.statusCode}');
    }
  }
}

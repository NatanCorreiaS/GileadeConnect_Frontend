import 'dart:convert';

import '../models/login_response.dart';
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

  Future<List<Usuario>> listarPessoas({int limit = 50, int offset = 0}) async {
    final response = await _client.get('/api/v1/pessoas', queryParameters: {
      'limit': limit.toString(),
      'offset': offset.toString(),
    });
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Falha ao listar pessoas. Codigo: ${response.statusCode}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => Usuario.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Usuario> buscarPessoa(int id) async {
    final response = await _client.get('/api/v1/pessoas/$id');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Falha ao buscar pessoa. Codigo: ${response.statusCode}');
    }
    return Usuario.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> atualizarPessoa(int id, Map<String, dynamic> dados) async {
    final response = await _client.putJson('/api/v1/pessoas/$id', dados);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Falha ao atualizar pessoa. Codigo: ${response.statusCode}');
    }
  }

  Future<void> removerPessoa(int id) async {
    final response = await _client.delete('/api/v1/pessoas/$id');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Falha ao remover pessoa. Codigo: ${response.statusCode}');
    }
  }
}

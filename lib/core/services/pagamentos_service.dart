import 'dart:convert';

import '../models/checkout.dart';
import '../models/pagamento.dart';
import 'api_client.dart';

class PagamentosService {
  PagamentosService(this._client);

  final ApiClient _client;

  Future<CheckoutResponse> criarCheckout(CheckoutRequest request) async {
    final response = await _client.postJson(
      '/api/v1/pagamentos/checkout',
      request.toJson(),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body);
      final mensagem = body['error'] ?? body['mensagem'] ?? body['message'] ?? response.body;
      throw Exception(mensagem.toString());
    }
    return CheckoutResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<Pagamento>> listarPagamentos({
    required int usuarioId,
    String? status,
    String? dataInicio,
    String? dataFim,
    int limit = 50,
    int offset = 0,
  }) async {
    final queryParams = <String, String>{
      'usuario_id': usuarioId.toString(),
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (status != null) queryParams['status'] = status;
    if (dataInicio != null) queryParams['data_inicio'] = dataInicio;
    if (dataFim != null) queryParams['data_fim'] = dataFim;

    final response =
        await _client.get('/api/v1/pagamentos', queryParameters: queryParams);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'Falha ao listar pagamentos. Codigo: ${response.statusCode}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => Pagamento.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

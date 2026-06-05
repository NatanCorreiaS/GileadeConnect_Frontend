import 'dart:convert';

import '../models/ticket_compra.dart';
import 'api_client.dart';

class TicketsCompraService {
  TicketsCompraService(this._client);

  final ApiClient _client;

  Future<TicketCompra> criarCompra(Map<String, dynamic> dados) async {
    final response = await _client.postJson('/api/v1/tickets-compra', dados);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Falha ao criar compra. Codigo: ${response.statusCode}');
    }
    return TicketCompra.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<TicketCompra> buscarCompra(int id) async {
    final response = await _client.get('/api/v1/tickets-compra/$id');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Falha ao buscar compra. Codigo: ${response.statusCode}');
    }
    return TicketCompra.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<TicketCompra>> listarComprasUsuario(int usuarioId,
      {int limit = 50, int offset = 0}) async {
    final response = await _client.get(
      '/api/v1/usuarios/$usuarioId/tickets-compra',
      queryParameters: {
        'limit': limit.toString(),
        'offset': offset.toString(),
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'Falha ao listar compras. Codigo: ${response.statusCode}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => TicketCompra.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> atualizarStatusCompra(int id, String status) async {
    final response = await _client.patchJson(
      '/api/v1/tickets-compra/$id/status',
      {'status': status},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'Falha ao atualizar status da compra. Codigo: ${response.statusCode}');
    }
  }

  Future<void> removerCompra(int id) async {
    final response = await _client.delete('/api/v1/tickets-compra/$id');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'Falha ao remover compra. Codigo: ${response.statusCode}');
    }
  }
}

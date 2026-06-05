import 'dart:convert';

import '../models/ticket.dart';
import 'api_client.dart';

class TicketsService {
  TicketsService(this._client);

  final ApiClient _client;

  Future<List<Ticket>> listarTickets({int limit = 50, int offset = 0}) async {
    final response = await _client.get('/api/v1/tickets', queryParameters: {
      'limit': limit.toString(),
      'offset': offset.toString(),
    });
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Falha ao listar tickets. Codigo: ${response.statusCode}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Ticket> buscarTicket(int id) async {
    final response = await _client.get('/api/v1/tickets/$id');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Falha ao buscar ticket. Codigo: ${response.statusCode}');
    }
    return Ticket.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Ticket> criarTicket(Map<String, dynamic> dados) async {
    final response = await _client.postJson('/api/v1/tickets', dados);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = response.body;
      throw Exception(
          'Falha ao criar ticket: ${response.statusCode} - $body');
    }
    return Ticket.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Ticket> atualizarTicket(int id, Map<String, dynamic> dados) async {
    final response = await _client.putJson('/api/v1/tickets/$id', dados);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'Falha ao atualizar ticket. Codigo: ${response.statusCode}');
    }
    return Ticket.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> removerTicket(int id) async {
    final response = await _client.delete('/api/v1/tickets/$id');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Falha ao remover ticket. Codigo: ${response.statusCode}');
    }
  }
}

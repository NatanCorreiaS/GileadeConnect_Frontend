import 'api_client.dart';

class AdminExportService {
  AdminExportService(this._client);

  final ApiClient _client;

  Future<List<int>> exportarUsuarios() async {
    final response = await _client.get('/api/v1/admin/export/usuarios');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'Falha ao exportar usuarios. Codigo: ${response.statusCode}');
    }
    return response.bodyBytes;
  }

  Future<List<int>> exportarPagamentos() async {
    final response = await _client.get('/api/v1/admin/export/pagamentos');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'Falha ao exportar pagamentos. Codigo: ${response.statusCode}');
    }
    return response.bodyBytes;
  }

  Future<List<int>> exportarTickets() async {
    final response = await _client.get('/api/v1/admin/export/tickets');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'Falha ao exportar tickets. Codigo: ${response.statusCode}');
    }
    return response.bodyBytes;
  }

  Future<List<int>> exportarTicketsCompra() async {
    final response = await _client.get('/api/v1/admin/export/tickets-compra');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'Falha ao exportar tickets-compra. Codigo: ${response.statusCode}');
    }
    return response.bodyBytes;
  }

  Future<List<int>> exportarBeneficiados() async {
    final response = await _client.get('/api/v1/admin/export/beneficiados');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'Falha ao exportar beneficiados. Codigo: ${response.statusCode}');
    }
    return response.bodyBytes;
  }
}

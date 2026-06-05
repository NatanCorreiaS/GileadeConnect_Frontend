import 'package:flutter/foundation.dart';

import '../models/ticket.dart';
import '../models/login_response.dart';
import '../models/pagamento.dart';
import '../services/api_client.dart';
import '../services/tickets_service.dart';
import '../services/pessoas_service.dart';
import '../services/pagamentos_service.dart';

class AdminProvider extends ChangeNotifier {
  AdminProvider(ApiClient client)
      : _ticketsService = TicketsService(client),
        _pessoasService = PessoasService(client),
        _pagamentosService = PagamentosService(client);

  final TicketsService _ticketsService;
  final PessoasService _pessoasService;
  final PagamentosService _pagamentosService;

  List<Ticket> _tickets = [];
  List<Usuario> _usuarios = [];
  List<Pagamento> _pagamentos = [];
  bool _loading = false;
  String? _erro;

  List<Ticket> get tickets => _tickets;
  List<Usuario> get usuarios => _usuarios;
  List<Pagamento> get pagamentos => _pagamentos;
  bool get loading => _loading;
  String? get erro => _erro;

  Future<void> carregarTickets() async {
    _loading = true;
    _erro = null;
    notifyListeners();
    try {
      _tickets = await _ticketsService.listarTickets();
    } catch (e) {
      _erro = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> carregarUsuarios() async {
    _loading = true;
    _erro = null;
    notifyListeners();
    try {
      _usuarios = await _pessoasService.listarPessoas();
    } catch (e) {
      _erro = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> carregarPagamentos({int? usuarioId}) async {
    _loading = true;
    _erro = null;
    notifyListeners();
    try {
      if (usuarioId != null) {
        _pagamentos =
            await _pagamentosService.listarPagamentos(usuarioId: usuarioId);
      } else {
        _pagamentos =
            await _pagamentosService.listarPagamentos(usuarioId: 0);
      }
    } catch (e) {
      _erro = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Ticket> criarTicket(Map<String, dynamic> dados) async {
    final ticket = await _ticketsService.criarTicket(dados);
    _tickets.add(ticket);
    notifyListeners();
    return ticket;
  }

  Future<Ticket> atualizarTicket(int id, Map<String, dynamic> dados) async {
    final ticket = await _ticketsService.atualizarTicket(id, dados);
    final index = _tickets.indexWhere((t) => t.id == id);
    if (index != -1) _tickets[index] = ticket;
    notifyListeners();
    return ticket;
  }

  Future<void> removerTicket(int id) async {
    await _ticketsService.removerTicket(id);
    _tickets.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<void> atualizarUsuario(int id, Map<String, dynamic> dados) async {
    await _pessoasService.atualizarPessoa(id, dados);
    final index = _usuarios.indexWhere((u) => u.id == id);
    if (index != -1) {
      final atualizado = await _pessoasService.buscarPessoa(id);
      _usuarios[index] = atualizado;
      notifyListeners();
    }
  }

  Future<void> removerUsuario(int id) async {
    await _pessoasService.removerPessoa(id);
    _usuarios.removeWhere((u) => u.id == id);
    notifyListeners();
  }
}

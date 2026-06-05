import 'package:flutter/foundation.dart';

import '../models/ticket.dart';
import '../services/api_client.dart';
import '../services/tickets_service.dart';

class TicketsProvider extends ChangeNotifier {
  TicketsProvider(ApiClient client)
      : _service = TicketsService(client);

  final TicketsService _service;
  List<Ticket> _tickets = [];
  bool _loading = false;
  String? _erro;

  List<Ticket> get tickets => _tickets;
  bool get loading => _loading;
  String? get erro => _erro;

  Future<void> carregarTickets() async {
    _loading = true;
    _erro = null;
    notifyListeners();

    try {
      _tickets = await _service.listarTickets();
    } catch (e) {
      _erro = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

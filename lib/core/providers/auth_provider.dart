import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/login_response.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
    _client = ApiClient(baseUrl: baseUrl);
    _authService = AuthService(_client);
  }

  late final ApiClient _client;
  late final AuthService _authService;
  Usuario? _usuario;
  bool _loading = false;

  Usuario? get usuario => _usuario;
  bool get isAuthenticated => _usuario != null;
  bool get loading => _loading;

  Future<void> login({required String cpf, required String senha}) async {
    _loading = true;
    notifyListeners();

    try {
      final response = await _authService.login(cpf: cpf, senha: senha);
      _client.token = response.token;
      _usuario = response.usuario;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _loading = true;
    notifyListeners();

    try {
      await _authService.logout();
    } finally {
      _client.token = null;
      _usuario = null;
      _loading = false;
      notifyListeners();
    }
  }
}

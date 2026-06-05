import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/login_response.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
    _client = ApiClient(baseUrl: baseUrl);
    _authService = AuthService(_client);
    _storage = const FlutterSecureStorage();
    _loadSavedSession();
  }

  late final ApiClient _client;
  late final AuthService _authService;
  late final FlutterSecureStorage _storage;
  Usuario? _usuario;
  bool _loading = false;

  ApiClient get client => _client;
  Usuario? get usuario => _usuario;
  bool get isAuthenticated => _usuario != null;
  bool get isAdmin => _usuario?.tipoUsuario == 'Admin';
  bool get loading => _loading;

  Future<void> _loadSavedSession() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final userJson = await _storage.read(key: 'usuario');
      if (token != null && userJson != null) {
        _client.token = token;
        _usuario =
            Usuario.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> login({required String cpf, required String senha}) async {
    _loading = true;
    notifyListeners();

    try {
      final response = await _authService.login(cpf: cpf, senha: senha);
      _client.token = response.token;
      _usuario = response.usuario;
      await _storage.write(key: 'jwt_token', value: response.token);
      await _storage.write(
          key: 'usuario', value: jsonEncode(response.usuario.toJson()));
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
      await _storage.delete(key: 'jwt_token');
      await _storage.delete(key: 'usuario');
      _loading = false;
      notifyListeners();
    }
  }
}

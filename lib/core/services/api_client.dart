import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({required String baseUrl, http.Client? client, this.token})
      : _client = client ?? http.Client(),
        _baseUrl = _normalizeBaseUrl(baseUrl);

  final http.Client _client;
  final String _baseUrl;
  String? token;

  Uri _buildUri(String path, [Map<String, String>? queryParameters]) {
    final uri = Uri.parse(_baseUrl);
    return uri.replace(
      path: _combinePath(uri.path, path),
      queryParameters: queryParameters,
    );
  }

  Future<http.Response> postJson(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? queryParameters,
  }) {
    final uri = _buildUri(path, queryParameters);
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return _client.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  static String _normalizeBaseUrl(String raw) {
    if (raw.endsWith('/')) {
      return raw.substring(0, raw.length - 1);
    }
    return raw;
  }

  static String _combinePath(String basePath, String path) {
    if (basePath.isEmpty || basePath == '/') {
      return path.startsWith('/') ? path : '/$path';
    }
    final trimmedBase = basePath.endsWith('/')
        ? basePath.substring(0, basePath.length - 1)
        : basePath;
    final trimmedPath = path.startsWith('/') ? path.substring(1) : path;
    return '$trimmedBase/$trimmedPath';
  }
}

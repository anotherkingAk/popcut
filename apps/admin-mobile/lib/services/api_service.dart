import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  static const String _baseUrl = 'http://localhost:4001/api/v1';
  static const String _tokenKey = 'admin_auth_token';
  static const String _userKey = 'admin_user_data';

  String? _token;
  Map<String, dynamic>? _cachedUser;

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  bool get isAuthenticated => _token != null;

  String? get token => _token;
  Map<String, dynamic>? get cachedUser => _cachedUser;

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      _cachedUser = jsonDecode(userJson) as Map<String, dynamic>;
    }
  }

  Future<void> _saveSession(String token, Map<String, dynamic> user) async {
    _token = token;
    _cachedUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user));
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final token = data['accessToken'] as String? ??
          data['token'] as String? ??
          (data['data'] as Map<String, dynamic>?)?['accessToken'] as String?;
      final user = data['user'] as Map<String, dynamic>? ??
          (data['data'] as Map<String, dynamic>?)?['user'] as Map<String, dynamic>?;
      if (token == null || user == null) {
        throw ApiException(500, 'Invalid response format');
      }
      await _saveSession(token, user);
      return user;
    }

    final body = _parseError(response.body);
    throw ApiException(response.statusCode, body);
  }

  Future<void> logout() async {
    _token = null;
    _cachedUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    _ensureAuth();
    final response = await _client.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    _ensureAuth();
    final response = await _client.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patch(String endpoint, {Map<String, dynamic>? body}) async {
    _ensureAuth();
    final response = await _client.patch(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    _ensureAuth();
    final response = await _client.delete(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  void _ensureAuth() {
    if (_token == null) {
      throw ApiException(401, 'Not authenticated');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw ApiException(response.statusCode, _parseError(response.body));
  }

  String _parseError(String body) {
    try {
      final data = jsonDecode(body);
      return data['message'] as String? ??
          data['error'] as String? ??
          'Unknown error';
    } catch (_) {
      return 'Unknown error';
    }
  }

  void dispose() {
    _client.close();
  }
}

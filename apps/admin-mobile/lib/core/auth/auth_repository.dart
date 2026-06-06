import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/constants.dart';
import '../../core/network/api_endpoints.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('Must be overridden in bootstrap');
});

class AuthRepository {
  final Dio _dio;
  final SharedPreferences _prefs;
  AdminUserData? _user;

  AuthRepository(this._dio, this._prefs);

  AdminUserData? get cachedUser => _user;
  bool get isLoggedIn => _prefs.getString(AppConstants.tokenKey) != null;

  Future<void> tryAutoLogin() async {
    final userJsonStr = _prefs.getString(AppConstants.userKey);
    if (userJsonStr != null) {
      try {
        final userJson = jsonDecode(userJsonStr) as Map<String, dynamic>;
        _user = AdminUserData.fromJson(userJson);
      } catch (_) {
        await _prefs.remove(AppConstants.tokenKey);
        await _prefs.remove(AppConstants.userKey);
      }
    }
  }

  Future<AdminUserData> login(String email, String password) async {
    final response = await _dio.post(
      ApiEndpoints.authLogin,
      data: {'email': email, 'password': password},
    );
    final data = response.data as Map<String, dynamic>;
    final result = data['data'] as Map<String, dynamic>? ?? data;
    final token = result['accessToken'] as String? ?? result['token'] as String? ?? '';
    final refreshToken = result['refreshToken'] as String?;
    final userData = result['user'] as Map<String, dynamic>? ?? result;

    await _prefs.setString(AppConstants.tokenKey, token);
    if (refreshToken != null) {
      await _prefs.setString(AppConstants.refreshTokenKey, refreshToken);
    }

    final user = AdminUserData.fromJson(userData);
    await _prefs.setString(AppConstants.userKey, user.toJson());
    _user = user;
    return user;
  }

  Future<void> logout() async {
    await _prefs.remove(AppConstants.tokenKey);
    await _prefs.remove(AppConstants.refreshTokenKey);
    await _prefs.remove(AppConstants.userKey);
    _user = null;
  }
}

class AdminUserData {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String role;
  final List<String> permissions;

  AdminUserData({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.role = 'analyst',
    this.permissions = const [],
  });

  factory AdminUserData.fromJson(Map<String, dynamic> json) {
    return AdminUserData(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? json['display_name'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? json['photo_url'] as String?,
      role: json['role'] as String? ?? (json['roles'] is List ? ((json['roles'] as List).isNotEmpty ? (json['roles'] as List).first as String : 'analyst') : 'analyst'),
      permissions: (json['permissions'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  String toJson() {
    return '{"id":"$id","email":"$email","displayName":"$displayName","photoUrl":"$photoUrl","role":"$role","permissions":$permissions}';
  }
}

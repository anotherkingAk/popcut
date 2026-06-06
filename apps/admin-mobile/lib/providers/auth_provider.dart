import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, loading, error }

class AuthProvider extends ChangeNotifier {
  final ApiService _api;
  AuthStatus _status = AuthStatus.uninitialized;
  AdminUser? _user;
  String? _errorMessage;
  bool _isLoading = false;

  AuthProvider(this._api);

  AuthStatus get status => _status;
  AdminUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> initialize() async {
    await _api.loadSession();
    if (_api.isAuthenticated && _api.cachedUser != null) {
      _user = AdminUser.fromJson(_api.cachedUser!);
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final userData = await _api.login(email, password);
      _user = AdminUser.fromJson(userData);
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Connection failed. Check your network.';
      _status = AuthStatus.error;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _api.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }
}

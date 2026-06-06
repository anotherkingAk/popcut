import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AppProvider extends ChangeNotifier {
  final AuthService _auth;
  AppUser? _user;
  bool _isLoading = false;

  AppProvider(this._auth) {
    _auth.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  AppUser? get user => _user;
  AuthService get auth => _auth;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  void _onAuthChanged() {
    final fbUser = _auth.user;
    if (fbUser != null && _user?.uid != fbUser.uid) {
      _user = AppUser(
        uid: fbUser.uid,
        email: fbUser.email,
        displayName: fbUser.displayName,
        photoUrl: fbUser.photoURL,
        phoneNumber: fbUser.phoneNumber,
      );
    } else if (fbUser == null) {
      _user = null;
    }
    notifyListeners();
  }

  void setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  Future<void> signOut() async {
    setLoading(true);
    try {
      await _auth.signOut();
      _user = null;
    } finally {
      setLoading(false);
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }
}

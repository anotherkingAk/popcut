import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_repository.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final AdminUserData? user;
  final String? error;

  const AuthState({this.status = AuthStatus.initial, this.user, this.error});

  AuthState copyWith({AuthStatus? status, AdminUserData? user, String? error, bool clearError = false}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepo = ref.read(authRepositoryProvider);
  return AuthNotifier(authRepo);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepo;

  AuthNotifier(this._authRepo) : super(const AuthState()) {
    if (_authRepo.isLoggedIn) {
      state = AuthState(status: AuthStatus.authenticated, user: _authRepo.cachedUser);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final user = await _authRepo.login(email, password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e is Exception ? e.toString().replaceAll('Exception: ', '') : 'Login failed',
      );
    }
  }

  Future<void> logout() async {
    await _authRepo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(error: null, clearError: true);
  }
}

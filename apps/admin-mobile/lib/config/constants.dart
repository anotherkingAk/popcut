abstract final class AppConstants {
  static const appName = 'PopCut Admin';
  static const apiBaseUrl = 'http://localhost:4001/api/v1';
  static const wsBaseUrl = 'ws://localhost:4001';
  static const tokenKey = 'admin_auth_token';
  static const refreshTokenKey = 'admin_refresh_token';
  static const userKey = 'admin_user_data';
  static const pageSize = 20;
  static const connectionTimeout = Duration(seconds: 30);
  static const receiveTimeout = Duration(seconds: 30);
  static const socketReconnectDelay = Duration(seconds: 5);
}

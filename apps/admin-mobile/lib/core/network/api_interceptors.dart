import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/constants.dart';

class AuthInterceptor extends Interceptor {
  final SharedPreferences _prefs;

  AuthInterceptor(this._prefs);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _prefs.getString(AppConstants.tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = _prefs.getString(AppConstants.refreshTokenKey);
      if (refreshToken != null) {
        try {
          final dio = Dio(BaseOptions(baseUrl: err.requestOptions.baseUrl));
          final response = await dio.post('/api/v1/auth/refresh', data: {
            'refreshToken': refreshToken,
          });
          final newToken = response.data['accessToken'] as String?;
          final newRefresh = response.data['refreshToken'] as String?;
          if (newToken != null) {
            await _prefs.setString(AppConstants.tokenKey, newToken);
            if (newRefresh != null) {
              await _prefs.setString(AppConstants.refreshTokenKey, newRefresh);
            }
            err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final retryResponse = await Dio(BaseOptions(baseUrl: err.requestOptions.baseUrl)).fetch(err.requestOptions);
            handler.resolve(retryResponse);
            return;
          }
        } catch (_) {
          await _prefs.remove(AppConstants.tokenKey);
          await _prefs.remove(AppConstants.refreshTokenKey);
          await _prefs.remove(AppConstants.userKey);
        }
      }
    }
    handler.next(err);
  }
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}

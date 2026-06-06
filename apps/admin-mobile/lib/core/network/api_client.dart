import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/constants.dart';
import 'api_interceptors.dart';

final dioClientProvider = Provider<Dio>((ref) => createDioClient());

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in bootstrap');
});

Dio createDioClient() {
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: AppConstants.connectionTimeout,
    receiveTimeout: AppConstants.receiveTimeout,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
  return dio;
}

final authDioProvider = Provider<Dio>((ref) {
  final dio = createDioClient();
  final prefs = ref.watch(sharedPreferencesProvider);
  dio.interceptors.addAll([
    AuthInterceptor(prefs),
    LoggingInterceptor(),
  ]);
  return dio;
});

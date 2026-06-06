import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/api_client.dart';
import 'core/auth/auth_repository.dart';

Future<ProviderContainer> bootstrap() async {
  final prefs = await SharedPreferences.getInstance();
  final dio = createDioClient();
  final authRepository = AuthRepository(dio, prefs);
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      dioClientProvider.overrideWithValue(dio),
      authRepositoryProvider.overrideWithValue(authRepository),
    ],
  );
  await authRepository.tryAutoLogin();
  return container;
}

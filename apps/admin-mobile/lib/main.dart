import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bootstrap.dart';
import 'config/routes.dart';
import 'config/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  final container = await bootstrap();
  runApp(UncontrolledProviderScope(container: container, child: const PopCutAdminApp()));
}

class PopCutAdminApp extends ConsumerWidget {
  const PopCutAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'PopCut Admin',
      debugShowCheckedModeBanner: false,
      theme: ref.watch(themeProvider),
      routerConfig: router,
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US')],
    );
  }
}

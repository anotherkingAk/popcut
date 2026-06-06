import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'services/api_service.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const PopCutAdminApp());
}

class PopCutAdminApp extends StatelessWidget {
  const PopCutAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService)),
        ChangeNotifierProvider(create: (_) => DashboardProvider(apiService)),
      ],
      child: MaterialApp(
        title: 'PopCut Admin',
        debugShowCheckedModeBanner: false,
        theme: AdminTheme.dark,
        home: const AppRouter(),
      ),
    );
  }
}

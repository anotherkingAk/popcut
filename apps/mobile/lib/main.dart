import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/project_service.dart';
import 'providers/app_provider.dart';
import 'providers/editor_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const CapCardApp());
}

class CapCardApp extends StatelessWidget {
  const CapCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider(AuthService())),
        ChangeNotifierProvider(create: (_) => ProjectService()..loadMockData()),
        ChangeNotifierProvider(create: (_) => EditorProvider()),
      ],
      child: MaterialApp(
        title: 'PopCut',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const AppRouter(),
      ),
    );
  }
}

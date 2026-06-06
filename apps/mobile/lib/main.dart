import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
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

class CapCardApp extends StatefulWidget {
  const CapCardApp({super.key});

  @override
  State<CapCardApp> createState() => _CapCardAppState();
}

class _CapCardAppState extends State<CapCardApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectService>().loadMockData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider(AuthService())),
        ChangeNotifierProvider(create: (_) => ProjectService()),
        ChangeNotifierProvider(create: (_) => EditorProvider()),
        ChangeNotifierProxyProvider<EditorProvider, PlaybackNotifier>(
          create: (ctx) => ctx.read<EditorProvider>().playback,
          update: (_, editor, __) => editor.playback,
        ),
        ChangeNotifierProxyProvider<EditorProvider, SelectionNotifier>(
          create: (ctx) => ctx.read<EditorProvider>().selection,
          update: (_, editor, __) => editor.selection,
        ),
        ChangeNotifierProxyProvider<EditorProvider, TimelineNotifier>(
          create: (ctx) => ctx.read<EditorProvider>().timeline,
          update: (_, editor, __) => editor.timeline,
        ),
        ChangeNotifierProxyProvider<EditorProvider, ToolNotifier>(
          create: (ctx) => ctx.read<EditorProvider>().tool,
          update: (_, editor, __) => editor.tool,
        ),
      ],
      child: const AppRouter(),
    );
  }
}

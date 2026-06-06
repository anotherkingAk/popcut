import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/projects_screen.dart';
import 'screens/templates_screen.dart';
import 'screens/template_detail_screen.dart';
import 'screens/ai_studio_screen.dart';
import 'screens/editor_screen.dart';
import 'screens/export_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/delete_account_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_users_screen.dart';
import 'screens/admin/admin_effects_screen.dart';
import 'screens/admin/admin_content_screen.dart';
import 'screens/admin/admin_analytics_screen.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PopCut',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: '/splash',
      onGenerateRoute: _onGenerateRoute,
      navigatorObservers: [_RouteObserver()],
    );
  }
}

Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
  final args = settings.arguments is Map<String, dynamic>
      ? settings.arguments as Map<String, dynamic>
      : <String, dynamic>{};

  return MaterialPageRoute<void>(
    settings: settings,
    builder: (context) {
      switch (settings.name) {
        case '/splash':
          return SplashScreen(
            onComplete: () {
              final auth = context.read<AppProvider>();
              Navigator.of(context).pushReplacementNamed(auth.isLoggedIn ? '/home' : '/onboarding');
            },
          );
        case '/onboarding':
          return OnboardingScreen(
            onComplete: () => Navigator.of(context).pushReplacementNamed('/login'),
          );
        case '/login':
          return LoginScreen(
            onSignup: () => Navigator.of(context).pushNamed('/signup'),
            onForgotPassword: () => Navigator.of(context).pushNamed('/forgot-password'),
            onOtp: (phone, verId) => Navigator.of(context).pushNamed('/otp', arguments: {'phone': phone, 'verId': verId}),
            onSuccess: () => Navigator.of(context).pushReplacementNamed('/home'),
          );
        case '/forgot-password':
          return ForgotPasswordScreen(
            onBack: () => Navigator.of(context).pop(),
          );
        case '/signup':
          return SignupScreen(
            onLogin: () => Navigator.of(context).pop(),
            onOtp: (phone, verId) => Navigator.of(context).pushNamed('/otp', arguments: {'phone': phone, 'verId': verId}),
          );
        case '/otp':
          return OtpScreen(
            phone: args['phone'] as String? ?? '',
            verificationId: args['verId'] as String? ?? '',
            onSuccess: () => Navigator.of(context).pushReplacementNamed('/home'),
          );
        case '/home':
          return HomeScreen(
            onNavigate: (route, {args}) => Navigator.of(context).pushNamed(route, arguments: args),
          );
        case '/projects':
          return ProjectsScreen(
            onBack: () => Navigator.of(context).pop(),
            onNavigate: (route, {args}) => Navigator.of(context).pushNamed(route, arguments: args),
          );
        case '/editor':
          return EditorScreen(
            projectId: args['projectId'] as String?,
            onBack: () => Navigator.of(context).pop(),
            onExport: (projectId) => Navigator.of(context).pushNamed('/export', arguments: {'projectId': projectId}),
          );
        case '/templates':
          return TemplatesScreen(
            onBack: () => Navigator.of(context).pop(),
            onNavigate: (route, {args}) => Navigator.of(context).pushNamed(route, arguments: args),
          );
        case '/template-detail':
          return TemplateDetailScreen(
            templateId: args['templateId'] as String? ?? '1',
            templateName: args['templateName'] as String? ?? 'Wedding Highlights',
            onBack: () => Navigator.of(context).pop(),
            onNavigate: (route, {args}) => Navigator.of(context).pushNamed(route, arguments: args),
          );
        case '/ai-studio':
          return AiStudioScreen(
            onBack: () => Navigator.of(context).pop(),
          );
        case '/export':
          return ExportScreen(
            projectId: args['projectId'] as String?,
            onBack: () => Navigator.of(context).pop(),
            onNavigate: (route) => Navigator.of(context).pushNamed(route),
          );
        case '/settings':
          return SettingsScreen(
            onBack: () => Navigator.of(context).pop(),
            onNavigate: (route) => Navigator.of(context).pushNamed(route),
          );
        case '/subscription':
          return SubscriptionScreen(
            onBack: () => Navigator.of(context).pop(),
          );
        case '/privacy':
          return PrivacyScreen(
            onBack: () => Navigator.of(context).pop(),
            onNavigate: (route, {args}) => Navigator.of(context).pushNamed(route, arguments: args),
          );
        case '/delete-account':
          return DeleteAccountScreen(
            onBack: () => Navigator.of(context).pop(),
            onNavigate: (route, {args}) => Navigator.of(context).pushNamed(route, arguments: args),
          );
        case '/admin':
          return AdminDashboard(
            onNavigate: (route) => Navigator.of(context).pushNamed(route),
            onBack: () => Navigator.of(context).pop(),
          );
        case '/admin/users':
          return AdminUsersScreen(
            onBack: () => Navigator.of(context).pop(),
          );
        case '/admin/effects':
          return AdminEffectsScreen(
            onBack: () => Navigator.of(context).pop(),
          );
        case '/admin/content':
          return AdminContentScreen(
            onBack: () => Navigator.of(context).pop(),
          );
        case '/admin/analytics':
          return AdminAnalyticsScreen(
            onBack: () => Navigator.of(context).pop(),
          );
        default:
          return Scaffold(body: Center(child: Text('Route not found: ${settings.name}', style: const TextStyle(color: Colors.white))));
      }
    },
  );
}

class _RouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
  }
}

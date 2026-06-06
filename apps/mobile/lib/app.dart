import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  String _currentRoute = '/splash';
  final _navStack = <String>['/splash'];
  String _pendingPhone = '';
  String _pendingVerId = '';
  Map<String, dynamic> _routeArgs = {};

  void _navigate(String route, {bool replace = false, Map<String, dynamic>? args}) {
    setState(() {
      if (replace) _navStack.clear();
      _currentRoute = route;
      _navStack.add(route);
      if (args != null) _routeArgs = args;
    });
  }

  void _goBack() {
    if (_navStack.length > 1) {
      setState(() {
        _navStack.removeLast();
        _currentRoute = _navStack.last;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildScreen(_currentRoute);
  }

  Widget _buildScreen(String route) {
    switch (route) {
      case '/splash':
        return SplashScreen(
          onComplete: () {
            final auth = context.read<AppProvider>();
            _navigate(auth.isLoggedIn ? '/home' : '/onboarding', replace: true);
          },
        );
      case '/onboarding':
        return OnboardingScreen(onComplete: () => _navigate('/login', replace: true));
      case '/login':
        return LoginScreen(
          onSignup: () => _navigate('/signup'),
          onForgotPassword: () => _navigate('/forgot-password'),
          onOtp: (phone, verId) {
            _pendingPhone = phone;
            _pendingVerId = verId;
            _navigate('/otp');
          },
          onSuccess: () => _navigate('/home', replace: true),
        );
      case '/forgot-password':
        return ForgotPasswordScreen(onBack: () => _navigate('/login'));
      case '/signup':
        return SignupScreen(
          onLogin: () => _navigate('/login'),
          onOtp: (phone, verId) {
            _pendingPhone = phone;
            _pendingVerId = verId;
            _navigate('/otp');
          },
        );
      case '/otp':
        return OtpScreen(
          phone: _pendingPhone,
          verificationId: _pendingVerId,
          onSuccess: () => _navigate('/home', replace: true),
        );
      case '/home':
        return HomeScreen(onNavigate: _navigate);
      case '/projects':
        return ProjectsScreen(onBack: _goBack, onNavigate: _navigate);
      case '/editor':
        return EditorScreen(
          projectId: _routeArgs['projectId'] as String?,
          onBack: _goBack,
          onExport: (projectId) => _navigate('/export', args: {'projectId': projectId}),
        );
      case '/templates':
        return TemplatesScreen(onBack: _goBack, onNavigate: _navigate);
      case '/template-detail':
        return TemplateDetailScreen(
          templateId: _routeArgs['templateId'] as String? ?? '1',
          templateName: _routeArgs['templateName'] as String? ?? 'Wedding Highlights',
          onBack: _goBack,
          onNavigate: _navigate,
        );
      case '/ai-studio':
        return AiStudioScreen(onBack: _goBack);
      case '/export':
        return ExportScreen(
          projectId: _routeArgs['projectId'] as String?,
          onBack: _goBack,
          onNavigate: _navigate,
        );
      case '/settings':
        return SettingsScreen(onBack: _goBack, onNavigate: _navigate);
      case '/subscription':
        return SubscriptionScreen(onBack: _goBack);
      case '/privacy':
        return PrivacyScreen(onBack: _goBack, onNavigate: _navigate);
      case '/delete-account':
        return DeleteAccountScreen(onBack: _goBack, onNavigate: _navigate);
      case '/admin':
        return AdminDashboard(onNavigate: _navigate, onBack: _goBack);
      case '/admin/users':
        return AdminUsersScreen(onBack: _goBack);
      case '/admin/effects':
        return AdminEffectsScreen(onBack: _goBack);
      case '/admin/content':
        return AdminContentScreen(onBack: _goBack);
      case '/admin/analytics':
        return AdminAnalyticsScreen(onBack: _goBack);
      default:
        return Scaffold(body: Center(child: Text('Route not found: $route', style: const TextStyle(color: Colors.white))));
    }
  }
}

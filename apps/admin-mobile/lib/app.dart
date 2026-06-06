import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/users_screen.dart';
import 'screens/user_detail_screen.dart';
import 'screens/approvals_screen.dart';
import 'screens/ai_factory_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/settings_screen.dart';

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  String _currentRoute = '/loading';
  final _navStack = <String>['/loading'];
  Map<String, dynamic> _routeArgs = {};

  void _navigate(String route, {bool replace = false, Map<String, dynamic>? args}) {
    setState(() {
      if (replace) _navStack.clear();
      _currentRoute = route;
      _navStack.add(route);
      if (args != null) _routeArgs = args;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildScreen(_currentRoute);
  }

  Widget _buildScreen(String route) {
    switch (route) {
      case '/loading':
        return _LoadingScreen(
          onComplete: () {
            final auth = context.read<AuthProvider>();
            _navigate(
              auth.isAuthenticated ? '/dashboard' : '/login',
              replace: true,
            );
          },
        );
      case '/login':
        return LoginScreen(
          onLoginSuccess: () => _navigate('/dashboard', replace: true),
        );
      case '/dashboard':
        return DashboardScreen(
          onNavigate: _navigate,
          currentRoute: route,
        );
      case '/users':
        return UsersScreen(
          onNavigate: (r, {args}) => _navigate(r, args: args),
          currentRoute: route,
        );
      case '/user-detail':
        return UserDetailScreen(
          userId: _routeArgs['userId'] as String? ?? '',
        );
      case '/approvals':
        return ApprovalsScreen(
          currentRoute: route,
          onNavigate: _navigate,
        );
      case '/ai-factory':
        return AiFactoryScreen(
          currentRoute: route,
          onNavigate: _navigate,
        );
      case '/notifications':
        return NotificationsScreen(
          currentRoute: route,
          onNavigate: _navigate,
        );
      case '/analytics':
        return AnalyticsScreen(
          currentRoute: route,
          onNavigate: _navigate,
        );
      case '/settings':
        return SettingsScreen(
          currentRoute: route,
          onNavigate: _navigate,
          onLogout: () => _navigate('/login', replace: true),
        );
      default:
        return Scaffold(
          backgroundColor: AdminColors.background,
          body: Center(
            child: Text(
              'Route not found: $route',
              style: const TextStyle(color: AdminColors.textLow),
            ),
          ),
        );
    }
  }
}

class _LoadingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const _LoadingScreen({required this.onComplete});

  @override
  State<_LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<_LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await context.read<AuthProvider>().initialize();
    if (mounted) {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AdminColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                size: 36,
                color: AdminColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'PopCut Admin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AdminColors.textHigh,
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AdminColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

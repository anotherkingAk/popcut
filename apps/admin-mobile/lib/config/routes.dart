import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app.dart';
import '../core/auth/auth_provider.dart';
import '../core/rbac/rbac_guard.dart';
import '../shared/widgets/app_scaffold.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/executive_dashboard_screen.dart';
import '../features/dashboard/screens/revenue_dashboard_screen.dart';
import '../features/dashboard/screens/ai_dashboard_screen.dart';
import '../features/users/screens/users_list_screen.dart';
import '../features/users/screens/user_detail_screen.dart';
import '../features/content/screens/templates_screen.dart';
import '../features/content/screens/effects_screen.dart';
import '../features/content/screens/filters_screen.dart';
import '../features/content/screens/fonts_screen.dart';
import '../features/content/screens/audio_screen.dart';
import '../features/content/screens/transitions_screen.dart';
import '../features/content/screens/color_grades_screen.dart';
import '../features/ai_factory/screens/generate_screen.dart';
import '../features/ai_factory/screens/queue_screen.dart';
import '../features/ai_factory/screens/review_screen.dart';
import '../features/monetization/screens/plans_screen.dart';
import '../features/monetization/screens/coupons_screen.dart';
import '../features/monetization/screens/revenue_screen.dart';
import '../features/monetization/screens/transactions_screen.dart';
import '../features/analytics/screens/analytics_home_screen.dart';
import '../features/analytics/screens/retention_screen.dart';
import '../features/notifications/screens/notifications_list_screen.dart';
import '../features/notifications/screens/broadcast_screen.dart';
import '../features/support/screens/support_dashboard_screen.dart';
import '../features/support/screens/ticket_detail_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/settings/screens/admin_users_screen.dart';
import '../features/settings/screens/feature_flags_screen.dart';
import '../features/settings/screens/audit_logs_screen.dart';
import '../features/settings/screens/system_health_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.user;
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isLoginRoute = state.matchedLocation == AppRoutes.login;
      final isSplashRoute = state.matchedLocation == AppRoutes.splash;

      if (isSplashRoute) return null;

      if (!isLoggedIn && !isLoginRoute) return AppRoutes.login;
      if (isLoggedIn && isLoginRoute) return AppRoutes.dashboard;

      if (isLoggedIn && user != null) {
        if (!RBACGuard.checkRouteAccess(user.role, state.matchedLocation)) {
          return AppRoutes.dashboard;
        }
      }
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      ShellRoute(
        builder: (_, __, child) => AppScaffold(child: child),
        routes: [
          GoRoute(path: AppRoutes.dashboard, builder: (_, __) => const ExecutiveDashboardScreen()),
          GoRoute(path: AppRoutes.revenueDashboard, builder: (_, __) => const RevenueDashboardScreen()),
          GoRoute(path: AppRoutes.aiDashboard, builder: (_, __) => const AiDashboardScreen()),
          GoRoute(path: AppRoutes.users, builder: (_, __) => const UsersListScreen()),
          GoRoute(path: AppRoutes.userDetail, builder: (_, state) => UserDetailScreen(userId: state.pathParameters['id']!)),
          GoRoute(path: AppRoutes.templates, builder: (_, __) => const TemplatesScreen()),
          GoRoute(path: AppRoutes.effects, builder: (_, __) => const EffectsScreen()),
          GoRoute(path: AppRoutes.filters, builder: (_, __) => const FiltersScreen()),
          GoRoute(path: AppRoutes.fonts, builder: (_, __) => const FontsScreen()),
          GoRoute(path: AppRoutes.audio, builder: (_, __) => const AudioScreen()),
          GoRoute(path: AppRoutes.transitions, builder: (_, __) => const TransitionsScreen()),
          GoRoute(path: AppRoutes.colorGrades, builder: (_, __) => const ColorGradesScreen()),
          GoRoute(path: AppRoutes.aiFactory, builder: (_, __) => const GenerateScreen()),
          GoRoute(path: AppRoutes.aiGenerate, builder: (_, __) => const GenerateScreen()),
          GoRoute(path: AppRoutes.aiQueue, builder: (_, __) => const QueueScreen()),
          GoRoute(path: AppRoutes.aiReview, builder: (_, __) => const ReviewScreen()),
          GoRoute(path: AppRoutes.plans, builder: (_, __) => const PlansScreen()),
          GoRoute(path: AppRoutes.coupons, builder: (_, __) => const CouponsScreen()),
          GoRoute(path: AppRoutes.revenue, builder: (_, __) => const RevenueScreen()),
          GoRoute(path: AppRoutes.transactions, builder: (_, __) => const TransactionsScreen()),
          GoRoute(path: AppRoutes.analytics, builder: (_, __) => const AnalyticsHomeScreen()),
          GoRoute(path: AppRoutes.retention, builder: (_, __) => const RetentionScreen()),
          GoRoute(path: AppRoutes.notifications, builder: (_, __) => const NotificationsListScreen()),
          GoRoute(path: AppRoutes.broadcast, builder: (_, __) => const BroadcastScreen()),
          GoRoute(path: AppRoutes.support, builder: (_, __) => const SupportDashboardScreen()),
          GoRoute(path: AppRoutes.ticketDetail, builder: (_, state) => TicketDetailScreen(ticketId: state.pathParameters['id']!)),
          GoRoute(path: AppRoutes.settings, builder: (_, __) => const SettingsScreen()),
          GoRoute(path: AppRoutes.adminUsers, builder: (_, __) => const AdminUsersScreen()),
          GoRoute(path: AppRoutes.featureFlags, builder: (_, __) => const FeatureFlagsScreen()),
          GoRoute(path: AppRoutes.auditLogs, builder: (_, __) => const AuditLogsScreen()),
          GoRoute(path: AppRoutes.systemHealth, builder: (_, __) => const SystemHealthScreen()),
        ],
      ),
    ],
  );
});

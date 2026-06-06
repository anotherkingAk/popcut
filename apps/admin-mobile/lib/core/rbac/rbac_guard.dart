import 'permissions.dart';

abstract final class RBACGuard {
  static bool hasPermission(AdminRole role, Permission permission) {
    final perms = RolePermissions.permissions[role];
    return perms?.contains(permission) ?? false;
  }

  static bool checkRouteAccess(String roleStr, String route) {
    final role = AdminRole.fromString(roleStr);
    final permission = _routeToPermission(route);
    if (permission == null) return true;
    return hasPermission(role, permission);
  }

  static Permission? _routeToPermission(String route) {
    if (route.startsWith('/dashboard/revenue')) return Permission.viewRevenueDashboard;
    if (route.startsWith('/dashboard/ai')) return Permission.viewAiDashboard;
    if (route.startsWith('/dashboard')) return Permission.viewDashboard;
    if (route.startsWith('/users')) return Permission.viewUsers;
    if (route.startsWith('/content/templates')) return Permission.viewTemplates;
    if (route.startsWith('/content/effects')) return Permission.viewEffects;
    if (route.startsWith('/content/filters')) return Permission.viewFilters;
    if (route.startsWith('/content/fonts')) return Permission.viewFonts;
    if (route.startsWith('/content/audio')) return Permission.viewAudio;
    if (route.startsWith('/content/transitions')) return Permission.viewTransitions;
    if (route.startsWith('/content/color-grades')) return Permission.viewColorGrades;
    if (route.startsWith('/content')) return Permission.viewContent;
    if (route.startsWith('/ai-factory/review')) return Permission.viewAiReview;
    if (route.startsWith('/ai-factory/queue')) return Permission.viewAiQueue;
    if (route.startsWith('/ai-factory')) return Permission.viewAiFactory;
    if (route.startsWith('/monetization/plans')) return Permission.viewPlans;
    if (route.startsWith('/monetization/coupons')) return Permission.viewCoupons;
    if (route.startsWith('/monetization/revenue')) return Permission.viewRevenue;
    if (route.startsWith('/monetization/transactions')) return Permission.viewTransactions;
    if (route.startsWith('/monetization')) return Permission.viewMonetization;
    if (route.startsWith('/analytics/retention')) return Permission.viewRetention;
    if (route.startsWith('/analytics')) return Permission.viewAnalytics;
    if (route.startsWith('/notifications/broadcast')) return Permission.broadcastNotifications;
    if (route.startsWith('/notifications')) return Permission.viewNotifications;
    if (route.startsWith('/support')) return Permission.viewSupport;
    if (route.startsWith('/settings/admin-users')) return Permission.manageAdminUsers;
    if (route.startsWith('/settings/feature-flags')) return Permission.manageFeatureFlags;
    if (route.startsWith('/settings/audit-logs')) return Permission.viewAuditLogs;
    if (route.startsWith('/settings/system-health')) return Permission.viewSystemHealth;
    if (route.startsWith('/settings')) return Permission.viewSettings;
    return null;
  }
}

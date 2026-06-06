import 'package:flutter/material.dart';
import '../models/dashboard_model.dart';
import '../models/user_model.dart';
import '../models/ai_job_model.dart';
import '../services/api_service.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _api;

  DashboardStats _stats = DashboardStats();
  ChartData _chartData = ChartData();
  List<AdminUser> _users = [];
  List<AiJob> _aiJobs = [];
  List<ApprovalItem> _approvals = [];
  List<NotificationItem> _notifications = [];

  bool _isLoading = false;
  bool _isLoadingUsers = false;
  bool _isLoadingJobs = false;
  bool _isLoadingApprovals = false;
  bool _isLoadingNotifications = false;
  String? _error;

  int _usersPage = 1;
  int _jobsPage = 1;
  int _approvalsPage = 1;
  int _notificationsPage = 1;
  bool _hasMoreUsers = true;
  bool _hasMoreJobs = true;
  bool _hasMoreApprovals = true;
  bool _hasMoreNotifications = true;
  String _userSearch = '';

  DashboardProvider(this._api);

  DashboardStats get stats => _stats;
  ChartData get chartData => _chartData;
  List<AdminUser> get users => _users;
  List<AiJob> get aiJobs => _aiJobs;
  List<ApprovalItem> get approvals => _approvals;
  List<NotificationItem> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get isLoadingUsers => _isLoadingUsers;
  bool get isLoadingJobs => _isLoadingJobs;
  bool get isLoadingApprovals => _isLoadingApprovals;
  bool get isLoadingNotifications => _isLoadingNotifications;
  String? get error => _error;
  bool get hasMoreUsers => _hasMoreUsers;
  bool get hasMoreJobs => _hasMoreJobs;
  bool get hasMoreApprovals => _hasMoreApprovals;
  bool get hasMoreNotifications => _hasMoreNotifications;
  String get userSearch => _userSearch;

  int get unreadNotifications =>
      _notifications.where((n) => !n.read).length;

  Future<void> fetchDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('/admin/dashboard');
      final data = response['data'] as Map<String, dynamic>? ?? response;
      _stats = DashboardStats.fromJson(data);
      _chartData = ChartData.fromJson(
          data['charts'] as Map<String, dynamic>? ?? {});
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load dashboard';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUsers({bool refresh = false}) async {
    if (refresh) {
      _usersPage = 1;
      _hasMoreUsers = true;
      _users = [];
    }
    if (!_hasMoreUsers || _isLoadingUsers) return;

    _isLoadingUsers = true;
    _error = null;
    notifyListeners();

    try {
      final queryParams = <String, String>{
        'page': _usersPage.toString(),
        'limit': '20',
      };
      if (_userSearch.isNotEmpty) {
        queryParams['search'] = _userSearch;
      }
      final query = queryParams.entries
          .map((e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      final response = await _api.get('/admin/users?$query');
      final data = response['data'] as Map<String, dynamic>? ?? response;
      final paginated = PaginatedUsers.fromJson(data);

      _users.addAll(paginated.users);
      _hasMoreUsers = paginated.hasMore;
      _usersPage++;
      _isLoadingUsers = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoadingUsers = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load users';
      _isLoadingUsers = false;
      notifyListeners();
    }
  }

  Future<void> searchUsers(String query) async {
    _userSearch = query;
    await fetchUsers(refresh: true);
  }

  Future<bool> suspendUser(String userId) async {
    try {
      await _api.patch('/admin/users/$userId/suspend');
      final idx = _users.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        _users[idx] = AdminUser.fromJson({
          ..._users[idx].toJson(),
          'status': 'suspended',
        });
        notifyListeners();
      }
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to suspend user';
      notifyListeners();
      return false;
    }
  }

  Future<bool> unsuspendUser(String userId) async {
    try {
      await _api.patch('/admin/users/$userId/unsuspend');
      final idx = _users.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        _users[idx] = AdminUser.fromJson({
          ..._users[idx].toJson(),
          'status': 'active',
        });
        notifyListeners();
      }
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to unsuspend user';
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchAiJobs({bool refresh = false}) async {
    if (refresh) {
      _jobsPage = 1;
      _hasMoreJobs = true;
      _aiJobs = [];
    }
    if (!_hasMoreJobs || _isLoadingJobs) return;

    _isLoadingJobs = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('/admin/ai-jobs?page=$_jobsPage&limit=20');
      final data = response['data'] as Map<String, dynamic>? ?? response;
      final jobs = (data['jobs'] as List<dynamic>?)
              ?.map((e) => AiJob.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      _aiJobs.addAll(jobs);
      _hasMoreJobs = data['hasMore'] as bool? ?? false;
      _jobsPage++;
      _isLoadingJobs = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoadingJobs = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load AI jobs';
      _isLoadingJobs = false;
      notifyListeners();
    }
  }

  Future<bool> retryAiJob(String jobId) async {
    try {
      await _api.post('/admin/ai-jobs/$jobId/retry');
      final idx = _aiJobs.indexWhere((j) => j.id == jobId);
      if (idx != -1) {
        _aiJobs[idx] = AiJob.fromJson({
          ..._aiJobs[idx].toJson(),
          'status': 'pending',
          'retryCount': _aiJobs[idx].retryCount + 1,
          'errorMessage': null,
        });
        notifyListeners();
      }
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to retry job';
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchApprovals({bool refresh = false}) async {
    if (refresh) {
      _approvalsPage = 1;
      _hasMoreApprovals = true;
      _approvals = [];
    }
    if (!_hasMoreApprovals || _isLoadingApprovals) return;

    _isLoadingApprovals = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get(
          '/admin/approvals?page=$_approvalsPage&limit=20');
      final data = response['data'] as Map<String, dynamic>? ?? response;
      final items = (data['approvals'] as List<dynamic>?)
              ?.map(
                  (e) => ApprovalItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      _approvals.addAll(items);
      _hasMoreApprovals = data['hasMore'] as bool? ?? false;
      _approvalsPage++;
      _isLoadingApprovals = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoadingApprovals = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load approvals';
      _isLoadingApprovals = false;
      notifyListeners();
    }
  }

  Future<bool> approveItem(String id) async {
    try {
      await _api.patch('/admin/approvals/$id/approve');
      final idx = _approvals.indexWhere((a) => a.id == id);
      if (idx != -1) {
        _approvals[idx] = ApprovalItem.fromJson({
          ..._approvals[idx].toJson(),
          'status': 'approved',
        });
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to approve';
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectItem(String id) async {
    try {
      await _api.patch('/admin/approvals/$id/reject');
      final idx = _approvals.indexWhere((a) => a.id == id);
      if (idx != -1) {
        _approvals[idx] = ApprovalItem.fromJson({
          ..._approvals[idx].toJson(),
          'status': 'rejected',
        });
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to reject';
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      _notificationsPage = 1;
      _hasMoreNotifications = true;
      _notifications = [];
    }
    if (!_hasMoreNotifications || _isLoadingNotifications) return;

    _isLoadingNotifications = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get(
          '/admin/notifications?page=$_notificationsPage&limit=20');
      final data = response['data'] as Map<String, dynamic>? ?? response;
      final items = (data['notifications'] as List<dynamic>?)
              ?.map((e) =>
                  NotificationItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      _notifications.addAll(items);
      _hasMoreNotifications = data['hasMore'] as bool? ?? false;
      _notificationsPage++;
      _isLoadingNotifications = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoadingNotifications = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load notifications';
      _isLoadingNotifications = false;
      notifyListeners();
    }
  }

  Future<bool> markNotificationRead(String id) async {
    try {
      await _api.patch('/admin/notifications/$id/read');
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        _notifications[idx] = NotificationItem.fromJson({
          ..._notifications[idx].toJson(),
          'read': true,
        });
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markAllNotificationsRead() async {
    try {
      await _api.post('/admin/notifications/read-all');
      _notifications = _notifications
          .map((n) => NotificationItem.fromJson({...n.toJson(), 'read': true}))
          .toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to mark all as read';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

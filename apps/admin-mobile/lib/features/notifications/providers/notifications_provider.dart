import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool read;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  NotificationItem({required this.id, required this.title, required this.body, this.type = 'info', this.read = false, required this.createdAt, this.data});

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.month}/${createdAt.day}';
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
    id: json['_id'] as String? ?? json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? json['message'] as String? ?? '',
    type: json['type'] as String? ?? 'info',
    read: json['read'] as bool? ?? json['isRead'] as bool? ?? false,
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
    data: json['data'] as Map<String, dynamic>?,
  );
}

class NotificationsState {
  final List<NotificationItem> notifications;
  final bool isLoading;
  final String? error;
  final int unreadCount;

  const NotificationsState({this.notifications = const [], this.isLoading = false, this.error, this.unreadCount = 0});

  NotificationsState copyWith({List<NotificationItem>? notifications, bool? isLoading, String? error, int? unreadCount, bool clearError = false}) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  final dio = ref.watch(authDioProvider);
  return NotificationsNotifier(dio);
});

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final Dio _dio;

  NotificationsNotifier(this._dio) : super(const NotificationsState());

  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dio.get(ApiEndpoints.notifications);
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data as Map<String, dynamic>;
      final list = (data['notifications'] as List<dynamic>?)?.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>)).toList() ?? [];
      state = state.copyWith(notifications: list, isLoading: false, unreadCount: list.where((n) => !n.read).length);
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message ?? 'Failed to load notifications');
    }
  }

  Future<bool> markRead(String id) async {
    try {
      await _dio.patch(ApiEndpoints.notificationRead(id));
      final idx = state.notifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        final list = [...state.notifications];
        list[idx] = NotificationItem(id: list[idx].id, title: list[idx].title, body: list[idx].body, type: list[idx].type, read: true, createdAt: list[idx].createdAt, data: list[idx].data);
        state = state.copyWith(notifications: list, unreadCount: state.unreadCount - 1);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markAllRead() async {
    try {
      await _dio.post(ApiEndpoints.readAllNotifications);
      state = state.copyWith(notifications: state.notifications.map((n) => NotificationItem(id: n.id, title: n.title, body: n.body, type: n.type, read: true, createdAt: n.createdAt, data: n.data)).toList(), unreadCount: 0);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> broadcast(String title, String body) async {
    try {
      await _dio.post(ApiEndpoints.broadcastNotification, data: {'title': title, 'body': body});
      return true;
    } catch (_) {
      return false;
    }
  }
}

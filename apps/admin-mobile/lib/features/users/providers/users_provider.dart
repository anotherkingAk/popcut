import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/user_model.dart';

class UsersState {
  final List<AdminUser> users;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int page;
  final bool hasMore;
  final String search;

  const UsersState({
    this.users = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.page = 1,
    this.hasMore = true,
    this.search = '',
  });

  UsersState copyWith({List<AdminUser>? users, bool? isLoading, bool? isLoadingMore, String? error, int? page, bool? hasMore, String? search, bool clearError = false}) {
    return UsersState(users: users ?? this.users, isLoading: isLoading ?? this.isLoading, isLoadingMore: isLoadingMore ?? this.isLoadingMore, error: clearError ? null : (error ?? this.error), page: page ?? this.page, hasMore: hasMore ?? this.hasMore, search: search ?? this.search);
  }
}

final usersProvider = StateNotifierProvider<UsersNotifier, UsersState>((ref) {
  final dio = ref.watch(authDioProvider);
  return UsersNotifier(dio);
});

class UsersNotifier extends StateNotifier<UsersState> {
  final Dio _dio;

  UsersNotifier(this._dio) : super(const UsersState());

  Future<void> fetchUsers({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(users: [], page: 1, hasMore: true, isLoading: true, clearError: true);
    } else if (state.page == 1) {
      state = state.copyWith(isLoading: true, clearError: true);
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      final queryParams = <String, String>{'page': state.page.toString(), 'limit': '20'};
      if (state.search.isNotEmpty) queryParams['search'] = state.search;
      final query = queryParams.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
      final response = await _dio.get('${ApiEndpoints.users}?$query');
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data as Map<String, dynamic>;
      final paginated = PaginatedUsers.fromJson(data);

      state = state.copyWith(
        users: refresh || state.page == 1 ? paginated.users : [...state.users, ...paginated.users],
        isLoading: false,
        isLoadingMore: false,
        page: state.page + 1,
        hasMore: paginated.hasMore,
      );
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, isLoadingMore: false, error: e.message ?? 'Failed to load users');
    } catch (e) {
      state = state.copyWith(isLoading: false, isLoadingMore: false, error: 'Failed to load users');
    }
  }

  Future<void> searchUsers(String query) async {
    state = state.copyWith(search: query);
    await fetchUsers(refresh: true);
  }

  Future<bool> toggleSuspend(String userId) async {
    try {
      await _dio.patch(ApiEndpoints.userToggleSuspend(userId));
      final idx = state.users.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        final user = state.users[idx];
        final newStatus = user.isActive ? 'suspended' : 'active';
        final updated = AdminUser.fromJson({'_id': user.id, 'email': user.email, 'displayName': user.displayName, 'photoUrl': user.photoUrl, 'phoneNumber': user.phoneNumber, 'status': newStatus, 'plan': user.plan, 'projectsCount': user.projectsCount, 'storageUsed': user.storageUsed, 'storageLimit': user.storageLimit, 'createdAt': user.createdAt.toIso8601String(), 'lastActive': user.lastActive.toIso8601String(), 'emailVerified': user.emailVerified, 'roles': user.roles});
        final users = [...state.users];
        users[idx] = updated;
        state = state.copyWith(users: users);
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}

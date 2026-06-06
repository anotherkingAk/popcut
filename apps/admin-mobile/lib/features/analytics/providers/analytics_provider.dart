import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class AnalyticsState {
  final Map<String, dynamic> revenueData;
  final Map<String, dynamic> retentionData;
  final Map<String, dynamic> usersData;
  final Map<String, dynamic> contentData;
  final bool isLoading;
  final String? error;

  const AnalyticsState({this.revenueData = const {}, this.retentionData = const {}, this.usersData = const {}, this.contentData = const {}, this.isLoading = false, this.error});

  AnalyticsState copyWith({Map<String, dynamic>? revenueData, Map<String, dynamic>? retentionData, Map<String, dynamic>? usersData, Map<String, dynamic>? contentData, bool? isLoading, String? error, bool clearError = false}) {
    return AnalyticsState(
      revenueData: revenueData ?? this.revenueData,
      retentionData: retentionData ?? this.retentionData,
      usersData: usersData ?? this.usersData,
      contentData: contentData ?? this.contentData,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  final dio = ref.watch(authDioProvider);
  return AnalyticsNotifier(dio);
});

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final Dio _dio;

  AnalyticsNotifier(this._dio) : super(const AnalyticsState());

  Future<void> fetchAll() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _dio.get(ApiEndpoints.analyticsRevenue),
        _dio.get(ApiEndpoints.analyticsRetention),
        _dio.get(ApiEndpoints.analyticsUsers),
        _dio.get(ApiEndpoints.analyticsContent),
      ]);
      state = state.copyWith(
        isLoading: false,
        revenueData: results[0].data['data'] as Map<String, dynamic>? ?? results[0].data as Map<String, dynamic>,
        retentionData: results[1].data['data'] as Map<String, dynamic>? ?? results[1].data as Map<String, dynamic>,
        usersData: results[2].data['data'] as Map<String, dynamic>? ?? results[2].data as Map<String, dynamic>,
        contentData: results[3].data['data'] as Map<String, dynamic>? ?? results[3].data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message ?? 'Failed to load analytics');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load analytics');
    }
  }
}

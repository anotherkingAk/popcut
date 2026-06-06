import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/dashboard_model.dart';

class DashboardState {
  final DashboardStats stats;
  final ChartData chartData;
  final bool isLoading;
  final String? error;

  DashboardState({
    this.stats = const DashboardStats(),
    this.chartData = const ChartData(),
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({DashboardStats? stats, ChartData? chartData, bool? isLoading, String? error, bool clearError = false}) {
    return DashboardState(
      stats: stats ?? this.stats,
      chartData: chartData ?? this.chartData,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final dio = ref.watch(authDioProvider);
  return DashboardNotifier(dio);
});

class DashboardNotifier extends StateNotifier<DashboardState> {
  final Dio _dio;

  DashboardNotifier(this._dio) : super(DashboardState());

  Future<void> fetchDashboard() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dio.get(ApiEndpoints.dashboard);
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data as Map<String, dynamic>;
      state = state.copyWith(
        isLoading: false,
        stats: DashboardStats.fromJson(data),
        chartData: ChartData.fromJson(data['charts'] as Map<String, dynamic>? ?? data),
      );
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message ?? 'Failed to load dashboard');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load dashboard');
    }
  }
}

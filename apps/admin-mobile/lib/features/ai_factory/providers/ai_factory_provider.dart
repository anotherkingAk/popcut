import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/ai_job_model.dart';

class AiFactoryState {
  final List<AiJob> jobs;
  final bool isLoading;
  final String? error;
  final int page;
  final bool hasMore;
  final bool isGenerating;

  const AiFactoryState({this.jobs = const [], this.isLoading = false, this.error, this.page = 1, this.hasMore = true, this.isGenerating = false});

  AiFactoryState copyWith({List<AiJob>? jobs, bool? isLoading, String? error, int? page, bool? hasMore, bool? isGenerating, bool clearError = false}) {
    return AiFactoryState(jobs: jobs ?? this.jobs, isLoading: isLoading ?? this.isLoading, error: clearError ? null : (error ?? this.error), page: page ?? this.page, hasMore: hasMore ?? this.hasMore, isGenerating: isGenerating ?? this.isGenerating);
  }
}

final aiFactoryProvider = StateNotifierProvider<AiFactoryNotifier, AiFactoryState>((ref) {
  final dio = ref.watch(authDioProvider);
  return AiFactoryNotifier(dio);
});

class AiFactoryNotifier extends StateNotifier<AiFactoryState> {
  final Dio _dio;

  AiFactoryNotifier(this._dio) : super(const AiFactoryState());

  Future<void> fetchJobs({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(jobs: [], page: 1, hasMore: true, isLoading: true, clearError: true);
    } else if (state.page == 1) {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final response = await _dio.get('${ApiEndpoints.aiFactory}/jobs?page=${state.page}&limit=20');
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data as Map<String, dynamic>;
      final jobs = (data['jobs'] as List<dynamic>?)?.map((e) => AiJob.fromJson(e as Map<String, dynamic>)).toList() ?? [];
      state = state.copyWith(
        jobs: refresh || state.page == 1 ? jobs : [...state.jobs, ...jobs],
        isLoading: false,
        page: state.page + 1,
        hasMore: data['hasMore'] as bool? ?? false,
      );
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message ?? 'Failed to load jobs');
    }
  }

  Future<bool> generate(Map<String, dynamic> params) async {
    state = state.copyWith(isGenerating: true);
    try {
      await _dio.post(ApiEndpoints.aiGenerate, data: params);
      state = state.copyWith(isGenerating: false);
      await fetchJobs(refresh: true);
      return true;
    } catch (e) {
      state = state.copyWith(isGenerating: false, error: 'Generation failed');
      return false;
    }
  }

  Future<bool> retryJob(String jobId) async {
    try {
      await _dio.post(ApiEndpoints.aiJobRetry(jobId));
      final idx = state.jobs.indexWhere((j) => j.id == jobId);
      if (idx != -1) {
        final jobs = [...state.jobs];
        jobs[idx] = AiJob.fromJson({'_id': jobId, 'userId': state.jobs[idx].userId, 'type': state.jobs[idx].type.name, 'status': 'pending', 'progress': 0, 'createdAt': state.jobs[idx].createdAt.toIso8601String(), 'retryCount': state.jobs[idx].retryCount + 1});
        state = state.copyWith(jobs: jobs);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelJob(String jobId) async {
    try {
      await _dio.post(ApiEndpoints.aiJobCancel(jobId));
      await fetchJobs(refresh: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> approveReview(String jobId) async {
    try {
      await _dio.post('${ApiEndpoints.aiFactory}/reviews/$jobId/approve');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectReview(String jobId) async {
    try {
      await _dio.post('${ApiEndpoints.aiFactory}/reviews/$jobId/reject');
      return true;
    } catch (e) {
      return false;
    }
  }
}

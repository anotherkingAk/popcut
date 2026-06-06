class _AnalyticsEvent {
  final DateTime timestamp;
  final String name;
  final Map<String, dynamic> properties;

  _AnalyticsEvent({
    required this.timestamp,
    required this.name,
    this.properties = const {},
  });
}

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  factory AnalyticsService() => _instance;
  AnalyticsService._();

  final List<_AnalyticsEvent> _events = [];
  static const int _maxEvents = 1000;

  void trackEvent(String name, {Map<String, dynamic>? properties}) {
    final event = _AnalyticsEvent(
      timestamp: DateTime.now(),
      name: name,
      properties: properties ?? {},
    );
    _events.add(event);
    if (_events.length > _maxEvents) {
      _events.removeAt(0);
    }
    // Analytics log suppressed in production
  }

  void trackScreen(String screenName) {
    trackEvent('screen_view', properties: {'screen': screenName});
  }

  void trackExport({
    required bool success,
    required int duration,
    required int fileSize,
    required String format,
  }) {
    trackEvent('export', properties: {
      'success': success,
      'duration': duration,
      'fileSize': fileSize,
      'format': format,
    });
  }

  void trackToolUse(String toolName) {
    trackEvent('tool_use', properties: {'tool': toolName});
  }

  void trackAIFeature(String featureName, {required bool success, Duration? processingTime}) {
    trackEvent('ai_feature', properties: {
      'feature': featureName,
      'success': success,
      'processingTimeMs': processingTime?.inMilliseconds,
    });
  }

  void trackError(String errorSource, String errorMessage) {
    trackEvent('error', properties: {
      'source': errorSource,
      'message': errorMessage,
    });
  }

  List<Map<String, dynamic>> getRecentEvents(int count) {
    return _events.reversed
        .take(count)
        .map((e) => {
              'timestamp': e.timestamp.toIso8601String(),
              'name': e.name,
              'properties': e.properties,
            })
        .toList();
  }

  Map<String, int> getAggregated({required String eventName, String? groupBy}) {
    final filtered = _events.where((e) => e.name == eventName);
    final result = <String, int>{};
    for (final event in filtered) {
      final key = groupBy != null ? '${event.properties[groupBy]}' : eventName;
      result[key] = (result[key] ?? 0) + 1;
    }
    return result;
  }
}

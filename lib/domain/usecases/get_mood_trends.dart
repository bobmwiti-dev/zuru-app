import '../../data/repositories/analytics_repository.dart';

/// Use case for getting mood trends
abstract class GetMoodTrends {
  /// Execute the use case
  Future<Map<String, dynamic>> call({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });
}

/// Implementation of GetMoodTrends use case
class GetMoodTrendsImpl implements GetMoodTrends {
  final AnalyticsRepository _repository;

  GetMoodTrendsImpl(this._repository);

  @override
  Future<Map<String, dynamic>> call({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getMoodAnalytics(userId, startDate: startDate, endDate: endDate);
  }
}
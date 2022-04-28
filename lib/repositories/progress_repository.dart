import '../models/progress.dart';

abstract class ProgressRepository {
  Future<Map<int, Progress>> getProgressMap(DateTime targetDate);
  Future<void> updateQuantityProgress(int scheduleId, DateTime dateTime, int diff);
  Future<void> updateDurationProgress(int scheduleId, DateTime dateTime, Duration diff);
}

import '../models/progress.dart';

abstract class ProgressRepository {
  Future<Map<int, Progress>> getProgressMap(DateTime targetDate);
  Future<void> addProgress(int scheduleId, DateTime completeDateTime);
}

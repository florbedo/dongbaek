import '../models/progress.dart';
import '../models/schedule.dart';

abstract class ProgressRepository {
  Future<Progress?> findProgress(ScheduleId scheduleId, DateTime dateTime);

  Future<Map<ScheduleId, Progress>> getProgresses(Iterable<ScheduleId> scheduleIds, DateTime targetDate);

  Future<void> updateProgress(ScheduleId scheduleId, ProgressStatus progressStatus, DateTime startDate,
      {DateTime? endDate});
}

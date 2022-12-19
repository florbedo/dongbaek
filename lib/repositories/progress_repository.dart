import '../models/progress.dart';
import '../models/schedule.dart';

abstract class ProgressRepository {
  Future<ProgressId> nextProgressId();

  Future<Progress> findProgress(ProgressId progressId);

  Future<Progress> findProgressBySchedule(ScheduleId scheduleId, DateTime dateTime);

  Future<Map<ScheduleId, Progress>> getProgresses(Iterable<ScheduleId> scheduleIds, DateTime targetDate);

  Future<void> replaceProgress(Progress progress);
}

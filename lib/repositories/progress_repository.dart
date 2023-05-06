import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/models/schedule.dart';

abstract class ProgressRepository {
  Future<Progress> findProgress(ProgressId progressId);

  Future<Progress> findProgressBySchedule(ScheduleId scheduleId, DateTime dateTime);

  Future<Map<ScheduleId, Progress>> getProgresses(Iterable<ScheduleId> scheduleIds, DateTime targetDate);

  Future<void> replaceProgress(ProgressData progress);
}

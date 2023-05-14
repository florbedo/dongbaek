import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/models/schedule.dart';

abstract class ProgressRepository {
  Future<Map<ScheduleId, Progress>> getProgresses(Iterable<ScheduleId> scheduleIds, DateTime targetDate);

  Future<void> replaceProgress(Progress progress);
}

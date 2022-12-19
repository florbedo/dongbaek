import '../models/schedule.dart';

abstract class ScheduleRepository {
  Future<ScheduleId> nextScheduleId();

  Future<Schedule> findSchedule(ScheduleId scheduleId);

  Future<List<Schedule>> getSchedules(DateTime currentDate);

  Future<void> addSchedule(Schedule schedule);

  Future<void> removeSchedule(ScheduleId scheduleId);
}

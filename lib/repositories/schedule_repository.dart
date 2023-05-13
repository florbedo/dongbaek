import 'package:dongbaek/models/schedule.dart';

abstract class ScheduleRepository {
  Future<Schedule> getSchedule(ScheduleId scheduleId);

  Future<List<Schedule>> getSchedules(DateTime currentDate);

  Future<void> addSchedule(ScheduleData schedule);

  Future<void> completeSchedule(ScheduleId scheduleId, DateTime endDateTime);

  Future<void> removeSchedule(ScheduleId scheduleId);
}

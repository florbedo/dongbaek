import '../models/schedule.dart';

abstract class ScheduleRepository {
  Future<List<Schedule>> getSchedules(DateTime currentDate);
  Future<void> addSchedule(Schedule schedule);
  Future<void> removeSchedule(int scheduleId);
}

import '../models/schedule.dart';

abstract class ScheduleRepository {
  List<Schedule> getSchedules(DateTime currentDate);
  void addSchedule(Schedule schedule);
  void removeSchedule(int targetId);
}

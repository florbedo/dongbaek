import '../models/schedule.dart';
import '../utils/datetime_utils.dart';

class ScheduleService {
  final List<Schedule> _weeklySchedules = [];
  final Map<DayOfWeek, List<Schedule>> _dailyScheduleMap = {};

  List<Schedule> getSchedules(DayOfWeek dayOfWeek) {
    return (_dailyScheduleMap[dayOfWeek] ?? []) + _weeklySchedules;
  }

  void addSchedule(Schedule schedule) {
    if (schedule.repeatInfo is RepeatPerWeek) {
      _weeklySchedules.add(schedule);
    } else {
      final repeatPerDay = (schedule.repeatInfo as RepeatPerDay);
      for (var dayOfWeek in repeatPerDay.daysOfWeek) {
        _dailyScheduleMap.update(
          dayOfWeek,
          (schedules) {
            return schedules + [schedule];
          },
          ifAbsent: () {
            return [schedule];
          },
        );
      }
    }
  }

  void removeSchedule(int targetId) {
    _weeklySchedules.removeWhere((element) => element.id == targetId);
    for (var schedules in _dailyScheduleMap.values) {
      schedules.removeWhere((element) => element.id == targetId);
    }
  }
}

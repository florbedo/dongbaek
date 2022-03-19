import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/repositories/schedule_repository.dart';
import 'package:dongbaek/utils/datetime_utils.dart';

class VolatileScheduleRepository implements ScheduleRepository {
  final List<Schedule> _weeklySchedules = [];
  final Map<DayOfWeek, List<Schedule>> _dailyScheduleMap = {};

  @override
  List<Schedule> getSchedules(DateTime currentDate) {
    final dayOfWeek = DateTimeUtils.getDayOfWeek(currentDate);
    return (_dailyScheduleMap[dayOfWeek] ?? []) + _weeklySchedules;
  }

  @override
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

  @override
  void removeSchedule(int targetId) {
    _weeklySchedules.removeWhere((element) => element.id == targetId);
    for (var schedules in _dailyScheduleMap.values) {
      schedules.removeWhere((element) => element.id == targetId);
    }
  }
}

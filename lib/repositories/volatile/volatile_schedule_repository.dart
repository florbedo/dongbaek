import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/repositories/schedule_repository.dart';
import 'package:dongbaek/utils/datetime_utils.dart';

import 'id_counter.dart';

class VolatileScheduleRepository implements ScheduleRepository {
  final List<Schedule> _weeklySchedules = [];
  final Map<DayOfWeek, List<Schedule>> _dailyScheduleMap = {};

  @override
  Future<List<Schedule>> getSchedules(DateTime currentDate) {
    final dayOfWeek = DateTimeUtils.getDayOfWeek(currentDate);
    return Future.value((_dailyScheduleMap[dayOfWeek] ?? []) + _weeklySchedules);
  }

  @override
  Future<void> addSchedule(Schedule schedule) {
    final inserting = Schedule(IdCounter.next(), schedule.title, schedule.repeatInfo, schedule.startDate);
    if (inserting.repeatInfo is RepeatPerWeek) {
      _weeklySchedules.add(inserting);
    } else {
      final repeatPerDay = (inserting.repeatInfo as RepeatPerDay);
      for (var dayOfWeek in repeatPerDay.daysOfWeek) {
        _dailyScheduleMap.update(
          dayOfWeek,
          (schedules) {
            return schedules + [inserting];
          },
          ifAbsent: () {
            return [inserting];
          },
        );
      }
    }
    return Future.value();
  }

  @override
  Future<void> removeSchedule(int scheduleId) {
    _weeklySchedules.removeWhere((element) => element.id == scheduleId);
    for (var schedules in _dailyScheduleMap.values) {
      schedules.removeWhere((element) => element.id == scheduleId);
    }
    return Future.value();
  }
}

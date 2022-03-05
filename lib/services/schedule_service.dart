import '../models/schedule.dart';

class ScheduleService {
  final List<Schedule> _schedules = [];

  List<Schedule> get schedules {
    return List.unmodifiable(_schedules);
  }

  void addSchedule(Schedule schedule) {
    _schedules.add(schedule);
  }

  void removeSchedule(int targetId) {
    _schedules.removeWhere((element) => element.id == targetId);
  }
}
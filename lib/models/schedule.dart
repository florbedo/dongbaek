import 'package:dongbaek/models/goal.dart';
import 'package:dongbaek/models/repeat_info.dart';

class ScheduleId {
  final String value;

  const ScheduleId(this.value);
}

class Schedule {
  final ScheduleId id;
  final String title;
  final Goal goal;
  final RepeatInfo repeatInfo;
  final DateTime startDate;
  final DateTime? dueDate;
  final DateTime? finishDate;

  Schedule(this.id, this.title, this.goal, this.repeatInfo, this.startDate, {this.dueDate, this.finishDate});

  bool isFinished() {
    return finishDate != null;
  }
}

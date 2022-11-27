import 'package:dongbaek/models/goal.dart';
import 'package:dongbaek/models/schedule.dart';

class Progress {
  final ScheduleId scheduleId;
  final DateTime startDate;
  final DateTime endDate;
  final ProgressStatus progressStatus;

  Progress(this.scheduleId, this.startDate, this.endDate, this.progressStatus);

  static Progress getDefaultProgress(Schedule schedule) {
    final goal = schedule.goal;
    if (goal is QuantityGoal) {
      return Progress(schedule.id, schedule.startDate, schedule.startDate.add(Duration(days: 7)), QuantityProgress());
    }
    if (goal is DurationGoal) {
      return Progress(schedule.id, schedule.startDate, schedule.startDate.add(Duration(days: 7)), DurationProgress());
    }
    throw UnimplementedError("INVALID_GOAL_TYPE_WHILE_GET_DEFAULT_PROGRESS ${schedule.goal}");
  }
}

abstract class ProgressStatus {
  const ProgressStatus();
}

class UnknownProgressStatus extends ProgressStatus {
  const UnknownProgressStatus();
}

class QuantityProgress extends ProgressStatus {
  final int quantity;

  QuantityProgress({this.quantity = 0});
}

class DurationProgress extends ProgressStatus {
  final Duration duration;

  DurationProgress({this.duration = const Duration()});
}

import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/models/schedule.dart';

class Snapshot {
  final Schedule schedule;
  final Progress progress;

  Snapshot(this.schedule, this.progress);

  bool isComplete() {
    switch (schedule.repeatInfo.repeatType) {
      case RepeatType.repeatPerDay:
        return (schedule.repeatInfo as RepeatPerDay).repeatCount <= progress.completeTimes.length;
      case RepeatType.repeatPerWeek:
        return (schedule.repeatInfo as RepeatPerWeek).repeatCount <= progress.completeTimes.length;
    }
  }
}

import 'package:dongbaek/models/goal.dart';
import 'package:dongbaek/models/repeat_info.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule.freezed.dart';

@freezed
class ScheduleId with _$ScheduleId {
  const factory ScheduleId(
    String value,
  ) = _ScheduleId;
}

@freezed
class Schedule with _$Schedule {
  const Schedule._();

  const factory Schedule(ScheduleId id, String title, Goal goal, RepeatInfo repeatInfo, DateTime startDate,
      {DateTime? dueDate, DateTime? finishDate}) = _Schedule;

  bool isFinished() {
    return finishDate != null;
  }
}

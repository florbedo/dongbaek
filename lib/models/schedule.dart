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

  const factory Schedule(
    ScheduleId id,
    String title,
    Goal goal,
    RepeatInfo repeatInfo,
    DateTime startDateTime, {
    DateTime? dueDateTime,
    DateTime? finishDateTime,
  }) = _Schedule;

  bool isFinished() {
    return finishDateTime != null;
  }
}

@freezed
class ScheduleData with _$ScheduleData {
  const ScheduleData._();

  const factory ScheduleData(String title, Goal goal, RepeatInfo repeatInfo, DateTime startDateTime,
      {DateTime? dueDateTime, DateTime? finishDateTime}) = _ScheduleData;

  Schedule toSchedule(ScheduleId id) {
    return Schedule(id, title, goal, repeatInfo, startDateTime);
  }
}

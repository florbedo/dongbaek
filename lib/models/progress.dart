import 'dart:developer' as dev;

import 'package:dongbaek/models/goal.dart';
import 'package:dongbaek/models/schedule.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'progress.freezed.dart';

@freezed
class ProgressId with _$ProgressId {
  const factory ProgressId(String value) = _ProgressId;
}

sealed class Progress {
  late final ScheduleId scheduleId;
  late final DateTime startDateTime;
  late final DateTime? endDateTime;

  ProgressId getId() {
    return ProgressId("${scheduleId.value}_${startDateTime.toUtc().toString()}");
  }

  bool isCompleted(Schedule schedule);
}

@freezed
class QuantityProgress extends Progress with _$QuantityProgress {
  QuantityProgress._();

  factory QuantityProgress(ScheduleId scheduleId, DateTime startDateTime, DateTime? endDateTime,
      {@Default(0) int quantity}) = _QuantityProgress;

  @override
  bool isCompleted(Schedule schedule) {
    switch (schedule.goal) {
      case QuantityGoal goal:
        return goal.quantity <= quantity;
      default:
        throw UnimplementedError();
    }
  }

  QuantityProgress diff(int diff) {
    return QuantityProgress(scheduleId, startDateTime, endDateTime, quantity: quantity + diff);
  }
}

@freezed
class DurationProgress extends Progress with _$DurationProgress {
  DurationProgress._();

  factory DurationProgress(ScheduleId scheduleId, DateTime startDateTime, DateTime? endDateTime,
      {@Default(Duration()) Duration duration, DateTime? ongoingStartTime}) = _DurationProgress;

  @override
  bool isCompleted(Schedule schedule) {
    switch (schedule.goal) {
      case DurationGoal goal:
        return goal.duration.compareTo(duration) <= 0;
      default:
        throw UnimplementedError();
    }
  }

  bool get isOngoing {
    return ongoingStartTime != null;
  }

  DurationProgress started(DateTime startTime) {
    if (isOngoing) {
      dev.log("Invalid started() for ongoing Progress $scheduleId $startDateTime $ongoingStartTime");
      return this;
    }
    return DurationProgress(scheduleId, startDateTime, endDateTime, duration: duration, ongoingStartTime: startTime);
  }

  DurationProgress stopped(DateTime endTime) {
    if (!isOngoing) {
      dev.log("Invalid stopped() for not started Progress $scheduleId $startDateTime $ongoingStartTime");
      return this;
    }
    final diff = endTime.difference(ongoingStartTime!);
    return DurationProgress(scheduleId, startDateTime, endDateTime, duration: duration + diff);
  }
}

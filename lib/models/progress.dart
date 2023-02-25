import 'dart:developer' as dev;

import 'package:dongbaek/models/schedule.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'progress.freezed.dart';

@freezed
class ProgressId with _$ProgressId {
  const factory ProgressId(String value) = _ProgressId;
}

mixin Progress {
  late final ProgressId id;
  late final ScheduleId scheduleId;
  late final DateTime startDate;
  late final DateTime? endDate;
}

@freezed
class QuantityProgress with Progress, _$QuantityProgress {
  QuantityProgress._();

  factory QuantityProgress(ProgressId id, ScheduleId scheduleId, DateTime startDate, DateTime? endDate,
      {@Default(0) int quantity}) = _QuantityProgress;

  QuantityProgress diff(int diff) {
    return QuantityProgress(id, scheduleId, startDate, endDate, quantity: quantity + diff);
  }
}

@freezed
class DurationProgress with Progress, _$DurationProgress {
  DurationProgress._();

  factory DurationProgress(ProgressId id, ScheduleId scheduleId, DateTime startDate, DateTime? endDate,
      {@Default(Duration()) Duration duration, DateTime? ongoingStartTime}) = _DurationProgress;

  bool get isOngoing {
    return ongoingStartTime != null;
  }

  DurationProgress started(DateTime startTime) {
    if (isOngoing) {
      dev.log("Invalid started() for ongoing Progress $id $ongoingStartTime");
      return this;
    }
    return DurationProgress(id, scheduleId, startDate, endDate, duration: duration, ongoingStartTime: startTime);
  }

  DurationProgress stopped(DateTime endTime) {
    if (!isOngoing) {
      dev.log("Invalid stopped() for not started Progress $id $ongoingStartTime");
      return this;
    }
    final diff = endTime.difference(ongoingStartTime!);
    return DurationProgress(id, scheduleId, startDate, endDate, duration: duration + diff);
  }
}

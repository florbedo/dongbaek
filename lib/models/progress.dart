import 'dart:developer' as dev;

import 'package:dongbaek/models/schedule.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'progress.freezed.dart';

@freezed
class ProgressId with _$ProgressId {
  const factory ProgressId(String value) = _ProgressId;
}

mixin Progress implements ProgressData {
  late final ProgressId id;
}

mixin ProgressData {
  late final ScheduleId scheduleId;
  late final DateTime startDate;
  late final DateTime? endDate;

  Progress toProgress(ProgressId id);
}

@freezed
class QuantityProgress with Progress, ProgressData, _$QuantityProgress {
  QuantityProgress._();

  factory QuantityProgress(ProgressId id, ScheduleId scheduleId, DateTime startDate, DateTime? endDate,
      {@Default(0) int quantity}) = _QuantityProgress;

  QuantityProgress diff(int diff) {
    return QuantityProgress(id, scheduleId, startDate, endDate, quantity: quantity + diff);
  }

  @override
  QuantityProgress toProgress(ProgressId id) {
    // May not be used
    return this;
  }
}

@freezed
class DurationProgress with Progress, ProgressData, _$DurationProgress {
  DurationProgress._();

  factory DurationProgress(ProgressId id, ScheduleId scheduleId, DateTime startDate, DateTime? endDate,
      {@Default(Duration()) Duration duration, DateTime? ongoingStartTime}) = _DurationProgress;

  @override
  DurationProgress toProgress(ProgressId id) {
    // May not be used
    return this;
  }

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

@freezed
class QuantityProgressData with ProgressData, _$QuantityProgressData {
  QuantityProgressData._();

  factory QuantityProgressData(ScheduleId scheduleId, DateTime startDate, DateTime? endDate,
      {@Default(0) int quantity}) = _QuantityProgressData;

  @override
  QuantityProgress toProgress(ProgressId id) {
    return QuantityProgress(id, scheduleId, startDate, endDate, quantity: quantity);
  }
}

@freezed
class DurationProgressData with ProgressData, _$DurationProgressData {
  DurationProgressData._();

  factory DurationProgressData(ScheduleId scheduleId, DateTime startDate, DateTime? endDate,
      {@Default(Duration()) Duration duration, DateTime? ongoingStartTime}) = _DurationProgressData;

  @override
  DurationProgress toProgress(ProgressId id) {
    return DurationProgress(id, scheduleId, startDate, endDate);
  }
}

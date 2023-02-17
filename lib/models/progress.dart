import 'dart:developer' as dev;

import 'package:dongbaek/models/schedule.dart';

class ProgressId {
  final String value;

  const ProgressId(this.value);
}

abstract class Progress {
  final ProgressId id;
  final ScheduleId scheduleId;
  final DateTime startDate;
  final DateTime? endDate;

  Progress(this.id, this.scheduleId, this.startDate, this.endDate);
}

class QuantityProgress extends Progress {
  final int quantity;

  QuantityProgress(ProgressId id, ScheduleId scheduleId, DateTime startDate, DateTime? endDate, {this.quantity = 0})
      : super(id, scheduleId, startDate, endDate);

  QuantityProgress diff(int diff) {
    return QuantityProgress(id, scheduleId, startDate, endDate, quantity: quantity + diff);
  }
}

class DurationProgress extends Progress {
  final Duration duration;
  final DateTime? ongoingStartTime;

  bool get isOngoing {
    return ongoingStartTime != null;
  }

  DurationProgress(ProgressId id, ScheduleId scheduleId, DateTime startDate, DateTime? endDate,
      {this.duration = const Duration(), this.ongoingStartTime})
      : super(id, scheduleId, startDate, endDate);

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

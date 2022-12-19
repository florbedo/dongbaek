import 'dart:developer' as dev;

import 'package:dongbaek/models/schedule.dart';

class ProgressId {
  final String value;

  const ProgressId(this.value);
}

class Progress {
  final ProgressId id;
  final ScheduleId scheduleId;
  final DateTime startDate;
  final DateTime? endDate;
  final ProgressStatus progressStatus;

  Progress(this.id, this.scheduleId, this.startDate, this.endDate, this.progressStatus);

  Progress diffQuantityProgress(int diff) {
    if (progressStatus is! QuantityProgress) {
      dev.log("Invalid diffQuantityProgress() for DurationProgress");
      return this;
    }
    final newProgressStatus = QuantityProgress(quantity: (progressStatus as QuantityProgress).quantity + diff);
    return Progress(id, scheduleId, startDate, endDate, newProgressStatus);
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

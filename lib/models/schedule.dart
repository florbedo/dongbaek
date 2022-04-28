import 'package:dongbaek/utils/datetime_utils.dart';

class Schedule {
  final int? id;
  final String title;
  final RepeatInfo repeatInfo;
  final DateTime startDate;

  Schedule(this.id, this.title, this.repeatInfo, this.startDate);
}

abstract class RepeatInfo {
  DateTime get startDate;

  bool get ended;

  static List<Type> getTypes() {
    return [Once, OnceByInterval, QuantityByPeriod, DurationByPeriod];
  }
}

class Once extends RepeatInfo {
  @override
  final DateTime startDate;
  @override
  final bool ended;

  Once(this.startDate, {this.ended = false});

  Once.withBase(Once base, {DateTime? startDate, bool? ended})
      : this(startDate ?? base.startDate, ended: ended ?? base.ended);
}

class OnceByInterval extends RepeatInfo {
  @override
  final DateTime startDate;
  @override
  final bool ended;

  final int intervalDays;

  OnceByInterval(this.startDate, this.intervalDays, {this.ended = false});

  OnceByInterval.withBase(OnceByInterval base, {DateTime? startDate, int? intervalDays, bool? ended})
      : this(startDate ?? base.startDate, intervalDays ?? base.intervalDays, ended: ended ?? base.ended);
}

class QuantityByPeriod extends RepeatInfo {
  @override
  final DateTime startDate;
  @override
  final bool ended;

  final int periodDays;
  final int quantity;

  QuantityByPeriod(this.startDate, this.periodDays, this.quantity, {this.ended = false});

  QuantityByPeriod.withBase(QuantityByPeriod base, {DateTime? startDate, int? periodDays, int? quantity, bool? ended})
      : this(startDate ?? base.startDate, periodDays ?? base.periodDays, quantity ?? base.quantity,
            ended: ended ?? base.ended);
}

class DurationByPeriod extends RepeatInfo {
  @override
  final DateTime startDate;
  @override
  final bool ended;

  final int periodDays;
  final Duration duration;

  DurationByPeriod(this.startDate, this.periodDays, this.duration, {this.ended = false});

  DurationByPeriod.withBase(DurationByPeriod base,
      {DateTime? startDate, int? periodDays, Duration? duration, bool? ended})
      : this(startDate ?? base.startDate, periodDays ?? base.periodDays, duration ?? base.duration,
            ended: ended ?? base.ended);
}

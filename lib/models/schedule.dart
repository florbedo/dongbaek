import 'package:dongbaek/utils/datetime_utils.dart';

class Schedule {
  final int? id;
  final String title;
  final RepeatInfo repeatInfo;
  final DateTime startDate;

  Schedule(this.id, this.title, this.repeatInfo, this.startDate);
}

abstract class RepeatInfo {
  RepeatType get repeatType;
}

enum RepeatType {
  repeatPerDay,
  repeatPerWeek,
}

class RepeatPerDay extends RepeatInfo {
  final int repeatCount;
  final List<DayOfWeek> daysOfWeek;

  RepeatPerDay(this.repeatCount, this.daysOfWeek);

  @override
  get repeatType => RepeatType.repeatPerDay;
}

class RepeatPerWeek extends RepeatInfo {
  final int repeatCount;

  RepeatPerWeek(this.repeatCount);

  @override
  get repeatType => RepeatType.repeatPerWeek;
}

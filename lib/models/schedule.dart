import 'package:dongbaek/utils/datetime_utils.dart';

class Schedule {
  final int? id;
  final String title;
  final RepeatInfo repeatInfo;
  final DateTime startDate;

  Schedule(this.id, this.title, this.repeatInfo, this.startDate);
}

abstract class RepeatInfo {
  get type;
}

class RepeatPerDay extends RepeatInfo {
  static const repeatType = "RepeatPerDay";

  final int repeatCount;
  final List<DayOfWeek> daysOfWeek;

  RepeatPerDay(this.repeatCount, this.daysOfWeek);

  @override
  get type => repeatType;
}

class RepeatPerWeek extends RepeatInfo {
  static const repeatType = "RepeatPerWeek";

  final int repeatCount;

  RepeatPerWeek(this.repeatCount);

  @override
  get type => repeatType;
}

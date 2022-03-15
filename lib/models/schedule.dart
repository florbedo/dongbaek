import 'package:dongbaek/utils/datetime_utils.dart';

class Schedule {
  final int id;
  final String title;
  final RepeatInfo repeatInfo;

  Schedule(this.id, this.title, this.repeatInfo);
}

abstract class RepeatInfo {}

class RepeatPerDay extends RepeatInfo {
  final int repeatCount;
  final List<DayOfWeek> daysOfWeek;

  RepeatPerDay(this.repeatCount, this.daysOfWeek);
}

class RepeatPerWeek extends RepeatInfo {
  final int repeatCount;

  RepeatPerWeek(this.repeatCount);
}

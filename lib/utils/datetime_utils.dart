class DateTimeUtils {
  static const int _msEpochDayDivisor = 24 * 3600 * 1000;

  static int asEpochDay(DateTime dateTime) {
    return (dateTime.millisecondsSinceEpoch + dateTime.timeZoneOffset.inMilliseconds) ~/ _msEpochDayDivisor;
  }

  static DateTime truncateToDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static DayOfWeek getDayOfWeek(DateTime dateTime) {
    switch (dateTime.weekday) {
      case DateTime.sunday:
        return DayOfWeek.sunday;
      case DateTime.monday:
        return DayOfWeek.monday;
      case DateTime.tuesday:
        return DayOfWeek.tuesday;
      case DateTime.wednesday:
        return DayOfWeek.wednesday;
      case DateTime.thursday:
        return DayOfWeek.thursday;
      case DateTime.friday:
        return DayOfWeek.friday;
      case DateTime.saturday:
        return DayOfWeek.saturday;
      default:
        // Never reaches here
        throw Exception("Invalid dateTime");
    }
  }

  static DayOfWeek dayOfWeekFromName(String name) {
    return DayOfWeek.values.firstWhere((element) => element.name == name);
  }
}

enum DayOfWeek {
  sunday,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
}

extension DayOfWeekExtension on DayOfWeek {
  String get shortName {
    switch (this) {
      case DayOfWeek.sunday:
        return "일";
      case DayOfWeek.monday:
        return "월";
      case DayOfWeek.tuesday:
        return "화";
      case DayOfWeek.wednesday:
        return "수";
      case DayOfWeek.thursday:
        return "목";
      case DayOfWeek.friday:
        return "금";
      case DayOfWeek.saturday:
        return "토";
    }
  }
}

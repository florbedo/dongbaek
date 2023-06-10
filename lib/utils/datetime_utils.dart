class DateTimeUtils {
  static int asEpochDay(DateTime dateTime) {
    return (dateTime.millisecondsSinceEpoch - dateTime.timeZoneOffset.inMilliseconds) ~/ Duration.millisecondsPerDay;
  }

  static DateTime fromEpochDay(int epochDay) {
    return DateTime.fromMillisecondsSinceEpoch(epochDay * Duration.millisecondsPerDay);
  }

  static bool isEqualDate(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }
    return asEpochDay(a) == asEpochDay(b);
  }

  static DateTime currentDay() {
    return truncateToDay(DateTime.now());
  }

  static DateTime truncateToDay(DateTime dateTime) {
    final localDateTime = dateTime.toLocal();
    return DateTime(localDateTime.year, localDateTime.month, localDateTime.day);
  }

  static String formatDate(DateTime dateTime) {
    final localDateTime = dateTime.toLocal();
    return "${localDateTime.year}. ${localDateTime.month}. ${localDateTime.day}.";
  }

  static DayOfWeek getDayOfWeek(DateTime dateTime) {
    switch (dateTime.toLocal().weekday) {
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

class DateTimeUtils {
  static const int _msEpochDayDivisor = 24 * 3600 * 1000;

  static int asEpochDay(DateTime dateTime) {
    return (dateTime.millisecondsSinceEpoch + dateTime.timeZoneOffset.inMilliseconds) ~/ _msEpochDayDivisor;
  }

  static DateTime truncateToDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
}

extension DurationExtension on Duration {
  String get text {
    String daysDesc = "";
    if (inDays > 0) {
      daysDesc = "${inDays}일";
    }
    String hoursDesc = "";
    if (inHours % 24 > 0) {
      hoursDesc = "${inHours % 24}시간";
    }
    String minutesDesc = "";
    if (inMinutes % 60 > 0) {
      minutesDesc = "${inMinutes % 60}분";
    }
    String secondsDesc = "";
    if ((daysDesc.isEmpty && hoursDesc.isEmpty && minutesDesc.isEmpty) || inSeconds % 60 > 0) {
      secondsDesc = "${inSeconds % 60}초";
    }
    return [daysDesc, hoursDesc, minutesDesc, secondsDesc].where((s) => s.isNotEmpty).join(" ");
  }
}

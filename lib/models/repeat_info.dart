abstract class RepeatInfo {
  const RepeatInfo();
}

class UnknownRepeat extends RepeatInfo {
  const UnknownRepeat();
}

class Unrepeated extends RepeatInfo {
  const Unrepeated();
}

class PeriodicRepeat extends RepeatInfo {
  final int periodDays;
  final int offsetDays;

  PeriodicRepeat(this.periodDays, this.offsetDays);
}

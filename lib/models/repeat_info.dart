import 'package:freezed_annotation/freezed_annotation.dart';

part 'repeat_info.freezed.dart';

abstract class RepeatInfo {
  const RepeatInfo();
}

@freezed
class UnknownRepeat extends RepeatInfo with _$UnknownRepeat {
  const factory UnknownRepeat() = _UnknownRepeat;
}

@freezed
class Unrepeated extends RepeatInfo with _$Unrepeated {
  const factory Unrepeated() = _Unrepeated;
}

@freezed
class PeriodicRepeat extends RepeatInfo with _$PeriodicRepeat {
  const factory PeriodicRepeat(int periodDays, int offsetDays) = _PeriodicRepeat;
}

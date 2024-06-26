import 'package:freezed_annotation/freezed_annotation.dart';

part 'repeat_info.freezed.dart';

sealed class RepeatInfo {
  const RepeatInfo();
}

@freezed
class UnknownRepeat extends RepeatInfo with _$UnknownRepeat {
  const factory UnknownRepeat() = _UnknownRepeat;
}

@freezed
class PeriodicRepeat extends RepeatInfo with _$PeriodicRepeat {
  const factory PeriodicRepeat(Duration periodDuration, Duration offsetDuration) = _PeriodicRepeat;
}

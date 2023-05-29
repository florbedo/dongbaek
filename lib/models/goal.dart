import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal.freezed.dart';

sealed class Goal {
  const Goal();
}

class UnknownGoal extends Goal {
  const UnknownGoal();
}

@freezed
class QuantityGoal extends Goal with _$QuantityGoal {
  const factory QuantityGoal(int quantity) = _QuantityGoal;
}

@freezed
class DurationGoal extends Goal with _$DurationGoal {
  const factory DurationGoal(Duration duration) = _DurationGoal;
}

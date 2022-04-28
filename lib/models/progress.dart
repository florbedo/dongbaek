import 'package:dongbaek/models/schedule.dart';

abstract class Progress {
  static Progress getDefault(RepeatInfo repeatInfo) {
    if (repeatInfo is Once || repeatInfo is OnceByInterval) {
      return OnceProgress(false);
    }
    if (repeatInfo is QuantityByPeriod) {
      return QuantityProgress(0);
    }
    if (repeatInfo is DurationByPeriod) {
      return DurationProgress(const Duration());
    }
    throw UnimplementedError("INVALID_REPEAT_INFO_TYPE");
  }
}

class OnceProgress extends Progress {
  final bool complete;

  OnceProgress(this.complete);
}

class QuantityProgress extends Progress {
  final int quantity;

  QuantityProgress(this.quantity);
}

class DurationProgress extends Progress {
  final Duration duration;

  DurationProgress(this.duration);
}

import 'package:dongbaek/models/goal.dart';
import 'package:dongbaek/models/progress.dart';

class ProgressService {
  static isDoneProgress(Goal goal, Progress progress) {
    switch (progress) {
      case QuantityProgress p:
        switch (goal) {
          case QuantityGoal goal:
            return goal.quantity <= p.quantity;
          default:
            throw UnimplementedError();
        }
      case DurationProgress p:
        switch (goal) {
          case DurationGoal goal:
            return goal.duration.compareTo(p.duration) <= 0;
          default:
            throw UnimplementedError();
        }
    }
  }
}

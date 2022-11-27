abstract class Goal {
  const Goal();
}

class UnknownGoal extends Goal {
  const UnknownGoal();
}

class QuantityGoal extends Goal {
  final int quantity;

  QuantityGoal(this.quantity);
}

class DurationGoal extends Goal {
  final Duration duration;

  DurationGoal(this.duration);
}

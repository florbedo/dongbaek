class Schedule {
  final int id;
  final String title;
  final CycleUnitType cycleUnitType;

  Schedule(this.id, this.title, this.cycleUnitType);
}

enum CycleUnitType {
  daily,
  weekly,
}

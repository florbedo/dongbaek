import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/models/schedule.dart';

class Snapshot {
  final Schedule schedule;
  final Progress progress;

  Snapshot(this.schedule, this.progress);
}

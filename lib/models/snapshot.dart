import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/models/schedule.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'snapshot.freezed.dart';

@freezed
class Snapshot with _$Snapshot {
  const factory Snapshot(Schedule schedule, Progress progress) = _Snapshot;
}

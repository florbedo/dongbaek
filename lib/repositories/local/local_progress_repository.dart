import 'package:collection/collection.dart';
import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/proto/messages.pb.dart';
import 'package:dongbaek/repositories/local/local_database.dart';
import 'package:dongbaek/repositories/progress_repository.dart';
import 'package:dongbaek/utils/protobuf_utils.dart';
import 'package:drift/drift.dart';

class LocalProgressRepository implements ProgressRepository {
  final LocalDatabase _localDatabase = LocalDatabase();

  @override
  Future<Progress?> findProgress(ScheduleId scheduleId, DateTime dateTime) async {
    final progressCont = await _localDatabase.findProgressContainer(scheduleId, dateTime);
    return progressCont == null ? null : PbProgress.fromJson(progressCont.progressProtoJson).getProgress();
  }

  @override
  Future<Map<ScheduleId, Progress>> getProgresses(Iterable<ScheduleId> scheduleIds, DateTime dateTime) async {
    final entryFutures = scheduleIds.map((scheduleId) async {
      final progress = await findProgress(scheduleId, dateTime);
      return progress == null ? null : MapEntry(scheduleId, progress);
    });
    final entries = (await Stream.fromFutures(entryFutures).toList()).whereNotNull();
    return Map.fromEntries(entries);
  }

  @override
  Future<void> updateProgress(ScheduleId scheduleId, ProgressStatus progressStatus, DateTime startDate,
      {DateTime? endDate}) async {
    final quantityProgress = PbProgressExt.asQuantityProgress(progressStatus);
    final durationProgress = PbProgressExt.asDurationProgress(progressStatus);
    final startTimestamp = ProtobufUtils.asPbTimestamp(startDate);
    final endTimestamp = (endDate != null) ? ProtobufUtils.asPbTimestamp(endDate) : null;
    final progressData = PbProgress(
        scheduleId: scheduleId.value,
        startDate: startTimestamp,
        endDate: endTimestamp,
        quantityProgress: quantityProgress,
        durationProgress: durationProgress);
    final inserting = ProgressContainerCompanion.insert(
        scheduleId: scheduleId.value,
        startDate: startDate,
        endDate: Value(endDate),
        progressProtoJson: progressData.writeToJson());
    _localDatabase.insertProgressContainer(inserting);
  }
}

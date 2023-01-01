import 'dart:developer' as dev;

import 'package:collection/collection.dart';
import 'package:dongbaek/models/goal.dart';
import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/models/repeat_info.dart';
import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/proto/messages.pb.dart';
import 'package:dongbaek/repositories/local/local_database.dart';
import 'package:dongbaek/repositories/local/local_schedule_repository.dart';
import 'package:dongbaek/repositories/progress_repository.dart';
import 'package:dongbaek/repositories/schedule_repository.dart';
import 'package:dongbaek/utils/datetime_utils.dart';
import 'package:dongbaek/utils/protobuf_utils.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class LocalProgressRepository implements ProgressRepository {
  final uuid = const Uuid();
  final LocalDatabase _localDatabase = LocalDatabase();
  final ScheduleRepository _scheduleRepository = LocalScheduleRepository();

  @override
  Future<ProgressId> nextProgressId() async {
    return ProgressId(uuid.v1());
  }

  @override
  Future<Progress> findProgress(ProgressId progressId) async {
    final progressCont = await _localDatabase.findProgress(progressId);
    return PbProgress.fromJson(progressCont.progressProtoJson).getProgress();
  }

  @override
  Future<Progress> findProgressBySchedule(ScheduleId scheduleId, DateTime dateTime) async {
    final schedule = await _scheduleRepository.findSchedule(scheduleId);
    final progressCont = await _localDatabase.findProgressContainerBySchedule(scheduleId, dateTime);
    if (progressCont == null) {
      final progress = await _getDefaultProgress(schedule, dateTime);
      await replaceProgress(progress);
      return progress;
    }
    return PbProgress.fromJson(progressCont.progressProtoJson).getProgress();
  }

  @override
  Future<Map<ScheduleId, Progress>> getProgresses(Iterable<ScheduleId> scheduleIds, DateTime dateTime) async {
    final entryFutures = scheduleIds.map((scheduleId) async {
      final progress = await findProgressBySchedule(scheduleId, dateTime);
      dev.log("progressId: ${progress.id.value}");
      return MapEntry(scheduleId, progress);
    });
    final entries = (await Stream.fromFutures(entryFutures).toList()).whereNotNull();
    return Map.fromEntries(entries);
  }

  @override
  Future<void> replaceProgress(Progress progress) async {
    final pbQuantityProgress = PbProgressExt.asPbQuantityProgress(progress.progressStatus);
    final pbDurationProgress = PbProgressExt.asPbDurationProgress(progress.progressStatus);
    final startTimestamp = ProtobufUtils.asPbTimestamp(progress.startDate);
    final endTimestamp = (progress.endDate != null) ? ProtobufUtils.asPbTimestamp(progress.endDate!) : null;
    final progressData = PbProgress(
        id: progress.id.value,
        scheduleId: progress.scheduleId.value,
        startDate: startTimestamp,
        endDate: endTimestamp,
        quantityProgress: pbQuantityProgress,
        durationProgress: pbDurationProgress);
    final inserting = ProgressContainerCompanion.insert(
        id: progress.id.value,
        scheduleId: progress.scheduleId.value,
        startDate: progress.startDate,
        endDate: progress.endDate == null ? const Value.absent() : Value.ofNullable(progress.endDate),
        progressProtoJson: progressData.writeToJson());
    _localDatabase.replaceProgressContainer(inserting);
  }

  Future<Progress> _getDefaultProgress(Schedule schedule, DateTime dateTime) async {
    final progressId = await nextProgressId();
    final repeatInfo = schedule.repeatInfo;
    final progress = schedule.goal is QuantityGoal ? QuantityProgress() : DurationProgress();
    if (repeatInfo is Unrepeated) {
      return Progress(progressId, schedule.id, schedule.startDate, null, progress);
    }
    if (repeatInfo is PeriodicRepeat) {
      final epochDay = DateTimeUtils.asEpochDay(dateTime);
      final startDate = DateTimeUtils.fromEpochDay(epochDay - repeatInfo.offsetDays);
      final endDate = DateTimeUtils.fromEpochDay(epochDay + repeatInfo.periodDays - repeatInfo.offsetDays);
      return Progress(progressId, schedule.id, startDate, endDate, progress);
    }
    throw UnimplementedError("INVALID_REPEAT_INFO_WHILE_GET_DEFAULT_PROGRESS ${schedule.goal}");
  }
}

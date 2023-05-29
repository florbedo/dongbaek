import 'package:collection/collection.dart';
import 'package:dongbaek/models/goal.dart';
import 'package:dongbaek/models/progress.dart';
import 'package:dongbaek/models/repeat_info.dart';
import 'package:dongbaek/models/schedule.dart';
import 'package:dongbaek/proto/models.pb.dart';
import 'package:dongbaek/repositories/local/local_database.dart';
import 'package:dongbaek/repositories/local/local_schedule_repository.dart';
import 'package:dongbaek/repositories/progress_repository.dart';
import 'package:dongbaek/repositories/schedule_repository.dart';
import 'package:dongbaek/utils/datetime_utils.dart';
import 'package:dongbaek/utils/pb_utils.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class LocalProgressRepository implements ProgressRepository {
  final uuid = const Uuid();
  final LocalDatabase _localDatabase = LocalDatabase();
  final ScheduleRepository _scheduleRepository = LocalScheduleRepository();

  @override
  Future<Map<ScheduleId, Progress>> getProgresses(Iterable<ScheduleId> scheduleIds, DateTime dateTime) async {
    final entryFutures = scheduleIds.map((scheduleId) async {
      final progress = await _getProgressOrDefault(scheduleId, dateTime);
      return MapEntry(scheduleId, progress);
    });
    final entries = (await Stream.fromFutures(entryFutures).toList()).whereNotNull();
    return Map.fromEntries(entries);
  }

  @override
  Future<void> replaceProgress(Progress progress) async {
    final pbQuantityProgress = progress.getPbQuantityProgress();
    final pbDurationProgress = progress.getPbDurationProgress();
    final startTimestamp = progress.startDateTime.toPbTimestamp();
    final endTimestamp = progress.endDateTime?.toPbTimestamp();
    final pbProgress = PbProgress(
        scheduleId: progress.scheduleId.value,
        startTimestamp: startTimestamp,
        endTimestamp: endTimestamp,
        quantityProgress: pbQuantityProgress,
        durationProgress: pbDurationProgress);
    final inserting = ProgressContainerCompanion.insert(
        id: progress.getId().value,
        scheduleId: progress.scheduleId.value,
        startDate: progress.startDateTime,
        endDate: progress.endDateTime == null ? const Value.absent() : Value.ofNullable(progress.endDateTime),
        progressProtoJson: pbProgress.writeToJson());
    _localDatabase.replaceProgressContainer(inserting);
  }

  Future<Progress> _getProgressOrDefault(ScheduleId scheduleId, DateTime dateTime) async {
    final schedule = await _scheduleRepository.getSchedule(scheduleId);
    final progressCont = await _localDatabase.findProgressContainerBySchedule(scheduleId, dateTime);
    if (progressCont == null) {
      final progress = await _getDefaultProgress(schedule, dateTime);
      await replaceProgress(progress);
      return progress;
    }
    return PbProgress.fromJson(progressCont.progressProtoJson).toProgress();
  }

  Future<Progress> _getDefaultProgress(Schedule schedule, DateTime dateTime) async {
    final repeatInfo = schedule.repeatInfo;
    if (schedule.goal is QuantityGoal) {
      if (repeatInfo is Unrepeated) {
        return QuantityProgress(schedule.id, schedule.startDateTime, null);
      }
      if (repeatInfo is PeriodicRepeat) {
        final epochDay = DateTimeUtils.asEpochDay(dateTime);
        final startDate = DateTimeUtils.fromEpochDay(epochDay - repeatInfo.offsetDays);
        final endDate = DateTimeUtils.fromEpochDay(epochDay + repeatInfo.periodDays - repeatInfo.offsetDays);
        return QuantityProgress(schedule.id, startDate, endDate);
      }
    }
    if (schedule.goal is DurationGoal) {
      if (repeatInfo is Unrepeated) {
        return DurationProgress(schedule.id, schedule.startDateTime, null);
      }
      if (repeatInfo is PeriodicRepeat) {
        final epochDay = DateTimeUtils.asEpochDay(dateTime);
        final startDate = DateTimeUtils.fromEpochDay(epochDay - repeatInfo.offsetDays);
        final endDate = DateTimeUtils.fromEpochDay(epochDay + repeatInfo.periodDays - repeatInfo.offsetDays);
        return DurationProgress(schedule.id, startDate, endDate);
      }
    }
    throw UnimplementedError("INVALID_REPEAT_INFO_WHILE_GET_DEFAULT_PROGRESS ${schedule.goal}");
  }
}
